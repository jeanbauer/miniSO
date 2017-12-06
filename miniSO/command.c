/*
 * Universidade Luterana do Brasil
 * Curso de Bacharelado em Ciência da Computação
 * Disciplina: Projeto de Sistemas Operacionais
 * Professor: Roland Teodorowitsch
 *
 * Arquivo: command.c
 * Assunto: Interpretador de comandos
 *
 */


/* --- INCLUSÃO DE ARQUIVOS ------------------------------*/

#include "miniSO.h"
#include "command.h"
#include "lib.h"


/* --- VARIÁVEIS GLOBAIS ---------------------------------*/

static int	end_command;	/* Controla o fim de execução do interpretador de comandos */
/* Variáveis para leitura da linha de comandos */
static char	cmdline [MAXLINE+1];
static char	palavra [MAXLINE+1];
static char	argline [MAXLINE+1+MAXARGS*VAR_VALOR_TAM];
static char far *argv [MAXARGS];
/* Variáveis para controle do histórico */
static char	history [MAXHISTORY][MAXLINE+1];
static int	history_len;	/* Número de itens no histórico */
static int	history_ini;	/* Indice do primeiro item do histórico */
static int	history_nxt;	/* Próximo item do histórico */
static int	history_pos;	/* Posição para navegação no histórico */

/* Variáveis para definição de variáveis internas */
static int num_var = 0;		/* Número de variáveis definidas */
static variable_t var[VAR_MAX];	/* Conteúdo das variáveis definidas */
/* Tabela de comandos internos */
static command_t commands[MAXCOMMANDS] = {
  "?","                   exibe estas informacoes",				cmd_help,
  "help","                exibe estas informacoes",				cmd_help,
  "ver","                 mostra a versao do MSO",				cmd_ver,
  "date","                mostra a data",					cmd_date,
  "time","                mostra a hora",					cmd_time,
  "cls","                 limpa a tela",					cmd_cls,
  "clear","               limpa a tela",					cmd_cls,
  "reboot","              reinicializa o sistema",				cmd_reboot,
  "exit","                abandona o sistema",					cmd_exit,
  "quit","                abandona o sistema",					cmd_exit,
  "ps","                  exibe processos/threads em execucao",			cmd_ps,
  "kill"," <pid>          encerra um processo/thread",				cmd_kill,
  "demo"," <exitcode>     inicia processos/threads de demonstracao",		cmd_demo,
  "set"," [<var> [<val>]] define o valor da variavel ou exibe variaveis",	cmd_set, 
  "unset"," <var>         apaga a variavel",					cmd_unset,
  "echo"," [-n] <args>... imprime argumentos",					cmd_echo,
  "waitpid"," <pid>       espera pelo processo-filho indicado",			cmd_waitpid,
  "wait","                espera por um processo-filho",			cmd_wait,
  "semls","               lista tabela de semaforos",				cmd_semls,
  "semcreate"," <value>   cria um semaforo",					cmd_semcreate,
  "semtest"," <semid>     aplicacao para teste de semaforos",			cmd_semtest,
  "semup"," <semid>       incrementa o valor de um semaforo",			cmd_semup,
  "semdestroy"," <semid>  destroi um semaforo",					cmd_semdestroy,
  "stop"," <pid> suspende um processo/thread",                  cmd_stop,
  "resume"," <pid> reinicia um processo/thread",                cmd_resume,
  "prodcons"," inicia o processo consumidor e produtor", cmd_prodcons,
  "tprod","  inicia produtor", cmd_tprod,
  "tcons","  inicia consumidor", cmd_tcons
};


/* --- SESSAO CRITICA (variaveis) ------------------------*/
static int buffer[20];

static long segundoDoProcessador = 600000; // varia de processador para processador

static int tamanhoDoBuffer = 0;
static int tempoDeProducao;
static int tempoDeConsumo;

static semid_t mutex;
static semid_t vazio;
static semid_t cheio;


/* --- FUNÇÕES -------------------------------------------*/

void command()
{
  char car,str[10];
  int numcar;
  int i,achou,pos;
  int novalinha,res,argc;
  char far *ptrline,far *var;
    
  /* Inicializações... */
  numcar = 0;
  end_command = 0;
  history_ini = 0;
  history_nxt = 0;
  history_pos = -1;
  /* Mensagem inicial */
  setcolor(7);
  clrscr();
  setcolor(LOGOCOLOR);
  putstr("                  ÜÜÜÜÜÜÜ  ÜÜÜÜÜÜ\n");
  putstr(" ÜÜÜÜÜ  Ü  ÜÜÜ  Ü ÛÛ   ßß  ÛÛ  ÛÛ  "); setcolor(7); putstr("MinisSistema Operacional\n"); setcolor(LOGOCOLOR);
  putstr("ÜÛ Û Û ÜÛ ÜÛ Û ÜÛ ßßßßÛÛÛ ÛÛÛ  ÛÛ  "); setcolor(7); putstr("Vs "); putstr(miniSO_VERSION); putstr("\n"); setcolor(LOGOCOLOR);
  putstr("ÛÛ Û Û ÛÛ ÛÛ Û ÛÛ ÛÛÜÜÛÛÛ ÛÛÛÜÜÛÛ  "); setcolor(7); putstr("por Roland Teodorowitsch\n");
  putstr("ÛÛ Û Û ÛÛ ÛÛ Û ÛÛ ÛÛÜÜÛÛÛ ÛÛÛÜÜÛÛ  "); setcolor(7); putstr("alteracoes por Jean Bauer\n");

  putstr("\nDigite 'help' ou '?' para ajuda...\n\n");

  putstr("\nModificado em 25/10/2017\n\n");
  putstr("\nPor Jean... testando output\n\n");

  /* Inicializa variáveis de ambiente */
  command_var_init();
  command_var_set("PROMPT","miniSO>");
  command_var_set("ERRORLEVEL","0");
  /* Imprime sinal de pronto */
  command_showprompt();
  /* Laço para interpretação de comandos */
  while ( !end_command )  {
        car=getch();
        switch (car)  {
               case 9:
                    break;
               case 8:
                    if (numcar>0)  {
                       --numcar;
                       command_backspace();
                    }
                    break;
               case 27:
                    /* Limpa a linha de comandos */
                    while (numcar>0)  {
                          --numcar;
                          command_backspace();
                    }
                    break;
               case 0:
                    car=getch();
                    switch (car)  {
                           case 65: /* F7 */
                                history_pos = -1;
                                /* Limpa a linha de comandos */
                                while (numcar>0)  {
                                      --numcar;
                                      command_backspace();
                                }
                                putch('\n');
                                /* Imprime o histórico */
                                for (i=0;i<history_len;++i)  {
                                    putstr(history[(history_ini+i)%MAXHISTORY]);
                                    putch('\n');
                                }
                                command_showprompt();
                                break;
                           case 75: /* Seta para esquerda */
                                if (numcar>0)  {
                                   --numcar;
                                   command_backspace();
                                }
                                break;
                           case 72: /* Seta para cima */
                                if (history_len>0)  {
                                   novalinha=0;
                                   if (history_len<MAXHISTORY)  {
                                      if (history_pos==-1)  {
                                         history_pos=history_nxt-1;
                                         novalinha=1;
                                      }
                                      else  {
                                         if (history_pos>0)  {
                                            history_pos--;
                                            novalinha=1;
                                         }
                                      }
                                   }
                                   else  {
                                      if (history_pos==-1)  {
                                         history_pos=history_nxt-1;
                                         if (history_pos<0)
                                            history_pos=MAXHISTORY-1;
                                         novalinha=1;
                                      }
                                      else  {
                                         if (history_pos!=history_ini)  {
                                            novalinha=1;
                                            if (history_pos>history_ini)
                                               --history_pos;
                                            else  {  /* history_pos<history_ini */
                                               if (history_pos>0)
                                                  history_pos--;
                                               else
                                                  history_pos=MAXHISTORY-1;
                                             }
                                         }
                                      }
                                   }
                                   if (novalinha)  {
                                      /* Limpa a linha de comandos */
                                      while (numcar>0)  {
                                            --numcar;
                                            command_backspace();
                                      }
                                      strcpy(cmdline,history[history_pos]);
                                      putstr(cmdline);
                                      numcar=strlen(cmdline);
                                   }
                                }
                                break;
                           case 80: /* Seta para baixo */
                                if (history_len>0 && history_pos!=-1)  {
                                   if (history_len<MAXHISTORY)  {
                                      if (history_pos<history_len-1)
                                         history_pos++;
                                      else
                                         history_pos = -1;
                                   }
                                   else  {
                                      history_pos++;
                                      if (history_pos>=MAXHISTORY)
                                         history_pos = 0;
                                      if (history_pos==history_nxt)
                                         history_pos = -1;
                                   }
                                   /* Limpa a linha de comandos */
                                   while (numcar>0)  {
                                         --numcar;
                                         command_backspace();
                                   }
                                   if (history_pos!=-1)  {
                                      strcpy(cmdline,history[history_pos]);
                                      putstr(cmdline);
                                      numcar=strlen(cmdline);
                                   }
                                }
                                break;
                    }
                    break;
               case 13:
                    history_pos = -1;
                    putch('\n');
                    cmdline[numcar]='\0';
                    /* Divide a linha de comandos em comando e opções */
                    ptrline = cmdline;
                    argc = 0;
                    pos = 0;
                    while (1) {
                          while (*ptrline!='\0' && (*ptrline==' ' || *ptrline=='\t'))
                                ++ptrline;
                          if (*ptrline=='\0')
                             break;
                          i = 0;     
                          while (*ptrline!='\0' && *ptrline!=' ' && *ptrline!='\t')  {
                                palavra[i++] = *ptrline;
                                ++ptrline;
                          }
                          palavra[i] = '\0';
                          if (palavra[0]=='$')  {
                             var = command_var_value(&palavra[1]);
                             if (var!=NULL)  {
                                strcpy(palavra,var);
                                i = strlen(palavra);
                             }
                             else
                                continue;
                             
                          }
                          strcpy(&argline[pos],palavra);
                          argv[argc++] = &argline[pos];
                          pos+= (i+1);
                          if (*ptrline=='\0')
                             break;
                          ++ptrline;
                    }
                    /* Se é comando vazio não faz nada */
                    if (argc==0)  {
                       command_showprompt();
                       break;
                    }
                    /* Salva linha de comando no histórico */
                    strcpy (history[history_nxt],cmdline);
                    if (history_len<MAXHISTORY)
                       ++history_len;
                    else  {
                       if (history_ini==MAXHISTORY-1)
                          history_ini = 0;
                       else
                          ++history_ini;
                    }
                    if (history_nxt==MAXHISTORY-1)
                       history_nxt = 0;
                    else
                       ++history_nxt;
                    /* Verifica qual é o comando ... */
                    achou = 0;
                    for (i=0;i<MAXCOMMANDS;++i)  {
                        if (strcmp(argv[0],commands[i].name)==0)  {
                           achou=1;
                           break;
                        }
                    }

                    /* Executa o comando */
                    if (achou)  {
                       res = commands[i].code(argc,argv);
                       inttostr(str,res);
                       command_var_set("ERRORLEVEL",str);
                    }
                    else
                       putstr("Erro: comando desconhecido!\n");

                    if (!end_command)
                       command_showprompt();

                    numcar=0;
                    break;
               default:
                    if (numcar<MAXLINE)  {
                       putch(car);
                       cmdline[numcar++]=car;
                    }
        }
  }

}



static void command_backspace()
{
  int x,y;

  x = wherex();
  y = wherey();
  --x;
  gotoxy(x,y);
  putch(' ');
  gotoxy(x,y);
}



static void command_showprompt()
{
  char cor;
  char far *prompt;

  prompt = command_var_value("PROMPT");
  if (prompt!=NULL)  {
     cor = getcolor();
     setcolor(PROMPTCOLOR);
     putstr(prompt);
     setcolor(cor);
  }
  putch(' ');
}



static void command_var_init()
{
  int i;

  for (i=0;i<VAR_MAX;++i)  {
      var[i].name[0]='\0';
      var[i].value[0]='\0';
  }
  num_var = 0;
}



static int command_var_nextfree()
{
  int i;

  if (num_var>=VAR_MAX)
     return -1;
  for (i=0;i<VAR_MAX;++i)
      if (var[i].name[0]=='\0')
         return i;
  return -1;
}



static void command_var_list()
{
  int i;
  char cor;

  cor = getcolor();
  for (i=0;i<VAR_MAX;++i)  {
      if (var[i].name[0]!='\0')  {
         putstr(var[i].name);
         putch('=');
         setcolor(VARCOLOR);
         putstr(var[i].value);
         setcolor(cor);
         putch('\n');
      }
  }
}



static int  command_var_search(char far *nome)
{
  int i;

  if (nome[0] == '\0')
     return -1;
  for (i=0;i<VAR_MAX;++i)  {
      if (strcmp(nome,var[i].name)==0)
         return i;
  }
  return -1;
}


static int  command_var_unset(char far *nome)
{
  int i;

  i = command_var_search(nome);
  if (i==-1)
     return -1;
  var[i].name[0]='\0';
  var[i].value[0]='\0';
  --num_var;
  return 0;
}


static char far *command_var_value(char far *nome)
{
  int i;

  i = command_var_search(nome);
  if (i==-1)
     return NULL;
  return var[i].value;
}


static int command_var_set(char far *nome,char far *valor)
{
  int i;

  if (strlen(nome)>VAR_NOME_TAM)
     return -3;
  if (strlen(valor)>VAR_VALOR_TAM)
     return -4;
  i = command_var_search(nome);
  if (i==-1)  {
     i = command_var_nextfree();
     if (i==-1)
        return -2;
     strcpy(var[i].name,nome);
  }
  strcpy(var[i].value,valor);
  return 0;
}


int cmd_reboot(int argc, char far *argv[])
{
  argc=argc;
  argv=argv;
  reboot();
  return 0;
}


int cmd_exit(int argc, char far *argv[])
{
  argc=argc;
  argv=argv;
  end_command = 1;
  return 0;
}


int cmd_help(int argc, char far *argv[])
{
  int i;

  argc=argc;
  argv=argv;
  putstr("Comandos do minisSistema Operacional:\n");
  for (i=0;i<MAXCOMMANDS;++i)  {
      putstr(commands[i].name);
      putstr(commands[i].help);
      putch('\n');
  }
  return 0;
}


int cmd_date(int argc, char far *argv[])
{
  struct date d;
  char str[20];

  argc=argc;
  argv=argv;



  getdate(&d);
  unsignedtostr(str,d.da_day,2,'0');
  putstr(str);
  putch('/');
  unsignedtostr(str,d.da_mon,2,'0');
  putstr(str);
  putch('/');
  unsignedtostr(str,d.da_year,4,'0');
  putstr(str);
  putch('\n');
  return 0;
}


int cmd_time(int argc, char far *argv[])
{
  struct time t;
  char str[20];

  argc=argc;
  argv=argv;
  gettime(&t);
  unsignedtostr(str,t.ti_hour,2,'0');
  putstr(str);
  putch(':');


  unsignedtostr(str,t.ti_min,2,'0');
  putstr(str);
  putch(':');
  unsignedtostr(str,t.ti_sec,2,'0');
  putstr(str);
  putch('\n');
  return 0;
}


int cmd_cls(int argc, char far *argv[])
{
  argc=argc;
  argv=argv;
  clrscr();
  return 0;
}


int cmd_ver(int argc, char far *argv[])
{
  argc=argc;
  argv=argv;
  putstr("minisSistema Operacional - Vs ");
  putstr(miniSO_VERSION);
  putch('\n');
  return 0;
}


int cmd_ps(int argc, char far *argv[])
{
  int i,l;
  static char str[20];
  extern miniSO_PCB miniSO_thread[];

  argc=argc;
  argv=argv;
  putstr(" BCP   PID   PPID  STATUS   WAIT   ZLIST  PREV   NEXT\n");
  for (i=0;i<miniSO_MAXTHREADS;++i)  {
      if (miniSO_thread[i].status!=FREE)  {
         inttostr(str,i);
         l=strlen(str);
         while (l++<3)
               putch(' ');
         putstr(str);
         putstr("  ");
         inttostr(str,miniSO_thread[i].pid);
         l=strlen(str);
         while (l++<5)
               putch(' ');
         putstr(str);
         putstr("  ");
         inttostr(str,miniSO_thread[i].ppid);
         l=strlen(str);
         while (l++<5)
               putch(' ');
         putstr(str);
         putstr("  ");
         switch(miniSO_thread[i].status)  {
               case FREE:    putstr(strFREE);    break;
               case READY:   putstr(strREADY);   break;
               case RUNNING: putstr(strRUNNING); break;
               case ZOMBIE:  putstr(strZOMBIE);  break;
               case WAIT:    putstr(strWAIT);    break;
               case WAITSIG: putstr(strWAITSIG); break;
               case WAITSEM: putstr(strWAITSEM); break;
               case STOPPED: putstr(strSTOPPED); break;
         }
         putstr("  ");
         inttostr(str,miniSO_thread[i].wait);
         l=strlen(str);
         while (l++<5)
               putch(' ');
         putstr(str);

         putstr("  ");
         inttostr(str,miniSO_thread[i].zombies);
         l=strlen(str);
         while (l++<5)
               putch(' ');
         putstr(str);

         putstr(" ");
         inttostr(str,miniSO_thread[i].prev);
         l=strlen(str);
         while (l++<5)
               putch(' ');
         putstr(str);

         putstr("  ");
         inttostr(str,miniSO_thread[i].next);
         l=strlen(str);
         while (l++<5)
               putch(' ');
         putstr(str);
         putch('\n');
      }
  }
  return 0;
}


int cmd_kill(int argc, char far *argv[])
{
  int t=0;
  pid_t pid=0;
  char str[10];

  if (argc<=1)  {
     putstr("Erro em kill: parametro nao fornecido!\n");
     return 1;
  }
  pid = atoi(argv[1]);
  t = kill(pid);
  if (t==miniSO_ERROR)  {
     putstr("kill: impossivel matar o processo/thread\n");
     return 1;
  }
  return 0;
}


int cmd_set(int argc, char far *argv[])
{
  int res;

  if (argc == 1)  {
     command_var_list();
     return 0;
  }
  if (argc == 2)
     res = command_var_set(argv[1],"");
  else if (argc == 3)
       res = command_var_set(argv[1],argv[2]);
  else
     res = -5;  
  switch (res)  {
         case -2:
              putstr("Erro em set: nao ha espaco para novas variaveis!\n");
              return 1;
         case -3:
              putstr("Erro em set: o tamanho do nome da variavel e muito grande!\n");
              return 1;
         case -4:
              putstr("Erro em set: o tamanho do conteudo da variavel e muito grande!\n");
              return 1;
         case -5:
              putstr("Erro em set: argumentos demais na linha de comando!\n");
              return 1;
  }
  return 0;
}


int cmd_unset(int argc, char far *argv[])
{
  int res;

  if (argc != 2)  {
     putstr("Erro em unset: numero invalido de argumentos!\n");
     return 1;
  }
  res = command_var_unset(argv[1]);
  if (res == -1)  {
     putstr("Erro em unset: variavel inexistente!\n");
     return 1;
  }
  return 0;
}


int cmd_echo(int argc, char far *argv[])
{
  int i,control_n=1;

  if (argc>1)  {
     if (strcmp(argv[1],"-n")==0)
        control_n = 0;
     else
        putstr(argv[1]);
     for (i=2;i<argc;++i)  {
         if (i!=2 || control_n)
            putch(' ');
         putstr(argv[i]);
     }             
  }
  if (control_n)
     putch('\n');
  return 0;
}


static void demo (void);

static int demo_linha = -4;
static int exitcode = 0;

void demo()
{
  extern int demo_linha;
  extern int exitcode;
  unsigned i;
  int ini = demo_linha;
  char str[20];
  int ec = exitcode;

  putstrxy(65,ini+0,"ÚÄÄ Thread ÄÄÄÄ¿");
  putstrxy(65,ini+1,"³ PID  =       ³");
  putstrxy(65,ini+2,"³ Execucao:    ³");
  putstrxy(65,ini+3,"³              ³");
  putstrxy(65,ini+4,"ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ");

  inttostr(str,getpid());
  putstrxy(74,ini+1,str);

  for (i=0;i<60000U;++i)  {
      unsignedtostr(str,i,5,'0');
      putstrxy(70,ini+3,str);
  }
  for (i=0;i<60000U;++i)  {
      unsignedtostr(str,i,5,'0');
      putstrxy(70,ini+3,str);
  }
  for (i=0;i<60000U;++i)  {
      unsignedtostr(str,i,5,'0');
      putstrxy(70,ini+3,str);
  }
  for (i=0;i<60000U;++i)  {
      unsignedtostr(str,i,5,'0');
      putstrxy(70,ini+3,str);
  }
  for (i=0;i<60000U;++i)  {
      unsignedtostr(str,i,5,'0');
      putstrxy(70,ini+3,str);
  }
  for (i=0;i<60000U;++i)  {
      unsignedtostr(str,i,5,'0');
      putstrxy(70,ini+3,str);
  }
  exit(ec);
}


int cmd_demo(int argc, char far *argv[])
{
	extern int demo_linha;

	if	(argc != 2)  {
		putstr("Erro em demo: numero invalido de argumentos!\n");
		return 1;
	}
	demo_linha += 5;
	if	(demo_linha >21)
		demo_linha = 1;
	exitcode = atoi(argv[1]);
	if	(fork(demo)==miniSO_ERROR)  {
		putstr("Erro em demo: fork() nao conseguiu criar thread!\n");
		return 1;
	}
	return 0;
}

int cmd_waitpid(int argc, char far *argv[])
{
	int	status;
	pid_t	pid;
	char	str[20];

	if	(argc != 2)  {
		putstr("Erro em waitpid: numero invalido de argumentos!\n");
		return 1;
	}
	pid = atoi(argv[1]);
	pid = waitpid(pid,&status);
	putstr("Processo ");
	inttostr(str,pid);
	putstr(str);
	putstr(" encerrado com codigo de fim ");
	inttostr(str,status);
	putstr(str);
	putstr("!\n");
	return 0;
}


int cmd_wait(int argc, char far *argv[])
{
	int	status=123;
	pid_t	pid;
	char	str[20];

	argc=argc;
	argv=argv;
	pid = wait(&status);
	putstr("Processo ");
	inttostr(str,pid);
	putstr(str);
	putstr(" encerrado com codigo de fim ");
	inttostr(str,status);
	putstr(str);
	putstr("!\n");
	return 0;
}


int cmd_semls(int argc, char far *argv[])
{
	int i,n=0;
	char str[20];
	extern miniSO_SEM miniSO_sem[miniSO_MAXSEMAPHORES];

	argc=argc;
	argv=argv;
	putstr("Semaphores:\n");
	for	(i=0;i<miniSO_MAXSEMAPHORES;++i)
		if	(miniSO_sem[i].status!=FREE) {
			putstr("- id=");
			inttostr(str,miniSO_sem[i].semid);
			putstr(str);
			putstr(" value=");
			inttostr(str,miniSO_sem[i].value);
			putstr(str);
			putstr(" queue=");
			inttostr(str,miniSO_sem[i].queue);
			putstr(str);
			putch('\n');
			++n;
		}
	putstr("TOTAL=");
	inttostr(str,n);
	putstr(str);
	putstr("\n\n");
	return 0;
}


int cmd_semcreate(int argc, char far *argv[])
{
	int	res,value;
	semid_t	semid;
	char	str[20];

	if	(argc != 2)	{
		putstr("Erro em semcreate: numero invalido de argumentos!\n");
		return 1;
	}
	value = atoi(argv[1]);
	semid = semcreate(value);
	if	(semid==miniSO_ERROR)
		return 1;
	putstr("Semaforo id=");
	inttostr(str,semid);
	putstr(str);
	putstr(" criado (value=");
	inttostr(str,value);
	putstr(str);
	putstr(")\n");
	return 0;
}


semid_t semid;

void sem_aplic()
{
	extern int demo_linha;
	extern semid_t semid;
	unsigned i;
	int ini = demo_linha;
	char str[20];

	putstrxy(65,ini+0,"ÚÄÄ Thread ÄÄÄÄ¿");
	putstrxy(65,ini+1,"³ PID  =       ³");
	putstrxy(65,ini+2,"³ Execucao:    ³");
	putstrxy(65,ini+3,"³              ³");
	putstrxy(65,ini+4,"ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ");

	inttostr(str,getpid());
	putstrxy(74,ini+1,str);
	for	(i=0;i<30000U;++i)  {
		unsignedtostr(str,i,5,'0');
		putstrxy(70,ini+3,str);
	}
	semdown(semid);
	for	(;i<60000U;++i)  {
		unsignedtostr(str,i,5,'0');
		putstrxy(70,ini+3,str);
 	}
	exit(0);
}


int cmd_semtest(int argc, char far *argv[])
{
	extern int demo_linha;
	extern semid_t semid;

	if	(argc != 2)	{
		putstr("Erro em semtest: numero invalido de argumentos!\n");
		return 1;
	}
	semid = atoi(argv[1]);
	demo_linha += 5;
	if	(demo_linha >21)
		demo_linha = 1;
	if	(fork(sem_aplic)==miniSO_ERROR)  {
		putstr("Erro em demo: fork() nao conseguiu criar thread!\n");
		return 1;
 	}
	return 0;
}


int cmd_semup(int argc, char far *argv[])
{
	semid_t semid;

	if	(argc != 2)	{
		putstr("Erro em semtest: numero invalido de argumentos!\n");
		return 1;
	}
	semid = atoi(argv[1]);
	return semup(semid);
}


int cmd_semdestroy(int argc, char far *argv[])
{
	semid_t semid;

	if	(argc != 2)	{
		putstr("Erro em semtest: numero invalido de argumentos!\n");
		return 1;
	}
	semid = atoi(argv[1]);
	return semdestroy(semid);
}

int cmd_stop(int argc, char far *argv[]){
    int t=0;
    pid_t pid=0;
    if(argc<2) {
        putstr("stop: nenhum parametro foi fornecido\n");
        return miniSO_ERROR;
    }
    pid = atoi(argv[1]);
    t = stop(pid);
    if(t==miniSO_ERROR){ putstr("stop: impossivel suspender a thread\n");}
    return t; 
}

int cmd_resume(int argc, char far *argv[]){
    int t=0;
    pid_t pid=0;
    if(argc<2){
        putstr("resume: nenhum parametro foi fornecido\n");
        return miniSO_ERROR;
    }
    pid = atoi(argv[1]);
    t = resume(pid);
    if(t==miniSO_ERROR){ putstr("resume: impossivel reiniciar a thread\n");}
    return t; 
}


void inicializaBuffer() {
    int i=0;
    for (; i < tamanhoDoBuffer; i++) buffer[i] = 0;
}

void imprimeConteudoBuffer() {
    char str[1];
    
    int i = 0;
    int x = 56;
    int y = demo_linha + 10;
    
    for(;i<tamanhoDoBuffer;i++) {
        inttostr(str, buffer[i]);
        putstrxy(x+2+i, y+8, str);
    }
}

void imprimeBuffer() {
    extern int demo_linha;
    int x = 56;
    int y = demo_linha + 10;
    char str[20];
    
    putstrxy(x, y+4, "              ");
    putstrxy(x, y+5, "              ");
    putstrxy(x, y+6, "   Prodcons   ");

    putstrxy(x, y+7, "Tamanho do buffer:");
    inttostr(str, tamanhoDoBuffer);
    putstrxy(x+17, y+7, str);
    
    putstrxy(x, y+8, "X ");
    imprimeConteudoBuffer();
    putstrxy(x+20, y+8, "  X");
    
    inttostr(str, tempoDeProducao);
    putstrxy(x, y+9, "Produtor:       ");
    putstrxy(x+12, y+9, str);
    
    inttostr(str, tempoDeConsumo);
    putstrxy(x, y+10, "Consumidor:       ");
    putstrxy(x+14, y+10, str);
    
    putstrxy(x, y+11, " --------------- ");
}


int incrementaPosicaoNoBuffer(pos) {
    return pos == tamanhoDoBuffer - 1 ? 0 : pos + 1;
}

void sleep(int segundos) {
    long i = 0;
    long j;
    
    for(;i < segundos; i++) {
        for(j=0; j < segundoDoProcessador; j++) {}
    }
}


int produz(pos) {
    buffer[pos] = 1;
    imprimeBuffer();
    return incrementaPosicaoNoBuffer(pos);
}

void produtor() {
    int posicaoDeProducao = 0;
    while(1) {
        semdown(vazio);
        semdown(mutex);
        
        posicaoDeProducao = produz(posicaoDeProducao);
        
        semup(mutex);
        semup(cheio);
        
        sleep(tempoDeProducao);
    }
    
}

int consome(pos) {
    buffer[pos] = 0;
    imprimeBuffer();
    return incrementaPosicaoNoBuffer(pos);
}

void consumidor() {
    int posicaoDeConsumo = 0;
    while(1) {
        semdown(cheio);
        semdown(mutex);
        
        posicaoDeConsumo = consome(posicaoDeConsumo);
        
        semup(mutex);
        semup(vazio);
        
        sleep(tempoDeProducao);
    }    
}

int cmd_prodcons(int argc, char far *argv[])
{
    
	if	(argc != 4)  {
		putstr("Erro em prodcons: numero invalido de argumentos!\n");
		return 1;
	}
	
    tempoDeProducao = atoi(argv[1]);
    tempoDeConsumo = atoi(argv[2]);
    tamanhoDoBuffer = atoi(argv[3]);
    
    if (tamanhoDoBuffer == 0) {
		putstr("Erro em prodcons: numero invalido de tamanho do buffer!\n");
		return 1;
	}
    
    mutex = semcreate(1);
    vazio = semcreate(tamanhoDoBuffer);
    cheio = semcreate(0);
    
    inicializaBuffer();
    
    imprimeBuffer();
    
    if (fork(produtor)==miniSO_ERROR) {
        putstr("Erro em prodcons: erro ao criar fork!\n");
        return 1;
    }
    
    if (fork(consumidor)==miniSO_ERROR) {
        putstr("Erro em prodcons: erro ao criar fork!\n");
        return 1;
    }
    
    sleep(tempoDeProducao);
	return 0;
}

int cmd_tprod(int argc, char far *argv[]) {
    if (argc != 2) {
        putstr("Erro em prodcons: numero invalido de argumentos!\n");
        return 1;
    }
    
    tempoDeProducao = atoi(argv[1]); return 0;
}

int cmd_tcons(int argc, char far *argv[]) {
    if (argc != 2) {
        putstr("Erro em prodcons: numero invalido de argumentos!\n");
        return 1;
    }
    
    tempoDeConsumo = atoi(argv[1]); return 0;
}


