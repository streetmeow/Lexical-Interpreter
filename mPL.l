%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mPL.h"
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
"int"		    { yylval.str = strdup(yytext); return INT;}
"float"	    	{ yylval.str = strdup(yytext); return FLOAT;}
">="	    	{ yylval.str = strdup(yytext); return GE;}
"<="	    	{ yylval.str = strdup(yytext); return LE;}
"=="	    	{ yylval.str = strdup(yytext); return EQ;}
"!="	    	{ yylval.str = strdup(yytext); return NE;}
"!"		    	{ yylval.str = strdup(yytext); return NOT; }
"mainprog"  	{ yylval.str = strdup(yytext); return MAINPROG;}
"function"  	{ yylval.str = strdup(yytext); return FUNCTION;}
"procedure"  	{ yylval.str = strdup(yytext); return PROCEDURE;}
"begin" 		{ yylval.str = strdup(yytext); return _BEGIN;}
"end"	    	{ yylval.str = strdup(yytext); return END;}
"if"		    { yylval.str = strdup(yytext); return IF;}
"then"	     	{ yylval.str = strdup(yytext); return THEN;}
"else"	     	{ yylval.str = strdup(yytext); return ELSE;}
"nop"	     	{ yylval.str = strdup(yytext); return NOP;}
"while"	    	{ yylval.str = strdup(yytext); return WHILE;}
"return"    	{ yylval.str = strdup(yytext); return RETURN;}
"print"	    	{ yylval.str = strdup(yytext); return PRINT;}
"in"            { yylval.str = strdup(yytext); return IN;}
"for"           { yylval.str = strdup(yytext); return FOR;}
"elif"          { yylval.str = strdup(yytext); return ELIF;}
"["		    	{ yylval.str = strdup(yytext); return LSBRACKET;}
"]"		     	{ yylval.str = strdup(yytext); return RSBRACKET;}

{Delimiter}		{ yylval.str = strdup(yytext); return yytext[0];}
{Identifier}	{ yylval.str = strdup(yytext); return ID;}
{Integer}	    { yylval.int_value = atoi(yytext); return INTEGERNUM;}
{Float}		    { yylval.float_value = atof(yytext); return FLOATNUM;}
{Whitespace}	;
{Comment}	;
.               yyerror("Undefined character");
%%

int yywrap(void)
{
    return 1;
}