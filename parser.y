%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex(void);
int total_asignaciones = 0;
extern int num_linea;
%}

%union {
    char* cadena;
    int num;
}

%token ASIGNACION PYCOMA SUMA RESTA PARENIZQUIERDO PARENDERECHO
%token <cadena> ID
%token <num> CONSTANTE

%type <num> expresion primaria operadorAditivo

%%

programa: sentencias
;

sentencias: sentencias sentencia
| sentencia
;

sentencia: ID {
    if (strlen($1) > 10) {
        printf("[Error Semántico - Línea %d]: El identificador '%s' supera los 10 caracteres permitidos.\n", num_linea, $1);
    }
    total_asignaciones++;
} ASIGNACION expresion PYCOMA {
    printf("-> Asignación correcta procesada para la variable: %s\n", $1);
    free($1);
}
| error PYCOMA {
    yyerrok;
}
;

expresion: primaria { $$ = $1; }
| expresion operadorAditivo primaria {
    if ($2 == 1) {
        $$ = $1 + $3;
    } else {
        $$ = $1 - $3;
    }
}
;

primaria: ID {
    free($1);
    $$ = 0;
}
| CONSTANTE {
    if ($1 > 32767) {
        printf("[Alerta Semántica - Línea %d]: Constante grande detectada: %d\n", num_linea, $1);
    }
    $$ = $1;
}
| PARENIZQUIERDO expresion PARENDERECHO {
    $$ = $2;
}
;

operadorAditivo: SUMA { $$ = 1; }
| RESTA { $$ = -1; }
;

%%

int main() {
    printf("--- Compilador Micro Iniciado ---\n");
    yyparse();
    printf("Análisis concluido. Total de sentencias procesadas: %d\n", total_asignaciones);
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "[Error Sintáctico - Línea %d]: Fallo en la estructura de la sentencia (Detalle: %s)\n", num_linea, s);
}
