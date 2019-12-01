%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    //#include "mPL.h"

    typedef enum VarEnum {
      intType,
      floatType,
      voidType,
      arrayIntType,
      arrayFloatType
    } varEnum;

    typedef struct Func {
      char* name;
      varEnum returnType;
      varEnum parameter[50];
      int paramCount;
      struct Func* previous;
    } func;

    typedef struct Var {
      varEnum type;
      char* name;
      int setCount;
      int scopeLevel;
      func* masterFunc;
      struct Var* previous;
      struct Var* next;
      union {
        int int_value;
        double float_value;
      };
    } var;

    int yylex();
    void yyerror(const char *s);
    func* initFunction(char* name);
    func* findFunction(char* name);
    void addFunction(func* function);
    void deleteFunc();
    void addParam(func* function, varEnum param);
    void print_tok();
    var* searchVar(char* _name);
    void setInt(var* varPtr,  int num);
    int getInt(var* varPtr);
    void setFloat(var* varPtr, double num);
    float getFloat(var* varPtr);
    bool checkFloat(float val);
    void yyerror_variable(const char *s, char* _name);


    int varCount = 0;
	  var* front = NULL;
    func* curFunc = NULL;
    func* funcList = NULL;
    varEnum parameter[50];
    int paramCount = 0;
	  int scopeLevel = 0;
    int errorCount = 0;
	  func* myFunc = NULL;
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
%token MAINPROG FUNCTION PROCEDURE _BEGIN END IF THEN ELSE NOP WHILE RETURN PRINT IN FOR ELIF
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
            {
            if(searchVar($2) == NULL)
            {
                var * newVal = (var*)malloc(sizeof(var));
                newVal->name = $2;
                if (front == NULL) {
                  front = (var*)malloc(sizeof(var));
                  front->next = newVal;
                  front->name = "";
                }
                else {
                  var * curr = front;
                  while(curr->next != NULL)
                    curr = curr->next;
                  curr->next = newVal;
                }

                if($1==intType)
                {
                  newVal->type = intType;
                }else if($1==floatType)
                {
                  newVal->type = floatType;
                }else if($1==arrayIntType)
                {
                  newVal->type = arrayIntType;
                }else if($1== arrayFloatType)
                {
                  newVal->type = arrayFloatType;
                }
                else
                {
                 free(newVal);
                 yyerror("Undefined type");
                }
            } else {
              yyerror("Already Exist");
            }
          } 
          | ;

identifier_list: ID
               | ID ',' identifier_list
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

subprogram_head: FUNCTION ID arguments ':' standard_type ';'
                  {
                    if(findFunction($2) != NULL) {yyerror("Already declared function error occured"); YYERROR;}
                    else {func* temp = initFunction($2); addFunction(temp);}
                    curFunc->returnType = $5;
                  }
               | PROCEDURE ID arguments ';' {$$ = initFunction($2); $$->returnType = voidType; addFunction($$);}
               ;

parameter_list: identifier_list ':' type {addParam(curFunc, $3);}
              | identifier_list ':' type {addParam(curFunc, $3);} ';' parameter_list
              ;

arguments: '(' parameter_list ')' {$$ = $2;}
         |
         ;

compound_statement: _BEGIN statement_list END
                  ;

statement_list: statement
			        | statement statement_list
			        | error statement_list
			        ;

statement: variable '=' expression
         {
           var* v;
           v = searchVar($1);
           if (v != NULL) {
             if (v->type == intType) {
               if (checkFloat($3)==false) {
                 setInt(v,(int)$3);
               }
               else {
                 yyerror_variable("Variable Type error", v->name);
               }
             }
             else if(v->type == floatType) {
               setFloat(v,$3);
             } else {
               yyerror_variable("Array type not defined",v->name);
             }
           }
           else {
             yyerror("undefined variable");
           }
         }
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

//print_statement: PRINT {printf("\n");};
print_statement: PRINT
               {
                 printf("\n");
               }
               | PRINT '(' expression ')'
               {
                 printf("%f\n", $3);
               }
               | PRINT '(' variable ')'
               {
                 var* temp;
                 if ((temp = searchVar($3)) != NULL) {
                   if (temp->type == intType) {
                     printf("%d\n", temp->int_value);
                   } else if (temp->type == floatType) {
                     printf("%f\n", temp->float_value);
                   }
                 } else {
                   yyerror("undefined variable");
                 }
               } ;

variable: ID {$$ = $1;}

        | ID LSBRACKET expression RSBRACKET
        ;

procedure_statement: ID '(' actual_parameter_expression ')'
                  ;

actual_parameter_expression: expression_list
                           |
                           ;

expression_list: expression
               | expression ',' expression_list
               ;

expression: simple_expression
          | simple_expression relop simple_expression
          {
            if ($2 == '<') {
              $$ = $1 < $3;
            }
            else if ($2 == '<=') {
              $$ = $1 <= $3;
            }
            else if ($2 == '>') {
              $$ = $1 > $3;
            }
            else if ($2 == '>=') {
              $$ = $1 >= $3;
            }
            else if ($2 == '==') {
              $$ = $1 == $3;
            }
            else if ($2 == '!=') {
              $$ = $1 != $3;
            }
          }
          ;

simple_expression: term {$$ = $1;}
                 | term addop simple_expression
                 {
                   if($2 == '+')
                     $$ = $1 + $3;
                   else
                     $$ = $1 - $3;
                 }
                 | '(' simple_expression ')'
                 {
                   $$ = $2;
                 }
                 ;

term: factor {$$ = $1;} ;
    | factor multop term
    {
      if($2 == '*') {
        $$ = $1 * $3;
      } else {
        if ($3 == 0)
          yyerror("zero division error\n");
        else
          $$ = $1 / $3;
      }
    }
    | '(' term ')'
    {
      $$ = $2;
    }
    ;

factor: INTEGERNUM {$$ = $1;}
	    | FLOATNUM {$$ = $1;}
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
var* searchVar(char* _name)
{
	var* curr = front;
	char isOutofScopeRange = 0;
	while(curr != NULL)
	{
		if(!(strcmp(curr->name,_name)) )
		{
			 if(curr->masterFunc == NULL)         return curr;
			 if(curr->masterFunc == myFunc)  return curr;
			 else isOutofScopeRange = 1;
		}
		curr = curr->next;
	}

	if(isOutofScopeRange)yyerror_variable("Out of scope range" , _name);
  else return NULL;
}

void setInt(var* varPtr,  int num)
{
	varPtr->setCount++;
	varPtr->int_value=num;
}

int getInt(var* varPtr)
{
	if(varPtr->setCount)
	{
	return varPtr->int_value;
	}
	else
	{
	yyerror_variable("Uninitialized variable" , varPtr->name);
	return 0;
	}
}

void setFloat(var* varPtr, double num)
{
	varPtr->setCount++;
	varPtr->float_value=num;
}

float getFloat(var* varPtr)
{
	if(varPtr->setCount)
	{
	return varPtr->float_value;
	}
	else
	{
		yyerror_variable("Uninitialized variable" , varPtr->name);

		return 0;
	}
}


void yyerror_variable(const char *s, char* _name)
{
	errorCount++;
	fprintf(stderr, "*** %s : %s at line: %d, near a Token: ", s,_name, yylineno);
	print_tok();
}

bool checkFloat(float val) {
  float ran;
  ran = val - (int)val;
  if (ran == 0.0f) return false; else return true;
}
