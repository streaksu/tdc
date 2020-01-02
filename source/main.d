module main;

import std.string:       toStringz;
import std.stdio:        writeln, writefln;
import std.getopt:       getopt, defaultGetoptPrinter, Option;
import core.stdc.stdlib: exit;

import compiler:       VERSION, OUTPUTEXTENSION;
import utils.messages: error;

import dmd.globals:      global, Loc;
import dmd.target:       target;
import dmd.arraytypes:   Strings, Modules;
import dmd.mars:         createModules;
import dmd.mtype:        Type;
import dmd.id:           Id;
import dmd.dmodule:      Module;
import dmd.expression:   Expression;
import dmd.objc:         Objc;
import dmd.builtin:      builtin_init;
import dmd.filecache:    FileCache;
import dmd.root.ctfloat: CTFloat;
import dmd.root.array:   Array;
import dmd.identifier:   Identifier;
import dmd.dsymbolsem:   dsymbolSemantic;
import dmd.semantic2:    semantic2;
import dmd.semantic3:    semantic3;
import dmd.inline:       inlineScanModule;

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

private void initDMD() {
    // Set path and version IDs.
    global.path = new Array!(const(char)*);
    global.versionids = new Array!Identifier;

    // Set OS specific fields.
    version (Windows) {
        global.params.isWindows = true;
        global.versionids.push(new Identifier("Windows"));
    } else {
        global.params.isLinux = true;
        global.path.push("/usr/include/d");
        global.path.push("/usr/include/d/druntime/import");
        global.versionids.push(new Identifier("Posix"));
    }

    // Initialize DMD, taken straight from the original at 'dmd/mars.d'.
    Type._init();
    Id.initialize();
    Module._init();
    target._init(global.params);
    Expression._init();
    Objc._init();
    builtin_init();
    FileCache._init();
    CTFloat.initialize();
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

    // Initialise DMD's core.
    initDMD();

    // Create modules for DMD.
    Strings dmdFiles;
    Strings libModules;
    dmdFiles.push(toStringz(source));
    Modules mod = createModules(dmdFiles, libModules);

    // Parse the module.
    auto m = mod[0];
    m.read(Loc.initial);
    m.parse();

    // Manage included modules.
    m.importAll(null);

    // Semantical analysis.
    m.dsymbolSemantic(null);
    m.semantic2(null);
    m.semantic3(null);
    Module.runDeferredSemantic3();

    // Scan for functions to inline.
    inlineScanModule(m);
}
