module sid.obj.inst;

import sid.obj.core;

enum OpMode {
    NONE = 0,
    IMMEDIATE,
    INDIRECT_FP,
    INDIRECT_MP,
    DOUBLE_INDIRECT_FP,
    DOUBLE_INDIRECT_MP,
    RESERVED
};


struct DisInstruction {
    ubyte opcode;
    ubyte address_mode;

    OpMode middle_mode;
    OpMode source_mode;
    OpMode dest_mode;

    int middle_op;

    int source_op_1;
    int source_op_2;

    int dest_op_1;
    int dest_op_2;

    this(F)(F f) {
        ubyte[2] buf;
        f.rawRead(buf[]);

        opcode = buf[0];
        address_mode = buf[1];

        switch ((address_mode & 0xc0) >> 6) {
            case 0:
                middle_mode = OpMode.NONE;
                break;
            case 1:
                middle_mode = OpMode.IMMEDIATE;
                break;
            case 2:
                middle_mode = OpMode.INDIRECT_FP;
                break;
            case 3:
                middle_mode = OpMode.INDIRECT_MP;
                break;
            default:
                middle_mode = OpMode.RESERVED;
                break;
        }

        switch ((address_mode & 0x38) >> 3) {
            case 0:
                source_mode = OpMode.INDIRECT_MP;
                break;
            case 1:
                source_mode = OpMode.INDIRECT_FP;
                break;
            case 2:
                source_mode = OpMode.IMMEDIATE;
                break;
            case 3:
                source_mode = OpMode.NONE;
                break;
            case 4:
                source_mode = OpMode.DOUBLE_INDIRECT_MP;
                break;
            case 5:
                source_mode = OpMode.DOUBLE_INDIRECT_FP;
                break;
            default:
                source_mode = OpMode.RESERVED;
                break;
        }

        switch (address_mode & 0x7) {
            case 0:
                dest_mode = OpMode.INDIRECT_MP;
                break;
            case 1:
                dest_mode = OpMode.INDIRECT_FP;
                break;
            case 2:
                dest_mode = OpMode.IMMEDIATE;
                break;
            case 3:
                dest_mode = OpMode.NONE;
                break;
            case 4:
                dest_mode = OpMode.DOUBLE_INDIRECT_MP;
                break;
            case 5:
                dest_mode = OpMode.DOUBLE_INDIRECT_FP;
                break;
            default:
                dest_mode = OpMode.RESERVED;
                break;
        }

        if (middle_mode != OpMode.NONE) {
            middle_op = f.read_op();
        }

        if (source_mode != OpMode.NONE) {
            source_op_1 = f.read_op();
        }
        if ((source_mode == OpMode.DOUBLE_INDIRECT_MP) || 
                (source_mode == OpMode.DOUBLE_INDIRECT_FP)) {
            source_op_2 = f.read_op();
        }

        if (dest_mode != OpMode.NONE) {
            dest_op_1 = f.read_op();
        }
        if ((dest_mode == OpMode.DOUBLE_INDIRECT_MP) || 
                (dest_mode == OpMode.DOUBLE_INDIRECT_FP)) {
            dest_op_2 = f.read_op();
        }  
    };
};

string[] Mnemonics = [
 "nop",
 "alt",
 "nbalt",
 "goto",
 "call",
 "frame",
 "spawn",
 "runt",
 "load",
 "mcall",
 "mspawn",
 "mframe",
 "ret",
 "jmp",
 "case",
 "exit",
 "new",
 "newa",
 "newcb",
 "newcw",
 "newcf",
 "newcp",
 "newcm",
 "newcmp",
 "send",
 "recv",
 "consb",
 "consw",
 "consp",
 "consf",
 "consm",
 "consmp",
 "headb",
 "headw",
 "headp",
 "headf",
 "headm",
 "headmp",
 "tail",
 "lea",
 "indx",
 "movp",
 "movm",
 "movmp",
 "movb",
 "movw",
 "movf",
 "cvtbw",
 "cvtwb",
 "cvtfw",
 "cvtwf",
 "cvtca",
 "ctvac",
 "cvtwc",
 "cvtcw",
 "cvtfc",
 "cvtcf",
 "addb",
 "addw",
 "addf",
 "subb",
 "subw",
 "subf",
 "mulb",
 "mulw",
 "mulf",
 "divb",
 "divw",
 "divf",
 "modw",
 "modb",
 "andb",
 "andw",
 "orb",
 "orw",
 "xorb",
 "xorw",
 "shlb",
 "shlw",
 "shrb",
 "shrw",
 "insc",
 "indc",
 "addc",
 "lenc",
 "lena",
 "lenl",
 "beqb",
 "bneb",
 "bltb",
 "bleb",
 "bgtb",
 "bgeb",
 "beqw",
 "bnew",
 "bltw",
 "blew",
 "bgtw",
 "bgew",
 "beqf",
 "bnef",
 "bltf",
 "blef",
 "bgtf",
 "bgef",
 "beqc",
 "bnec",
 "bltc",
 "blec",
 "bgtc",
 "bgec",
 "slicea",
 "slicela",
 "slicec",
 "indw",
 "indf",
 "indb",
 "negf",
 "molv",
 "addl",
 "subl",
 "divl",
 "modl",
 "mull",
 "andl",
 "orl",
 "xorl",
 "shll",
 "shrl",
 "bnel",
 "bltl",
 "blel",
 "bgtl",
 "bgel",
 "beql",
 "cvtlf",
 "cvtfl",
 "cvtlw",
 "cvtwl",
 "cvtlc",
 "cvtcl",
 "headl",
 "cons",
 "newcl",
 "casec",
 "indl",
 "movpc",
 "tcmp",
 "mnewz",
 "cvtrf",
 "cvtfr",
 "cvtws",
 "cvtsw",
 "lsrw",
 "lsrl",
 "eclr",
 "newz",
 "newaz"
];
