%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

extern char *yytext;
extern int yyleng;
extern int yylex(void);
extern void yyerror(const char*);
extern int num_linea;
%}

%union{
   char* cadena;
   int num;
}

%token ASIGNACION PYCOMA SUMA RESTA PARENIZQUIERDO PARENDERECHO
%token <cadena> ID
%token <num> CONSTANTE

%%

sentencias: sentencias sentencia
| sentencia
;

sentencia: ID {
    /* Rutina semántica: Validación de longitud máxima de 32 caracteres */
    if (yyleng > 32) {
        char msg[100];
        sprintf(msg, "El identificador '%s' supera el límite semántico de 32 caracteres", $1);
        yyerror(msg);
    }
} ASIGNACION expresion PYCOMA
;

expresion: primaria
| expresion operadorAditivo primaria
;

primaria: ID
| CONSTANTE
| PARENIZQUIERDO expresion PARENDERECHO
;

operadorAditivo: SUMA
| RESTA
;

%%

int main() {
    if (yyparse() == 0) {
        printf("Compilación finalizada exitosamente.\n");
    }
    return 0;
}

void yyerror(const char *s) {
    printf("[Error Sintáctico/Semántico - Línea %d]: %s\n", num_linea, s);
}
