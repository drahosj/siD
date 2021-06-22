module sid.frame;

import sid.mod;
import sid.app;

import sid.obj.inst;

import std.stdio;


void executeFrame(H)(ref DisModule!H mod, uint pc) {
    while (pc < mod.code.length) {
        writef("%s(%d): ", mod.name.array, pc);
        mod.code[pc].dbg();

        if (mod.code[pc].opcode == Opcode.RET) {
            writeln("--- RETURNING FROM FRAME ---");
        }
        pc++;
    }
}
