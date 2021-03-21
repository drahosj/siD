module sid.mod;

import sid.obj.header;
import sid.obj.core;
import sid.obj.inst;
import sid.obj.type;
import sid.mem.alloc;
import sid.mem.refcount;
import sid.mem.heap;
import sid.endian;

import sid.app;

struct DisModule(H) {

    RefCountedArray!DisInstruction code;
    RefCountedArray!DisTypeDesc type;
    RefCountedArray!ubyte link;

    RefCountedArray!char name;

    DisHeader header;

    int mp_offset;
    int end_of_data;

    ulong data_segment_file_start;


    H heap;

    this(F)(F f, H h) {
        header = DisHeader(f);

        heap = h;

        code = RefCountedArray!DisInstruction(header.code_size);
        type = RefCountedArray!DisTypeDesc(header.type_size);
        link = RefCountedArray!ubyte(header.link_size);

        foreach (i; 0..header.code_size) {
            code[i] = DisInstruction(f);
        }

        foreach (i; 0..header.type_size) {
            type[i] = DisTypeDesc(f);
        }

        data_segment_file_start = f.tell();
        mp_offset = heap.allocate(header.data_size);
        int data_filled;

        /* Heap size is declared. Single pass needed to populate data segment
         * and allocate heap storage */
        while (data_filled < header.data_size) {
            HeapItem item = HeapItem(f);
            switch (item.type) {
                case ItemType.BYTE:
                    foreach (i; 0..item.count) {
                        byte[1] buf;
                        f.rawRead(buf[]);
                        *heap_ptr!ubyte(item.offset + 1) = buf[0];
                    }
                    break;
                case ItemType.WORD:
                    foreach (i; 0..item.count) {
                        ubyte[4] buf;
                        f.rawRead(buf[]);
                        uint val = be_to_uint(buf[]);

                        *(heap.ptr!int(mp_offset + item.offset + (4*i))) = val;
                    }
                    break;
                case ItemType.BIG:
                    foreach (i; 0..item.count) {
                        ubyte[8] buf;
                        f.rawRead(buf[]);
                        ulong val = be_to_ulong(buf[]);

                        *(heap.ptr!ulong(mp_offset+item.offset+(8*i))) = val;
                    }
                    break;
                case ItemType.REAL:
                    foreach (i; 0..item.count) {
                        ubyte[4] buf;
                        f.rawRead(buf[]);
                        float val = *(cast(float *) buf.ptr);

                        *(heap.ptr!float(mp_offset+item.offset+(4*i))) = val;
                    }
                    break;
                case ItemType.STRING:
                    int heap_offset = heap.allocate(item.heap_size);
                    f.rawRead(heap.mem.array[heap_offset..(heap_offset +
                                item.heap_size)]);
                    *(heap.ptr!int(mp_offset + item.offset)) = heap_offset;
                    break;
                case ItemType.ARRAY:
                    /* Calculate actual size of the array and allocate */
                    ubyte[8] buf;
                    f.rawRead(buf);
                    uint typedesc = be_to_uint(buf[0..4]);
                    uint arraylen = be_to_uint(buf[0..4]);
                    uint typesize = type[typedesc].size;
                    item.heap_size = typesize * arraylen;
                    foreach (i; 0..item.count) {
                        int heap_offset = heap.allocate(typesize);
                        *(heap.ptr!int(mp_offset+item.offset+(4*i))) = 
                            heap_offset;
                    }
                    break;
                    /* Not implemented yet */
                case ItemType.SET_ARRAY_ADDRESS:
                case ItemType.RESTORE_LOAD_ADDRESS:
                default:
                    break;
            }
            data_filled += item.data_seg_size;

            ubyte[1] buf;
            f.rawRead(buf);
            if (buf[0] == 0) {
                break;
            } else {
                f.seek(f.tell() - 1);
            }
        }

        end_of_data = heap.getSize();

        ulong name_start = f.tell();
        ubyte[1] buf;
        ulong name_end;

        do {
            f.rawRead(buf);
            name_end = f.tell() + 1;
        } while (buf[0] != 0);
        f.seek(name_start);

        name = RefCountedArray!char(name_end - name_start);
        f.rawRead(name.array);

        f.rawRead(link.array);
    }

    T * heap_ptr(T)(int offset) {
        return heap.ptr!T(offset);
    }
};
