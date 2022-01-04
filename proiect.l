%{
#include <stdio.h>
#include "y.tab.h"
void invalid_token();
void yyerror(char *s);
int yywrap(void);
%}
whitespace [ \t\r\v\f]
linefeed \n
%%
 
"int"  |
"const int" |
"bool" |
"const bool" |
"float" |
"const float" |
"string" |
"const string" |
"char" |
"const char" { yylval.data_type=strdup(yytext); return DATA_TYPE;}
"call"      return CALL;
"struct"    return STRUCT;
"class"     return CLASS;
"function"  return FUNCTION;
"array"     return ARRAY;
"if"        return IF;
"else"      return ELSE;
"while"     return WHILE;
"for"       return FOR;
":"         return COLON;
";"         return SEMI_COLON;
","         return COMMA;
"="         return EQUAL;
"("         return LEFT_PARAN;
")"         return RIGHT_PARAN;
"{"         return LEFT_BRACE;
"}"         return RIGHT_BRACE;
"["         return LEFT_SQUARE;
"]"         return RIGHT_SQUARE;
"\""        return QUOTE_MARK;
"+"         return PLUS;
"TRUE"      {yylval.value = strdup(yytext); return BOOL_VALUE;}
"FALSE"     {yylval.value = strdup(yytext); return BOOL_VALUE;}
"print"     return PRINT;
"*"         return MULTIPLY;
"-"         return MINUS;
"/"         return DIVIDE;
"%"         return MODULO;
"copy"      return STRCOPY;
"substring" return SUBSTRING;
"compare"   return STRCMP;
"&&"        return AND;
"||"        return OR;
"=="        return EQ;
"!="        return NEQ;
">"         return GRE;
"<"         return LES;
">="        return GEQ;
"<="        return LEQ;
 "."        return POINT;
[a-zA-Z][_a-zA-Z0-9]*   {yylval.name=strdup(yytext); return VARIABLE_NAME;}
[0-9]+   {yylval.value=strdup(yytext); return INT_VALUE;}
[0-9]*\.?[0-9]+ {yylval.value = strdup(yytext); return FLOAT_VALUE;}
\"(\\.|[^"])*\" {yylval.value = strdup(yytext); return STRING_VALUE;}
[\'][a-zA-Z][\'] {yylval.value= strdup(yytext); return CHAR_VALUE;}
 
{linefeed} {yylineno++;}
{whitespace} ;
. {invalid_token();}
 
%%
 
int yywrap(void){
    return 1;
}
 
void yyerror(char *s) {
    fprintf(stderr, "\nERROR ON LINE %d: \n %s \n", yylineno, s);
    exit(0);
}
 
void invalid_token(){
    printf("ERROR ON LINE %d: \n Invalid Token %s\n",yylineno,yytext);
    exit(0);
}