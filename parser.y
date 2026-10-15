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

int semanticError = 0;
int syntaxError = 0;

enum { TYPE_INT, TYPE_BOOL, TYPE_INVALID };

typedef struct Symbol
{
    char *name;
    int type;
} Symbol;

typedef struct ExprInfo
{
    char *place;
    int type;
} ExprInfo;

#define MAX_SYMBOLS 500

Symbol symbolTable[MAX_SYMBOLS];
int symbolCount = 0;

int lookupSymbol(const char *name)
{
    int i;
    for (i = 0; i < symbolCount; i++)
    {
        if (strcmp(symbolTable[i].name, name) == 0)
            return i;
    }
    return -1;
}

void declareSymbol(char *name, int type)
{
    if (lookupSymbol(name) != -1)
    {
        fprintf(stderr,"Semantic Error: '%s' is already declared\n", name);
        semanticError = 1;
        return;
    }
    if (symbolCount >= MAX_SYMBOLS)
    {
        fprintf(stderr, "Semantic Error: Symbol table is full\n");
        semanticError = 1;
        return;
    }
    symbolTable[symbolCount].name = strdup(name);
    symbolTable[symbolCount].type = type;
    symbolCount++;
}

int getSymbolType(const char *name)
{
    int index = lookupSymbol(name);
    if (index == -1)
    {
        fprintf(stderr,"Semantic Error: '%s' is not declared\n", name);
        semanticError = 1;
        return TYPE_INVALID;
    }
    return symbolTable[index].type;
}

ExprInfo *makeExpr(const char *place, int type)
{
    ExprInfo *expr = malloc(sizeof(ExprInfo));
    if (expr == NULL)
    {
        perror("Memory allocation failed");
        exit(EXIT_FAILURE);
    }
    expr->place = strdup(place);
    if (expr->place == NULL)
    {
        perror("Memory allocation failed");
        exit(EXIT_FAILURE);
    }
    expr->type = type;
    return expr;
}

char *newTemp(void)
{
    char buffer[20];
    snprintf(buffer, sizeof(buffer), "t%d", tempCount++);
    return strdup(buffer);
}

%}

%code requires 
{
    typedef struct ExprInfo ExprInfo;
}

%union 
{
    char *str;
    int type;
    ExprInfo *expr;
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

%type <type> type
%type <expr> aexpr term factor

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
    {
        declareSymbol($2, $1);
    }
    ;

type
    : INT
    {
        $$ = TYPE_INT;
    }
    | BOOL
    {
        $$ = TYPE_BOOL;
    }
    ;

stmtlist
    : stmtlist stmt
    | stmtlist SEMI
    | stmt
    ;

stmt
    : ID ASSIGN aexpr
    {
        int lhsType = getSymbolType($1);
        if (lhsType != TYPE_INVALID &&
            $3->type != TYPE_INVALID &&
            lhsType != $3->type)
        {
            fprintf(stderr,
                "Semantic Error: Type mismatch in assignment to '%s'\n",
                $1);
            semanticError = 1;
        }
        if (!semanticError &&
            lhsType != TYPE_INVALID &&
            $3->type != TYPE_INVALID)
        {
            fprintf(tacFile, "%s = %s\n", $1, $3->place);
        }
    }
    ;

expr
    : aexpr RELOP aexpr
    | aexpr
    ;

aexpr
    : aexpr PLUS term
    {
        if ($1->type != TYPE_INT ||
            $3->type != TYPE_INT)
        {
            fprintf(stderr,
                "Semantic Error: '+' requires int operands\n");
            semanticError = 1;
            $$ = makeExpr("", TYPE_INVALID);
        }
        else
        {
            char *temp = newTemp();
            $$ = makeExpr(temp, TYPE_INT);

            if (!semanticError)
            {
                fprintf(tacFile, "%s = %s + %s\n",
                    temp, $1->place, $3->place);
            }
        }
    }
| term
    {
        $$ = $1;
    }
    ;

term
    : term MUL factor
    {
        if ($1->type != TYPE_INT ||
            $3->type != TYPE_INT)
        {
            fprintf(stderr,
                "Semantic Error: '*' requires int operands\n");
            semanticError = 1;
            $$ = makeExpr("", TYPE_INVALID);
        }
        else
        {
            char *temp = newTemp();
            $$ = makeExpr(temp, TYPE_INT);

            if (!semanticError)
            {
                fprintf(tacFile, "%s = %s * %s\n",
                    temp, $1->place, $3->place);
            }
        }
    }
    | factor
    {
        $$ = $1;
    }
    ;

factor
    : ID
    {
        int varType = getSymbolType($1);
        $$ = makeExpr($1, varType);
    }
    | NUM
    {
        $$ = makeExpr($1, TYPE_INT);
    }
    | LPAREN aexpr RPAREN
    {
        $$ = $2;
    }
    ;
%%

void yyerror(const char *s)
{
    (void)s;
    fprintf(stderr, "Syntax Error\n");
    syntaxError = 1;
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

    int parseResult = yyparse();

    fclose(tacFile);
    fclose(yyin);

    if (parseResult == 0 && !semanticError && !syntaxError)
    {
        printf("Parsing Successful\n");
        return 0;
    }

    remove("tac.txt");
    printf("Compilation failed\n");
    return 1;
}