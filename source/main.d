module main;

import std.stdio:        writeln, writefln;
import std.getopt:       getopt, defaultGetoptPrinter, Option;
import core.stdc.stdlib: exit;

import compiler:       VERSION, OUTPUTEXTENSION;
import utils.messages: error;

import dmd.mtype:        Type;
import dmd.id:           Id;
import dmd.dmodule:      Module;
import dmd.expression:   Expression;
import dmd.objc:         Objc;
import dmd.builtin:      builtin_init;
import dmd.filecache:    FileCache;
import dmd.root.ctfloat: CTFloat;

private void printUsage(Option[] options) {
    writeln("Usage:");
    writeln("\ttdc [options] -c <source>");
    writeln("");
    defaultGetoptPrinter("Flags and options:", options);
}

private void printVersion() {
    writefln("TDC D Compiler version %s.", VERSION);
    writefln("Distributed under the BSL-1.0 license.");
}

void main(string[] args) {
    // Arguments that we get from commandline.
    bool vers;
    string source;
    string output;
    bool oparse;

    try {
        auto cml = getopt(
            args,
            "version|V", "Print the version and targets", &vers,
            "c", "Set a source file to compile", &source,
            "o", "Set an output file for compilation", &output,
            "oparse", "Only parse the source, no code gen", &oparse
        );

        if (cml.helpWanted) {
            printUsage(cml.options);
            exit(0);
        }
    } catch (Exception e) {
        error(e.msg);
    }

    // Check the values we got.
    if (vers) {
        printVersion();
        exit(0);
    }

    if (source == "") {
        error("No source files were passed for compilation");
    }

    if (output == "") {
        output = source ~ OUTPUTEXTENSION;
    }

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
