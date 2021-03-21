import std.stdio;

import sid.obj.core;
import sid.obj.header;
import sid.obj.inst;
import sid.obj.type;
import sid.mem.alloc;
import sid.mem.heap;
import sid.mod;

void main(string[] args)
{
    if (args.length < 2) {
        writeln("Specify .dis file.");
        return;
    }

    ObjectFile obj = ObjectFile(args[1]);
    obj.header.dbg();

    BadHeap heap = BadHeap(4096 * 12);

    DisModule *mod = allocate!DisModule(DisModule(File(args[1]), heap));

    dbg(*mod);

    deallocate(mod);
}

void printBuf(T)(T[] buf) {
    foreach(b; buf) {
        writef("%02X ", b);
    }
}

void dbg(DisHeader header) {
    writeln("Magic: ", header.magic_number,
            ((header.magic_number == XMAGIC) ||
             (header.magic_number == SMAGIC)) ?
            " (Valid)" : " (Invalid)");

    writeln("Signed?: ", header.signed ? "Yes" : "No");
    writef("Flags: 0x%02X\n", header.runtime_flag);
    writeln("Stack Extent: ", header.stack_extent);

    writeln("Section sizes: ");
    writeln("\tCode: ", header.code_size);
    writeln("\tData: ", header.data_size);
    writeln("\tType: ", header.type_size);
    writeln("\tLink: ", header.link_size);

    writeln("Entry PC: ", header.entry_pc);
    writeln("Entry Type: ", header.entry_type);
}

void dbg(DisInstruction inst) {
    writef("%s\t",  Mnemonics[inst.opcode]);
    dbg(inst.source_mode, inst.source_op_1, inst.source_op_2);
    dbg(inst.middle_mode, inst.middle_op);
    dbg(inst.dest_mode, inst.dest_op_1, inst.dest_op_2, "\t\t");
    writef("MODE %02x\n", inst.address_mode);
}

void dbg(DisTypeDesc desc) {
    writefln("Index: %d", desc.desc_number);
    writefln("Size: %d", desc.size);
    writefln("Map size: %d", desc.number_ptrs);
    write("Map: \"");
    foreach (b; desc.map) {
        writef("%02x", b);
    }
    writeln("\"");
}

void dbg(OpMode mode, int op_1, int op_2 = 0, string append=", ") {
    switch (mode) {
        case OpMode.IMMEDIATE:
            writef("$%d", op_1);
            write(append);
            break;
        case OpMode.INDIRECT_FP:
            writef("%d(fp)", op_1);
            write(append);
            break;
        case OpMode.INDIRECT_MP:
            writef("%d(mp)", op_1);
            write(append);
            break;
        case OpMode.DOUBLE_INDIRECT_FP:
            writef("%d(%d(fp))", op_1, op_2);
            write(append);
            break;
        case OpMode.DOUBLE_INDIRECT_MP:
            writef("%d(%d(mp))", op_1, op_2);
            write(append);
            break;
        case OpMode.NONE:
            break;
        default:
            write("BAD ENCODING");
            break;
    }
}

void dbg(DisModule mod) {
    writeln("Module name: ", mod.name.array);
    writeln("Module header: ");
    mod.header.dbg();

    writeln("Code section:");
    writeln("Instructions: ", mod.code.length);
    foreach(i, inst; mod.code) {
        writef("\t%d\t", i);
        inst.dbg();
    }
    writeln();

    writeln("Type section:");
    writeln("Type Declarations: ", mod.type.array.length);
    foreach(d; mod.type) {
        d.dbg();
    }

    writeln("Data section:");
    writeln();

    writeln("Name raw:");
    printBuf(mod.name.array);
    writeln("Size: ", mod.name.array.length);
    writeln();

    writeln("Link section:");
    writeln("Link entries: ", mod.link.array.length);
    writeln();
}
