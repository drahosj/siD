module sid.mod;

import sid.obj.header;
import sid.obj.core;
import sid.mem.alloc;
import sid.mem.refcount;

import std.stdio;

struct DisModule {

    RefCountedArray!ubyte code;
    RefCountedArray!ubyte type;
    RefCountedArray!ubyte data;
    RefCountedArray!ubyte link;

    RefCountedArray!char name;

    DisHeader header;

    this(F)(F f) {
        header = DisHeader(f);


        code = RefCountedArray!ubyte(header.code_size);
        type = RefCountedArray!ubyte(header.code_size);
        data = RefCountedArray!ubyte(header.code_size);
        link = RefCountedArray!ubyte(header.code_size);

        f.rawRead(code.array);
        f.rawRead(type.array);
        f.rawRead(data.array);

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
