%{
int lines=0,process=0,loop=0,array=0;
%}
BIBLIOTHEQUE ##PROCESS|##LOOP|##ARRAY
%%
{BIBLIOTHEQUE} {
if(!strcmp(yytext,"##PROCESS")) process = 1;
if(!strcmp(yytext,"##LOOP")) loop = 1;
if(!strcmp(yytext,"##ARRAY")) array = 1;
}
\n {lines++;}
[ \t] {}
. {printf("%s: erreur lexical", yytext);} 
%%
void main(){
yylex();
printf("process:%d,loop:%d, array:%d,lines: %d \n",process,loop,array,lines);
}
