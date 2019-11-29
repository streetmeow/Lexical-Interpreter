%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "PL.h"

    func* initFunction(char* name);
    func* findFunction(char* name);
    void addFunction(func* function);
    void deleteFunc();
    void addParam(func* function, varEnum param);

    void print_tok();

    func* curFunc = NULL;
    func* funcList = NULL;
    varEnum parameter[50];
    int paramCount = 0;
    func* myFunc = NULL;
    int errorCount = 0;
%}

%token <str> ID
%token <int_value> INTEGERNUM
%token <float_value> FLOATNUM
%token INT FLOAT
%token MAINPROG FUNCTION PROCEDURE BEGIN END IF THEN ELSE NOP WHILE RETURN PRINT IN
%token GE LE EQ NE NOT // >= <= == != !
%token LSBRACKET RSBRACKET // [ ]

%start program
%right '='
%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%type <function> subprogram_head
%type <varType> type standard_type parameter_list arguments
%type <float_value> term factor simple_expression expression sign relop addop multop
%type <str> variable identifier_list

%%
program: MAINPROG ID ';' declarations subprogram_declarations compound_statement | error ';' declarations subprogram_declarations compound_statement |
MAINPROG ID ';' error subprogram_declarations compound_statement | MAINPROG ID ';' declarations error compound_statement | MAINPROG ID ';' declarations subprogram_declarations error;

declarations: type identifier_list ';' declarations | ;
identifier_list: ID | ID ';' identifier_list;
type: standard_type {$$ = $1;} | standard_type LSBRACKET INTEGERNUM RSBRACKET {if($1==intType) {$$ = arrayIntType;} else {$$ = arrayFloatType;}};
standard_type: INT {$$ = intType;} | FLOAT {$$ = floatType;};
subprogram_declarations: subprogram_declaration subprogram_declarations | ;
subprogram_declaration: subprogram_head declarations compound_statement | error declarations compound_statement;
subprogram_head: FUNCTION ID {if(findFunction($2) != NULL) {yyerror("Already declared function error occured"); YYERROR;} else {func* temp = initFunction($2); addFunction(temp);}}
arguments ':' standard_type ';' {curFunc->returnType = $5;} | PROCEDURE ID arguments ';' {$$ = initFunction($2); $$->returnType = voidType; addFunction($$);}
arguments: '(' parameter_list ')' {$$ = $2;} | ;
%%

main(argc, argv)
int argc;
char** argv;
{
  FILE *file;
  file = fopen(argv[1],"r");
  if (argc > 1) {
    if(!file) {
      fprintf(stderr, "Open Failed");
      exit(1);
    }
    yyin = file;
  }
  else {
    printf("No Input File\n");
    exit(1);
  }
  yyparse();
  if (!errorCount) printf("No Error\n"); else printf("%d Error Made\n", errorCount);
  return 0;
}
void yyerror(const char *s) {
  errorCount++;
  fprintf(stderr, "- %s at line: %d, near token: ", s, yylineno)
  print_tok();
}
void yyerror(const char *s, char* name_) {
  errorCount++;
  fprintf(stderr, "- %s : %s at line: %d, near token: ", s, name_, yylineno);
  print_tok();
}

void print_tok() {
  switch (yychar) {
    case INTEGERNUM: fprintf(stderr, "(%d)\n", yylval); break;
    case FLOATNUM: fprintf(stderr, "(%f)\n", yylval); break;
    default: fprintf(stderr, "(%s)\n", yylval); break;
  }
}
func* initFunction(char* name) {
  func* function;
  if((function = malloc(sizeof(func))) == NULL) yyerror("Out of Memory");
  function->name = strdup(name);
  function->paramCount = 0;
  function->previous = NULL;
  return function;
}

void addParam(func* function, varEnum Param) {
  if (function-> = 50) function->parameter[function->paramCount++] = Param;
}

void addFunction (func* function) {
  function->previous = curFunc;
  curFunc = function;
  function->previous = funcList;
  funcList = function;
  myFunc = function;
}

void deleteFunc() {
  myFunc = NULL;
  if(curFunc != NULL) {
    curFunc= curFunc->previous;
  }
}

void findFunction (char* name) {
  func* temp = funcList;
  while(temp!=NULL) {
    if (strcmp(temp->name,name) == 0) return temp;
    else temp=temp->previous;
  }
  return NULL;
}
