%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE *yyin;
int yylex(void);
void yyerror(const char *s);

/* indent printing */
static int g_indent = 0;
static void print_indent() {
    for (int i=0; i<g_indent; i++) printf("  ");
}

/* remove eventual ':' final na string da condição */
static void trim_colon(char *s) {
    if (!s) return;
    size_t n = strlen(s);
    if (n > 0 && s[n-1] == ':') s[n-1] = '\0';
}
%}

%union {
    char *s;
}

%token <s> QUESTION SUBQUESTION ANSWER BRANCH WHILE REPEAT CONCLUSION TEXT
%token INDENT DEDENT NEWLINE
%start program

%%

program:
      /* vazio */
    | program statement
    ;

statement:
      QUESTION          { print_indent(); printf("Question: %s\n", $1); free($1); }
    | SUBQUESTION       { print_indent(); printf("SubQuestion: %s\n", $1); free($1); }
    | ANSWER            { print_indent(); printf("Answer: %s\n", $1); free($1); }
    | CONCLUSION        { print_indent(); printf("Conclusion: %s\n", $1); free($1); }

    /* BRANCH with mid-rule actions:
       - when we see BRANCH INDENT {action} program DEDENT {action_end}
       - the mid-rule action runs after INDENT is shifted but before program is parsed */
    | BRANCH INDENT    { trim_colon($1); print_indent(); printf("Branch (condition: %s)\n", $1); g_indent++; free($1); }
                       program DEDENT { g_indent--; }

    /* WHILE with same approach */
    | WHILE INDENT     { trim_colon($1); print_indent(); printf("While (condition: %s)\n", $1); g_indent++; free($1); }
                       program DEDENT { g_indent--; }

    /* REPEAT similarly */
    | REPEAT INDENT    { trim_colon($1); print_indent(); printf("Repeat (times: %s)\n", $1); g_indent++; free($1); }
                       program DEDENT { g_indent--; }

    | TEXT              { print_indent(); printf("Text: %s\n", $1); free($1); }

    /* aceitar e ignorar tokens isolados */
    | INDENT            { /* ignore standalone INDENT */ }
    | DEDENT            { /* ignore standalone DEDENT */ }
    | NEWLINE           { /* ignore */ }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) { perror("fopen"); return 1; }
        yyin = f;
    }
    yyparse();
    return 0;
}
