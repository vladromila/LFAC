#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>

struct symbol_table
{
    char data_type[256];
    char name[256];
    char value[256];
    char scope[256];
};

struct symbol_table symbols[50];
int no_symbols = 0;

struct symbol_table_struct
{
    char scope[256];
    char data_type[256]; 
    char name[256];
    int index;
    int max_index;
    struct symbol_table variables[50];
    int array[100];
};

struct symbol_table_struct str[50];
int nr_struct = 0;

struct symbol_table_struct arrays[50];
int no_arrays = 0;

struct symbol_table_struct functions[50];
int no_functions = 0;
int is_int(char value[256])
{
    for (int i = 0; i < strlen(value); i++)
        if (!isdigit(value[i]) && value[i] != '-' && value[i] != '+')
            return 0;

    return 1;
}

int is_float(char value[256])
{
    for (int i = 0; i < strlen(value); i++)
        if (!isdigit(value[i]) && value[i] != '.')
            return 0;

    return 1;
}
