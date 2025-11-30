/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    VAR_ID = 258,                  /* VAR_ID  */
    LIT_STRING = 259,              /* LIT_STRING  */
    LIT_NUMBER = 260,              /* LIT_NUMBER  */
    LIT_BOOL = 261,                /* LIT_BOOL  */
    TOKEN_INDENT = 262,            /* TOKEN_INDENT  */
    TOKEN_DEDENT = 263,            /* TOKEN_DEDENT  */
    KW_SE = 264,                   /* KW_SE  */
    KW_SENAO = 265,                /* KW_SENAO  */
    KW_ENQUANTO = 266,             /* KW_ENQUANTO  */
    KW_TAMANHO = 267,              /* KW_TAMANHO  */
    OP_ASSIGN = 268,               /* OP_ASSIGN  */
    OP_APPEND = 269,               /* OP_APPEND  */
    OP_ARROW = 270,                /* OP_ARROW  */
    OP_EQ = 271,                   /* OP_EQ  */
    OP_NEQ = 272,                  /* OP_NEQ  */
    OP_GTE = 273,                  /* OP_GTE  */
    OP_LTE = 274,                  /* OP_LTE  */
    OP_LT = 275,                   /* OP_LT  */
    OP_GT = 276,                   /* OP_GT  */
    OP_LOG = 277,                  /* OP_LOG  */
    OP_QUEST = 278,                /* OP_QUEST  */
    OP_CONCL = 279,                /* OP_CONCL  */
    COLON = 280,                   /* COLON  */
    COMMA = 281,                   /* COMMA  */
    LBRACKET = 282,                /* LBRACKET  */
    RBRACKET = 283,                /* RBRACKET  */
    LPAREN = 284,                  /* LPAREN  */
    RPAREN = 285,                  /* RPAREN  */
    PLUS = 286,                    /* PLUS  */
    MINUS = 287,                   /* MINUS  */
    MULT = 288,                    /* MULT  */
    DIV = 289,                     /* DIV  */
    MOD = 290,                     /* MOD  */
    OP_AND = 291,                  /* OP_AND  */
    OP_OR = 292,                   /* OP_OR  */
    NEWLINE = 293                  /* NEWLINE  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 21 "parser.y"

    double dVal;
    bool bVal;
    std::string* sVal;
    Node* node;
    Expression* expr;
    Block* block;
    ListLiteral* listLit;

#line 112 "parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
