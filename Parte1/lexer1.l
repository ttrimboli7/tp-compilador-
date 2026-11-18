%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

int num_linea = 1;
extern int errLexicos;
%}

DIGITO        [0-9]
LETRA         [a-zA-Z]
IDENTIFICADOR {LETRA}({LETRA}|{DIGITO})*
constEntera   {DIGITO}+

%%

"inicio"      { return INICIO; }
"fin"         { return FIN; }
"leer"        { return LEER; }
"escribir"    { return ESCRIBIR; }

":="          { return ASIGNACION; }
"+"           { return SUMA; }
"-"           { return RESTA; }
";"           { return PYCOMA; }
","           { return COMA; }
"("           { return PARENIZQUIERDO; }
")"           { return PARENDERECHO; }

":"           {
    printf(">> [Error Lexico - Linea %d]: Se encontro ':' solo; la asignacion se escribe ':='.\n", num_linea);
    errLexicos++;
    return ASIGNACION;
}

"="           {
    printf(">> [Error Lexico - Linea %d]: Se encontro '=' solo; la asignacion se escribe ':='.\n", num_linea);
    errLexicos++;
    return ASIGNACION;
}

{DIGITO}+{LETRA}({LETRA}|{DIGITO})* {
    printf(">> [Error Lexico - Linea %d]: '%s' no es valido: un identificador debe comenzar con una letra.\n", num_linea, yytext);
    errLexicos++;
    yylval.num = 0;
    return CONSTANTE;
}

{constEntera} {
    yylval.num = atoi(yytext);
    return CONSTANTE;
}

{IDENTIFICADOR} {
    char *copia = malloc(33);

    if (yyleng > 32) {
        printf(">> [Error Lexico - Linea %d]: El identificador '%s' tiene %d caracteres y el maximo permitido es 32.\n",
               num_linea, yytext, yyleng);
        errLexicos++;
    }
    strncpy(copia, yytext, 32);
    copia[32] = '\0';
    yylval.cadena = copia;
    return ID;
}

[ \t\r]+      ;
\n            { num_linea++; }

.             {
    printf(">> [Error Lexico - Linea %d]: Se encontro el caracter no permitido '%c'.\n", num_linea, yytext[0]);
    errLexicos++;
}

%%

int yywrap() {
    return 1;
}
