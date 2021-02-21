%{
	#include <stdio.h>
	#include "parser.tab.h"
	int lines=1,process=0,loop=0,array=0;
%}
/*matches all characters (used to match sequences of gibberish in a comment*/
ALL_CHARS (.|\n)*
/*Libraries (PROCESS, LOOP , ARRAY)*/
LIB ##PROCESS|##LOOP|##ARRAY
/*TYPES*/
TYPE INTEGER|REAL|CHAR|STRING
/*numbers (used to match signed numbers , tab sizes , and floating point numbers) */
NUMBER [0-9]+
/*matches signed numbers*/
SIGNED_NUMBER \-?{NUMBER}
/* floating point numbers*/
FLOAT {SIGNED_NUMBER}.{NUMBER}
/*Letters*/
LETTER [A−Za−z]
/*comments (doesn't work on multiline because of greedy match)*/
COMMENT \/\*{ALL_CHARS}\*\/
/* comparaison operators*/
COMPARAISON SUP|EG|SUPE|DIFF|INFE|INF
/* low priority arithmetic operators (+ -)*/
LP_ARITHMETIC_OP \-|\+ 
/* high priority arithmetic operators (* /)*/
HP_ARITHMETIC_OP \*|\/
/*Identifiers (starts with an uppercase letter followed by a a series of number or letter, */
/* max length 10 chars)*/
IDF [A-Z][0-9a-zA-Z]{0,9}
/*matches the size of the array*/
TAB_SIZE \[{NUMBER}\] 
/*matches a string betwwen two double quotes*/
STRING \"(\\.|[^"\\])*\"
/*matches a single character between to simple quotes*/
CHAR \'.\'
/*matches a format sign used for IO*/
FORMAT_SIGN [;%#&]
%%
{LIB} {
	return LIB;
}
VAR {return VAR;}
= {return EQUAL;}
:= {return ASSIGN_OP;}
:: {return DOUBLE_PERIOD;}
\| {return PIPE;}
@ {return AT;}
Programme {return PROGRAMME;}
READ {return READ;}
WRITE {return WRITE;}
EXECUT {return EXECUTE;}
IF {return IF;}
ELSE {return ELSE;}
END_IF {return END_IF ;}
While {return WHILE;} 
CONST {return CONST;}
"//" {return SEP;}
\( { return OPENING_PARENTHESIS ;}
\) {return CLOSING_PARENTHESIS;}
\{ {return OPENING_BRACKET;}
\} {return CLOSING_BRACKET;} 
\n|\r {lines++;}
\$ {return END;}
\" {printf("DOUBLE_QUOTE\t");return DOUBLE_QUOTE;}
\' {return QUOTE;}
{COMPARAISON} {return COMP;}
{TAB_SIZE} {return SIZE ;}
{TYPE} {return TYPE; }
{SIGNED_NUMBER} {return NUMBER;}
{FLOAT} {return FLOAT;}
{IDF} {printf("IDF\n"); return IDF;}
{LP_ARITHMETIC_OP} {return LPOP;}
{HP_ARITHMETIC_OP} {return HPOP;}
{FORMAT_SIGN} {return FORMAT_SIGN;}
{STRING} {printf("String");return STRING;}
{CHAR} {return CHAR;}
{COMMENT} {return COMMENT;}
[ \t] {}
. {printf("%s: lexical error in line %d\n", yytext, lines);break;} 
