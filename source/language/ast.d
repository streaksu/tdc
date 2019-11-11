module language.ast;

/*
 * <AST> ::= { <Declaration> }
 *
 * <Declaration> ::= <Signature> Semicolon | <Function>
 *
 * <Signature> ::= Native Identifier OpenParenthesis CloseParenthesis
 * <Function>  ::= <Signature> OpenBrace { <Statement> } CloseBrace
 *
 * <Statement> ::= <Return>
 *
 * <Return>   ::= Return [ <Expression> ] Semicolon
 *
 * <Expression> ::= <Addition>
 *
 * <Addition>       ::= <Multiplication> { (Plus | Minus) <Multiplication> }
 * <Multiplication> ::= <Factor> { (Asterisk | Slash) <Factor> }
 *
 * <Factor> ::= <Unary> | <Integer>
 *
 * <Unary>    ::= Minus <Factor>
 * <Integer>  ::= Integer
 */

class AST {
    string        path;
    Declaration[] body;

    this(string ph, Declaration[] b) { this.path = ph; this.body = b; }
}

class Declaration {
    union Decl {
        Signature signature;
        Function  func;
    }

    int  type;
    Decl value;

    this(Signature s) { this.type = 0; this.value.signature = s; }
    this(Function fn) { this.type = 1; this.value.func = fn;     }
}

class Signature {
    uint   line;
    string type;
    string id;

    this(string t, string i) { this.type = t; this.id = i; }
}

class Function {
    Signature   signature;
    Statement[] body;

    this(Signature s, Statement[] b) { this.signature = s; this.body = b; }
}

alias Statement = Return;

class Return {
    Expression value;

    this()             { this.value = null; }
    this(Expression v) { this.value = v;    }
}

alias Expression = Addition;

class Addition {
    ubyte[]          types;
    Multiplication[] elements;

    this(ubyte[] t, Multiplication[] e) {
        this.types = t; this.elements = e;
    }
}

class Multiplication {
    ubyte[]  types;
    Factor[] elements;

    this(ubyte[] t, Factor[] e) {
        this.types = t; this.elements = e;
    }
}

class Factor {
    union Fct {
        Unary   unary;
        Integer integer;
    }

    int type;
    Fct value;

    this(Unary u)   { this.type = 0; this.value.unary   = u; }
    this(Integer i) { this.type = 1; this.value.integer = i; }
}

class Unary {
    Factor value;

    this(Factor f) {this.value = f; }
}

class Integer {
    string value;

    this(string v) { this.value = v; }
}
