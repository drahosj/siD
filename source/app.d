module sid.app;

import std.stdio;

import sid.obj.core;
import sid.obj.header;
import sid.obj.inst;
import sid.obj.type;
import sid.obj.link;
import sid.mem.alloc;
import sid.mem.heap;
import sid.mod;
import sid.frame;

void main(string[] args)
{
    if (args.length < 2) {
        writeln("Specify .dis file.");
        return;
    }

    ObjectFile obj = ObjectFile(args[1]);
    obj.header.dbg();

    BadHeap heap = BadHeap(4096 * 12);

    File f = File(args[1]);
    DisModule!BadHeap *mod = 
        allocate!(DisModule!BadHeap)(DisModule!BadHeap(f, heap));

    dbg(*mod);

    print_data!BadHeap(*mod, f);

    executeFrame(*mod, mod.link[0].pc);


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
    writefln("\tIndex: %d", desc.desc_number);
    writefln("\tSize: %d", desc.size);
    writefln("\tMap size: %d", desc.number_ptrs);
    write("\tMap: \"");
    foreach (b; desc.map) {
        writef("%02x", b);
    }
    writeln("\"");
    writeln();
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

void dbg(H)(DisModule!H mod) {
    writeln("Module name: ", mod.name.array);
    writeln("Name len: ", mod.name.array.length);
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
    writeln("Items: ", mod.header.data_size);
    writeln();

    writeln("Name raw:");
    printBuf(mod.name.array);
    writeln("Size: ", mod.name.array.length);
    writeln();

    writeln("Link section:");
    writeln("Link entries: ", mod.link.array.length);
    writeln();

    foreach(e; mod.link.array) {
        e.dbg();
        writeln();
    }
}

void dbg(HeapItem h) {
    writefln("\tCode: %02x", h.code);
    writefln("\tCount: %d", h.count);
    writefln("\tOffset: %d", h.offset);
    writefln("\tType: %d", h.type);

    writefln("\tSize in data segment: %d", h.data_seg_size);
    writefln("\tSize on heap: %d", h.heap_size);
    writefln("\tOperand size in object file: %d", h.operand_size);
    writeln();
}

void dbg(DisLinkEntry e) {
    writefln("\tLink no.: %d", e.link_number);
    writefln("\tName: %s", e.name.array);
    writefln("\tpc: %02x", e.pc);
    writefln("\tsig hash: %08x", e.sig);
}

void print_data(H)(DisModule!H mod, File f) {
    writeln("Module data segment: ");
    f.seek(mod.data_segment_file_start);
    HeapItem item = HeapItem(f);
    while (item.code != 0) {
        writeln("Data Item:");
        dbg(item);
        switch (item.type) {
            case ItemType.WORD:
                writefln("\tItem is a word: %d", 
                        *mod.heap.ptr!int(item.offset));
                break;
            case ItemType.STRING:
                writeln("\tItem is a string.");
                int pointer = *mod.heap_ptr!int(item.offset);
                writefln("\tPointer value: %d", pointer);
                write("\tString at pointer: ");
                foreach (i; 0..item.count) {
                    writef("%c", *mod.heap_ptr!char(pointer++));
                }
                writeln();
                writeln();

                break;
            default:
                break;
        }
        f.seek(f.tell() + item.operand_size);
        item = HeapItem(f);
    }
}
