module frontend.lexer;

import std.conv;
import std.array;
import std.regex;
import std.string;

import language.token;
import utils.files;
import utils.messages;

TokenStack lexSource(string path, string source) {
    auto toks  = appender!(Token[]);
    auto ln    = 1;
    auto value = "";

    // Main tokeniser loop.
    for (auto i = 0; i < source.length; i++) {
        // Check if we are facing an empty token, that we would skip.
        if (isEmptyToken(source[i])) {
            if (source[i] == '\n')
                ln += 1;
        }

        // Now we will check if we have a token that is a single char.
        else if (isCharToken(source[i]))
            toks.put(Token(ln, getCharToken(source[i]), to!string(source[i])));

        // Otherwise, we know that we are facing a multichar token.
        else {
            do {
                value ~= source[i++];
            } while (i < source.length        &&
                     !isEmptyToken(source[i]) &&
                     !isCharToken(source[i]));
            i -= 1;

            // Check if we can make a token with the multichar token.
            if (isKeyword(value))
                toks.put(Token(ln, getKeyword(value), value));
            else if (isDefinition(value))
                toks.put(Token(ln, getDefinition(value), value));
            else
                error(path, ln, "The token '" ~ value ~ "' couldn't be recognized");

            value = "";
        }
    }

    return new TokenStack(path, toks.data);
}
