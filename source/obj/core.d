module sid.obj.core;

import sid.obj.header;

import std.stdio;
import std.file;

const int XMAGIC = 819248;
const int SMAGIC = 923426;

int op_length(ubyte[] raw) {
    int enc = (raw[0] & 0xc0) >> 6;

    if (enc == 2) {
        return 2;
    } else if (enc == 3) {
        return 4; 
    } else {
        return 1;
    }
}

int parse_op(ubyte[] raw) {
    int enc = (raw[0] & 0xc0) >> 6;
    uint ret;

    if (enc == 2) {
        ret = ((raw[0] & 0x3f) << 8) | raw[1];

        if (ret & 0x20000000) {
            ret = ret | 0xc0000000;
        }
    } else if (enc == 3) {
        ret = ((raw[0] & 0x3f) << 24) | 
            (raw[1] << 16) | 
            (raw[2] << 8) |
            raw[3];

        if (ret & 0x2000) {
            ret = ret | 0xffffc000;
        }
    } else {
        ret = raw[0];
        if (ret & 0x40) {
            ret = ret | 0xffffff80;
        }
    }

    return cast(int) ret;
}

int read_op(File f) {
    ubyte[4] buf;
    auto opbuf = f.rawRead(buf[0..1]);

    if (op_length(buf) > 1) {
        f.rawRead(buf[1..op_length(opbuf)]);
    }

    return parse_op(buf);
};

struct ObjectFile {
    DisHeader header;

    this(string filename) {
        File f= File(filename, "r");

        header = DisHeader(f);
    }
};
