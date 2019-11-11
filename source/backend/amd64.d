module backend.amd64;

import std.conv;
import std.array;

import language.ast;

// The AST generator is built upon the following assumptions:
// - The result of sequential expressions is always stored in a register:
//     - Integer results go in RAX.
// - C calling convention is followed:
//     - The return for integer results goes in RAX.
string generateAMD64Code(AST ast) {
    auto code = appender!string;

    // Metadata.
    code.put(".file \"" ~ ast.path ~ "\"\n");

    // Generate the code.
    foreach (decl; ast.body) {
        code.put("\n");
        code.put(emitDeclaration(decl));
    }

    return code.data;
}

private string emitDeclaration(Declaration decl) {
    auto code = appender!string;
    auto item = decl.value;

    switch (decl.type) {
        case 0:
            code.put(".extern " ~ item.signature.id ~ "\n");
            break;
        default:
            code.put(".section .text\n");
            code.put(".global " ~ item.func.signature.id ~ "\n");
            code.put(item.func.signature.id ~ ":\n");
            foreach (b; item.func.body) {
                code.put(emitStatement(b));
            }
    }

    return code.data;
}

private string emitStatement(Statement stmt) {
    auto code = appender!string;

    if (stmt.value)
        code.put(emitExpression(stmt.value));

    code.put("\tret\n");

    return code.data;
}

private string emitExpression(Expression add) {
    auto code = appender!string;

    // Generate the first element.
    code.put(emitMultiplication(add.elements[0]));

    // Check if we only have a single factor.
    if (add.types.length == 0)
        return code.data;

    for (int i = 0; i < add.types.length; i++) {
        // Generate the operand. EAX will always be the first operand and ECX
        // the second.
        code.put("\tmov %eax, %edx\n");
        code.put(emitMultiplication(add.elements[i + 1]));
        code.put("\tmov %eax, %ecx\n");
        code.put("\tmov %edx, %eax\n");

        // Generate the actual operations.
        switch (add.types[i]) {
            case 0:
                code.put("\tadd %ecx, %eax\n");
                break;
            default:
                code.put("\tsub %ecx, %eax\n");
        }
    }

    return code.data;
}

private string emitMultiplication(Multiplication mult) {
    auto code = appender!string;

    // Generate the first element.
    code.put(emitFactor(mult.elements[0], "eax"));

    // Check if we only have a single factor.
    if (mult.types.length == 0)
        return code.data;

    for (int i = 0; i < mult.types.length; i++) {
        // Generate the operand. EAX will always be the first operand and ECX
        // the second.
        code.put(emitFactor(mult.elements[i + 1], "ecx"));

        // Generate the actual operations.
        switch (mult.types[i]) {
            case 0:
                code.put("\timul %ecx\n");
                break;
            case 1:
                code.put("\tcdq\n");
                code.put("\tidiv %ecx\n");
                break;
            default:
                code.put("\tcdq\n");
                code.put("\tidiv %ecx\n");
                code.put("\tmov %edx, %eax\n");
        }
    }

    return code.data;
}

private string emitFactor(Factor ft, string register) {
    auto code = appender!string;
    auto item = ft.value;

    switch (ft.type) {
        case 0:
            code.put(emitFactor(item.unary.value, register));
            code.put("\tneg %" ~ register ~ "\n");
            break;
        default:
            code.put("\tmov $" ~ item.integer.value ~ ", %" ~ register ~ "\n");
            break;
    }

    return code.data;
}
