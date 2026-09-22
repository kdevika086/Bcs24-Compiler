%{
#include <stdio.h>
#include "parser.tab.h"

int line_num = 1;
%}

DIGIT       [0-9]
LETTER      [a-zA-Z]
ID          {LETTER}({LETTER}|{DIGIT})*
NUM         {DIGIT}+
WS          [ \t\r]+

%%

"BcsMain"                       { return BCSMAIN; }
"if"                            { return IF; }
"else"                          { return ELSE; }
"while"                         { return WHILE; }
"int"                           { return INT; }
"bool"                          { return BOOL; }

"<="|">="|"=="|"!="|"<"|">"    { return RELOP; }

"="                             { return ASSIGN; }
"+"                             { return PLUS; }
"*"                             { return TIMES; }

"{"                             { return LBRACE; }
"}"                             { return RBRACE; }
"("                             { return LPAREN; }
")"                             { return RPAREN; }
";"                             { return SEMI; }

{NUM}                           { return NUM; }
{ID}                            { return ID; }

\n                              { line_num++; }
{WS}                            { }

.                               {
                                    fprintf(stderr,
                                            "Lexical Error: unexpected character '%s' on line %d\n",
                                            yytext, line_num);
                                    return UNKNOWN;
                                }

%%

int yywrap(void)
{
    return 1;
}