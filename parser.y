%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);

extern FILE *yyin;
%}

/* Tokens returned by lexer.l */
%token BCSMAIN
%token IF ELSE WHILE
%token INT BOOL
%token ID NUM
%token RELOP
%token ASSIGN PLUS MUL
%token LBRACE RBRACE LPAREN RPAREN SEMI
%token UNKNOWN

%%

program
    : BCSMAIN LBRACE declist stmtlist RBRACE
    ;

declist
    : declist decl
    | decl
    ;

decl
    : type ID SEMI
    ;

type
    : INT
    | BOOL
    ;

stmtlist
    : stmtlist SEMI stmt
    | stmt
    ;

stmt
    : ID ASSIGN aexpr
    | IF LPAREN expr RPAREN LBRACE stmtlist RBRACE ELSE LBRACE stmtlist RBRACE
    | WHILE LPAREN expr RPAREN LBRACE stmtlist RBRACE
    ;

expr
    : aexpr RELOP aexpr
    | aexpr
    ;

aexpr
    : aexpr PLUS term
    | term
    ;

term
    : term MUL factor
    | factor
    ;

factor
    : ID
    | NUM
    ;

%%

void yyerror(const char *s)
{
    fprintf(stderr, "Syntax Error\n");
}

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        fprintf(stderr, "Usage: %s <input-file>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");

    if (yyin == NULL)
    {
        perror("Error opening input file");
        return 1;
    }

    if (yyparse() == 0)
    {
        printf("Parsing Successful\n");
    }

    fclose(yyin);
    return 0;
}