%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "PL.h"

    int yylex();
    void yyerror(const char *s);
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
    extern FILE * yyin;
    extern int yylineno;
%}

%union {
  char* str;
  int   int_value;
  double  float_value;
  var* varPtr;
  func* function;
  varEnum varType;
}

%token <str> ID
%token <int_value> INTEGERNUM
%token <float_value> FLOATNUM
%token INT FLOAT
%token MAINPROG FUNCTION PROCEDURE _BEGIN END IF THEN ELSE NOP WHILE RETURN PRINT IN
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
program: MAINPROG ID ';' declarations subprogram_declarations compound_statement 
       | error ';' declarations subprogram_declarations compound_statement 
       | MAINPROG ID ';' error subprogram_declarations compound_statement 
       | MAINPROG ID ';' declarations error compound_statement 
       | MAINPROG ID ';' declarations subprogram_declarations error
       ;
declarations: type identifier_list ';' declarations 
            | 
            ;
identifier_list: ID 
               | ID ';' identifier_list
               ;
type: standard_type {$$ = $1;} 
    | standard_type LSBRACKET INTEGERNUM RSBRACKET {if($1==intType) {$$ = arrayIntType;} else {$$ = arrayFloatType;}}
    ;
standard_type: INT {$$ = intType;} 
             | FLOAT {$$ = floatType;}
             ;
subprogram_declarations: subprogram_declaration subprogram_declarations 
                       | 
                       ;
subprogram_declaration: subprogram_head declarations compound_statement 
                      | error declarations compound_statement
                      ;
subprogram_head: FUNCTION ID //push down?
                  {
                    if(findFunction($2) != NULL) {yyerror("Already declared function error occured"); YYERROR;} 
                    else {func* temp = initFunction($2); addFunction(temp);}
                  }
                 arguments ':' standard_type ';' {curFunc->returnType = $5;} 
               | PROCEDURE ID arguments ';' {$$ = initFunction($2); $$->returnType = voidType; addFunction($$);}
               ;
arguments: '(' parameter_list ')' {$$ = $2;} 
         | 
         ;

parameter_list: identifier_list ':' type {addParam(curFunc, $3);}
              ;

compound_statement: _BEGIN statement_list END;

//statement: variable '=' expression ;

statement_list: statement 
			        | statement ';' statement_list
			        | error ';' statement_list
			        ;
              
statement: variable '=' expression
         | print_statement
         | procedure_statement
         | compound_statement
         | if_statement
         | while_statement
         | for_statement
         | RETURN expression
         | NOP
         ;
         
if_statement: IF expression ':' statement elif_statement
            | IF expression ':' statement elif_statement ELSE ':' expression
            ;
elif_statement: ELIF expression ':' statement elif_statement
              |
              ; 
while_statement: WHILE expression ':' statement
               | WHILE expression ':' statement ELSE ':' statement
               ;
for_statement: FOR expression IN expression ':' statement
             | FOR expression IN expression ':' statement ELSE ':' statement
             ;

variable: ID {$$ = $1;} ;

print_statement: PRINT {printf("\n");};

expression: simple_expression
          | simple_expression relop simple_expression;

simple_expression: term {$$ = $1;}
                 | term addop simple_expression;

term: factor {$$ = $1;} ;
    | factor multop factor 
    ;

factor: INTEGER_NUM {$$ = $1;}
	    | FLOAT_NUM {$$ = $1;}				
	    | variable
        { 
          var* v = searchVar($1);
          if(v != NULL)
          {
            switch(v->type) //typeCheck
            {
              case intType: $$ = getInt(v);
              break;
              case floatType: $$ = getFloat(v);
              break;
            }
          }
        }
	    | procedure_statement
	    | NOT factor  {$$ = $2;}	
	    | sign factor {$$ = $2;}	
	    ;

sign: '+' {$$ = '+';}
	  | '-' {$$ = '-';}
	  ;

relop: '>' {$$ = '>';}
	   | GE  {$$ = GE; }
	   | '<' {$$ = '<';}
	   | LE  {$$ = LE; }
	   | EQ  {$$ = EQ; }
	   | NE  {$$ = NE; }
	   ;

addop: '+' {$$ = '+';}
	   | '-' {$$ = '-';}
	   ;

multop: '*' {$$ = '*';}
	    | '/' {$$ = '/';}
	    ;

%%

int main(int argc, char ** argv)
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
  fprintf(stderr, "- %s at line: %d, near token: ", s, yylineno);
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
  function = (func*)malloc(sizeof(func));
  if(function == NULL) yyerror("Out of Memory");
  function->name = strdup(name);
  function->paramCount = 0;
  function->previous = NULL;
  return function;
}

void addParam(func* function, varEnum Param) {
  if (function->paramCount < 50) function->parameter[function->paramCount++] = Param;
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

func* findFunction (char* name) {
  func* temp = funcList;
  while(temp!=NULL) {
    if (strcmp(temp->name,name) == 0) return temp;
    else temp=temp->previous;
  }
  return NULL;
}
