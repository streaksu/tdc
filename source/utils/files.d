module utils.files;

import std.utf;
import std.file;

import utils.messages;

string readFile(string path) {
    try
        return readText(path);
    catch (UTFException)
        error("'" ~ path ~ "' has unreadable characters (UTF encoding error)");
    catch (FileException)
        error("'" ~ path ~ "' couldn't be read, does it exist?");

    assert(0);
}

void writeFile(string path, string contents) {
    try
        write(path, contents);
    catch (Exception)
        error("Contents could not be written to '" ~ path ~ "'");
}
