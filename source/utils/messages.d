module utils.messages;

import std.stdio:        stderr;
import core.stdc.stdlib: exit;

private immutable(string) CMAGENTA;
private immutable(string) CRED;
private immutable(string) CRESET;

shared static this() {
    // We will only use scape sequences in a POSIX system
    version (Posix) {
        import core.sys.posix.unistd: isatty;

        // Test if stderr (2) is a tty, to use fancy escape sequences.
        if (isatty(2)) {
            CMAGENTA = "\033[1;35m";
            CRED     = "\033[1;31m";
            CRESET   = "\033[0m";
        }
    }
}

void warning(string message) {
    stderr.writefln("%sWarning:%s %s.", CMAGENTA, CRESET, message);
}

void error(string message) {
    stderr.writefln("%sError:%s %s.", CRED, CRESET, message);
    exit(1);
}
