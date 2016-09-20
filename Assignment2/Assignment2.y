%{
#include <stdio.h>
#include <stdlib.h>
	extern int yylex();
	extern int yyparse();
	extern FILE *yyin;
	FILE *output_file;
	extern int line_num;
	void yyerror(const char *s);
%}
%token IDENTIFIER TYPE INTEGER BOOLEAN 
%token START EQ SC OP CP OB CB OSB CSB ADDOP MULOP
%%
Program:
	START OP CP OB Declarations Statements CB { fprintf(output_file, "Program encountered\n");}
	;
Declarations:
	/* empty string */
	| Declarations Declaration
	| Declaration
	;
Declaration:
	TYPE IDENTIFIER SC {
	if (strcmp($1,"int") == 0) fprintf(output_file, "Int");
	else if (strcmp($1,"bool") == 0) fprintf(output_file, "Boolean");
	fprintf(output_file, " declaration encountered\nId=%s\n",$2);
	}
	| TYPE IDENTIFIER OSB INTEGER CSB SC {
	if (strcmp($1,"int") == 0) fprintf(output_file, "Int");
	else if (strcmp($1,"bool") == 0) fprintf(output_file, "Boolean");
	fprintf(output_file, " declaration encountered\nId=%s\nSize=%s\n",$2,$4);
	}
	;
Statements:
	/* empty string */
	| Statements Statement
	| Statement
	;
Statement:
	SC
	| Assignment
	;
Assignment:
	IDENTIFIER EQ Expression SC {fprintf(output_file, "Assignment operation encountered\n");}
	| IDENTIFIER OSB Expression CSB EQ Expression SC {fprintf(output_file, "Assignment operation encountered\n");}
	;
Expression:
	Term ADDOP Term { 
		if(strcmp($2,"+") == 0) fprintf(output_file, "Addition expression encountered\n");
		else fprintf(output_file, "Subtraction expression encountered\n");
	}
	| Term
	;
Term:
	Factor MULOP Factor {
		if (strcmp($2,"/") == 0) fprintf(output_file, "Division expression encountered\n");
		else if (strcmp($2,"*") == 0) fprintf(output_file, "Multiplication expression encountered\n");
		else if (strcmp($2,"%") == 0) fprintf(output_file, "Modulus expression encountered\n");
	}
	| Factor
Factor:
	IDENTIFIER
	| IDENTIFIER OSB Integer CSB
	| Literal
	| OP Expression CP
	;
Literal:
	Integer
	| BOOLEAN { fprintf (output_file, "Boolean literal encountered\nValue=%s\n",$1);} 
	;
Integer:
	INTEGER { fprintf (output_file, "Integer literal encountered\nValue=%s\n",$1);}
	;
%%
int main(int argc, char **argv) {
	output_file = fopen("bison_output.txt","w");

	if(argc == 1) yyerror("No Input File Given");

	FILE *input = fopen(argv[1], "r");

	if (!input)  yyerror("I can't open the given file!");
	yyin = input;
	
	do {
		yyparse();
	} while (!feof(yyin));
	printf("Success\n");
}
void yyerror(const char *s) {
	printf("Syntax Error at line %d\n",line_num);
	exit(-1);
}
