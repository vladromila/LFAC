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

struct AST_Node
{
    int type;
    char value[256];
    struct symbol_table node;
    struct AST_Node *left;
    struct AST_Node *right;
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

void push_symbol(char data_type[256], char name[256], char value[256], char scope[256])
{
    int x = no_symbols;
    strcpy(symbols[x].data_type, data_type);
    strcpy(symbols[x].name, name);

    // string quotes removed
    if (strstr(data_type, "string") || strstr(data_type, "char"))
    {
        *value++;
        value[strlen(value) - 1] = '\0';
    }
    if (strstr(data_type, "bool"))
    {
        if (strcmp(value, "0") == 0)
            strcpy(value, "FALSE");
        if (strcmp(value, "1") == 0)
            strcpy(value, "TRUE");
    }
    strcpy(symbols[x].value, value);
    strcpy(symbols[x].scope, scope);

    no_symbols++;
}

int lookup(char name[256])
{
    // check if variable exists. exists?1:0

    for (int i = 0; i < no_symbols; i++)
        if (strcmp(symbols[i].name, name) == 0) // daca gasim in tabela
            return 1;

    return 0;
}

int str_includes(char value[256], char substring[256])
{
    if (strstr(value, substring))
        return 1;
    return 0;
}
int str_cmp(char value[256], char value2[256])
{
    char buff[256];
    for (int i = 0; i < no_symbols; i++)
        if (strcmp(symbols[i].value, value) == 0) // daca gasim in tabela
            strcpy(buff, symbols[i].name);

    if (strcmp(value, value2) == 0)
        return 1;
    return 0;
}

char *get_value(char name[256])
{
    for (int i = 0; i < no_symbols; i++)
        if (strcmp(symbols[i].name, name) == 0)
            return symbols[i].value;
}
char *get_scope(char name[256])
{
    for (int i = 0; i < no_symbols; i++)
        if (strcmp(symbols[i].name, name) == 0)
            return symbols[i].scope;
}
char *get_data_type(char name[256])
{
    for (int i = 0; i < no_symbols; i++)
        if (strcmp(symbols[i].name, name) == 0)
            return symbols[i].data_type;
}

char *value_by_scope(char name[256], char scope[256])
{
    for (int i = 0; i < no_symbols; i++)
        if (strcmp(symbols[i].name, name) == 0 && strcmp(symbols[i].scope, scope) == 0)
            return symbols[i].value;
    return NULL;
}

int lookup_function_variable(char name[256])
{
    for (int i = 0; i < no_functions; i++)
        for (int j = 0; j < functions[i].index; j++)
        {
            if (strcmp(functions[i].variables[j].name, name) == 0)
            {
                return 1;
            }
        }
    return 0;
}

char *variable_value_by_scope(char name[256])
{
    for (int i = 0; i < no_functions; i++)
        for (int j = 0; i < functions[i].index; j++)
        {
            if (strcmp(functions[i].variables[j].name, name) == 0)
            {
                return functions[i].variables[j].value;
            }
        }
}

void print_string(char string[256])
{ // removes string quotes and prints static strings;
    *string++;
    string[strlen(string) - 1] = '\0';
    printf("%s\n", string);
}

int check_data_type(char data_type[256], char value[256])
{
    if (strstr("const int", data_type))
    {
        for (int i = 0; i < strlen(value); i++)
            if (!isdigit(value[i]) && value[i] != '-' && value[i] != '+')
                return 0;
    }

    if (strstr("const float", data_type))
    {
        int ok = 0;
        for (int i = 0; i < strlen(value); i++)
        {
            if (value[i] == '.')
                ok = 1;
        }

        if (ok == 0)
            return 0;
        for (int i = 0; i < strlen(value); i++)
        {
            if (!isdigit(value[i]) && value[i] != '.')
                return 0;
        }
    }

    if (strstr("const bool", data_type))
    {
        if (strcmp(value, "TRUE") != 0 && strcmp(value, "FALSE") != 0 && strcmp(value, "1") != 0 && strcmp(value, "0") != 0)
            return 0;
    }
    if (strstr("const string", data_type))
    {
        if (value[0] != '\"' || value[strlen(value) - 1] != '\"')
            return 0;
    }
    if (strstr("const char", data_type))
    {
        if (value[0] != '\'' || value[strlen(value) - 1] != '\'')
            return 0;
    }
    return 1;
}

void reassign_value(char name[256], char value[256])
{
    for (int i = 0; i < no_symbols; i++)
        if (strcmp(symbols[i].name, name) == 0)
            strcpy(symbols[i].value, value);
}

// array related functions

void push_array(char data_type[256], char name[256], char int_value[256], char scope[256])
{
    int x = no_arrays;
    strcpy(arrays[x].data_type, data_type);
    strcpy(arrays[x].name, name);
    strcpy(arrays[x].scope, scope);
    int a = atoi(int_value);
    arrays[x].max_index = a;
    no_arrays++;
}

void push_array_element(char name[256], char index[256], char value[256])
{
    int x = no_arrays;
    int ind = atoi(index);
    int val = atoi(value);
    for (int i = 0; i < x; i++)
        if (strcmp(arrays[i].name, name) == 0)
            arrays[i].array[ind] = val;
}

int check_inside(char name[256], char index[256])
{
    int x = no_arrays;
    int ind = atoi(index);
    for (int i = 0; i < x; i++)
        if (strcmp(arrays[i].name, name) == 0)
            if (ind < arrays[i].max_index)
                return 1;
    return 0;
}
int lookup_array(char name[256])
{
    int x = no_arrays;
    for (int i = 0; i < x; i++)
        if (strcmp(arrays[i].name, name) == 0)
            return 1;
    return 0;
}

int get_element(char name[256], char index[256])
{
    int ind = atoi(index);
    int x = no_arrays;
    for (int i = 0; i < x; i++)
        if (strcmp(arrays[i].name, name) == 0)
            return arrays[i].array[ind];
}

void print_to_file()
{
    FILE *file;
    file = fopen("symbol_table.txt", "w");
    fprintf(file, "SYMBOL TABLE:\n\n");
    for (int i = 0; i < no_symbols; i++)
        fprintf(file, "data_type: %s, name: %s, value:%s, scope:%s\n", symbols[i].data_type, symbols[i].name, symbols[i].value, symbols[i].scope);

    fprintf(file, "\nSTRUCT TABLE:\n\n");
    for (int i = 0; i < nr_struct; i++)
    {
        fprintf(file, "struct_name: %s\n", str[i].name);
        for (int j = 0; j < str[i].index; j++)
            fprintf(file, "data_type : %s , name : %s , value : %s\n", str[i].variables[j].data_type, str[i].variables[j].name, str[i].variables[j].value);
    }
    fprintf(file, "\nARRAY TABLE:\n\n");
    for (int i = 0; i < no_arrays; i++)
    {
        fprintf(file, "data_type: %s, ", arrays[i].data_type);
        fprintf(file, "name: %s, ", arrays[i].name);
        fprintf(file, "no_elements: %d, scope: %s ", arrays[i].max_index, arrays[i].scope);
        fprintf(file, "values:[ ");
        for (int j = 0; j < arrays[i].max_index; j++)
            fprintf(file, "%d ", arrays[i].array[j]);
        fprintf(file, "]\n");
    }
    fclose(file);

    file = fopen("symbol_table_functions.txt", "w");
    fprintf(file, "\nFUNCTIONS TABLE:\n");
    for (int i = 0; i < no_functions; i++)
    {

        fprintf(file, "\ndata_type: %s, ", functions[i].data_type);
        fprintf(file, "name: %s, ", functions[i].name);
        fprintf(file, "scope: %s\n", functions[i].scope);
        fprintf(file, "\n     FUNCTION VARIABLES: \n");
        for (int j = 0; j < functions[i - 1].index; j++)
            fprintf(file, "     scope: %s, data_type : %s, name : %s, value : %s\n", functions[i - 1].variables[j].scope, functions[i - 1].variables[j].data_type, functions[i - 1].variables[j].name, functions[i - 1].variables[j].value);
    }

    fclose(file);
}