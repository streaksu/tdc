module backend.emitasm;

import std.array: appender;

import compiler: VERSION;
import dmd.dmodule: Module;

string emitModuleASM(Module mod) {
    auto output = appender!string;

    // Header of the source
    output.put("// Code emitted by TDC - ");
    output.put(VERSION);
    output.put("\n");

    return output.data;
}
