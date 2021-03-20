module sid.mod;

import sid.obj.header;
import sid.obj.core;
import sid.obj.inst;
import sid.mem.alloc;
import sid.mem.refcount;

struct DisModule {

    RefCountedArray!DisInstruction code;
    RefCountedArray!ubyte type;
    RefCountedArray!ubyte data;
    RefCountedArray!ubyte link;

    RefCountedArray!char name;

    DisHeader header;

    this(F)(F f) {
        header = DisHeader(f);


        code = RefCountedArray!DisInstruction(header.code_size);
        type = RefCountedArray!ubyte(header.type_size);
        data = RefCountedArray!ubyte(header.data_size);
        link = RefCountedArray!ubyte(header.link_size);

        /* Paranoid maximum size is 2 + 4 + 8 + 8,
           even though 2x30bit double indirect is technically not allowed,
           same with 30bit op for middle */

        ubyte[22] inst_buffer;
        ulong buffered_bytes = 0;
        for (int i = 0; i < header.code_size; i++) {
            ulong bytes_read = f.rawRead(inst_buffer[buffered_bytes..$]).length;
            DisInstruction inst;
            ulong inst_length = inst.parseFrom(inst_buffer[]);

            code[i] = inst;

            /* Shift extra bytes to beginning of buffer */
            buffered_bytes = (buffered_bytes + bytes_read) - inst_length;
            for (ulong j = 0; j < buffered_bytes; j++) {
                inst_buffer[j] = inst_buffer[inst_length + j];
            }
        }

        /* Seek backwards any over-read */
        f.seek(f.tell() - buffered_bytes);

        /* These are wrong */
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
