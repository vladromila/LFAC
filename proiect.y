%{
#include <stdio.h>
#include "func.h"
extern char* yytext;
extern int yylineno;
void yyerror(const char *s);
int yylex();
int flag_error = 0;
char printare[1024];
char function_name[256];

%}
%nonassoc IF2
%nonassoc ELSE
%start START
%token FUNCTION PRINT TEXT QUOTE_MARK CLASS STRUCT EVAL LEFT_SQUARE RIGHT_SQUARE ARRAY
%token SEMI_COLON COMMA EQUAL LEFT_PARAN RIGHT_PARAN LEFT_BRACE RIGHT_BRACE
%token  COLON INT_VAL POINT
%token STRCOPY SUBSTRING STRCMP
%token IF WHILE FOR CALL
%token <name> VARIABLE_NAME
%token <value> INT_VALUE BOOL_VALUE STRING_VALUE CHAR_VALUE FLOAT_VALUE
%type <value> VALUE EXP EXP2
%token <data_type> DATA_TYPE
 
%union
{  
    char* data_type;
    char* name;
    char* value;
}
%left OR
%left AND 
%left GRE LES GEQ LEQ NEQ EQ
%left PLUS MINUS
%left MULTIPLY DIVIDE MODULO
%left LEFT_PARAN RIGHT_PARAN

%%

START : STMT SEMI_COLON {;}
      | START STMT SEMI_COLON {;}
      | START PRINT PRINT_LIST SEMI_COLON {;}
      | PRINT PRINT_LIST SEMI_COLON {;}
      | STRUCT STRUCT_BODY {;}
      | START STRUCT STRUCT_BODY {;}
      | STR_OPERATION SEMI_COLON {;}
      | START STR_OPERATION SEMI_COLON {;}
      | ARRAY ARRAY_BODY SEMI_COLON {;}
      | START ARRAY ARRAY_BODY SEMI_COLON {;}
      | IF_BODY {;}
      | START IF_BODY {;}
      | WHILE_BODY {;}
      | START WHILE_BODY {;}
      | FOR_BODY {;}
      | START FOR_BODY {;}
      | FUNCTION FUNCTION_ANTET {;}
      | START FUNCTION FUNCTION_ANTET {;}
      | FUNC_CALL SEMI_COLON {;}
      | START  FUNC_CALL SEMI_COLON {;}
      | STRUCT_VALUE {;}
      | START STRUCT_VALUE {;}
      ;
STRUCT_VALUE :  VARIABLE_NAME POINT VARIABLE_NAME EQUAL EXP SEMI_COLON {if(!check_variable_struct($1 , $3)) {printf("ERROR! Line %d, variable \"%s\" or \"%s\"does not exist.\n", yylineno, $1 , $3); flag_error = 1;
                    exit(0);}
                    if(update_value_struct($1 , $3 , $5) == 0)
                        {printf("ERROR! Line %d, variables \"%s\" and \"%s\" not a same data_type.\n", yylineno, $1 , $3); flag_error = 1;
                    exit(0);}
                    };

IF_BODY : IF LEFT_PARAN BOOL_EXP RIGHT_PARAN LEFT_BRACE IF_BLOCK RIGHT_BRACE %prec IF2   {;}
        | IF LEFT_PARAN BOOL_EXP RIGHT_PARAN LEFT_BRACE IF_BLOCK RIGHT_BRACE ELSE LEFT_BRACE IF_BLOCK RIGHT_BRACE{;}

IF_BLOCK :  DATA_TYPE VARIABLE_NAME EQUAL EXP SEMI_COLON {push_symbol($1, $2, $4, "if");}  
          |  IF_BLOCK DATA_TYPE VARIABLE_NAME EQUAL EXP SEMI_COLON {push_symbol($2, $3, $5, "if");}
          |  DATA_TYPE VARIABLE_NAME  SEMI_COLON {push_symbol($1, $2, "NULL", "if");}
          |  IF_BLOCK DATA_TYPE VARIABLE_NAME  SEMI_COLON {push_symbol($2, $3, "NULL", "if");}
          |  IF_BLOCK ARRAY ARRAY_IF SEMI_COLON{;}
          |  ARRAY ARRAY_IF SEMI_COLON{;}
          |  PRINT_IF SEMI_COLON {;}
          |  IF_BLOCK PRINT_IF SEMI_COLON {;}

PRINT_IF : PRINT LEFT_PARAN VALUE COMMA VARIABLE_NAME RIGHT_PARAN { if (lookup($5)) {
                                {char buff[256]="";
                                strcpy(buff,$3);
                                buff[strlen(buff)-1]='\0';
                                strcpy(buff,buff+1);
                                strcat(printare,buff);
                                if(value_by_scope($5, "if")!=NULL) strcpy(buff, value_by_scope($5, "if"));
                                else strcpy(buff, get_value($5));
                                strcat(printare,buff);
                                strcat(printare,"\n");}}
                                else {printf("ERROR! Line %d, variable \"%s\" not declared.\n", yylineno, $5);
                               flag_error = 1; exit(0);}}
            // | PRINT_IF COMMA VARIABLE_NAME { if (lookup($3)) {
            //                     {char buff[256]="";
            //                     if(value_by_scope($3, "if")!=NULL) strcpy(buff, value_by_scope($3, "if"));
            //                     else strcpy(buff, get_value($3));
            //                     strcat(printare,buff);
            //                     strcat(printare,"\n");}}
            //                     else {printf("ERROR! Line %d, variable \"%s\" not declared.\n", yylineno, $3);
            //                    flag_error = 1; exit(0);}}
            //    | PRINT LEFT_PARAN VALUE RIGHT_PARAN {strcat(printare, $3); strcat(printare, "\n");}                                
            // | PRINT_FOR COMMA VALUE {strcat(printare, $3); strcat(printare, "\n");}     
ARRAY_IF : DATA_TYPE VARIABLE_NAME LEFT_SQUARE INT_VALUE RIGHT_SQUARE{push_array($1, $2, $4, "if");}
           | VARIABLE_NAME LEFT_SQUARE INT_VALUE RIGHT_SQUARE EQUAL VALUE {;}



FOR_BLOCK :  DATA_TYPE VARIABLE_NAME EQUAL EXP SEMI_COLON {push_symbol($1, $2, $4, "for");}  
          |  FOR_BLOCK DATA_TYPE VARIABLE_NAME EQUAL EXP SEMI_COLON {push_symbol($2, $3, $5, "for");}
          |  DATA_TYPE VARIABLE_NAME  SEMI_COLON {push_symbol($1, $2, "NULL", "for");}
          |  FOR_BLOCK DATA_TYPE VARIABLE_NAME  SEMI_COLON {push_symbol($2, $3, "NULL", "for");}
          |  FOR_BLOCK ARRAY ARRAY_FOR SEMI_COLON{;}
          |  ARRAY ARRAY_FOR SEMI_COLON{;}
          |  PRINT_FOR SEMI_COLON {;}
          |  FOR_BLOCK PRINT_FOR SEMI_COLON {;}

PRINT_FOR : PRINT LEFT_PARAN VALUE COMMA VARIABLE_NAME RIGHT_PARAN { if (lookup($5)) {
                                {char buff[256]="";
                                strcpy(buff,$3);
                                buff[strlen(buff)-1]='\0';
                                strcpy(buff,buff+1);
                                strcat(printare,buff);
                                if(value_by_scope($5, "for")!=NULL) strcpy(buff, value_by_scope($5, "for"));
                                else strcpy(buff, get_value($5));
                                strcat(printare,buff);
                                strcat(printare,"\n");}}
                                else {printf("ERROR! Line %d, variable \"%s\" not declared.\n", yylineno, $5);
                               flag_error = 1; exit(0);}}
          //   | PRINT_FOR COMMA VARIABLE_NAME { if (lookup($3)) {
          //                       {char buff[256]="";
          //                       if(value_by_scope($3, "for")!=NULL) strcpy(buff, value_by_scope($3, "for"));
          //                       else strcpy(buff, get_value($3));
          //                       strcat(printare,buff);
          //                       strcat(printare,"\n");}}
          //                       else {printf("ERROR! Line %d, variable \"%s\" not declared.\n", yylineno, $3);
          //                      flag_error = 1; exit(0);}}
          //      | PRINT LEFT_PARAN VALUE RIGHT_PARAN  {strcat(printare, $3); strcat(printare, "\n");}                      
          // | PRINT_FOR COMMA VALUE {strcat(printare, $3); strcat(printare, "\n");}                                  
           
ARRAY_FOR : DATA_TYPE VARIABLE_NAME LEFT_SQUARE INT_VALUE RIGHT_SQUARE{push_array($1, $2, $4, "for");}
           | VARIABLE_NAME LEFT_SQUARE INT_VALUE RIGHT_SQUARE EQUAL VALUE {;}      


BOOL_EXP : EXP BOOL_TOKENS EXP {;}
         | BOOL_EXP LOGIC_OPERATORS EXP BOOL_TOKENS EXP {;}
         ;

LOGIC_OPERATORS : AND {;}
                | OR {;}         
                ;
BOOL_TOKENS : EQ {;}
            | NEQ {;}
            | GRE {;}
            | LES {;}
            | GEQ {;}
            | LEQ {;}

WHILE_BODY :  WHILE LEFT_PARAN BOOL_EXP RIGHT_PARAN LEFT_BRACE WHILE_BLOCK RIGHT_BRACE {;}

WHILE_BLOCK : DATA_TYPE VARIABLE_NAME EQUAL EXP SEMI_COLON {push_symbol($1, $2, $4, "while");}  
          |  WHILE_BLOCK DATA_TYPE VARIABLE_NAME EQUAL EXP SEMI_COLON {push_symbol($2, $3, $5, "while");}
          |  DATA_TYPE VARIABLE_NAME  SEMI_COLON {push_symbol($1, $2, "NULL", "while");}
          |  WHILE_BLOCK DATA_TYPE VARIABLE_NAME  SEMI_COLON {push_symbol($2, $3, "NULL", "while");}
          |  WHILE_BLOCK ARRAY ARRAY_WHILE SEMI_COLON{;}
          |  ARRAY ARRAY_WHILE SEMI_COLON{;}
          |  PRINT_WHILE SEMI_COLON {;}
          | WHILE_BLOCK PRINT_WHILE SEMI_COLON {;}


PRINT_WHILE : PRINT LEFT_PARAN VALUE COMMA VARIABLE_NAME RIGHT_PARAN { if (lookup($5)) {
                                {char buff[256]="";
                                strcpy(buff,$3);
                                buff[strlen(buff)-1]='\0';
                                strcpy(buff,buff+1);
                                strcat(printare,buff);
                                if(value_by_scope($5, "while")!=NULL) strcpy(buff, value_by_scope($5, "while"));
                                else strcpy(buff, get_value($5));
                                strcat(printare,buff);
                                strcat(printare,"\n");}}
                                else {printf("ERROR! Line %d, variable \"%s\" not declared.\n", yylineno, $5);
                               flag_error = 1; exit(0);}}

            // | PRINT_WHILE COMMA VARIABLE_NAME { if (lookup($3)) {
            //                     {char buff[256]="";
            //                     if(value_by_scope($3, "while")!=NULL) strcpy(buff, value_by_scope($3, "while"));
            //                     else strcpy(buff, get_value($3));
            //                     strcat(printare,buff);
            //                     strcat(printare,"\n");}}
            //                     else {printf("ERROR! Line %d, variable \"%s\" not declared.\n", yylineno, $3);
            //                    flag_error = 1; exit(0);}}
            // | PRINT LEFT_PARAN VALUE RIGHT_PARAN {strcat(printare, $3); strcat(printare, "\n");} 

            // | PRINT_WHILE COMMA VALUE {strcat(printare, $3); strcat(printare, "\n");}

ARRAY_WHILE: DATA_TYPE VARIABLE_NAME LEFT_SQUARE INT_VALUE RIGHT_SQUARE{push_array($1, $2, $4, "while");}
           | VARIABLE_NAME LEFT_SQUARE INT_VALUE RIGHT_SQUARE EQUAL VALUE {;}           

FOR_BODY : FOR LEFT_PARAN FOR1 COMMA BOOL_EXP COMMA FOR2 RIGHT_PARAN LEFT_BRACE FOR_BLOCK RIGHT_BRACE{;}

FOR1 :  DATA_TYPE VARIABLE_NAME EQUAL EXP {if(lookup($2))
                                {printf("ERROR! Line %d, variable already declared.\n", yylineno);flag_error = 1;
                                exit(0);}
                                if(!check_data_type($1,$4))
                                {printf("ERROR! Line %d, type not expected.\n", yylineno);flag_error = 1;
                                exit(0);}
                                push_symbol($1, $2, $4, "for");
                                }
      | VARIABLE_NAME  EQUAL EXP {if(is_const(get_data_type($1))) {printf("ERROR! Line %d, variable \"%s\" is const, cannot be reassigned.\n", yylineno, $1);
                               flag_error = 1; exit(0);}
                                    if(!lookup($1)) {printf("ERROR! Line %d, variable \"%s\" not declared.\n", yylineno, $1);
                               flag_error = 1; exit(0);}
                                    if(!check_data_type(get_data_type($1),$3))
                                {printf("ERROR! Line %d, type not expected.\n", yylineno);flag_error = 1;
                                exit(0);} reassign_value($1, $3);}                          

FOR2 : EXP EQUAL EXP {;} 


ARRAY_BODY : DATA_TYPE VARIABLE_NAME LEFT_SQUARE INT_VALUE RIGHT_SQUARE{push_array($1, $2, $4, "global");}
           | VARIABLE_NAME LEFT_SQUARE INT_VALUE RIGHT_SQUARE EQUAL VALUE {if(is_int($6)) {if(!lookup_array($1))
                                                                        {printf("ERROR! Line %d, \"%s\" not declared.\n",yylineno, $1);flag_error = 1; exit(0);} 
                                                                           if(!check_inside($1, $3)){printf("ERROR! Line %d, index %s out of bound.\n",yylineno, $1);flag_error = 1; exit(0);}
                                                                          push_array_element($1, $3, $6); }
                                                                          else {printf("ERROR! Line %d, expected type int.\n",yylineno);flag_error = 1; exit(0);} }   

PRINT_LIST : 
// LEFT_PARAN VALUE COMMA VARIABLE_NAME RIGHT_PARAN {if(lookup($4)){
//                                if(!is_value_null($4)) 
//                                      {printf("ERROR! Line %d, \"%s\" not initialized.\n",yylineno, $4); flag_error = 1;exit(0);}
//                              if(strcmp(get_scope($4), "global")) {printf("ERROR! Line %d, \"%s\" not declared in this scope.\n",yylineno, $4);flag_error = 1; exit(0);}
//                             char buff[256]="";
//                                 strcpy(buff,$2);
//                                 buff[strlen(buff)-1]='\0';
//                                 strcpy(buff,buff+1);
//                                 strcat(printare,buff);
//                             sprintf(buff, "%s\n", get_value($4));
//                             strcat(printare, buff);}
//                             else {printf("ERROR! Line %d, \"%s\" not found.\n",yylineno, $4);flag_error = 1; exit(0);}
//                             };
//             | 
            ARRAY_PRINT;
            | LEFT_PARAN VALUE COMMA EXP2 RIGHT_PARAN{
             char buff[256]="";
            strcpy(buff,$2);
            buff[strlen(buff)-1]='\0';
            strcpy(buff,buff+1);
            strcat(printare,buff);
            strcat(printare,$4);
            strcat(printare,"\n");
            };
            ;

FUNC_CALL : CALL VARIABLE_NAME LEFT_PARAN FUNC_CALL_PARAM RIGHT_PARAN {if(!look_function($2))
{printf("ERROR! Line %d, function not declared.\n", yylineno); flag_error = 1; exit(0);}
                                                                        }
          | CALL VARIABLE_NAME LEFT_PARAN FUNC_CALL RIGHT_PARAN {;}

FUNC_CALL_PARAM : EXP {;}          
                | FUNC_CALL_PARAM COMMA EXP {;}
FUNCTION_ANTET : DATA_TYPE VARIABLE_NAME LEFT_PARAN  INT_VALUE COMMA FUNCTION_PARAMETERS RIGHT_PARAN FUNCTION_BODY 
                                                                  {if(check_signature($1, $2, $4))
                                                                  push_function($1, $2, $4, "global");
                                                                  else {printf("ERROR! Line %d, function signature already exists.\n", yylineno); flag_error = 1; exit(0);}
                                                                        }

FUNCTION_PARAMETERS : DATA_TYPE VARIABLE_NAME {push_function_param($1, $2, "NULL", "antet");}
                                              
                    | FUNCTION_PARAMETERS COMMA DATA_TYPE VARIABLE_NAME {push_function_param($3, $4, "NULL","antet");}

FUNCTION_BODY : LEFT_BRACE FUNC_BLOCK RIGHT_BRACE {;}

FUNC_BLOCK : DATA_TYPE VARIABLE_NAME EQUAL EXP SEMI_COLON {push_function_param($1, $2, $4, "function");}  
          |  FUNC_BLOCK DATA_TYPE VARIABLE_NAME EQUAL EXP SEMI_COLON {push_function_param($2, $3, $5, "function");}
          |  DATA_TYPE VARIABLE_NAME  SEMI_COLON {push_function_param($1, $2, "NULL", "function");}
          |  FUNC_BLOCK DATA_TYPE VARIABLE_NAME  SEMI_COLON {push_function_param($2, $3, "NULL", "function");}
          |  FUNC_BLOCK ARRAY ARRAY_FUNC SEMI_COLON{;}
          |  ARRAY ARRAY_FUNC SEMI_COLON{;}
          |  PRINT_FUNC SEMI_COLON {;}
          |  FUNC_BLOCK PRINT_FUNC SEMI_COLON {;}

PRINT_FUNC : PRINT LEFT_PARAN VALUE COMMA VARIABLE_NAME RIGHT_PARAN { 
      if(lookup_function_variable($5))
      {
        char buff[256];
        strcpy(buff,$3);
        buff[strlen(buff)-1]='\0';
        strcpy(buff,buff+1);
        strcat(printare, buff);
          strcat(printare, variable_value_by_scope($5));
          strcat(printare,"\n");   
        }
      else
      if(lookup($5))
      {
        char buff[256];
        strcpy(buff,$3);
        buff[strlen(buff)-1]='\0';
        strcpy(buff,buff+1);
        strcat(printare, buff);
        strcat(printare,get_value($5));
        strcat(printare,"\n");
      }
      else
       {printf("ERROR! Line %d, \"%s\" not declared in this scope.\n",yylineno, $5);flag_error = 1; exit(0);}
      }
          //   | PRINT_FUNC COMMA VARIABLE_NAME {;}
          //      | PRINT VALUE {strcat(printare, $2); strcat(printare, "\n");}                      
          // | PRINT_FUNC COMMA VALUE {strcat(printare, $3); strcat(printare, "\n");}                                  
           
ARRAY_FUNC : DATA_TYPE VARIABLE_NAME LEFT_SQUARE INT_VALUE RIGHT_SQUARE{push_array($1, $2, $4, "function");}
           | VARIABLE_NAME LEFT_SQUARE INT_VALUE RIGHT_SQUARE EQUAL VALUE {;}



ARRAY_PRINT : LEFT_PARAN VALUE COMMA VARIABLE_NAME LEFT_SQUARE INT_VALUE RIGHT_SQUARE RIGHT_PARAN {if(!lookup_array($4))
                                                            {printf("ERROR! Line %d, \"%s\" array not found.\n",yylineno, $4);flag_error = 1; exit(0);}
                                                            if(!check_inside($4, $6))
                                                            {printf("ERROR! Line %d, \"%s\" index out of bound.\n",yylineno, $6);flag_error = 1; exit(0);}
                                                            char buff[256]=""; 
                                                            strcpy(buff,$2);
                                                            buff[strlen(buff)-1]='\0';
                                                            strcpy(buff,buff+1);
                                                            strcat(printare,buff);
                                                            sprintf(buff, "%d\n", get_element($4,$6));
                                                            strcat(printare, buff);} 
STMT : DATA_TYPE VARIABLE_NAME EQUAL EXP {if(lookup($2))
                                {printf("ERROR! Line %d, variable already declared.\n", yylineno);flag_error = 1;
                                exit(0);}
                                if(!check_data_type($1,$4))
                                {printf("ERROR! Line %d, type not expected.\n", yylineno);flag_error = 1;
                                exit(0);}
                                push_symbol($1, $2, $4, "global");}
     | DATA_TYPE VARIABLE_NAME {if(lookup($2))
                                {printf("ERROR! Line %d, variable already declared.\n", yylineno);flag_error = 1;
                                exit(0);}
                                 if(is_const($1)){printf("ERROR! Line %d, const must be initialised.\n", yylineno);flag_error = 1;
                                exit(0);}  
                                push_symbol($1, $2, "NULL", "global");}
     | VARIABLE_NAME  EQUAL EXP {if(is_const(get_data_type($1))) {printf("ERROR! Line %d, variable \"%s\" is const, cannot be reassigned.\n", yylineno, $1);
                                flag_error = 1;exit(0);}
                                    if(!lookup($1)) {printf("ERROR! Line %d, variable \"%s\" not declared.\n", yylineno, $1);
                                flag_error = 1;exit(0);}
                                    if(!check_data_type(get_data_type($1),$3))
                                {printf("ERROR! Line %d, type not expected.\n", yylineno);flag_error = 1;
                                exit(0);} reassign_value($1, $3);}
     
 
 
 
EXP : EXP PLUS EXP {if(is_int($3))  {int a=atoi($1), b=atoi($3); int c=a+b;sprintf($$, "%d", c);}
                      else if(is_float($3)) {float a=atof($1), b=atof($3); float c=a+b;;sprintf($$, "%f", c);}
                      else
                      {printf("ERROR! Line %d, expected an integer or float value.\n", yylineno); flag_error = 1;
                                exit(0);}} 

    | EXP MINUS EXP {if(is_int($3))  {int a=atoi($1), b=atoi($3); int c=a-b;sprintf($$, "%d", c);}
                      else if(is_float($3)) {float a=atof($1), b=atof($3); float c=a-b;;sprintf($$, "%f", c);}
                      else
                      {printf("ERROR! Line %d, expected an integer or float value.\n", yylineno); flag_error = 1;
                                exit(0);}} 
    
    | EXP MULTIPLY EXP {if(is_int($3))  {int a=atoi($1), b=atoi($3); int c=a*b;sprintf($$, "%d", c);}
                      else if(is_float($3)) {float a=atof($1), b=atof($3); float c=a*b;;sprintf($$, "%f", c);}
                      else
                      {printf("ERROR! Line %d, expected an integer or float value.\n", yylineno); flag_error = 1;
                                exit(0);}} 
    
    | EXP DIVIDE EXP {if(is_int($3))  {int a=atoi($1), b=atoi($3); int c=a/b;sprintf($$, "%d", c);}
                      else if(is_float($3)) {float a=atof($1), b=atof($3); float c=a/b;;sprintf($$, "%f", c);}
                      else
                      {printf("ERROR! Line %d, expected an integer or float value.\n", yylineno); flag_error = 1;
                                exit(0);}} 
                               
    | LEFT_PARAN EXP RIGHT_PARAN { $$=$2;}
    |  VALUE { strcpy($$, $1);}
    | VARIABLE_NAME { if(!is_value_null($1)) {printf("ERROR! Line %d, variable \"%s\" not initialised.\n", yylineno, $1); 
                    flag_error = 1; exit(0);} 
                     if(!lookup($1)) 
                    {printf("ERROR! Line %d, variable \"%s\" not declared.\n", yylineno, $1); flag_error = 1;
                    exit(0);}
                    if(!is_int(get_value($1)) && !is_float(get_value($1))) {printf("ERROR! Line %d, expected an integer or float value.\n", yylineno); 
                            flag_error = 1;    exit(0);}  
                    strcpy($$,get_value($1));
                    }
    ;

EXP2 : EXP2 PLUS EXP2 {if(is_int($3))  {int a=atoi($1), b=atoi($3); int c=a+b;sprintf($$, "%d", c);}
                      else if(is_float($3)) {float a=atof($1), b=atof($3); float c=a+b;;sprintf($$, "%f", c);}
                      else
                      {printf("ERROR! Line %d, expected an integer or float value.\n", yylineno); flag_error = 1;
                                exit(0);}} 

    | EXP2 MINUS EXP2 {if(is_int($3))  {int a=atoi($1), b=atoi($3); int c=a-b;sprintf($$, "%d", c);}
                      else if(is_float($3)) {float a=atof($1), b=atof($3); float c=a-b;;sprintf($$, "%f", c);}
                      else
                      {printf("ERROR! Line %d, expected an integer or float value.\n", yylineno); flag_error = 1;
                                exit(0);}} 
    
    | EXP2 MULTIPLY EXP2 {if(is_int($3))  {int a=atoi($1), b=atoi($3); int c=a*b;sprintf($$, "%d", c);}
                      else if(is_float($3)) {float a=atof($1), b=atof($3); float c=a*b;;sprintf($$, "%f", c);}
                      else
                      {printf("ERROR! Line %d, expected an integer or float value.\n", yylineno); flag_error = 1;
                                exit(0);}} 
    
    | EXP2 DIVIDE EXP2 {if(is_int($3))  {int a=atoi($1), b=atoi($3); int c=a/b;sprintf($$, "%d", c);}
                      else if(is_float($3)) {float a=atof($1), b=atof($3); float c=a/b;;sprintf($$, "%f", c);}
                      else
                      {printf("ERROR! Line %d, expected an integer or float value.\n", yylineno); flag_error = 1;
                                exit(0);}} 
                               
    | LEFT_PARAN EXP2 RIGHT_PARAN { $$=$2;}
    |  VALUE { strcpy($$, $1);}
    | VARIABLE_NAME { if(!is_value_null($1)) {printf("ERROR! Line %d, variable \"%s\" not initialised.\n", yylineno, $1); 
                    flag_error = 1; exit(0);} 
                     if(!lookup($1)) 
                    {printf("ERROR! Line %d, variable \"%s\" not declared.\n", yylineno, $1); flag_error = 1;
                    exit(0);}
                    if(!is_int(get_value($1)) && !is_float(get_value($1))) {printf("ERROR! Line %d, expected an integer or float value.\n", yylineno); 
                            flag_error = 1;    exit(0);}  
                    strcpy($$,get_value($1));
                    }
    ;        

VALUE : INT_VALUE {;}
      | STRING_VALUE {;}  
      | FLOAT_VALUE {;}  
      | CHAR_VALUE {;}  
      | BOOL_VALUE {;}  
      ;
 
STRUCT_BODY :  VARIABLE_NAME LEFT_BRACE STMT_LIST RIGHT_BRACE VARIABLE_LIST SEMI_COLON
                {push_struct($1);};
 
STMT_STRUCT : DATA_TYPE VARIABLE_NAME EQUAL EXP{push_variables($1 , $2 , $4);}
            | DATA_TYPE VARIABLE_NAME {push_variables($1 , $2 , "NULL");};
 
STMT_LIST : STMT_STRUCT SEMI_COLON {;}
            | STMT_LIST STMT_STRUCT SEMI_COLON {;}
 
VARIABLE_LIST : VARIABLE_NAME {push_variables("struct_variable" , $1 , "NULL");}
                | VARIABLE_LIST COMMA VARIABLE_NAME {push_variables("struct_variable" , $3 , "NULL");};

STR_OPERATION : STRCOPY LEFT_PARAN VARIABLE_NAME COMMA STRING_VALUE RIGHT_PARAN
                {if(!lookup($3)){printf("ERROR! Line %d, \"%s\" not declared.\n", yylineno, $3); 
                               flag_error = 1; exit(0);}
                 if(!is_string($3)) {printf("ERROR! Line %d, %s not a string.\n", yylineno, $3); 
                                flag_error = 1;exit(0);}               
                reassign_value($3, $5);}
                | STRCOPY LEFT_PARAN VARIABLE_NAME COMMA VARIABLE_NAME RIGHT_PARAN
                {if(!lookup($3)){printf("ERROR! Line %d, \"%s\" not declared.\n", yylineno, $3); 
                               flag_error = 1; exit(0);}
                    if(!lookup($5)){printf("ERROR! Line %d, \"%s\" not declared.\n", yylineno, $5); 
                              flag_error = 1;  exit(0);}            
                 if(!is_string($3)) {printf("ERROR! Line %d, %s not a string.\n", yylineno, $3); 
                              flag_error = 1;  exit(0);}
                                if(!is_string($5)) {printf("ERROR! Line %d, %s not a string.\n", yylineno, $5); 
                              flag_error = 1;  exit(0);}                
                reassign_value($3, get_value($5));}
                | SUBSTRING LEFT_PARAN VARIABLE_NAME COMMA STRING_VALUE RIGHT_PARAN
                {if(!lookup($3)){printf("ERROR! Line %d, \"%s\" not declared.\n", yylineno, $3); 
                             flag_error = 1;   exit(0);}
                  if(!is_string($3)) {printf("ERROR! Line %d, \"%s\" not a string.\n", yylineno, $3); 
                              flag_error = 1;  exit(0);}              
                if(str_includes(get_value($3), $5))
                    strcat(printare, "First string contains the substring.\n");
                 else
                 strcat(printare, "First string does not contain the substring.\n");}    
                | SUBSTRING LEFT_PARAN VARIABLE_NAME COMMA VARIABLE_NAME RIGHT_PARAN
                {if(!lookup($3)){printf("ERROR! Line %d, \"%s\" not declared.\n", yylineno, $3); 
                             flag_error = 1;   exit(0);}
                       if(!lookup($5)){printf("ERROR! Line %d, \"%s\" not declared.\n", yylineno, $5); 
                             flag_error = 1;   exit(0);}         
                  if(!is_string($3)) {printf("ERROR! Line %d, \"%s\" not a string.\n", yylineno, $3); 
                              flag_error = 1;  exit(0);}
                                if(!is_string($5)) {printf("ERROR! Line %d, \"%s\" not a string.\n", yylineno, $5); 
                              flag_error = 1;  exit(0);}                
                if(str_includes(get_value($3), get_value($5)))
                    strcat(printare, "First string contains the substring.\n");
                 else
                 strcat(printare, "First string does not contain the substring.\n");}  
                | STRCMP LEFT_PARAN VARIABLE_NAME COMMA STRING_VALUE RIGHT_PARAN
                  {if(!lookup($3)){printf("ERROR! Line %d, %s not declared.\n", yylineno, $3); flag_error = 1;
                                exit(0);
                    }
                   if(!is_string($3)) {printf("ERROR! Line %d, %s not a string.\n", yylineno, $3); 
                                exit(0);} 
                  if(str_cmp(get_value($3), $5))
                      strcat(printare, "The strings are equal.\n");
                  else strcat(printare, "The strings are not equal.\n");}    
                | STRCMP LEFT_PARAN VARIABLE_NAME COMMA VARIABLE_NAME RIGHT_PARAN
                  {if(!lookup($3)){printf("ERROR! Line %d, %s not declared.\n", yylineno, $3); 
                                 flag_error = 1;  exit(0);}
                    if(!is_string($3)) {printf("ERROR! Line %d, %s not a string.\n", yylineno, $3); 
                            flag_error = 1;    exit(0);}
                       if(!is_string($5)) {printf("ERROR! Line %d, %s not a string.\n", yylineno, $5); 
                             flag_error = 1;   exit(0);}                        
                    if(str_cmp(get_value($3), get_value($5))) 
                    strcat(printare,"The strings are equal.\n");
                    else strcat(printare,"The strings are not equal.\n");}
                        
                               
%%
 
 
 
int main(){

 yyparse();
 printf("%s", printare);
if(flag_error == 0)
 print_to_file();
}