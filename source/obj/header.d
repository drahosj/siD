module sid.obj.header;

import sid.obj.core;

const int MUSTCOMPILE = 1 << 0;
const int DONTCOMPILE = 1 << 1;
const int SHAREMP = 1 << 2;


struct DisHeader {
    const int MAX_SIG_LENGTH = 0;

    int magic_number;

    int sig_length;
    byte[MAX_SIG_LENGTH] signature;

    int runtime_flag;
    int stack_extent;
    int code_size;
    int data_size;
    int type_size;
    int link_size;
    int entry_pc;
    int entry_type;

    bool signed;

    bool must_compile_flag;
    bool dont_compile_flag;
    bool share_mp_flag;

    this(F)(F f) {
        magic_number = f.read_op();

        if (magic_number == SMAGIC) {
            sig_length = f.read_op();
            if (sig_length > MAX_SIG_LENGTH) {
                f.seek(f.tell() + sig_length);
            } else {
                f.rawRead(signature[0..sig_length]);
            }
            signed = true;
        }

        runtime_flag = f.read_op();

        if (runtime_flag && MUSTCOMPILE) {
            must_compile_flag = true;
        }
        if (runtime_flag && DONTCOMPILE) {
            dont_compile_flag = true;
        }
        if (runtime_flag && SHAREMP) {
            share_mp_flag = true;
        }

        stack_extent = f.read_op();
        code_size = f.read_op();
        data_size = f.read_op();
        type_size = f.read_op();
        link_size = f.read_op();
        entry_pc = f.read_op();
        entry_type = f.read_op();

    }
};
