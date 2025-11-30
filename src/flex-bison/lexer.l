%{
#include <iostream>
#include <string>
#include <stack>
#include "ast.h"
#include "parser.tab.h"  /* Header gerado por bison */

std::stack<int> indent_stack;

%}

%option noyywrap
%option yylineno

%%

\n[ \t]* {
    std::string ws = yytext + 1;
    int width = 0;
    for(char c : ws) {
        if(c == ' ') width++;
        else if(c == '\t') width += 4; 
    }

    if (indent_stack.empty()) indent_stack.push(0);

    if (width > indent_stack.top()) {
        indent_stack.push(width);
        return TOKEN_INDENT;
    } 
    else if (width < indent_stack.top()) {
        indent_stack.pop();
        if (width < indent_stack.top()) {
            yyless(0);   /* reprocessa para gerar múltiplos DEDENT */
        }
        return TOKEN_DEDENT;
    }
    else {
        /* mesma indentação: apenas fim de comando */
        return NEWLINE;
    }
}

\r              { /* Ignora Windows CR */ }
[\xC2\xA0]      { /* Ignora NBSP */ }

"#".*           { /* Comentarios - até o fim da linha (o \n é tratado na regra acima) */ }

"Se"            { return KW_SE; }
"Senao"         { return KW_SENAO; }
"Enquanto"      { return KW_ENQUANTO; }
"Verdadeiro"    { yylval.bVal = true;  return LIT_BOOL; }
"Falso"         { yylval.bVal = false; return LIT_BOOL; }
"tamanho_de"    { return KW_TAMANHO; }
"AND"           { return OP_AND; }
"OR"            { return OP_OR; }

":="            { return OP_ASSIGN; }
"<<"            { return OP_APPEND; }
"->"            { return OP_ARROW; }
"=="            { return OP_EQ; }
"!="            { return OP_NEQ; }
">="            { return OP_GTE; }
"<="            { return OP_LTE; }
">>"            { return OP_LOG; }
"?"             { return OP_QUEST; }
">"             { return OP_GT; }
"!"             { return OP_CONCL; }
":"             { return COLON; }
","             { return COMMA; }
"["             { return LBRACKET; }
"]"             { return RBRACKET; }
"("             { return LPAREN; }
")"             { return RPAREN; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MULT; }
"/"             { return DIV; }
"%"             { return MOD; }
"<"             { return OP_LT; }

\"[^"]*\" { 
    std::string s = yytext; 
    yylval.sVal = new std::string(s.substr(1, s.length()-2)); 
    return LIT_STRING; 
}

[0-9]+(\.[0-9]+)? { 
    yylval.dVal = std::stod(yytext); 
    return LIT_NUMBER; 
}

@[a-zA-Z0-9_]+ { 
    yylval.sVal = new std::string(yytext); 
    return VAR_ID; 
}

[ \t]+  { /* ignora espaços e tabs isolados */ }

.       { std::cerr << "Ignorado: " << (int)(unsigned char)yytext[0] << std::endl; }

%%
