module frontend;

import frontend.lexer;
import frontend.parser;
import language.ast;
import utils.files;

AST parseFile(string path) {
    auto source = readFile(path);
    auto tokens = lexSource(path, source);
    return parseTokens(tokens);
}
