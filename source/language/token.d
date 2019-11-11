module language.token;

import std.conv;
import std.regex;
import std.algorithm;

import utils.messages;

enum TokenType {
    // Single char tokens.
    Semicolon,
    OpenParenthesis, CloseParenthesis,
    OpenBrace, CloseBrace,
    Asterisk, Slash, Percent,
    Plus, Minus,

    // Keywords.
    Native, Return,

    // Definitions
    Identifier, Integer
}

immutable(char[]) emptyTokens = [' ', '\t', '\r', '\n'];

immutable(TokenType[char])                             charTokens;
immutable(TokenType[string])                           keywords;
immutable(TokenType[const typeof(ctRegex!("").getRe)]) definitions;

shared static this() {
    charTokens = [
        ';' : TokenType.Semicolon,
        '(' : TokenType.OpenParenthesis,
        ')' : TokenType.CloseParenthesis,
        '{' : TokenType.OpenBrace,
        '}' : TokenType.CloseBrace,
        '*' : TokenType.Asterisk,
        '/' : TokenType.Slash,
        '%' : TokenType.Percent,
        '+' : TokenType.Plus,
        '-' : TokenType.Minus
    ];

    keywords = [
        "void"   : TokenType.Native,
        "int"    : TokenType.Native,
        "auto"   : TokenType.Native,
        "return" : TokenType.Return
    ];

    definitions = [
        ctRegex!(r"^[_a-zA-Z][_a-zA-Z0-9]*$") : TokenType.Identifier,
        ctRegex!(r"^[0-9]+$")                 : TokenType.Integer,
        ctRegex!(r"^0[xX][0-9a-fA-F]+$")      : TokenType.Integer
    ];
}

struct Token {
    uint      line;
    TokenType type;
    string    value;

    this(uint ln, TokenType t, string v) {
        line  = ln;
        type  = t;
        value = v;
    }
}

class TokenStack {
    immutable string path;
    private Token[]  contents;
    private size_t   currentIndex;

    this(string p, Token[] c) {
        path         = p;
        contents     = c;
        currentIndex = 0;
    }

    bool isEmpty() {
        return currentIndex == contents.length;
    }

    void expect() {
        if (isEmpty()) {
            error(path, 9999, "Unexpected end of file found");
        }
    }

    void expect(TokenType expected) {
        if (peekType() != expected) {
            error(path, peekLine(),
                "'" ~  to!string(peekType()) ~ "' was found, when '" ~
                to!string(expected) ~ "' was expected");
        }
    }

    uint peekLine() {
        expect();
        return contents[currentIndex].line;
    }

    string peekValue() {
        expect();
        return contents[currentIndex].value;
    }

    string peekValue(TokenType expected) {
        expect(expected);
        return contents[currentIndex].value;
    }

    TokenType peekType() {
        expect();
        return contents[currentIndex].type;
    }

    TokenType peekTypeWithLookahead(uint lookahead) {
        currentIndex += lookahead;
        expect();
        auto x = contents[currentIndex].type;
        currentIndex -= lookahead;
        return x;
    }

    Token peekToken() {
        expect();
        return contents[currentIndex];
    }

    void pass() {
        expect();
        currentIndex += 1;
    }

    void pop(TokenType expected) {
        expect(expected);
        pass();
    }

    uint popLine() {
        auto x = peekLine();
        pass();
        return x;
    }

    uint popLine(TokenType expected) {
        expect(expected);
        return popLine();
    }

    string popValue() {
        auto x = peekValue();
        pass();
        return x;
    }

    string popValue(TokenType expected) {
        expect(expected);
        return popValue();
    }

    TokenType popType() {
        auto x = peekType();
        pass();
        return x;
    }

    TokenType popType(TokenType expected) {
        expect(expected);
        return popType();
    }

    Token popToken() {
        auto x = peekToken();
        pass();
        return x;
    }
}

bool isEmptyToken(char value) {
    return canFind(emptyTokens, value);
}

bool isCharToken(char value) {
    return cast(bool)(value in charTokens);
}

TokenType getCharToken(char value) {
    return charTokens[value];
}

bool isKeyword(string value) {
    return cast(bool)(value in keywords);
}

TokenType getKeyword(string value) {
    return keywords[value];
}

bool isDefinition(string value) {
    foreach (key, type; definitions) {
        if (matchAll(value, key)) {
            return true;
        }
    }

    return false;
}

TokenType getDefinition(string value) {
    TokenType output;

    foreach (key, type; definitions) {
        if (matchAll(value, key)) {
            output = type;
        }
    }

    return output;
}
