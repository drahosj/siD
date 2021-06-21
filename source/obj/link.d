module sid.obj.link;

import sid.endian;

import sid.obj.core;

import sid.mem.refcount;

struct DisLinkEntry {
    int pc;
    int link_number;
    int sig;

    RefCountedArray!char name;

    this(F)(F f) {
        pc = f.read_op();
        link_number = f.read_op();

        ubyte[4] buf;
        f.rawRead(buf);

        sig = be_to_int(buf);

        ulong name_start = f.tell();
        ulong name_end;

        do {
            f.rawRead(buf[0..1]);
            name_end = f.tell();
        } while (buf[0] != 0);

        f.seek(name_start);
        name = RefCountedArray!char(name_end - name_start);
        f.rawRead(name.array);
    }
}
