%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

int num_linea = 1;
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

{constEntera} {
    yylval.num = atoi(yytext);
    return CONSTANTE;
}

{IDENTIFICADOR} {
    yylval.cadena = strdup(yytext);
    return ID;
}

[ \t\r]+      ;
\n            { num_linea++; }

. {
    fprintf(stderr, ">> [Error Léxico - Línea %d]: Se encontró el carácter no permitido '%c'.\n", num_linea, yytext[0]);
    return ERROR_LEXICO;
}

%%

int yywrap() {
    return 1;
}
