module main;

import std.stdio:        writefln;
import std.getopt:       getopt, defaultGetoptPrinter;
import core.stdc.stdlib: exit;

import compiler:       NAME, VERSION, LICENSE, OUTPUTEXTENSION;
import utils.messages: error;

import dmd.mtype:        Type;
import dmd.id:           Id;
import dmd.dmodule:      Module;
import dmd.expression:   Expression;
import dmd.objc:         Objc;
import dmd.builtin:      builtin_init;
import dmd.filecache:    FileCache;
import dmd.root.ctfloat: CTFloat;

void main(string[] args) {
    // Arguments that we get from commandline.
    bool   vers;
    string source;
    string output;
    bool   onlyparse;
    string target;

    try {
        auto cml = getopt(
            args,
            "V",  "Print the version and targets",      &vers,
            "c",  "Set a source file to compile",       &source,
            "o",  "Set an output file for compilation", &output,
            "op", "Only parse the source, no code gen", &onlyparse,
            "t",  "Target for the compilation process", &target
        );

        if (cml.helpWanted) {
            defaultGetoptPrinter("Flags and options:", cml.options);
            exit(0);
        }
    } catch (Exception e) {
        error(e.msg);
    }

    // Check the values we got.
    if (vers) {
        writefln("The glorious %s compilation system", NAME);
        writefln("Version '%s'", VERSION);
        writefln("Distributed under the %s license.", LICENSE);
        exit(0);
    }

    if (source == "")
        error("No source files were passed for compilation");

    if (output == "")
        output = source ~ OUTPUTEXTENSION;
    
    if (target == "")
        target = "amd64";

    // Initialize DMD, taken straight from the original at 'dmd/mars.d'.
    Type._init();
    Id.initialize();
    Module._init();
    // target._init(params);
    Expression._init();
    Objc._init();
    builtin_init();
    FileCache._init();
    CTFloat.initialize();
}
