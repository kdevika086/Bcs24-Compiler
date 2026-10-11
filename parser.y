%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

extern FILE *yyin;
extern int line_num;

FILE *tacFile;
int tempCount = 1;

char *newTemp(void)
{
    char buffer[20];
    snprintf(buffer, sizeof(buffer), "t%d", tempCount++);
    return strdup(buffer);
}

%}

%union 
{
    char *str;
}

/* Tokens returned by lexer.l */
%token BCSMAIN
%token IF ELSE WHILE
%token INT BOOL
%token <str> ID NUM
%token RELOP
%token ASSIGN PLUS MUL
%token LBRACE RBRACE LPAREN RPAREN SEMI
%token UNKNOWN

%type <str> aexpr term factor

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
    {
        fprintf(tacFile, "%s = %s\n", $1, $3);
    }
    | IF LPAREN expr RPAREN LBRACE stmtlist RBRACE ELSE LBRACE stmtlist RBRACE
    | WHILE LPAREN expr RPAREN LBRACE stmtlist RBRACE
    ;

expr
    : aexpr RELOP aexpr
    | aexpr
    ;

aexpr
    : aexpr PLUS term
    {
        $$ = newTemp();
        fprintf(tacFile, "%s = %s + %s\n", $$, $1, $3);
    }
    | term
    {
        $$ = $1;
    }
    ;

term
    : term MUL factor
    {
        $$ = newTemp();
        fprintf(tacFile, "%s = %s * %s\n", $$, $1, $3);
    }
    | factor
    {
        $$ = $1;
    }
    ;

factor
    : ID
    {
        $$ = $1;
    }
    | NUM
    {
        $$ = $1;
    }
    | LPAREN aexpr RPAREN
    {
        $$ = $2;
    }
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

    tacFile = fopen("tac.txt", "w");
    if (tacFile == NULL)
    {
        perror("Error opening TAC output file");
        fclose(yyin);
        return 1;
    }

    if (yyparse() == 0)
    {
        printf("Parsing Successful\n");
    }

    fclose(tacFile);
    fclose(yyin);
    return 0;
}