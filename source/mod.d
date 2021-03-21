module sid.mod;

import sid.obj.header;
import sid.obj.core;
import sid.obj.inst;
import sid.obj.type;
import sid.mem.alloc;
import sid.mem.refcount;
import sid.mem.heap;
import sid.endian;

struct DisModule {

    RefCountedArray!DisInstruction code;
    RefCountedArray!DisTypeDesc type;
    RefCountedArray!HeapItem data_items;
    RefCountedArray!ubyte link;

    RefCountedArray!char name;

    DisHeader header;

    int mp_offset;
    int end_of_data;

    ubyte[] data_segment;

    this(F, H)(F f, H heap) {
        header = DisHeader(f);


        code = RefCountedArray!DisInstruction(header.code_size);
        type = RefCountedArray!DisTypeDesc(header.type_size);
        data_items = RefCountedArray!HeapItem(header.data_size);
        link = RefCountedArray!ubyte(header.link_size);

        foreach (i; 0..header.code_size) {
            code[i] = DisInstruction(f);
        }

        foreach (i; 0..header.type_size) {
            type[i] = DisTypeDesc(f);
        }

        mp_offset = heap.getSize();
        ulong data_start = f.tell();

        /* First pass - allocate space in data segment */
        foreach (i; 0..header.data_size) {
            HeapItem item = HeapItem(f);
            data_items[i] = item;
            f.seek(f.tell() + item.operand_size);
            heap.allocate(item.data_seg_size);
        }
        end_of_data = heap.getSize();
        data_segment = heap.mem.array[mp_offset..end_of_data];

        f.seek(data_start);

        /* 2nd pass - allocate heap space for indirect data items (strings and
         * arrays) and populate data values - direct values populated into data
         * segment, pointers to allocated indirect items stored into data
         * segment */
        foreach (item_iter; 0..header.data_size) {
            /* Still have to read and re-parse item to advance file pointer */
            HeapItem item = HeapItem(f);
            switch (item.type) {
                case ItemType.BYTE:
                    foreach (i; 0..item.count) {
                        byte[1] buf;
                        f.rawRead(buf[]);
                        data_segment[item.offset + i] = buf[0];
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
        }

        auto name_start = f.tell();
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
};
