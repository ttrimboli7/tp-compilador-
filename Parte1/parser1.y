%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern char *yytext;
extern int yylex(void);
extern int num_linea;
void yyerror(const char *s);

int errLexicos = 0;
int errSintacticos = 0;
int errSemanticos = 0;

#define MAX_SIMBOLOS 1000

typedef struct {
    char nombre[33];
    int inicializada;
} Simbolo;

Simbolo tablaSimbolos[MAX_SIMBOLOS];
int cantSimbolos = 0;

int procesarIdentificador(char* id) {
    for (int i = 0; i < cantSimbolos; i++) {
        if (strcmp(tablaSimbolos[i].nombre, id) == 0) {
            return i;
        }
    }

    if (cantSimbolos >= MAX_SIMBOLOS) {
        printf(">> [Error Semantico - Linea %d]: La tabla de simbolos esta llena.\n", num_linea);
        errSemanticos++;
        return -1;
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
        printf(">> [Error Semantico - Linea %d]: La variable '%s' se usa sin haber recibido un valor (no se leyo ni se le asigno antes).\n",
               num_linea, id);
        errSemanticos++;
        tablaSimbolos[idx].inicializada = 1;
    }
}
%}

%union {
    char* cadena;
    int num;
}

%define parse.error verbose

%token END 0 "fin de archivo"
%token INICIO "inicio"
%token FIN "fin"
%token LEER "leer"
%token ESCRIBIR "escribir"
%token ASIGNACION "asignacion (:=)"
%token PYCOMA "punto y coma"
%token COMA "coma"
%token SUMA "operador +"
%token RESTA "operador -"
%token PARENIZQUIERDO "parentesis izquierdo"
%token PARENDERECHO "parentesis derecho"

%token <cadena> ID "identificador"
%token <num> CONSTANTE "constante"

%%

programa: INICIO listaSentencias FIN
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
    | error PYCOMA {
        printf(">> Se descarto la sentencia incorrecta (hasta la linea %d).\n", num_linea);
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

static void traducirEsperado(char *dst, size_t n, const char *src) {
    size_t j = 0;
    while (*src && j + 4 < n) {
        if (strncmp(src, " or ", 4) == 0) {
            memcpy(dst + j, " o ", 3);
            j += 3;
            src += 4;
        } else {
            dst[j++] = *src++;
        }
    }
    dst[j] = '\0';
}

void yyerror(const char *s) {
    const char *inesperado = strstr(s, "unexpected ");
    const char *esperado = strstr(s, ", expecting ");
    char encontrado[128] = "";
    char lista[256] = "";

    errSintacticos++;
    printf(">> [Error Sintactico - Linea %d]: ", num_linea);

    if (inesperado) {
        size_t len;
        inesperado += strlen("unexpected ");
        len = esperado ? (size_t)(esperado - inesperado) : strlen(inesperado);
        if (len >= sizeof encontrado) len = sizeof encontrado - 1;
        memcpy(encontrado, inesperado, len);
        encontrado[len] = '\0';

        printf("se encontro %s", encontrado);
        if (strcmp(encontrado, "identificador") == 0 || strcmp(encontrado, "constante") == 0) {
            printf(" '%s'", yytext);
        }
    } else {
        printf("%s", s);
    }

    if (esperado) {
        esperado += strlen(", expecting ");
        traducirEsperado(lista, sizeof lista, esperado);
        printf(", se esperaba %s", lista);
    }
    printf(".\n");
}

int main() {
    int ret, total;

    printf("Iniciando compilador de Lenguaje Micro...\n\n");
    ret = yyparse();
    total = errLexicos + errSintacticos + errSemanticos;

    printf("\n");
    if (total == 0 && ret == 0) {
        printf("--- Compilacion exitosa: 0 errores ---\n");
        return 0;
    }
    printf("--- Compilacion con errores: %d lexico(s), %d sintactico(s), %d semantico(s) ---\n",
           errLexicos, errSintacticos, errSemanticos);
    return 1;
}
