/*CHOUAKI FARES 181831013081*/
/*DEHRI FAYCAL */
%{
	#include "parser.tab.h"
    #include "Symbol_table.h"   
	int yyparse();
	extern int type;
	extern int lines,cols;
	extern YYSTYPE yylval;
%}
/*matches all characters (used to match sequences of gibberish in a comment)*/
ALL_CHARS (.|\n)*
/*Libraries (PROCESS, LOOP , ARRAY)*/
LIB ##PROCESS|##LOOP|##ARRAY

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
/* max length 10 chars*/
IDF [A-Z][0-9a-zA-Z]*
/*matches a string betwwen two double quotes*/
STRING \"(\\.|[^"\\])*\"
/*matches a single character between to simple quotes*/
CHAR \'.\'
/*matches a format sign used for IO*/
FORMAT_SIGN [;%?&]
%%
{LIB} {
	cols += strlen(yytext);
	yylval.str = strdup(yytext);
	search(yytext,"keyword","",0,1);
	return LIB;
}
0 {
	cols += 1;
	yylval.entier = atoi(yytext);
	return ZERO;
}
VAR {
	cols += strlen(yytext);
	search(yytext,"keyword","",0,1);
	return VAR;
}
= {
	cols += strlen(yytext);
	search(yytext,"separator","",0,2);
	return EQUAL;
}
:= {
	cols += strlen(yytext);
	search(yytext,"separator","",0,2);
	return ASSIGN_OP;
}
:: {
	cols += strlen(yytext);
	search(yytext,"separator","",0,2);
	return DOUBLE_PERIOD;
}
\| {
	cols += strlen(yytext);
	search(yytext,"separator","",0,2);
	return PIPE;
}
@ {
	cols += strlen(yytext);
	search(yytext,"separator","",0,2);
	return AT;
}
Programme {
	cols += strlen(yytext);
	search(yytext,"keyword","",0,1);
	return PROGRAMME;
}
READ {
	cols += strlen(yytext);
	search(yytext,"keyword","",0,1);
	return READ;
}
WRITE {
	cols += strlen(yytext);
	search(yytext,"keyword","",0,1);
	return WRITE;
}
EXECUT {
	cols += strlen(yytext);
	search(yytext,"keyword","",0,1);
	return EXECUTE;
}
IF {
	cols += strlen(yytext);
	search(yytext,"keyword","",0,1);
	return IF;
}
ELSE {
	cols += strlen(yytext);
	search(yytext,"keyword","",0,1);
	return ELSE;
}
END_IF {
	cols += strlen(yytext);
	search(yytext,"keyword","",0,1);
	return END_IF ;
}
While {
	cols += strlen(yytext);
	search(yytext,"keyword","",0,1);
	return WHILE;
} 
CONST {
	cols += strlen(yytext);
	search(yytext,"keyword","",0,1);
	return CONST;
}
"//" {
	cols += strlen(yytext);
	search(yytext,"separator","",0,2);
	return SEP;
}
\[ {
	cols += strlen(yytext);
	search(yytext,"separator","",0,2);
	return OPENING_CROCHET ;
}

\] {
	cols += strlen(yytext);
	search(yytext,"separator","",0,2);
	return CLOSING_CROCHET ;
}
\( { 
	cols += strlen(yytext);
	search(yytext,"separator","",0,2);
	return OPENING_PARENTHESIS ;
}
\) {
	cols += strlen(yytext);
	search(yytext,"separator","",0,2);
	return CLOSING_PARENTHESIS;
}
\{ {
	cols += strlen(yytext);
	search(yytext,"separator","",0,2);
	return OPENING_BRACKET;
}
\} {
	cols += strlen(yytext);
	search(yytext,"separator","",0,2);
	return CLOSING_BRACKET;
} 
\n|\r {lines++;cols = 1;}
\$ {
	cols += strlen(yytext);
	search(yytext,"separator","",0,2);
	return END;
}
\" {
	cols += strlen(yytext);
	search(yytext,"separator","",0,2);
	return DOUBLE_QUOTE;
}
\' {
	cols += strlen(yytext);
	search(yytext,"separator","",0,2);
	return QUOTE;
}
{COMPARAISON} {
	cols += strlen(yytext);
	search(yytext,"separator","",0,2);
	return COMP;
}
INTEGER {
	cols += strlen(yytext);
	yylval.str = strdup(yytext);
	search(yytext,"keyword","",0,1);
	return INTEGER;
}
REAL {
	cols += strlen(yytext);
	yylval.str = strdup(yytext);
	search(yytext,"keyword","",0,1);
	return REAL;
}
CHAR { 
	cols += strlen(yytext);
	yylval.str = strdup(yytext);
	search(yytext,"keyword","",0,1);
	return CAR;
}
STRING {
	cols += strlen(yytext);
	yylval.str = strdup(yytext);
	search(yytext,"keyword","",0,1);
	return STR;
}
{SIGNED_NUMBER} {
	cols += strlen(yytext);
	yylval.entier=atoi(yytext);
	search(yytext,"cst_integer","INTEGER",0,0);
	return NUMBER;
}
{FLOAT} {
	cols += strlen(yytext);
	yylval.reel=atof(yytext);
	search(yytext,"cst_real","REAL",0,0);
	return FLOAT;
}
{IDF} {
	cols += strlen(yytext);
	if(strlen(yytext)>10){
		printf("erreur lexical: identificateur ne doit pas depasser 10 caracteres");
		exit(1);
	}
	yylval.str=strdup(yytext);
	search(yytext,"IDF","",0,0);
	return IDF;
}
{LP_ARITHMETIC_OP} {
	cols += strlen(yytext);
	search(yytext,"separator","",0,2);
	return LPOP;
}
{HP_ARITHMETIC_OP} {
	cols += strlen(yytext);
	yylval.str=strdup(yytext);
	search(yytext,"separator","",0,2);
	return HPOP;
}
{FORMAT_SIGN} {
	cols += strlen(yytext);
	yylval.str = strdup(yytext);
	search(yytext,"separator","",0,2);
	return FORMAT_SIGN;
}
{STRING} {
	cols+= strlen(yytext);
	yylval.str = strdup(yytext);
	return STRING;
}
{CHAR} {
	cols += strlen(yytext);
	search(yytext,"cst_char","CHAR",strlen(yytext)-2,0);
	return CHAR;
}
{COMMENT} {cols+= strlen(yytext);}
[ \t] {cols += strlen(yytext);}
. {printf("\n%s: lexical error in line %d col %d\n", yytext, lines,cols);break;} 
%%
