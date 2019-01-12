%{
	#include <stdio.h>
     #include <string.h>

	int yylex();
	int yyerror(const char *msg);

     int EsteCorecta = 1;
	char msg[500];

	class TVAR
	{
	     char* nume;
	     int valoare;
	     TVAR* next;
	     public: static bool for_declare;
	     public: static bool for_read;

	  
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, int v = -1);
	     TVAR();
	     int exists(char* n);
             void add(char* n, int v = -1);
             int getValue(char* n);
	     void setValue(char* n, int v);
	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

	TVAR::TVAR(char* n, int v)
	{
	 this->nume = new char[strlen(n)+1];
	 strcpy(this->nume,n);
	 this->valoare = v;
	 this->next = NULL;
	}

	TVAR::TVAR()
	{
	  TVAR::head = NULL;
	  TVAR::tail = NULL;
	}

	int TVAR::exists(char* n)
	{
	  TVAR* tmp = TVAR::head;
	  while(tmp != NULL)
	  {
	    if(strcmp(tmp->nume,n) == 0)
	        return 1;
            tmp = tmp->next;
	  }
	  return 0;
	 }

         void TVAR::add(char* n, int v)
	 {
	   TVAR* elem = new TVAR(n, v);
	   if(head == NULL)
	   {
	     TVAR::head = TVAR::tail = elem;
	   }
	   else
	   {
	     TVAR::tail->next = elem;
	     TVAR::tail = elem;
	   }
	 }

         int TVAR::getValue(char* n)
	 {
	   TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0)
	      return tmp->valoare;
	     tmp = tmp->next;
	   }
	   return -1;
	  }

	  void TVAR::setValue(char* n, int v)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
		tmp->valoare = v;
	      }
	      tmp = tmp->next;
	    }
	  }
	
	bool TVAR::for_declare=true;
	bool TVAR::for_read=false;
	TVAR* ts = NULL;
%}

%code requires {
typedef struct punct { int x,y,z; } PUNCT;
}

%union { char* sir; int val; PUNCT p; }

%token TOK_PLUS TOK_MINUS TOK_MULTIPLY TOK_DIVIDE TOK_LEFT TOK_RIGHT TOK_DECLARE TOK_READ TOK_WRITE TOK_ERROR
%token TOK_ASSIGN TOK_PROGRAM TOK_BEGIN TOK_END TOK_INT TOK_INTEGER TOK_FOR TOK_DO TOK_TO TOK_VAR
%token <val> TOK_NUMBER
%token <sir> TOK_ID

%type <val> term exp factor 

%start prog

%left TOK_PLUS TOK_MINUS
%left TOK_MULTIPLY TOK_DIVIDE

%%
prog : 
    | 
    TOK_PROGRAM prog_name TOK_DECLARE dec_list end_dec TOK_BEGIN stmt_list TOK_END '.'  
    ;
prog_name : TOK_ID
	{
		if(ts!=NULL)
		{
			if(ts->exists($1)==0)
				ts->add($1);
			else
			{
				sprintf(msg,"%d:%d Eroare semantica: Declaratii multiple pentru variabila %s!", @1.first_line, 					@1.first_column, $1);
			        yyerror(msg);
				EsteCorecta = 0;
			        YYERROR;
			}  
		}
		else
		{
			ts = new TVAR();
			ts->add($1);
		}
	}
    ;
dec_list : dec
	|
	dec_list ';' dec
	|
	error TOK_BEGIN
        { EsteCorecta = 0; printf("Linia:%d Coloana:%d \n\n",@2.first_line,@2.first_column); }
	;
dec : id_list ':' type
		;
end_dec : { TVAR::for_declare=false; } 
	;
type : TOK_INTEGER
	;
id_list : TOK_ID
	{
		if(TVAR::for_declare==true)
		{			
			if(ts->exists($1)==0)
				ts->add($1);
			else
			{
				sprintf(msg,"%d:%d Eroare semantica: Declaratii multiple pentru variabila %s!", @1.first_line, 					@1.first_column, $1);
			        yyerror(msg);
				EsteCorecta = 0;
			}  
		}
		if(TVAR::for_declare==false)
		{
			if(ts->exists($1)==1)
			{
				if(ts->getValue($1)==-1&&TVAR::for_read==false)
				{
					sprintf(msg,"%d:%d Eroare semantica: Variablia '%s' nu a fost initializata !", @1.first_line, 						@1.first_column, $1);
			       		yyerror(msg);
					EsteCorecta = 0;
				}
				else
					;//$$=ts->getValue($1);
			}
			else
			{
				sprintf(msg,"%d:%d Eroare semantica: Variablia '%s' nu a fost declarata !", @1.first_line, 					@1.first_column, $1);
			        yyerror(msg);
				EsteCorecta = 0;
			}  
		}
	}
	|
	id_list ',' TOK_ID
	{
		if(TVAR::for_declare==true)
		{			
			if(ts->exists($3)==0)
				ts->add($3);
			else
			{
				sprintf(msg,"%d:%d Eroare semantica: Declaratii multiple pentru variabila %s!", @3.first_line, 					@3.first_column, $3);
			        yyerror(msg);
				EsteCorecta = 0;
			}  
		}
		else
		{
			if(ts->exists($3)==1&&TVAR::for_read==false)
			{
				if(ts->getValue($3)==-1)
				{
					sprintf(msg,"%d:%d Eroare semantica: Variablia '%s' nu a fost initializata !", @3.first_line, 						@3.first_column, $3);
			       		yyerror(msg);
					EsteCorecta = 0;
				}
				else
					;//$$=ts->getValue($1);
			}
			else
			{
				sprintf(msg,"%d:%d Eroare semantica: Variablia '%s' nu a fost declarata !", @3.first_line, 					@3.first_column, $3);
			        yyerror(msg);
				EsteCorecta = 0;
			}  
		}
	}
	;
stmt_list : stmt
	|
	stmt_list ';' stmt
	|
	error ';'
	{ EsteCorecta = 0; printf("Linia:%d Coloana:%d \n\n",@2.first_line-1,@2.first_column); }
	;
stmt : assign
	| 
	read
	|
	write	
	|
	for
	;
assign : TOK_ID TOK_ASSIGN exp
	{			
		if(ts->exists($1)==1)
			ts->setValue($1,$3);
		else
		{
			sprintf(msg,"%d:%d Eroare semantica: Variablia '%s' nu a fost declarata !", @1.first_line, 					@1.first_column, $1);
			yyerror(msg);
			EsteCorecta = 0;
			//YYERROR;
		}  
	}
	;
exp : term
	|
	exp TOK_PLUS term {$$ = $1+$3; }
	|
	exp TOK_MINUS term {$$ = $1-$3; }
	;
term : factor
	|
	term TOK_MULTIPLY factor {$$ = $1*$3; }
	|
	term TOK_DIVIDE factor
	{ 
	  if($3 == 0) 
	  { 
	      sprintf(msg,"%d:%d Eroare semantica: Impartire la zero!", @1.first_line, @1.first_column);
	      yyerror(msg);
	      EsteCorecta = 0;
	      YYERROR;
	  } 
	  else { $$ = $1 / $3; } 
	}
	;
factor : TOK_ID 
	{	
		if(ts->exists($1)==1)
			$$ = ts->getValue($1);
		else
		{ 
		      sprintf(msg,"%d:%d Eroare semantica: Variablia '%s' nu a fost declarata !", @1.first_line, @1.first_column,$1);
		      yyerror(msg);
		      EsteCorecta = 0;
		     // YYERROR;
	  	} 
	}
	|
	TOK_NUMBER
	|
	TOK_LEFT exp TOK_RIGHT {$$ = $2;}
	;
read : {TVAR::for_read=true;} TOK_READ TOK_LEFT id_list TOK_RIGHT {TVAR::for_read=false;}
	;
write : TOK_WRITE TOK_LEFT id_list TOK_RIGHT
	;
for : TOK_FOR index_exp TOK_DO body
	|
	error body
	{EsteCorecta = 0; printf("Linia:%d Coloana:%d \n\n",@1.first_line,@1.first_column);}	
	;
index_exp : TOK_ID TOK_ASSIGN exp TOK_TO exp	
	|
	error TOK_TO
	{EsteCorecta = 0; printf("Linia:%d Coloana:%d \n\n",@1.first_line,@1.first_column);}	
	;
body : stmt
	|
	TOK_BEGIN stmt_list TOK_END
	;

%%

int main()
{
	yyparse();
	
	if(EsteCorecta == 1)
	{
		printf("CORECTA\n");		
	}	

       return 0;
}

int yyerror(const char *msg)
{
	printf("Error: %s\n", msg);
	return 1;
}
