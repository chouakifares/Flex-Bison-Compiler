/*CHOUAKI FARES 181831013081*/
/*DEHRI FAYCAL */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// max size of a string of characters 
const int TAB_SIZE = 1024;
//structure used for the identifier symbol table
typedef struct{
    int state;
    char name[11];
    char code[20];
    char type[20];
    int taille;
} element;
// structure used for both the keyword symbole table and the separator symbol table
typedef struct
{
    int state;
    char name[11];
    char type[20];
} elt_sep_keywords;

// creation of our symbol tables 
element idf_const_symbol_table[1000];
elt_sep_keywords keywords_symbol_table[50], separators_symbol_table[50];

// initialization of the symbole tables by setting their state to 0
void init_symbole_tables(){
    int i;
    for (i = 0; i < 1000; i++)
        idf_const_symbol_table[i].state = 0;
    for (i = 0; i < 50; i++)
    {
        keywords_symbol_table[i].state = 0;
        separators_symbol_table[i].state = 0;
    }
}

// insertion fucntion : insert a row inside of the symbole tables
/*
 entity : name of the entity that we are looking for in the symbol table
 code : code of that entity
 type : of the entity 
 val: value of the entity (if the entity is a keyword or a separator we don't specify the value)
 y: param used to specify which symbol table the search is gonna be done in (0: idf_&_consts , 1: keywords , 2: separators) 
*/
void insert(char name[], char code[], char type[],int size, int i, int y)
{
    switch (y)
    {
    case 0:
        idf_const_symbol_table[i].taille = size;
        idf_const_symbol_table[i].state = 1;
        strcpy(idf_const_symbol_table[i].type, type);
        strcpy(idf_const_symbol_table[i].name, name);
        strcpy(idf_const_symbol_table[i].code, code);
        break;
    case 1:
        keywords_symbol_table[i].state = 1;
        strcpy(keywords_symbol_table[i].name, name);
        strcpy(keywords_symbol_table[i].type, code);
        break;
    case 2:
        separators_symbol_table[i].state = 1;
        strcpy(separators_symbol_table[i].name, name);
        strcpy(separators_symbol_table[i].type, code);
        break;
    }
}
// search function : search for a row inside of the symbol tables using the name of the entity as a search criteria
/*
 entity : name of the entity that we are looking for in the symbol table
 code : code of that entity
 type : of the entity 
 val: value of the entity (if the entity is a keyword or a separator we don't specify the value)
 y: param used to specify which symbol table the search is gonna be done in (0: idf_&_consts , 1: keywords , 2: separators) 
*/
void search(char entity[], char code[] ,char type[],int taille,int y){
    int i;
    switch (y)
    {
    // case of an identifier (variable or constant)
    case 0:
        for (i = 0; (i < 1000 && idf_const_symbol_table[i].state == 1 && strcmp(idf_const_symbol_table[i].name, entity) != 0); i++)
        {
        }
        if (i < 1000)
        {
            if (idf_const_symbol_table[i].state == 1)
            {
                if (strcmp(idf_const_symbol_table[i].type, ""))
                {
                    //double declaration
                    if (strcmp(type, "") && !(strcmp(idf_const_symbol_table[i].code, "cst_real") ||
                                              strcmp(idf_const_symbol_table[i].code, "cst_integer") ||
                                              strcmp(idf_const_symbol_table[i].code, "cst_string") ||
                                              strcmp(idf_const_symbol_table[i].code, "cst_char")))
                    {
                        printf("semantic error: identifier %s declared more than once\n", idf_const_symbol_table[i].name);
                        exit(1);
                    }
                }else
                {
                    //update the symbol table
                    strcpy(idf_const_symbol_table[i].type, type);
                    strcpy(idf_const_symbol_table[i].code, code);
                    idf_const_symbol_table[i].taille = taille;
                }
            }
            else
            {
                insert(entity, code, type, taille, i, 0);
            }
        }
        break;
    // case of keyword
    case 1:
        for (i = 0; (i < 50 && keywords_symbol_table[i].state == 1 && strcmp(keywords_symbol_table[i].name, entity) != 0); i++)
        {
        }
        if (i < 50)
        {
            if (keywords_symbol_table[i].state != 1)
            {
                insert(entity, type, code, 0, i, 1);
            }
        }
        break;
    case 2:
        for (i = 0; (i < 50 && separators_symbol_table[i].state == 1 && strcmp(separators_symbol_table[i].name, entity) != 0); i++)
        {
        }
        if (i < 50)
        {
            if (separators_symbol_table[i].state != 1)
            {
                insert(entity, type, code, 0, i, 2);
            }
        }
        break;
    default:
        for (i = 0; (i < 1000 && idf_const_symbol_table[i].state == 1 && strcmp(idf_const_symbol_table[i].name, entity) != 0); i++){}
        if (i < 1000)
        {
            if (idf_const_symbol_table[i].state == 1)
            {
                if (strcmp(idf_const_symbol_table[i].type, "") != 0)
                {
                    printf("semantic error: identifier declared more than once");
                }
                else
                {
                    //update the symbol table
                    strcpy(idf_const_symbol_table[i].type, type);
                    strcpy(idf_const_symbol_table[i].code, code);
                    idf_const_symbol_table[i].taille = y;
                }
            }
            else
            {
                insert(entity, code, type, taille, i, 0);
            }
        }
        break;
    }    
}
// printing function : prints all the symbol tables with their values
void afficher()
{
    int i;

    printf("/***************Table des symboles IDF*************/\n");
    printf("_______________________________________________________________________________________________________________________________\n");
    printf("\t|\t\t\t Nom_Entite \t\t\t\t\t|   Code_Entite  | Type_Entite  |    Taille    |\n");
    printf("_______________________________________________________________________________________________________________________________\n");
    for (i = 0; i < 1000 && idf_const_symbol_table[i].state==1;i++){
        printf("\t|%70s |%15s | %12s |%12d  |\n", idf_const_symbol_table[i].name, idf_const_symbol_table[i].code, idf_const_symbol_table[i].type,idf_const_symbol_table[i].taille);
    }
    printf("_______________________________________________________________________________________________________________________________|\n");

    printf("\n/***************Table des symboles mots clés*************/\n");

    printf("_____________________________________\n");
    printf("\t| NomEntite |  CodeEntite | \n");
    printf("_____________________________________\n");
    for (i = 0; i < 50 && keywords_symbol_table[i].state == 1;i++){
        printf("\t|%10s |%12s | \n", keywords_symbol_table[i].name, keywords_symbol_table[i].type);
    }

    printf("\n/***************Table des symboles séparateurs*************/\n");

    printf("_____________________________________\n");
    printf("\t| NomEntite |  CodeEntite | \n");
    printf("_____________________________________\n");
    for (i = 0; i < 50 && separators_symbol_table[i].state == 1; i++)
    {
        printf("\t|%10s |%12s | \n", separators_symbol_table[i].name, separators_symbol_table[i].type);
    }
}

//semantic routines and helper functions


void check_double_declared_var(char name[])
{
    int i;
    for (i = 0; (i < 1000 && idf_const_symbol_table[i].state == 1 && strcmp(idf_const_symbol_table[i].name, name) != 0); i++)
    {
    }
    if (!strcmp(idf_const_symbol_table[i].name, name))
    {
        if (strcmp(idf_const_symbol_table[i].type, ""))
        {
            printf("semantic error: identifier %s declared twice\n", idf_const_symbol_table[i].name);
            exit(1);
        }
    }
}

void check_declared_var(char name[], int line, int col)
{
    int i;
    for (i = 0; (i < 1000 && idf_const_symbol_table[i].state == 1 && strcmp(idf_const_symbol_table[i].name, name) != 0); i++)
    {
    }
    if (strcmp(idf_const_symbol_table[i].name, name) == 0)
    {
        if (!strcmp(idf_const_symbol_table[i].type, ""))
        {
            afficher();
            printf("semantic error: identifier %s not declared on line: %d col:%d \n", idf_const_symbol_table[i].name, line, col);
            exit(1);
        }
    }
}

void check_const_value_change(char name[],int line, int col){
    int i;
    for (i = 0; (i < 1000 && idf_const_symbol_table[i].state == 1 && strcmp(idf_const_symbol_table[i].name, name) != 0); i++)
    {
    }
    if (strcmp(idf_const_symbol_table[i].name, name) == 0)
    {
        if (!strcmp(idf_const_symbol_table[i].code, "CONST"))
        {
            printf("semantic error: trying to change value of constant %s on line: %d col:%d \n", idf_const_symbol_table[i].name, line, col);
            exit(1);
        }
    }
}

void check_array_size_execution(char name[], int taille,int line ,int col){
    int i;
    for (i = 0; (i < 1000 && idf_const_symbol_table[i].state == 1 && strcmp(idf_const_symbol_table[i].name, name) != 0); i++)
    {
    }
    if (idf_const_symbol_table[i].taille-1 < taille || taille <0)
    {
        printf("semantic error: invalid array index for array %s (size :  %d) on line: %d col:%d \n", idf_const_symbol_table[i].name, idf_const_symbol_table[i].taille, line, col);
        exit(1);
        
    }
}

void verify_type_compatibility(char t1[], char t2[], int lines, int cols)
{
    if (strcmp(t1, t2) && !((!strcmp(t1, "INTEGER") || !strcmp(t1, "REAL")) && !strcmp(t2, "EXPRESSION")))
    {
        printf("semantic error in line %d col %d: incompatible types %s and %s\n", lines, cols, t1, t2);
        exit(1);
    }
}

void check_idf_to_idf_type_compatibility(char idf1[], char idf2[], int line , int col){
    int i,j;
    for (i = 0; (i < 1000 && idf_const_symbol_table[i].state == 1 && strcmp(idf_const_symbol_table[i].name, idf1) != 0); i++)
    {
    }
    for (j = 0; (j < 1000 && idf_const_symbol_table[j].state == 1 && strcmp(idf_const_symbol_table[j].name, idf2) != 0); j++)
    {
    }   
    if (!strcmp(idf_const_symbol_table[j].type, "REAL") || !strcmp(idf_const_symbol_table[j].type, "INTEGER"))
    {
        verify_type_compatibility(idf_const_symbol_table[i].type ,"EXPRESSION", line, col);
    }
    else{
        verify_type_compatibility(idf_const_symbol_table[j].type, idf_const_symbol_table[i].type, line, col);
    }
    
}

void check_format_sign(char format_sign[], char idf[],int lines , int cols){
    int i;
    for (i = 0; (i < 1000 && idf_const_symbol_table[i].state == 1 && strcmp(idf_const_symbol_table[i].name, idf) != 0); i++)
    {
    }
    if (!strcmp(idf_const_symbol_table[i].type, "INTEGER") && strcmp(format_sign,";"))
    {
        printf("semantic error in line %d col %d: incompatible format sign %s with type %s\n", lines, cols, format_sign, idf_const_symbol_table[i].type);
        exit(1);
    }
    else if (!strcmp(idf_const_symbol_table[i].type, "REAL") && strcmp(format_sign, "%"))
    {
        printf("semantic error in line %d col %d: incompatible format sign %s with type %s\n", lines, cols, format_sign, idf_const_symbol_table[i].type);
        exit(1);
    }
    else if (!strcmp(idf_const_symbol_table[i].type, "STRING") && strcmp(format_sign,"?"))
    {
        printf("semantic error in line %d col %d: incompatible format sign %s with type %s\n", lines, cols, format_sign, idf_const_symbol_table[i].type);
        exit(1);
    }
    else if (!strcmp(idf_const_symbol_table[i].type, "CHAR") && strcmp(format_sign, "&"))
    {
        printf("semantic error in line %d col %d: incompatible format sign %s with type %s\n", lines, cols, format_sign, idf_const_symbol_table[i].type);
        exit(1);
    }
}

int construct_format_signs_array(int result[], char format_sign, char input_str[])
{
    int i = 0;
    char *temp;
    temp = strchr(input_str, format_sign);
    while (temp != NULL)
    {
        result[i] = temp - input_str;
        input_str[temp - input_str] = ' ';
        temp = strchr(input_str, format_sign);
        i++;
    }
    for (int j = i; j < TAB_SIZE; j++){
        result[j] = TAB_SIZE + 1;
    }
    return i;
}

int min(int a,int b, int c , int d){
    if( a< b ){
        if( a < c){
            if ( a < d){
                return 0;
            }
            else{
                return 3;
            }
        }
        else{
            if(c < d){
                return 2;
            }
            else{
                return 3;
            }
        }
    }
    else{
        if(b < c){
            if(b < d){
                return 1;
            }
            else{
                return 3;
            }
        }
        else{
            if(c < d){
                return 2;
            }
            else{
                return 3;
            }
        }
    }
}

void parse_format_sign(char str_to_parse[], int types_array[], int types_array_size, int lines , int cols){
    char temp[TAB_SIZE];
    strcpy(temp, str_to_parse);
    int types_array_index=types_array_size -1 , integer_array_index=0, real_array_index=0, char_array_index=0, string_array_index=0;
    int integer_counter, string_counter, real_counter, char_counter;
    int integer_format_signs[TAB_SIZE], real_format_signs[TAB_SIZE], char_format_signs[TAB_SIZE], string_format_signs[TAB_SIZE];
    integer_counter = construct_format_signs_array(integer_format_signs, ';', temp);
    real_counter = construct_format_signs_array(real_format_signs, '%', temp);
    char_counter = construct_format_signs_array(char_format_signs, '&', temp);
    string_counter = construct_format_signs_array(string_format_signs, '?', temp);
    char current_format_sign;
    int nb_total_format_signs = integer_counter + real_counter + char_counter + string_counter;
    if((nb_total_format_signs-types_array_size)){
        printf("semantic error : unmatched string parameter on lines %d col %d\n", lines , cols);
        printf("Number of format_signs in string %d\nNumber of refrences %d\n", nb_total_format_signs, types_array_size);
        exit(1);
    }
    while (types_array_index >= 0)
    {
        switch (min(integer_format_signs[integer_array_index], real_format_signs[real_array_index], char_format_signs[char_array_index], string_format_signs[string_array_index]))
        {
        case 0:
            current_format_sign = ';';
            if (types_array[types_array_index] - 1)
            {
                printf("semantic error in line %d col %d: incompatible type between reference and format sign; use `%c` to refer to integers only \n",
                       lines, cols, current_format_sign);
                exit(1);
            }
            integer_array_index++;
            break;
        case 1:
            current_format_sign = '%';
            if (types_array[types_array_index] - 2)
            {
                printf("semantic error in line %d col %d: incompatible type between reference and format sign; use `%c` to refer to reals only \n",
                       lines, cols, current_format_sign);
                exit(1);
            }
            real_array_index++;
            break;
        case 2:
            current_format_sign = '&';
            if (types_array[types_array_index] - 3)
            {
                printf("semantic error in line %d col %d: incompatible type between reference and format sign; use `%c` to refer to chars only \n",
                       lines, cols, current_format_sign);
                exit(1);
            }
            char_array_index++;
            break;
        case 3:
            current_format_sign = '?';
            if (types_array[types_array_index] - 4)
            {
                printf("semantic error in line %d col %d: incompatible type between reference and format sign; use `%c` to refer to strings only \n",
                       lines, cols, current_format_sign);
                exit(1);
            }
            string_array_index++;
            break;
        }
        types_array_index--;
        }
}

void get_types_in_io(int types_array[],char idf[], int index){
    int i;
    for (i = 0; (i < 1000 && idf_const_symbol_table[i].state == 1 && strcmp(idf_const_symbol_table[i].name, idf) != 0); i++)
    {
    }
    if (!strcmp(idf_const_symbol_table[i].type, "INTEGER")){
        types_array[index] = 1;
    }
    if (!strcmp(idf_const_symbol_table[i].type, "REAL"))
    {
        types_array[index] = 2;
    }
    if (!strcmp(idf_const_symbol_table[i].type, "CHAR"))
    {
        types_array[index] = 3;
    }
    if (!strcmp(idf_const_symbol_table[i].type, "STRING"))
    {
        types_array[index] = 4;
    }

}

void check_zero_division(char t[], int lines, int cols){
    if(!strcmp(t,"/")){
        printf("semantic error in line %d col %d: zero division\n", lines, cols);
        exit(1);
    }
}

void verify_array_size(int size, int lines, int cols)
{
    if (size < 0)
    {
        printf("semantic error in line %d col %d : array size can't be negative\n", lines, cols);
        exit(1);
    }
}

// checks if a library is imported
/*
* libs : boolean array used to check if the library has already been declared 
* lib : name of the library to check if it has already been imported
*/
void check_library(int libs[], char lib[], int lines, int cols)
{

    int error = 0;
    if (!strcmp(lib, "##PROCESS"))
    {
        if (libs[0])
            error = 1;
        libs[0] = 1;
    }
    if (!strcmp(lib, "##LOOP"))
    {
        if (libs[1])
            error = 1;
        libs[1] = 1;
    }

    if (!strcmp(lib, "##ARRAY"))
    {
        if (libs[2])
            error = 1;
        libs[2] = 1;
    }
    if (error)
    {
        printf("semantic error in line %d col %d : library %s imported multiple times\n", lines, cols, lib);
    }
}

void check_included(int libs[], int lib, int line, int col)
{
    if (!libs[lib])
    {
        printf("semantic error : missing library on line %d , col %d\n", line, col);
        switch (lib)
        {
        case 0:
            printf("You need to include the PROCESS library to use arithmetic expressions\n");
            exit(1);
        case 1:
            printf("You need to include the LOOP library to use loops\n");
            exit(1);
        case 2:
            printf("You need to include the ARRAY library to use arrays\n");
            exit(1);
        }
    }
}