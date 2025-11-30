%{
#include <iostream>
#include <vector>
#include <string>
#include <stack>
#include <cstdio>
#include "ast.h"

extern int yylex();
extern int yylineno;
extern FILE* yyin;
extern std::stack<int> indent_stack; 
void yyerror(const char *s);

Block* rootBlock = nullptr;
%}

%define parse.error verbose

%union {
    double dVal;
    bool bVal;
    std::string* sVal;
    Node* node;
    Expression* expr;
    Block* block;
    ListLiteral* listLit;
}

%token <sVal> VAR_ID LIT_STRING
%token <dVal> LIT_NUMBER
%token <bVal> LIT_BOOL
%token TOKEN_INDENT TOKEN_DEDENT
%token KW_SE KW_SENAO KW_ENQUANTO KW_TAMANHO
%token OP_ASSIGN OP_APPEND OP_ARROW OP_EQ OP_NEQ OP_GTE OP_LTE OP_LT OP_GT
%token OP_LOG OP_QUEST OP_CONCL
%token COLON COMMA LBRACKET RBRACKET LPAREN RPAREN
%token PLUS MINUS MULT DIV MOD OP_AND OP_OR
%token NEWLINE

%type <expr> expression logic_expr comp_expr math_expr term factor
%type <listLit> list_def list_items 
%type <block> program block statements
%type <node> statement assignment conditional loop question input_ans output conclusion

%left OP_OR
%left OP_AND
%left OP_EQ OP_NEQ OP_LT OP_GT OP_GTE OP_LTE OP_ARROW
%left PLUS MINUS
%left MULT DIV MOD

%%

program:
    opt_newlines statements opt_newlines { rootBlock = $2; }
    ;

opt_newlines:
    /* vazio */
    | opt_newlines NEWLINE
    ;

/* Agora aceita:
   - uma lista de statements
   - com 0, 1 ou vários NEWLINE entre eles
   - e também NEWLINE “a mais” no fim de bloco/arquivo
*/
statements:
      statement                               { $$ = new Block(); $$->add($1); }
    | statements NEWLINE statement            { $$ = $1; $$->add($3); }
    | statements NEWLINE                      { $$ = $1; /* linha em branco ou newline extra */ }
    ;

block:
    TOKEN_INDENT opt_newlines statements TOKEN_DEDENT { $$ = $3; }
    ;

statement:
    assignment    { $$ = $1; }
    | question    { $$ = $1; }
    | input_ans   { $$ = $1; }
    | output      { $$ = $1; }
    | conclusion  { $$ = $1; }
    | conditional { $$ = $1; }
    | loop        { $$ = $1; }
    ;

assignment:
    VAR_ID OP_ASSIGN expression                       { $$ = new Assignment(*$1, $3); delete $1; }
    | VAR_ID OP_APPEND expression                     { $$ = new Assignment(*$1, $3, true); delete $1; }
    | VAR_ID LBRACKET expression RBRACKET OP_ASSIGN expression
                                                      { $$ = new Assignment(*$1, $3, $6); delete $1; }
    ;

question:
    OP_QUEST expression { $$ = new Question($2); }
    ;

input_ans:
    OP_GT VAR_ID { $$ = new InputAnswer(*$2); delete $2; }
    ;

output:
    OP_LOG expression { $$ = new Output(">>", $2); }
    ;

conclusion:
    OP_CONCL expression { $$ = new Output("!", $2); }
    ;

conditional:
    OP_ARROW KW_SE expression COLON block
        { $$ = new IfStmt($3, $5); }
    | OP_ARROW KW_SE expression COLON block OP_ARROW KW_SENAO COLON block
        { $$ = new IfStmt($3, $5, $9); }
    ;

loop:
    KW_ENQUANTO expression COLON block { $$ = new WhileStmt($2, $4); }
    ;

expression:
    logic_expr { $$ = $1; }
    ;

logic_expr:
    logic_expr OP_AND comp_expr { $$ = new BinaryOp($1, "AND", $3); }
    | logic_expr OP_OR  comp_expr { $$ = new BinaryOp($1, "OR",  $3); }
    | comp_expr { $$ = $1; }
    ;

comp_expr:
    math_expr OP_EQ  math_expr { $$ = new BinaryOp($1, "==", $3); }
    | math_expr OP_NEQ math_expr { $$ = new BinaryOp($1, "!=", $3); }
    | math_expr OP_LT  math_expr { $$ = new BinaryOp($1, "<",  $3); }
    | math_expr OP_LTE math_expr { $$ = new BinaryOp($1, "<=", $3); }
    | math_expr OP_GT  math_expr { $$ = new BinaryOp($1, ">",  $3); }
    | math_expr OP_GTE math_expr { $$ = new BinaryOp($1, ">=", $3); }
    | math_expr { $$ = $1; }
    ;

math_expr:
    math_expr PLUS  term { $$ = new BinaryOp($1, "+", $3); }
    | math_expr MINUS term { $$ = new BinaryOp($1, "-", $3); }
    | term { $$ = $1; }
    ;

term:
    term MULT factor { $$ = new BinaryOp($1, "*", $3); }
    | term DIV  factor { $$ = new BinaryOp($1, "/", $3); }
    | term MOD  factor { $$ = new BinaryOp($1, "%", $3); }
    | factor { $$ = $1; }
    ;

factor:
    LPAREN expression RPAREN               { $$ = $2; }
    | LIT_NUMBER                           { $$ = new Literal(Value($1)); }
    | LIT_STRING                           { $$ = new Literal(Value(*$1)); delete $1; }
    | LIT_BOOL                             { $$ = new Literal(Value($1)); }
    | VAR_ID                               { $$ = new Variable(*$1); delete $1; }
    | VAR_ID LBRACKET expression RBRACKET  { $$ = new ListAccess(*$1, $3); delete $1; }
    | list_def                             { $$ = $1; }
    | KW_TAMANHO LPAREN VAR_ID RPAREN      { $$ = new LengthFunc(new Variable(*$3)); delete $3; }
    ;

list_def:
    LBRACKET RBRACKET              { $$ = new ListLiteral(); }
    | LBRACKET list_items RBRACKET { $$ = $2; }
    ;

list_items:
    list_items COMMA expression { $$ = $1; $$->add($3); }
    | expression                { $$ = new ListLiteral(); $$->add($1); }
    ;

%%

void yyerror(const char *s) {
    std::cerr << "Erro de Sintaxe: " << s << " na linha " << yylineno << std::endl;
}

int main(int argc, char** argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            std::cerr << "Erro ao abrir o arquivo: " << argv[1] << std::endl;
            return 1;
        }
        yyin = file;
    } else {
        std::cout << "Modo Interativo (Ctrl+D para sair)." << std::endl;
        yyin = stdin;
    }

    if (indent_stack.empty()) indent_stack.push(0);

    std::cout << "--- Interpretador Maieutic Iniciado ---" << std::endl;
    
    if (yyparse() == 0 && rootBlock != nullptr) {
        std::cout << "Sintaxe OK. Executando..." << std::endl << std::endl;
        try {
            rootBlock->execute();
        } catch (const std::exception& e) {
            std::cerr << "Erro de Execucao: " << e.what() << std::endl;
        }
    }
    
    if (argc > 1) fclose(yyin);
    return 0;
}
