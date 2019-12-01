%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdbool.h>
    //#include "mPL.h"

    typedef enum VarEnum {
      intType,
      floatType,
      voidType,
      arrayIntType,
      arrayFloatType,
      undefinedType,
    } varEnum;

    typedef struct Func {
      char* name;
      varEnum returnType;
      varEnum parameter[50];
      int paramCount;
      struct Func* prev;
    } func;

    typedef struct Var {
      varEnum type;
      char* name;
      int setCount;
      int scopeLevel;
      func* masterFunc;
      struct Var* prev;
      struct Var* next;
      union {
        int int_value;
        double float_value;
      };
    } var;

    int   yylex();
    void  yyerror(const char *s);
    func* initFunction(char* name);
    func* findFunction(char* name);
    void  deleteFunc();
    void  print_tok();

    var*  searchVar(char* _name);
    int   IsVarExist(char* _name);
    void  initVar(char* name, varEnum type);

    void  setInt(var* varPtr,  int num);
    int   getInt(var* varPtr);
    void  setFloat(var* varPtr, double num);
    float getFloat(var* varPtr);
    bool  isFloat(float val);
    void  yyerror_variable(const char *s, char* _name);


    int     varCount   = 0;

	  var*    front      = NULL;
	  var*    back       = NULL;

    func*   curFunc    = NULL;
    func*   funcTop   = NULL;
	  func*   myFunc     = NULL;

    int     paramCount = 0;
	  int     scopeLevel = 0;
    int     errorCount = 0;

    varEnum parameter[50];

    extern FILE * yyin;
    extern int yylineno;
%}

%union {
  char*   str;
  int     int_value;
  double  float_value;
  var*    varPtr;
  func*   function;
  varEnum varType;
}

%token <str> ID
%token <int_value> INTEGERNUM
%token <float_value> FLOATNUM
%token INT FLOAT
%token MAINPROG FUNCTION PROCEDURE _BEGIN END IF ELIF ELSE NOP WHILE RETURN PRINT IN FOR 
%token GE LE EQ NEQ NOT // >= <= == != !
%token LSBRACKET RSBRACKET // [ ]

%start program
%left GE LE EQ NEQ '>' '<' '+' '-' '*' '/'
%right '='
%nonassoc UMINUS

%type <function> subprogram_head
%type <varType> type standard_type parameter_list arguments
%type <float_value> term factor simple_expression expression sign relop addop multop actual_parameter_expression expression_list
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
                if(IsVarExist($2)==0)
                {
                    if($1==intType)               initVar($2,intType); 
                    else if($1==floatType)        initVar($2,floatType); 
                    else if($1 ==arrayIntType)    initVar($2,arrayIntType);
                    else if($1 == arrayFloatType) initVar($2,arrayFloatType);                  
                    else yyerror("Undefined type"); 	 
                }
              }
            | 
            ;

identifier_list: ID
               | ID ',' identifier_list
               ;

type: standard_type 
      {
        if($1==intType) {$$ = intType;} 
        else if($1==intType) {$$ = floatType;}
        else if($1==undefinedType) {yyerror("Undefined type");}
      }
    | standard_type LSBRACKET INTEGERNUM RSBRACKET {if($1==intType) {$$ = arrayIntType;} else {$$ = arrayFloatType;}}
    ;

standard_type: INT   {$$ = intType;}
             | FLOAT {$$ = floatType;}
             | error {$$ = undefinedType}
             ;

subprogram_declarations: subprogram_declaration subprogram_declarations
                       |
                       ;

subprogram_declaration: subprogram_head declarations compound_statement
                      | error declarations compound_statement
                      ;

subprogram_head: FUNCTION ID 
               { 
                 if(findFunction($2) != NULL) {yyerror("Already declared function error occured");}
                 else {$$ = initFunction($2);} 
               } 
                 arguments ':' standard_type ';' {curFunc->returnType = $6;}
               | PROCEDURE ID arguments ';' {$$ = initFunction($2); $$->returnType = voidType;}
               |
               ;

arguments: '(' parameter_list ')' {$$ = $2;}
         |
         ;

parameter_list: identifier_list ':' type 
              | identifier_list ':' type  ';' parameter_list 
              ;

compound_statement: _BEGIN statement_list END
                  ;

statement_list: statement
              | statement ';' statement_list
			        | error ';' statement_list
              |
			        ;

statement: variable '=' expression
         {
           var* v;
           v = searchVar($1);
           if (v != NULL) {
             if (v->type == intType) {
               if (isFloat($3)==false) {
                 setInt(v,(int)$3);
               }
               else {
                 yyerror_variable("Variable type error", v->name);
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

elif_statement: ELIF expression ':' statement elif_statement
              |
              ;

if_statement: IF expression ':' statement elif_statement
            | IF expression ':' statement elif_statement ELSE ':' expression
            ;


while_statement: WHILE expression ':' statement
               | WHILE expression ':' statement ELSE ':' statement
               ;

for_statement: FOR expression IN expression ':' statement
             | FOR expression IN expression ':' statement ELSE ':' statement
             ;

print_statement: PRINT
                 {
                    printf("\n");
                 }
               | PRINT '(' expression ')'
                 {
                   printf("Printing : \n", $3);
                 }
               | PRINT '(' variable ')'
                 {
                  var* temp;
                  if ((temp = searchVar($3)) != NULL) 
                  {
                    if (temp->type == intType) 
                    {
                        printf("Printing int value : %d\n", temp->int_value);
                    } 
                    else if (temp->type == floatType) 
                    {
                        printf("Printing float value : %f\n", temp->float_value);
                    }
                  } 
                  else 
                  {
                      yyerror("undefined variable\n");
                  }
                 } 
               ;

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
             if ($2 == '<') 
             {
               $$ = $1 < $3;
             }
             else if ($2 == LE) 
             {
               $$ = $1 <= $3;
             }
             else if ($2 == '>') 
             {
               $$ = $1 > $3;
             }
             else if ($2 == GE) 
             {
               $$ = $1 >= $3;
             }
             else if ($2 == EQ) 
             {
               $$ = $1 == $3;
             }
             else if ($2 == NEQ) 
             {
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
	   | NEQ  {$$ = NEQ; }
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
func* initFunction(char* name) 
{
  func* function;
  function = (func*)malloc(sizeof(func));
  if(function == NULL) yyerror("Out of Memory");
  function->name = strdup(name);
  function->paramCount = 0;
  function->prev = NULL;
  function->prev = curFunc;
  curFunc = function;
  function->prev = funcTop;
  funcTop = function;
  myFunc = function;
  return function;
}
func* findFunction (char* name) 
{
  func* temp = funcTop;
  while(temp!=NULL) {
    if (strcmp(temp->name,name) == 0) return temp;
    else temp=temp->prev;
  }
  return NULL;
}
void deleteFunc() 
{
  myFunc = NULL;
  if(curFunc != NULL) {
    curFunc= curFunc->prev;
  }
}
void print_tok() 
{
  switch (yychar) {
    case INTEGERNUM: fprintf(stderr, "(%d)\n", yylval); break;
    case FLOATNUM: fprintf(stderr, "(%f)\n", yylval); break;
    default: fprintf(stderr, "(%s)\n", yylval); break;
  }
}
var* searchVar(char* _name)
{
	var* current = front;
	bool isOutRange = 0;
	while(current != NULL)
	{
		if(!(strcmp(current->name,_name)) )
		{
			 if(current->masterFunc == NULL || current->masterFunc == myFunc)    return current;
			 else isOutRange = 1;
		}
		current = current->next;
	}

	if(isOutRange)yyerror_variable("Out of scope range" , _name);
  else return NULL;
}
int IsVarExist(char* _name)
{
	var* current = front;
	
	while(current != NULL)
	{	
		if((strcmp(current->name,_name))==0)
		{
			if(current->masterFunc == NULL) 
			{
				yyerror_variable("Already Exists Variable" , _name);
				return 1;
			}
				
			else if(current->masterFunc == myFunc)
			{
				yyerror_variable("Already Exists Variable" , _name);
			 	return 1;
			}
			 else if(current->masterFunc != myFunc)
				return 0;
		}
		current = current->next; 
	}
	return 0;
}
void initVar(char* name, varEnum type)
{
	var *varPtr;
    if ((varPtr = malloc(sizeof(var))) == NULL)
    yyerror("out of memory");
    
	varPtr->setCount=0;
	varPtr->name=strdup(name);
	varPtr->masterFunc = myFunc;
	varPtr->type=type;
	varPtr->scopeLevel = scopeLevel; 
	varPtr->prev=NULL;
	varPtr->next=NULL;

  
	if(front == NULL && back ==NULL)
  {
    front = varPtr;
    back  = varPtr;
  }
	else
	{
		back->next = varPtr;
		back = varPtr;
	}
  printf("successfully added variable : %s\n",varPtr->name);
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
bool isFloat(float val) 
{
  float ran;
  ran = val - (int)val;
  if (ran == 0.0f) return false; 
  else return true;
}
void yyerror_variable(const char *s, char* _name)
{
	errorCount++;
	fprintf(stderr, "*** %s : %s at line: %d, near a Token: ", s,_name, yylineno);
	print_tok();
}