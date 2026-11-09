%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern char *yytext;
extern int yylex(void);
extern void yyerror(const char*);
extern int num_linea;

/* --- ESTRUCTURA DE LA TABLA DE SIMBOLOS --- */

typedef struct {
    char nombre[33];
    int inicializada;
} Simbolo;

Simbolo tablaSimbolos[100];
int cantSimbolos = 0;

/* --- RUTINAS SEMANTICAS AUXILIARES --- */

int procesarIdentificador(char* id) {
    if (strlen(id) > 32) {
        char msg[128];
        sprintf(msg, "El identificador '%s' excede el limite semantico de 32 caracteres.", id);
        yyerror(msg);
        return -1;
    }

    for (int i = 0; i < cantSimbolos; i++) {
        if (strcmp(tablaSimbolos[i].nombre, id) == 0) {
            return i;
        }
    }

    strcpy(tablaSimbolos[cantSimbolos].nombre, id);
    tablaSimbolos[cantSimbolos].inicializada = 0;
    cantSimbolos++;

    return cantSimbolos - 1;
}

void marcarInicializada(char* id) {
    int idx = procesarIdentificador(id);

    if (idx != -1) {
        tablaSimbolos[idx].inicializada = 1;
    }
}

void verificarInicializacion(char* id) {
    int idx = procesarIdentificador(id);

    if (idx != -1 && tablaSimbolos[idx].inicializada == 0) {
        printf(">> [Advertencia Semantica - Linea %d]: La variable '%s' se esta usando sin haber sido inicializada previamente.\n", num_linea, id);
    }
}
%}

%union {
    char* cadena;
    int num;
}

%token INICIO FIN LEER ESCRIBIR
%token ASIGNACION PYCOMA COMA SUMA RESTA PARENIZQUIERDO PARENDERECHO
%token ERROR_LEXICO

%token <cadena> ID
%token <num> CONSTANTE

%%

programa: INICIO listaSentencias FIN {
    printf("\n--- Analisis Semantico y Sintactico Finalizado ---\n");
}
;

listaSentencias:
    listaSentencias sentencia
    | sentencia
;

sentencia:
    ID ASIGNACION expresion PYCOMA {
        marcarInicializada($1);
    }
    | LEER PARENIZQUIERDO listaIdentificadores PARENDERECHO PYCOMA
    | ESCRIBIR PARENIZQUIERDO listaExpresiones PARENDERECHO PYCOMA

    /* Recuperacion ante errores: descarta hasta encontrar ';' */
    | error PYCOMA {
        fprintf(stderr, ">> Se descarto la sentencia incorrecta en la linea %d.\n", num_linea);
        yyerrok;
    }
;

listaIdentificadores:
    ID {
        marcarInicializada($1);
    }
    | listaIdentificadores COMA ID {
        marcarInicializada($3);
    }
;

listaExpresiones:
    expresion
    | listaExpresiones COMA expresion
;

expresion:
    primaria
    | expresion operadorAditivo primaria
;

primaria:
    ID {
        verificarInicializacion($1);
    }
    | CONSTANTE
    | PARENIZQUIERDO expresion PARENDERECHO
;

operadorAditivo:
    SUMA
    | RESTA
;

%%

int main() {
    printf("Iniciando compilador de Lenguaje Micro...\n\n");
    return yyparse();
}

void yyerror(const char *s) {
    fprintf(stderr, ">> [Error Sintactico/Semantico - Linea %d]: %s\n", num_linea, s);
}
