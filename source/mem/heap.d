module sid.mem.heap;

import sid.mem.refcount;
import sid.obj.core;

enum ItemType {
    BYTE        = 0x01,
    WORD        = 0x02,
    STRING      = 0x03,
    REAL        = 0x04,
    ARRAY       = 0x05,
    SET_ARRAY_ADDRESS       = 0x06,
    RESTORE_LOAD_ADDRESS    = 0x07,
    BIG         = 0x08
};

struct HeapItem {
    int code;
    int count;
    int offset;

    int type;

    int data_seg_size;
    int heap_size;
    int operand_size;


    this(F)(F f) {
        ubyte[8] buf;   
        f.rawRead(buf[0..1]);

        code = buf[0];

        type = (code >> 4) & 0x0f;

        count = code & 0x0f;
        if (count == 0) {
            count = f.read_op();
        }

        offset = f.read_op();

        switch (type) {
            case ItemType.BYTE:
                data_seg_size = count;
                operand_size = count;
                break;
            case ItemType.WORD:
            case ItemType.REAL:
                data_seg_size = 4 * count;
                operand_size = 4 * count;
                break;
            case ItemType.BIG:
                data_seg_size = 8 * count;
                operand_size = 8 * count;
                break;
            case ItemType.STRING:
                data_seg_size = 4;
                operand_size = count;
                heap_size = count;
                break;
            case ItemType.SET_ARRAY_ADDRESS:
                operand_size = 8;
                break;
            case ItemType.ARRAY:
                operand_size = 8 * count;
                data_seg_size = 4 * count;
                /* Heap size not determinable without reading type desc */
                break;
            case ItemType.RESTORE_LOAD_ADDRESS:
            default:
                break;
        }
    }
};

struct BadHeap {
    RefCountedArray!ubyte mem;

    int size;

    this(int maxsize) {
        mem = RefCountedArray!ubyte(maxsize);
    }

    int allocate(int itemsize) {
        int ret = size;
        size += itemsize;
        return ret;
    }

    int place(ubyte[] item) {
        int ret = size;
        size += item.length;
        foreach (i, b; item) {
            mem[ret + i] = b;
        }
        return ret;
    }

    T * ptr(T)(int offset) {
        return cast(T *) mem.array[offset..(offset+1)].ptr;
    }

    int getSize() { return size; }

    ref ubyte opIndex(size_t i) { return mem[i]; }
    ubyte[] opIndex() { return mem[]; }
};
