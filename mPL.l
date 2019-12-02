%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mPL.h"
#include "mPL.tab.h"

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
"int"		    { printf("int        : %s\n",yytext); yylval.str = strdup(yytext); return INT;            }
"float"	    	{ printf("float      : %s\n",yytext); yylval.str = strdup(yytext); return FLOAT;          }
">="	    	{ printf(">=         : %s\n",yytext); yylval.str = strdup(yytext); return GE;             }
"<="	    	{ printf("<=         : %s\n",yytext); yylval.str = strdup(yytext); return LE;             }
"=="	    	{ printf("==         : %s\n",yytext); yylval.str = strdup(yytext); return EQ;             }
"!="	    	{ printf("!=         : %s\n",yytext); yylval.str = strdup(yytext); return NE;            }
"!"		    	{ printf("!          : %s\n",yytext); yylval.str = strdup(yytext); return NOT;            }      
"mainprog"  	{ printf("mainprog   : %s\n",yytext); yylval.str = strdup(yytext); return MAINPROG;       }
"function"  	{ printf("function   : %s\n",yytext); yylval.str = strdup(yytext); return FUNCTION;       }
"procedure"  	{ printf("procedure  : %s\n",yytext); yylval.str = strdup(yytext); return PROCEDURE;      }
"begin" 		{ printf("begin      : %s\n",yytext); yylval.str = strdup(yytext); return _BEGIN;         }
"end"	    	{ printf("end        : %s\n",yytext); yylval.str = strdup(yytext); return END;            }
"if"		    { printf("if         : %s\n",yytext); yylval.str = strdup(yytext); return IF;             }
"elif"          { printf("elif       : %s\n",yytext); yylval.str = strdup(yytext); return ELIF;           }
"else"	     	{ printf("else       : %s\n",yytext); yylval.str = strdup(yytext); return ELSE;           }
"nop"	     	{ printf("nop        : %s\n",yytext); yylval.str = strdup(yytext); return NOP;            }
"while"	    	{ printf("while      : %s\n",yytext); yylval.str = strdup(yytext); return WHILE;          }
"return"    	{ printf("return     : %s\n",yytext); yylval.str = strdup(yytext); return RETURN;         }
"print"	    	{ printf("print      : %s\n",yytext); yylval.str = strdup(yytext); return PRINT;          }
"in"            { printf("in         : %s\n",yytext); yylval.str = strdup(yytext); return IN;             }
"for"           { printf("for        : %s\n",yytext); yylval.str = strdup(yytext); return FOR;            }
"["		    	{ printf("[          : %s\n",yytext); yylval.str = strdup(yytext); return LSBRACKET;      }
"]"		     	{ printf("]          : %s\n",yytext); yylval.str = strdup(yytext); return RSBRACKET;      }

{Delimiter}		{ printf("Delimiter  : %s\n",yytext); yylval.str = strdup(yytext); return yytext[0];      }
{Identifier}	{ printf("Identifier : %s\n",yytext); yylval.str = strdup(yytext); return ID;             }
{Integer}	    { printf("Integer    : %s\n",yytext); yylval.int_value = atoi(yytext); return INTEGERNUM; }
{Float}		    { printf("Float      : %s\n",yytext); yylval.float_value = atof(yytext); return FLOATNUM; }
{Whitespace}	;
{Comment}	    ;
.               yyerror("Undefined character");
%%

int yywrap(void)
{
    return 1;
}