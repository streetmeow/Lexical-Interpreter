%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "PL.h"
#include "y.tab.h"

extern void yyerror(const char *);
%}
%option yylineno


Comment (\/\/.*\n)|(\/\/.*\*\/)
Letter [a-zA-Z]
Digit [0-9]
Identifier {Letter}({Letter}|{Digit})*
Integer {Digit}+
Float {Integer}+\.{Integer}+
Delimiter [-()<>=+*/:;,.]
Whitespace [ \t\n]+

%%
"int"		    { return INT;}
"float"	    	{ return FLOAT;}
">="	    	{ return GE;}
"<="	    	{ return LE;}
"=="	    	{ return EQ;}
"!="	    	{ return NE;}
"!"		    	{ return NOT; }
"mainprog"  	{ return MAINPROG;}
"function"  	{ return FUNCTION;}
"procedure"  	{ return PROCEDURE;}
"begin" 		{ return _BEGIN;}
"end"	    	{ return END;}
"if"		    { return IF;}
"then"	     	{ return THEN;}
"else"	     	{ return ELSE;}
"nop"	     	{ return NOP;}
"while"	    	{ return WHILE;}
"return"    	{ return RETURN;}
"print"	    	{ return PRINT;}
"in"            { return IN; }
"["		    	{ return LSBRACKET;}
"]"		     	{ return RSBRACKET;}

{Delimiter}		{ return yytext[0];}
{Identifier}	{ return ID;}
{Integer}	    { return INTEGERNUM;}
{Float}		    { return FLOATNUM;}
{Whitespace}	;
{Comment}	;
.               yyerror("Undefined character");
%%

int yywrap(void)
{
    return 1;
}
