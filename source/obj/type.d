module sid.obj.type;

import sid.obj.core;
import sid.obj.inst;

import sid.mem.refcount;

struct DisTypeDesc {
    int desc_number;
    int size;
    int number_ptrs;

    RefCountedArray!ubyte map;

    this(F)(F f) {
        desc_number = f.read_op();
        size = f.read_op();
        number_ptrs = f.read_op();

        map = RefCountedArray!ubyte(number_ptrs);
        f.rawRead(map[]);
    }

    bool is_pointer(int offset) {
        int map_index = offset / 8;
        int shift = offset % 8;
        return ((map[map_index] >> shift) & 0x01);
    }
};
