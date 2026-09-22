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
"int"                           { return INT; }
"bool"                          { return BOOL; }
"if"                            { return IF; }
"else"                          { return ELSE; }
"while"                         { return WHILE; }

"<"|">"|"<="|">="|"=="|"!="    { return RELOP; }

"+"                             { return PLUS; }
"*"                             { return MUL; }
"="                             { return ASSIGN; }

")"                             { return RPAREN; }
"("                             { return LPAREN; }
"}"                             { return RBRACE; }
"{"                             { return LBRACE; }
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