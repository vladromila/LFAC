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

int is_string(char name[256])
{
    for (int i = 0; i < no_symbols; i++)
        if (strcmp(symbols[i].name, name) == 0)
            if (strstr(symbols[i].data_type, "string"))
                return 1;
    return 0;
}

int is_const(char data_type[256])
{
    if (strstr(data_type, "const"))
        return 1;
    return 0;
}

int is_value_null(char name[256])
{
    for (int i = 0; i < no_symbols; i++)
        if (strcmp(symbols[i].name, name) == 0)
            if (strcmp(symbols[i].value, "NULL") == 0)
                return 0;
    return 1;
}

int update_value_struct(char name1[256], char name2[256], char value[256])
{
    for (int i = 0; i < nr_struct; i++)
        for (int j = 0; j < str[i].index; j++)
            if (strcmp(str[i].variables[j].name, name1) == 0)
            {
                for (int j = 0; j < str[i].index; j++)
                    if (strcmp(str[i].variables[j].name, name2) == 0)
                        if ((strcmp(str[i].variables[j].data_type, "int") == 0 && is_int(value) == 0) || (strcmp(str[i].variables[j].data_type, "float") == 0 && is_float(value) == 0))
                            return 0;
                        else
                        {
                            strcpy(str[i].variables[j].value, value);
                            return 1;
                        }
            }
    return 1;
}
int check_variable_struct(char name1[256], char name2[256])
{
    for (int i = 0; i < nr_struct; i++)
        for (int j = 0; j < str[i].index; j++)
            if (strcmp(str[i].variables[j].name, name1) == 0)
            {
                for (int j = 0; j < str[i].index; j++)
                    if (strcmp(str[i].variables[j].name, name2) == 0)
                        return 1;
            }
    return 0;
}
int look_function(char name[256])
{
    for (int i = 0; i < no_functions; i++)
        if (strcmp(functions[i].name, name) == 0)
            return 1;
    return 0;
}
int check_signature(char data_type[256], char name[256], char no_param[256])
{
    int x = atoi(no_param);
    for (int i = 0; i < no_functions; i++)
        if (strcmp(functions[i].data_type, data_type) == 0 && strcmp(functions[i].name, name) == 0 && functions[i].max_index == x)
            return 0;
    return 1;
}

void push_function_param(char data_type[256], char name[256], char value[256], char scope[256])
{

    strcpy(functions[no_functions - 1].variables[functions[no_functions - 1].index].data_type, data_type);
    strcpy(functions[no_functions - 1].variables[functions[no_functions - 1].index].name, name);
    strcpy(functions[no_functions - 1].variables[functions[no_functions - 1].index].value, value);
    strcpy(functions[no_functions - 1].variables[functions[no_functions - 1].index].scope, scope);
    functions[no_functions - 1].index++;
}
void push_function(char data_type[256], char name[256], char no_param[256], char scope[256])
{
    int x = atoi(no_param);
    strcpy(functions[no_functions].name, name);
    functions[no_functions].max_index = x;
    strcpy(functions[no_functions].scope, scope);
    strcpy(functions[no_functions].data_type, data_type);
    no_functions++;
}
void push_struct(char name[256])
{
    int x = nr_struct;
    strcpy(str[x].name, name);
    nr_struct++;
}

void push_variables(char data_type[256], char name[256], char value[256])
{
    int x = str[nr_struct].index;
    strcpy(str[nr_struct].variables[x].name, name);
    strcpy(str[nr_struct].variables[x].data_type, data_type);
    if (strcmp(data_type, "string") == 0 || strcmp(data_type, "char") == 0)
    {
        *value++;
        value[strlen(value) - 1] = '\0';
    }
    strcpy(str[nr_struct].variables[x].value, value);
    str[nr_struct].index++;
}
