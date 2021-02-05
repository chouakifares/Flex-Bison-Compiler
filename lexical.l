%{
	int lines=0,process=0,loop=0,array=0;
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
	if(!strcmp(yytext,"##PROCESS")) process = 1;
	if(!strcmp(yytext,"##LOOP")) loop = 1;
	if(!strcmp(yytext,"##ARRAY")) array = 1;
}
READ {printf("READ");}
WRITE {printf("WRITE");}
EXECUT {printf("EXECUTE \n");}
IF {printf("IF \n");}
ELSE {printf("ELSE \n");}
END_IF {printf("END_IF \n");}
While {printf("WHILE \n");} 
{COMPARAISON} {printf("OPERATOR_2 ");}
{TAB_SIZE} {printf("SIZE ");}
{TYPE} {printf("TYPE ");}
[0-9]+ {printf("%s ",yytext);}
CONST {printf("CONST ");}
{IDF} {printf("IDF ");}
{ARITHMETIC} {printf("OPERATOR_1 ");}
{FORMAT_SIGN} {printf("FORMAT_SIGN ");}
"//" {printf("SEP ");}
{STRING} {printf("STRING ");}
\( {printf("Opening parenthesis (");}
\) {printf(") Closing parenthesis \n");}
\{ {printf("Opening bracket {\n");}
\} {printf("} Closing bracket \n");} 
\n {lines++;}
\$ {printf(" end\n");}
{COMMENT} {printf("COMMENT ");}
[ \t] {}
. {printf("%s: lexical error in line %d\n", yytext, lines);break;} 
%%
void main(int argc, char** argv){
	if(argc>1) yyin = fopen(argv[1],"r");
	yylex();
	printf("process:%d,loop:%d, array:%d,lines: %d \n",process,loop,array,lines);
}
