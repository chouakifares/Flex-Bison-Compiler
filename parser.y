%{
    #include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
    int lines = 1, cols =1;
    int yylex();
    // used to indetify  which type  
    int type;
    // used to count the number of refrences that are inside of one write statement 
    int idf_count = 0;
    int types_in_str[1024];
    //control libraries
    void yyerror(char *s);
    // boolean array used to know wether a library is imported  or not [0]: Process lib , [1] : loop library , [2]: array library
    int libs[3]={0,0,0};
    // used to know which types are contained inside one expression , [0]: integer , [1] : real , [2]: char, [3]: string
    int types_in_expression[4] = {0,0,0,0};
%}
%union {
    int     entier;
    char*   str;
    float reel;
}
%token 
    <str>LIB PROGRAMME VAR READ WRITE CLOSING_CROCHET <entier>ZERO OPENING_CROCHET EXECUTE IF ELSE END_IF 
    WHILE COMP SIZE <str>INTEGER <str>REAL <str>CAR <str>STR CONST <str>IDF OP <str>FORMAT_SIGN AT PIPE 
    SEP <str>STRING CHAR OPENING_PARENTHESIS CLOSING_PARENTHESIS 
    OPENING_BRACKET CLOSING_BRACKET COMMENT END <reel>FLOAT 
    ASSIGN_OP ARTHE DOUBLE_PERIOD <entier>NUMBER DOUBLE_QUOTE QUOTE
    EQUAL LPOP <str>HPOP
%%
CODE: 
    IMPORT PROGRAMME IDF OPENING_BRACKET DECLARATION_PART INSTRUCTION_PART CLOSING_BRACKET {
        printf("syntaxe correcte\n");
        YYACCEPT;
    }; 
IMPORT: 
    LIB{
        check_library(libs,$1,lines,cols);
    } IMPORT | ;
DECLARATION_PART: 
    VAR DECLARATION | ;

TYPE: 
    INTEGER{
        type = 1;
    }|
    REAL{
        type = 2;
    }|
    CAR{
        type = 3;
    }|
    STR{
        type = 4;
    };

DECLARATION: 
    TYPE DOUBLE_PERIOD VAR_LIST DECLARATION|
    CONST TYPE DOUBLE_PERIOD CONST_LIST DECLARATION| ;
VAR_LIST: 
    IDF SEP {
        char temp_type[10] , temp_code[6];
        get_type(temp_type);
        // initialize idf to 0 if no value is affected to it 
        check_double_declared_var($1);
        search($1,"VAR",temp_type,0,0);
    } VAR_LIST | //simple declaration with recurssion without assignement 
    IDF OPENING_CROCHET NUMBER CLOSING_CROCHET SEP VAR_LIST{
        check_included(libs,2,lines ,cols);
        char temp_type[10] , temp_code[6];
        get_type(temp_type);
        verify_array_size($3,lines,cols);
        // initialize idf to 0 if no value is affected to it 
        check_double_declared_var($1);
        search($1,"VAR",temp_type,$3,0);
    }| // array declaration with recurssion
    IDF EQUAL ARITHMETIC_EXPRESSION{
        char temp_type[10] , temp_code[6];
        get_type(temp_type);
        verify_type_compatibility(temp_type,"EXPRESSION",lines,cols);
        // initialize idf to 0 if no value is affected to it 
        check_double_declared_var($1);
        search($1,"VAR",temp_type,0,0);
    } SEP VAR_LIST| // simple int (or float) declaration with recurssion with assignement
    IDF EQUAL STRING SEP VAR_LIST{
        char temp_type[10] , temp_code[6];
        get_type(temp_type);
        verify_type_compatibility(temp_type,"STRING",lines,cols);
        // initialize idf to 0 if no value is affected to it 
        check_double_declared_var($1);
        search($1,"VAR",temp_type,strlen($3),0);
    }| // simple string declaration with recurssion with assignement
    IDF EQUAL CHAR SEP VAR_LIST{
        char temp_type[10] , temp_code[6];
        get_type(temp_type);
        verify_type_compatibility(temp_type,"CHAR",lines,cols);   
        // initialize idf to 0 if no value is affected to it 
        check_double_declared_var($1);
        search($1,"VAR",temp_type,(int)strlen($3),0);
    }| // simple char declaration with recurssion with assignement
    IDF EQUAL ARITHMETIC_EXPRESSION END{
        char temp_type[10] , temp_code[6];
        get_type(temp_type);
        // initialize idf to 0 if no value is affected to it 
        verify_type_compatibility(temp_type,"EXPRESSION",lines,cols);
        check_double_declared_var($1);
        search($1,"VAR",temp_type,0,0);
    }| // simple int (or float) declaration without recurssion with assignement
    IDF EQUAL STRING END{
        char temp_type[10] , temp_code[6];
        get_type(temp_type);
        verify_type_compatibility(temp_type,"STRING",lines,cols);
        // initialize idf to 0 if no value is affected to it 
        check_double_declared_var($1);
        search($1,"VAR",temp_type,strlen($3),0);
    }| // simple string declaration without recurssion with assignement
    IDF EQUAL CHAR END{
        char temp_type[10] , temp_code[6];
        get_type(temp_type);
        verify_type_compatibility(temp_type,"CHAR",lines,cols);   
        // initialize idf to 0 if no value is affected to it    
        check_double_declared_var($1);
        search($1,"VAR",temp_type,strlen($3),0);
    }| //simple declaration without recurssion with char assignement
    IDF END{
        char temp_type[10] , temp_code[6];
        get_type(temp_type);
        // initialize idf to 0 if no value is affected to it 
        check_double_declared_var($1);
        search($1,"VAR",temp_type,0,0);
    }| //simple declaration without recurssion without assignement
    IDF OPENING_CROCHET NUMBER CLOSING_CROCHET END{
        check_included(libs,2,lines ,cols);
        verify_array_size($3,lines,cols);
        char temp_type[10] , temp_code[6];
        get_type(temp_type);
        // initialize idf to 0 if no value is affected to it 
        int taille = $3;
        check_double_declared_var($1);
        search($1,"VAR",temp_type,$3,0);
    }/*array declaration without recurssion without assignement*/; 
CONST_LIST: 
    IDF EQUAL ARITHMETIC_EXPRESSION{
        char temp_type[10] , temp_code[6];
        get_type(temp_type);
        verify_type_compatibility(temp_type,"EXPRESSION",lines,cols);
        // initialize idf to 0 if no value is affected to it 
        check_double_declared_var($1);
        search($1,"CONST",temp_type,0,0);
    } SEP CONST_LIST| 
    IDF EQUAL STRING {
        char temp_type[10] , temp_code[6];
        get_type(temp_type);
        verify_type_compatibility(temp_type,"STRING",lines,cols);
        // initialize idf to 0 if no value is affected to it 
        check_double_declared_var($1);
        search($1,"CONST",temp_type,strlen($3),0);
    } SEP CONST_LIST|
    IDF EQUAL CHAR  SEP CONST_LIST{
        char temp_type[10] , temp_code[6];
        get_type(temp_type);
        verify_type_compatibility(temp_type,"CHAR",lines,cols);
        // initialize idf to 0 if no value is affected to it 
        check_double_declared_var($1);
        search($1,"CONST",temp_type,strlen($3),0);
    } |
    IDF EQUAL STRING {
        char temp_type[10] , temp_code[6];
        get_type(temp_type);
        verify_type_compatibility(temp_type,"STRING",lines,cols);
        // initialize idf to 0 if no value is affected to it 
        check_double_declared_var($1);
        search($1,"CONST",temp_type,strlen($3),0);
    } END|
    IDF EQUAL CHAR END{
        char temp_type[10] , temp_code[6];
        get_type(temp_type);
        verify_type_compatibility(temp_type,"CHAR",lines,cols);
        // initialize idf to 0 if no value is affected to it 
        check_double_declared_var($1);
        search($1,"CONST",temp_type,0,0);
    }| 
    IDF EQUAL ARITHMETIC_EXPRESSION{
        char temp_type[10] , temp_code[6];
        get_type(temp_type);
        // initialize idf to 0 if no value is affected to it 
        check_double_declared_var($1);
        verify_type_compatibility(temp_type,"EXPRESSION",lines,cols);
        search($1,"CONST",temp_type,0,0);
    } END;

ARITHMETIC_EXPRESSION:  
    /* LPOP : Low Priority OPerator*/ 
    OPENING_PARENTHESIS FLOAT LPOP ARITHMETIC_EXPRESSION CLOSING_PARENTHESIS{
        check_included(libs,0,lines ,cols);
    }|
    OPENING_PARENTHESIS NUMBER LPOP ARITHMETIC_EXPRESSION CLOSING_PARENTHESIS{
        check_included(libs,0,lines ,cols);
    }|
    OPENING_PARENTHESIS IDF LPOP ARITHMETIC_EXPRESSION CLOSING_PARENTHESIS{
        check_included(libs,0,lines ,cols);
        check_declared_var($2,lines, cols);
    }|
    FLOAT LPOP ARITHMETIC_EXPRESSION{
        check_included(libs,0,lines ,cols);
    }|
    NUMBER LPOP ARITHMETIC_EXPRESSION{
        check_included(libs,0,lines ,cols);
    }|
    IDF LPOP ARITHMETIC_EXPRESSION{
        check_included(libs,0,lines ,cols);
        check_declared_var($1,lines, cols);
    }|
    OPENING_PARENTHESIS FLOAT CLOSING_PARENTHESIS|
    OPENING_PARENTHESIS NUMBER CLOSING_PARENTHESIS|
    OPENING_PARENTHESIS IDF CLOSING_PARENTHESIS{
        check_declared_var($2,lines, cols);
    }|
    LPOP OPENING_PARENTHESIS FLOAT CLOSING_PARENTHESIS{
        check_included(libs,0,lines ,cols);
    }|
    LPOP OPENING_PARENTHESIS NUMBER CLOSING_PARENTHESIS{
        check_included(libs,0,lines ,cols);
    }|
    LPOP OPENING_PARENTHESIS IDF CLOSING_PARENTHESIS{
        check_included(libs,0,lines ,cols);
        check_declared_var($3,lines, cols);
    }|
    FLOAT|
    NUMBER|
    IDF{
        check_declared_var($1,lines, cols);
    }|
    HP_ARITHMETIC_EXPRESSION;
/*High Priority ARITHMETIC_EXPRESSION*/
HP_ARITHMETIC_EXPRESSION:
    IDF HPOP ZERO{
        check_zero_division($2,lines,cols);
    }|
    OPENING_PARENTHESIS FLOAT HPOP ARITHMETIC_EXPRESSION CLOSING_PARENTHESIS{
        check_included(libs,0,lines ,cols);
    }|
    OPENING_PARENTHESIS NUMBER HPOP ARITHMETIC_EXPRESSION CLOSING_PARENTHESIS{
        check_included(libs,0,lines ,cols);
    }|
    OPENING_PARENTHESIS IDF HPOP ARITHMETIC_EXPRESSION CLOSING_PARENTHESIS{
        check_included(libs,0,lines ,cols);
        check_declared_var($2,lines, cols);
    }|
    FLOAT HPOP ARITHMETIC_EXPRESSION{
        check_included(libs,0,lines ,cols);
    }|
    NUMBER HPOP ARITHMETIC_EXPRESSION{
        check_included(libs,0,lines ,cols);
    }|
    IDF HPOP ARITHMETIC_EXPRESSION{
        check_included(libs,0,lines ,cols);
        check_declared_var($1,lines, cols);
    };
LOGICAL_EXPRESSION:
   
    //comparing an arithmetic expression and a string (ex: TestIdf + 78 * 7 SUP "test")
	OPENING_PARENTHESIS ARITHMETIC_EXPRESSION COMP STRING CLOSING_PARENTHESIS| 
	//comparing a string and an arithmetic expression (ex: "test" SUP TestIdf)
    OPENING_PARENTHESIS STRING COMP ARITHMETIC_EXPRESSION CLOSING_PARENTHESIS|
    //comparing an arithmetic expression and a char (ex: 7 SUP 'c')
    OPENING_PARENTHESIS ARITHMETIC_EXPRESSION COMP CHAR CLOSING_PARENTHESIS|
    //comparing a char and a arithmetic expression (ex:  'c' SUP TestIdf + 78 * 7  )
    OPENING_PARENTHESIS CHAR COMP ARITHMETIC_EXPRESSION CLOSING_PARENTHESIS|
    //comparing two arithmetic expression together(ex:  TestIdf2+ TestIdf - 872*(14+TestIdf3) SUP TestIdf + 78 * 7  )
    OPENING_PARENTHESIS ARITHMETIC_EXPRESSION COMP ARITHMETIC_EXPRESSION CLOSING_PARENTHESIS|	
    //comparing two strings together(ex:  "test" SUP "test4"  )
    OPENING_PARENTHESIS STRING COMP STRING CLOSING_PARENTHESIS|
    //comparing two chars together(ex:  't' SUP '6'  )
    OPENING_PARENTHESIS CHAR COMP CHAR CLOSING_PARENTHESIS|
    //comparing a char with a string (ex: "test" INF 'c')
    OPENING_PARENTHESIS STRING COMP CHAR CLOSING_PARENTHESIS|
    //comparing a char with a string (ex: "test" INF 'c')	
    OPENING_PARENTHESIS CHAR COMP STRING CLOSING_PARENTHESIS|
    // using the value of an arithmetic expression as a logical expression (ex: Eestqd - 852 *8 )	
    OPENING_PARENTHESIS ARITHMETIC_EXPRESSION CLOSING_PARENTHESIS|
    // using the value of an identifier as a logical expression
	IDF{
        check_declared_var($1,lines, cols);
    };
INSTRUCTION_PART: 
    ASSIGN INSTRUCTION_PART| 
    IO INSTRUCTION_PART | 
    LOOP INSTRUCTION_PART | 
    COND INSTRUCTION_PART | 
      ;
ASSIGN:  IDF ASSIGN_OP IDF  END{
        check_declared_var($1,lines,cols);
        check_const_value_change($1,lines,cols);
        check_idf_to_idf_type_compatibility($1,$3,lines,cols);
    }|IDF ASSIGN_OP ARITHMETIC_EXPRESSION  END{
        check_declared_var($1,lines,cols);
        check_const_value_change($1,lines,cols);
    }|
    IDF ASSIGN_OP STRING  END{
        check_declared_var($1,lines,cols);
        check_const_value_change($1,lines,cols);
        verify_type_compatibility($1, "STRING",lines, cols);
    }|
    IDF ASSIGN_OP CHAR  END{
        check_declared_var($1,lines,cols);
        check_const_value_change($1,lines,cols);
        verify_type_compatibility($1, "CHAR",lines, cols);
    }| 
    IDF OPENING_CROCHET NUMBER CLOSING_CROCHET  ASSIGN_OP ARITHMETIC_EXPRESSION END{
        check_declared_var($1,lines,cols);
        check_const_value_change($1,lines,cols);
        check_array_size_execution($1,$3,lines,cols);
    }|
    IDF OPENING_CROCHET NUMBER CLOSING_CROCHET  ASSIGN_OP STRING END{
        check_declared_var($1,lines,cols);
        check_const_value_change($1,lines,cols);
        check_array_size_execution($1,$3,lines,cols);
        verify_type_compatibility($1, "STRING",lines, cols);
    }|
    IDF OPENING_CROCHET NUMBER CLOSING_CROCHET  ASSIGN_OP CHAR END{
        check_declared_var($1,lines,cols);
        check_const_value_change($1,lines,cols);
        check_array_size_execution($1,$3,lines,cols);
        verify_type_compatibility($1, "CHAR",lines, cols);
    }; 
IO: READ OPENING_PARENTHESIS FORMAT_SIGN PIPE AT IDF CLOSING_PARENTHESIS END{
    check_declared_var($6);
    check_format_sign($3,$6,lines,cols);
}|  WRITE OPENING_PARENTHESIS STRING PIPE REFERENCE CLOSING_PARENTHESIS END{
    parse_format_sign($3,types_in_str,idf_count, lines,cols );
    for(int i = 0; i <idf_count ;i++){
        types_in_str[i] = 0;
    }
    idf_count = 0;
};
REFERENCE:  IDF{
    check_declared_var($1,lines, cols);
    get_types_in_io(types_in_str,$1,idf_count);
    idf_count++;
}|IDF SEP REFERENCE {
    check_declared_var($1,lines, cols);
    get_types_in_io(types_in_str,$1 ,idf_count);
    idf_count ++;
} ; 

LOOP: 
    WHILE{
       check_included(libs,1,lines ,cols);
    } LOGICAL_EXPRESSION OPENING_BRACKET INSTRUCTION_PART CLOSING_BRACKET END;

COND: 
    EXECUTE INSTRUCTION_PART IF  LOGICAL_EXPRESSION ELSE EXECUTE INSTRUCTION_PART END_IF END|	
    EXECUTE INSTRUCTION_PART IF  LOGICAL_EXPRESSION END_IF END;
%%
void main() {
    init_symbole_tables();
	yyparse();
	afficher();
}
void yyerror(char *s)
{ 
    printf("syntax error on line %d and colomn %d\n", lines, cols);
}
void yywarp(void){};

//function used to get the type of the variable that will be stored in our symbol table
/*params:
    temp[] : a pointer to an empty array that will store the value of the type 
*/
void get_type(char temp[]){
    switch(type){
        case 1 : 
            strcpy(temp,"INTEGER");
            break;
        case 2: 
            strcpy(temp , "REAL");
            break;
        case 3:
            strcpy(temp , "CHAR");
            break;
        case 4:
            strcpy(temp , "STRING");
            break;
    }
}
