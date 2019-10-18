import std.stdio;
import std.getopt;
import core.stdc.stdlib;

import compiler;
import utils.messages;

class Unit {
    // Paths of source and output.
    string source;
    string output;

    // Command line parameters.
    bool onlyparse;

    this(string[] args) {
        // First, parse the command line.
        bool vers = false;

        try {
            auto cml = getopt(
                args,
                "V",  "Print the version and targets",      &vers,
                "c",  "Set a source file to compile",       &this.source,
                "o",  "Set an output file for compilation", &this.output,
                "op", "Only parse the source, no code gen", &this.onlyparse
            );

            if (cml.helpWanted) {
                defaultGetoptPrinter("Flags and options:", cml.options);
                exit(0);
            }
        } catch (Exception e)
            error(e.msg);

        // Check the values we got.
        if (vers) {
            writefln("%s %s", COMPILERNAME, COMPILERVERSION);
            writefln("Distributed under the %s license.", COMPILERLICENSE);
            exit(0);
        }

        if (this.source == "")
            error("No source files were passed for compilation");

        if (this.output == "")
            this.output = this.source ~ OUTPUTEXT;
    }
}
