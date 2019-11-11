module backend;

import backend.amd64;
import language.ast;
import utils.messages;
import utils.files;

void outputTargetCode(AST ast, string target, string output) {
    string code;

    switch (target) {
        case "amd64":
            code = generateAMD64Code(ast);
            break;
        default:
            error("Target '" ~ target ~ "' wasn't recognised");
    }

    writeFile(output, code);
}
