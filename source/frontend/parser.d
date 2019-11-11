module frontend.parser;

import std.array;

import language.ast;
import language.token;
import utils.messages;

AST parseTokens(TokenStack tokens) {
    auto declarations = appender!(Declaration[]);

    while (!tokens.isEmpty()) {
        declarations.put(parseDeclaration(tokens));
    }

    return new AST(tokens.path, declarations.data);
}

private Declaration parseDeclaration(TokenStack tokens) {
    // Parse common elements.
    auto type = tokens.popValue(TokenType.Native);
    auto id   = tokens.popValue(TokenType.Identifier);
    tokens.pop(TokenType.OpenParenthesis);
    tokens.pop(TokenType.CloseParenthesis);

    // See if we are parsing a function or signature.
    switch (tokens.peekType()) {
        case TokenType.Semicolon:
            tokens.pass();
            return new Declaration(new Signature(type, id));
        default:
            tokens.pop(TokenType.OpenBrace);
            auto body = appender!(Statement[]);

            while (tokens.peekType() != TokenType.CloseBrace) {
                body.put(parseStatement(tokens));
            }

            tokens.pop(TokenType.CloseBrace);

            auto signature = new Signature(type, id);
            return new Declaration(new Function(signature, body.data));
    }
}

private Statement parseStatement(TokenStack tokens) {
    tokens.pop(TokenType.Return);
    
    if (tokens.peekType() == TokenType.Semicolon) {
        tokens.pop(TokenType.Semicolon);
        return new Return();
    } else {
        auto value = parseExpression(tokens);
        tokens.pop(TokenType.Semicolon);
        return new Return(value);
    }
}

private Expression parseExpression(TokenStack tokens) {
    ubyte[] types             = [];
    Multiplication[] elements = [];

    elements ~= [parseMultiplication(tokens)];

    auto type = tokens.peekType();

    while (type == TokenType.Plus || type == TokenType.Minus) {
        tokens.pass();

        switch (type) {
            case TokenType.Plus:
                types ~= [0];
                break;
            default:
                types ~= [1];
        }

        elements ~= [parseMultiplication(tokens)];
        type = tokens.peekType();
    }

    return new Addition(types, elements);
}

private Multiplication parseMultiplication(TokenStack tokens) {
    ubyte[] types     = [];
    Factor[] elements = [];

    elements ~= [parseFactor(tokens)];

    auto type = tokens.peekType();

    while (type == TokenType.Asterisk || type == TokenType.Slash ||
           type == TokenType.Percent) {
        tokens.pass();

        switch (type) {
            case TokenType.Asterisk:
                types ~= [0];
                break;
            case TokenType.Slash:
                types ~= [1];
                break;
            default:
                types ~= [2];
        }

        elements ~= [parseFactor(tokens)];
        type = tokens.peekType();
    }

    return new Multiplication(types, elements);
}

private Factor parseFactor(TokenStack tokens) {
    switch (tokens.peekType()) {
        case TokenType.Minus:
            tokens.pass();
            return new Factor(new Unary(parseFactor(tokens)));
        default:
            auto i = new Integer(tokens.popValue());
            return new Factor(i);
    }
}
