module sid.mod;

import sid.obj.header;
import sid.obj.core;
import sid.obj.inst;
import sid.obj.type;
import sid.mem.alloc;
import sid.mem.refcount;

struct DisModule {

    RefCountedArray!DisInstruction code;
    RefCountedArray!DisTypeDesc type;
    RefCountedArray!ubyte data;
    RefCountedArray!ubyte link;

    RefCountedArray!char name;

    DisHeader header;

    this(F)(F f) {
        header = DisHeader(f);


        code = RefCountedArray!DisInstruction(header.code_size);
        type = RefCountedArray!DisTypeDesc(header.type_size);
        data = RefCountedArray!ubyte(header.data_size);
        link = RefCountedArray!ubyte(header.link_size);

        foreach (i; 0..header.code_size) {
            code[i] = DisInstruction(f);
        }


        foreach (i; 0..header.type_size) {
            type[i] = DisTypeDesc(f);
        }

        /* These are wrong */
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
