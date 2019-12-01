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
"int"		    { printf("%s\n",yytext); yylval.str = strdup(yytext); return INT;            }
"float"	    	{ printf("%s\n",yytext); yylval.str = strdup(yytext); return FLOAT;          }
">="	    	{ printf("%s\n",yytext); yylval.str = strdup(yytext); return GE;             }
"<="	    	{ printf("%s\n",yytext); yylval.str = strdup(yytext); return LE;             }
"=="	    	{ printf("%s\n",yytext); yylval.str = strdup(yytext); return EQ;             }
"!="	    	{ printf("%s\n",yytext); yylval.str = strdup(yytext); return NE;             }
"!"		    	{ printf("%s\n",yytext); yylval.str = strdup(yytext); return NOT;            }      
"mainprog"  	{ printf("%s\n",yytext); yylval.str = strdup(yytext); return MAINPROG;       }
"function"  	{ printf("%s\n",yytext); yylval.str = strdup(yytext); return FUNCTION;       }
"procedure"  	{ printf("%s\n",yytext); yylval.str = strdup(yytext); return PROCEDURE;      }
"begin" 		{ printf("%s\n",yytext); yylval.str = strdup(yytext); return _BEGIN;         }
"end"	    	{ printf("%s\n",yytext); yylval.str = strdup(yytext); return END;            }
"if"		    { printf("%s\n",yytext); yylval.str = strdup(yytext); return IF;             }
"then"	     	{ printf("%s\n",yytext); yylval.str = strdup(yytext); return THEN;           }
"else"	     	{ printf("%s\n",yytext); yylval.str = strdup(yytext); return ELSE;           }
"nop"	     	{ printf("%s\n",yytext); yylval.str = strdup(yytext); return NOP;            }
"while"	    	{ printf("%s\n",yytext); yylval.str = strdup(yytext); return WHILE;          }
"return"    	{ printf("%s\n",yytext); yylval.str = strdup(yytext); return RETURN;         }
"print"	    	{ printf("%s\n",yytext); yylval.str = strdup(yytext); return PRINT;          }
"in"            { printf("%s\n",yytext); yylval.str = strdup(yytext); return IN;             }
"for"           { printf("%s\n",yytext); yylval.str = strdup(yytext); return FOR;            }
"elif"          { printf("%s\n",yytext); yylval.str = strdup(yytext); return ELIF;           }
"["		    	{ printf("%s\n",yytext); yylval.str = strdup(yytext); return LSBRACKET;      }
"]"		     	{ printf("%s\n",yytext); yylval.str = strdup(yytext); return RSBRACKET;      }

{Delimiter}		{ printf("%s\n",yytext); yylval.str = strdup(yytext); return yytext[0];      }
{Identifier}	{ printf("%s\n",yytext); yylval.str = strdup(yytext); return ID;             }
{Integer}	    { printf("%s\n",yytext); yylval.int_value = atoi(yytext); return INTEGERNUM; }
{Float}		    { printf("%s\n",yytext); yylval.float_value = atof(yytext); return FLOATNUM; }
{Whitespace}	;
{Comment}	    ;
.               yyerror("Undefined character");
%%

int yywrap(void)
{
    return 1;
}