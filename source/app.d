import std.stdio;

import sid.obj.core;
import sid.obj.header;
import sid.mod;

void main(string[] args)
{
    if (args.length < 2) {
        writeln("Specify .dis file.");
        return;
    }

    ObjectFile obj = ObjectFile(args[1]);
    obj.header.dbg();

    DisModule mod = DisModule(File(args[1]));

    mod.dbg();
}

void printBuf(T)(T[] buf) {
    foreach(T b; buf) {
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

void dbg(DisModule mod) {
    writeln("Module name: ", mod.name.array);
    writeln("Module header: ");
    mod.header.dbg();

    writeln("Code section:");
    writeln("Size: ", mod.code.array.length);
    printBuf(mod.code.array);
    writeln();

    writeln("Type section:");
    writeln("Size: ", mod.type.array.length);
    printBuf(mod.type.array);
    writeln();

    writeln("Data section:");
    writeln("Size: ", mod.data.array.length);
    printBuf(mod.data.array);
    writeln();

    writeln("Name raw:");
    writeln("Size: ", mod.name.array.length);
    printBuf(mod.name.array);
    writeln();

    writeln("Link section:");
    writeln("Size: ", mod.link.array.length);
    printBuf(mod.link.array);
    writeln();
}
