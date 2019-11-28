%{
    #include <stdio.h>
    
%}

%token <str> ID
%token <int_value> INTEGERNUM
%token <float_value> FLOATNUM
%token INT FLOAT
%token MAINPROG FUNCTION PROCEDURE BEGIN END IF THEN ELSE NOP WHILE RETURN PRINT IN
%token GE LE EQ NE NOT // >= <= == != !
%token LBRACKET RBRACKET LSBRACKET RSBRACKET // ( ) [ ] 

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

%%

//main(argc, argv) //파일 읽어오기 
//yyparse(); 
//void yyerror(const char *s) {} 삽입예정 
//void yyerror(const char *s, char* name_) {} 삽입예정 
 
