%{
	#include <stdio.h>
	#include "parser.tab.h"
	int lines=1,process=0,loop=0,array=0;
%}
ALL_CHARS (.|\n)*
LIB ##PROCESS|##LOOP|##ARRAY
TYPE INTEGER|REAL|CHAR|STRING
NUMBER [0-9]+
LETTER [A−Za−z]
COMMENT \/\*{ALL_CHARS}\*\/
COMPARAISON SUP|EG|SUPE|DIFF|INFE|INF
ARITHMETIC :=|\-|\+|\*|\/
IDF [A-Z][0-9a-zA-Z]{0,9}
TAB_SIZE \[{NUMBER}\] 
STRING \".*\"
FORMAT_SIGN [%#&\|]
%%
{LIB} {
	return LIB;
}
VAR {return VAR;}
Programme {return PROG;}
READ {return READ;}
WRITE {return WRITE;}
EXECUT {return EXECUTE;}
IF {return IF;}
ELSE {return ELSE;}
END_IF {return END_IF ;}
While {return WHILE;} 
{COMPARAISON} {return COMP;}
{TAB_SIZE} {return SIZE ;}
{TYPE} {return TYPE; }
[0-9]+ {printf("%s ",yytext);}
CONST {return CONST;}
{IDF} {return IDF;}
{ARITHMETIC} {return OP;}
{FORMAT_SIGN} {return FORMAT_SIGN;}
"//" {return SEP;}
{STRING} {return STRING;}
\( {return OPENING_PAR ;}
\) {return CLOSING_PAR;}
\{ {return OPENING_BRA;}
\} {return CLOSING_BRA;} 
\n|\r {lines++;}
\$ {return END;}
{COMMENT} {return COMMENT;}
[ \t] {}
. {printf("%s: lexical error in line %d\n", yytext, lines);break;} 
