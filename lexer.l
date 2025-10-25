%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

extern YYSTYPE yylval;

/* queue for tokens so we can emit INDENT/DEDENT before the line token */
#define QSIZE 512
typedef struct { int tok; char *txt; } QItem;
static QItem q[QSIZE];
static int qh = 0, qt = 0;
static void qpush(int tok, const char *txt) {
    if ((qt + 1) % QSIZE == qh) return; /* drop on overflow */
    q[qt].tok = tok;
    q[qt].txt = txt ? strdup(txt) : NULL;
    qt = (qt + 1) % QSIZE;
}
static int qpop(int *out_tok, char **out_txt) {
    if (qh == qt) return 0;
    *out_tok = q[qh].tok;
    *out_txt = q[qh].txt;
    qh = (qh + 1) % QSIZE;
    return 1;
}

/* indentation stack (counts of spaces; tabs counted as 4) */
#define MAX_INDENTS 100
static int indent_stack[MAX_INDENTS];
static int indent_top = 0;

/* helpers */
static char *copy_line_no_nl(const char *s) {
    size_t len = strlen(s);
    while (len > 0 && (s[len-1] == '\n' || s[len-1] == '\r')) len--;
    char *r = malloc(len + 1);
    if (!r) return NULL;
    memcpy(r, s, len);
    r[len] = '\0';
    return r;
}
static char *skip_spaces(char *s) {
    while (*s == ' ' || *s == '\t') s++;
    return s;
}
static int count_indent(const char *s) {
    int count = 0;
    while (*s == ' ' || *s == '\t') {
        if (*s == '\t') count += 4;
        else count++;
        s++;
    }
    return count;
}
static void strip_trailing_colon_and_trim(char *s) {
    if (!s) return;
    size_t n = strlen(s);
    while (n > 0 && (s[n-1] == ' ' || s[n-1] == '\t')) { s[n-1] = '\0'; n--; }
    if (n > 0 && s[n-1] == ':') s[n-1] = '\0';
}
%}

%option noyywrap

%%

[^\n]*\n    {
            int tok; char *txt;
            /* if queue has pending tokens, return next one immediately */
            if (qpop(&tok, &txt)) {
                if (txt) { yylval.s = txt; } else { yylval.s = NULL; }
                return tok;
            }

            /* otherwise process the current input line */
            char *line = copy_line_no_nl(yytext);
            if (!line) continue;

            int spaces = count_indent(line);
            char *p = skip_spaces(line);

            /* blank line: just return NEWLINE token */
            if (p[0] == '\0') { free(line); return NEWLINE; }

            /* compare indentation and enqueue DEDENTs / INDENT as needed */
            int current = indent_top ? indent_stack[indent_top - 1] : 0;
            if (spaces > current) {
                if (indent_top < MAX_INDENTS) {
                    indent_stack[indent_top++] = spaces;
                    /* enqueue INDENT before the line token */
                    qpush(INDENT, NULL);
                }
            } else if (spaces < current) {
                while (indent_top > 0 && indent_stack[indent_top - 1] > spaces) {
                    indent_top--;
                    qpush(DEDENT, NULL);
                }
            }

            /* identify which token this line corresponds to, and enqueue it */
            if (p[0] == '?' && p[1] == '?') {
                qpush(SUBQUESTION, p+2);
            } else if (p[0] == '?' ) {
                qpush(QUESTION, p+1);
            } else if (p[0] == '>') {
                qpush(ANSWER, p+1);
            } else if (p[0] == '!') {
                qpush(CONCLUSION, p+1);
            } else if (strncmp(p, "->", 2) == 0) {
                char *qstr = strstr(p, "Se");
                if (qstr) {
                    qstr += 2;
                    while (*qstr == ' ' || *qstr == '\t') qstr++;
                    char *tmp = strdup(qstr);
                    strip_trailing_colon_and_trim(tmp);
                    qpush(BRANCH, tmp);
                } else {
                    qpush(BRANCH, "");
                }
            } else if (strncmp(p, "Enquanto", 8) == 0 && (p[8] == ' ' || p[8] == '\t' || p[8] == '\0')) {
                char *qstr = p + 8; while (*qstr == ' ' || *qstr == '\t') qstr++;
                char *tmp = strdup(qstr);
                strip_trailing_colon_and_trim(tmp);
                qpush(WHILE, tmp);
            } else if (strncmp(p, "Repetir", 7) == 0 && (p[7] == ' ' || p[7] == '\t' || p[7] == '\0')) {
                char *qstr = p + 7; while (*qstr == ' ' || *qstr == '\t') qstr++;
                char *tmp = strdup(qstr);
                strip_trailing_colon_and_trim(tmp);
                qpush(REPEAT, tmp);
            } else {
                /* fallback: whole line */
                qpush(TEXT, p);
            }

            free(line);

            /* pop the first queued token and return it */
            if (qpop(&tok, &txt)) {
                if (txt) { yylval.s = txt; } else { yylval.s = NULL; }
                return tok;
            }
            continue;
        }

<<EOF>> {
            int tok; char *txt;
            /* enqueue DEDENTs to close all remaining indents */
            while (indent_top > 0) {
                indent_top--;
                qpush(DEDENT, NULL);
            }
            /* if any tokens are queued, return the next one */
            if (qpop(&tok, &txt)) {
                if (txt) { yylval.s = txt; } else { yylval.s = NULL; }
                return tok;
            }
            return 0; /* actual EOF */
        }

.    { /* ignore other single chars */ }

%%
