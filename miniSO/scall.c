/*
 * Universidade Luterana do Brasil
 * Curso de Bacharelado em Ciência da Computação
 * Disciplina: Projeto de Sistemas Operacionais
 * Professor: Roland Teodorowitsch
 *
 * Arquivo: scall.c
 * Assunto: Chamadas de sistema basicas
 *
 */


#include "miniSO.h"
#include "scall.h"
#include "lib.h"


#define int_10h()  asm{ int 10h }
#define int_16h()  asm{ int 16h }
#define int_1ah()  asm{ int 1ah }
#define mov_ax(A)  _AX=A
#define mov_ah(A)  _AH=A
#define mov_al(A)  _AL=A
#define mov_bx(A)  _BX=A
#define mov_bh(A)  _BH=A
#define mov_bl(A)  _BL=A
#define mov_cx(A)  _CX=A
#define mov_ch(A)  _CH=A
#define mov_cl(A)  _CL=A
#define mov_dx(A)  _DX=A
#define mov_dh(A)  _DH=A
#define mov_dl(A)  _DL=A
#define dec_dl()   asm{ dec dl }
#define get_ax()   _AX
#define get_al()   _AL
#define get_ah()   _AH
#define get_bx()   _BX
#define get_bl()   _BL
#define get_bh()   _BH
#define get_cx()   _CX
#define get_cl()   _CL
#define get_ch()   _CH
#define get_dx()   _DX
#define get_dl()   _DL
#define get_dh()   _DH


static char miniSO_col   = 80;
static char miniSO_cor   = 0x07;
static char miniSO_pag   = 0;
static char miniSO_iskey = 0;
static char miniSO_key   = 0;


/* Tabela de semáforos */
miniSO_SEM miniSO_sem[miniSO_MAXSEMAPHORES];
/* Identificador de semáforos */
static semid_t nextsemid = 0;
/* Tabela de processos */
miniSO_PCB miniSO_thread[miniSO_MAXTHREADS];
/* Indice do primeiro elemento da lista de prontos */
pcb_t  miniSO_ready=-1;
/* Indice do primeiro BCP da lista de BCPs livres */
pcb_t  miniSO_free=-1;
/* Indica se a thread corrente foi excluida */
char   miniSO_delcurthread;
/* Proxima thread a ganhar a UCP, quando diferente de miniSO_NONE */
pcb_t  miniSO_nextthread;
/* Endereco da rotina de atendimento da interrupcao do relogio (original) */
void interrupt (*miniSO_oldisr)();

scall_t miniSO_scall_table[miniSO_NUMSCALL] = {
	{ SC_PUTCH,		1, (scfun0_t)sc_putch		},
	{ SC_GETCH,		0, (scfun0_t)sc_getch		},
	{ SC_CLRSCR,		0, (scfun0_t)sc_clrscr		},
	{ SC_GETCOLOR,		0, (scfun0_t)sc_getcolor	},
	{ SC_SETCOLOR,		1, (scfun0_t)sc_setcolor	},
	{ SC_WHEREX,		0, (scfun0_t)sc_wherex		},
	{ SC_WHEREY,		0, (scfun0_t)sc_wherey		},
	{ SC_GOTOXY,		2, (scfun0_t)sc_gotoxy		},
	{ SC_GETDATE,		2, (scfun0_t)sc_getdate		},
	{ SC_GETTIME,		2, (scfun0_t)sc_gettime		},
	{ SC_REBOOT,		0, (scfun0_t)sc_reboot		},
	{ SC_FORK,		2, (scfun0_t)sc_fork		},
	{ SC_KILL,		1, (scfun0_t)sc_kill		},
	{ SC_WAITPID,		3, (scfun0_t)sc_waitpid		},
	{ SC_WAIT,		2, (scfun0_t)sc_wait		},
	{ SC_EXIT,		1, (scfun0_t)sc_exit		},
	{ SC_GETPID,		0, (scfun0_t)sc_getpid		},
	{ SC_GETPPID,		0, (scfun0_t)sc_getppid		},
	{ SC_SENDSIGNAL,	2, (scfun0_t)sc_sendsignal	},
	{ SC_WAITSIGNAL,	1, (scfun0_t)sc_waitsignal	},
	{ SC_SEMCREATE,		1, (scfun0_t)sc_semcreate	},
	{ SC_SEMSET,		2, (scfun0_t)sc_semset		},
	{ SC_SEMUP,		1, (scfun0_t)sc_semup		},
	{ SC_SEMDOWN,		1, (scfun0_t)sc_semdown		},
	{ SC_SEMDESTROY,	1, (scfun0_t)sc_semdestroy	},
    { SC_STOP,          1, (scfun0_t)sc_stop}, 
    { SC_RESUME,        1, (scfun0_t)sc_resume}
};


/* PROTOTIPOS DE VARIAVEIS LOCAIS */
static void   setCursorPosition (int pos);
static int    getCursorPosition (void);
static void   scroll            (void);
static void   end_mso           (char *msg);
static pcb_t  get_pcb           (pid_t pid);


int scall(unsigned servico,unsigned bx,unsigned cx,unsigned dx)
{
	int	i;

	for	(i=0;i<miniSO_NUMSCALL;++i) {
		if	(servico==(unsigned)miniSO_scall_table[i].ah) {
			switch	(miniSO_scall_table[i].numparam)  {
				case	0:
					return miniSO_scall_table[i].function.p0();
				case	1:
					return miniSO_scall_table[i].function.p1(bx);
				case	2:
					return miniSO_scall_table[i].function.p2(bx,cx);
				case	3:
					return miniSO_scall_table[i].function.p3(bx,cx,dx);
			}
		}
	}
	return 0;
}


void setCursorPosition(int pos)
{
	mov_dx(pos);
	mov_bh(miniSO_pag);
	mov_ah(2);
	int_10h();
}


int getCursorPosition()
{
	mov_bh(miniSO_pag);
	mov_ah(3);
	int_10h();
	return _DX;
}


void scroll()
{
	mov_al(1); /* número de linhas para scroll */
	mov_cx(0);
	mov_ah(6);
	mov_dh(24);
	mov_dl(miniSO_col);
	dec_dl();
	mov_bh(miniSO_cor);
	int_10h();
}


int sc_putch(int car)
{
	int	curpos,lin,col;

	car = car & 0x00ff;
	if	(car==10)  {
		curpos = getCursorPosition();
		lin = (curpos >> 8) & 0x00ff;
		col = 0;
		if	(lin<24)
			++lin;
		else
			scroll();
	}
	else	{
		/* Imprime o caracter */
		mov_bl(miniSO_cor);
		mov_bh(miniSO_pag);
		mov_cx(1);
		mov_ah(0x9);
		int_10h();
		curpos = getCursorPosition();
		lin = (curpos >> 8) & 0x00ff;
		col = curpos & 0x00ff;
		++col;
		if	(col==miniSO_col)  {
			col = 0;
			if	(lin<24)
				++lin;
			else
				scroll();
		}
	}
	curpos = (lin << 8)|col;
	setCursorPosition(curpos);
	return 0;
}


int sc_getch()
{
  int ax,al,ah;

  if (miniSO_iskey!=0)  {
     miniSO_iskey = 0;
     return miniSO_key;
  }

  mov_ah(0x10);
  int_16h();

  ax = get_ax();
  ah = (ax >> 8) & 0x00ff;
  al = 0x00ff & ax;

  if (al==0xe0 || al==0x00)  {
     miniSO_iskey = 1;
     miniSO_key = ah;
     al = 0;
  }
  return al;
}


int sc_clrscr()
{
  mov_al(0);
  mov_cx(0);
  mov_dh(24);
  mov_dl(miniSO_col);
  dec_dl();
  mov_ah(6);
  mov_bh(7);
  int_10h();
  setCursorPosition(0);
  return 0;
}


int sc_getcolor()
{
  return miniSO_cor;
}


int sc_setcolor(int cor)
{
  miniSO_cor = cor;
  return 0;
}


int sc_wherex()
{
  return getCursorPosition() & 0x00ff;
}


int sc_wherey()
{
  return (getCursorPosition()>>8) & 0x00ff;
}


int sc_gotoxy(int x, int y)
{
  x = x & 0x00ff;
  y = (y<<8) & 0xff00;
  setCursorPosition(x|y);
  return 0;
}

int sc_getdate(unsigned seg, unsigned off)
{
  struct date far *dt;
  unsigned d,m,a;

  dt = MK_FP(seg,off);
  mov_ah(4);
  int_1ah();
  d=get_dl();
  m=get_dh();
  a=get_cx();
  dt->da_day  = 10*((d & 0xf0)>>4) + (d & 0x0f);
  dt->da_mon  = 10*((m & 0xf0)>>4) + (m & 0x0f);
  dt->da_year = 1000*((a & 0xf000)>>12) + 100*((a & 0x0f00)>>8) + 10*((a & 0x00f0)>>4) + (a & 0x000f);
  return 0;
}

int sc_gettime(unsigned seg,unsigned off)
{
  struct time far *tm;
  unsigned h,m,s;

  tm = MK_FP(seg,off);
  mov_ah(2);
  int_1ah();
  h=get_ch();
  m=get_cl();
  s=get_dh();
  tm->ti_hour = 10*((h & 0xf0)>>4) + (h & 0x0f);
  tm->ti_min  = 10*((m & 0xf0)>>4) + (m & 0x0f);
  tm->ti_sec  = 10*((s & 0xf0)>>4) + (s & 0x0f);
  tm->ti_hund = 0;
  return 0;
}

void miniSO_contextswitch ()
{
  if ( miniSO_nextthread == miniSO_NONE )
     miniSO_nextthread=miniSO_thread[miniSO_ready].next;
  /* Se houve alteracao de thread corrente ... */
  if (miniSO_nextthread!=miniSO_ready)  {
     if (miniSO_delcurthread)          /* Se a thread corrente foi excluida ... */
	miniSO_delcurthread=0;        /* zera o flag para deletado e nao captura SS:SP */
     else  {
	/* Salva SS:SP da thread corrente no BCP */
	miniSO_thread[miniSO_ready].ss=_SS;
	miniSO_thread[miniSO_ready].sp=_SP;
        if (miniSO_thread[miniSO_ready].status==RUNNING)
           miniSO_thread[miniSO_ready].status=READY;
     }
     /* Atualiza thread corrente */
     miniSO_ready=miniSO_nextthread;
     miniSO_thread[miniSO_ready].status=RUNNING;
     /* Define SS:SP para a thread corrente */
     _SS=miniSO_thread[miniSO_ready].ss;
     _SP=miniSO_thread[miniSO_ready].sp;

  }
  miniSO_nextthread = miniSO_NONE;
}



static void end_mso(char *msg)
{
  /* Restaura a interrupção do relógio original */
  setvect(miniSO_CLOCKINT,miniSO_oldisr);
  enable();
  putstr("\n\n");
  putstr(msg);
  putch('\n');
  putstr("Pressione uma tecla para reiniciar...\n");
  getch();
  /* Reinicializa a máquina */
  sc_reboot();
}




static pcb_t get_pcb(pid_t pid)
{
	pcb_t	pcb;

	for	(pcb=0;pcb<miniSO_MAXTHREADS;++pcb)  {
		if	( miniSO_thread[pcb].status!=FREE && miniSO_thread[pcb].pid==pid )
			return pcb;
	}
	return -1;
}


void miniSO_init_semtable()
{
	int i;

	for	(i=0;i<miniSO_MAXSEMAPHORES;++i)
		miniSO_sem[i].status = FREE;
}


void miniSO_init_proctable()
{
  pcb_t i;

  disable();

  /* Inicializa a tabela de semaforos */
  miniSO_init_semtable();
  /* Inicializa tabela de threads */
  miniSO_ready =  0;
  miniSO_thread[miniSO_ready].pid      = 0;
  miniSO_thread[miniSO_ready].ppid     = -1;
  miniSO_thread[miniSO_ready].next     = miniSO_ready;
  miniSO_thread[miniSO_ready].prev     = miniSO_ready;
  miniSO_thread[miniSO_ready].status   = RUNNING;
  miniSO_thread[miniSO_ready].recvsig  = 0;
  miniSO_thread[miniSO_ready].wait     = -1;
  miniSO_thread[miniSO_ready].zombies  = -1;
  /* O resto dos BCPs permanece na lista de livres */
  miniSO_free  =  1;
  for ( i=1 ; i<miniSO_MAXTHREADS-1 ; ++i)  {
      miniSO_thread[i].next   = i+1;
      miniSO_thread[i].status = FREE;
  }
  miniSO_thread[miniSO_MAXTHREADS-1].next   = -1;
  miniSO_thread[miniSO_MAXTHREADS-1].status = FREE;
  /* Zera tempos do sistema */
  miniSO_delcurthread  = 0;
  miniSO_nextthread = miniSO_NONE;
  /* Habilita as interrupcoes e retorna */
  enable();
}


int sc_reboot()
{
	/* Restaura a interrupção do relógio original */
	setvect(miniSO_CLOCKINT,miniSO_oldisr);
	enable();
	asm	{
		int	19h
	}
	return 0;
}


int sc_fork(unsigned cs, unsigned ip)
{
	pid_t		pid;
	pcb_t		pcb,last;
	unsigned far *	stack;
	static pid_t	nextpid=1; /* Número do próximo pid */
	extern void	miniSO_return_addr(void);

	/* Se o nucleo esta' instalado e existem BCPs livres insere no fim da lista ... */
	if	(miniSO_free == -1)
		return miniSO_ERROR;
	disable();
	/* Gera um pid para a thread */
	pcb = 0;
	while	(pcb!=-1)  {
		pcb = get_pcb (nextpid);
		if	(pcb==-1)
			pid = nextpid;
		if	(nextpid==32767)
			nextpid=1;
		else
			nextpid++;
	}
	/* Retira um BCP da lista de BCPs livres */
	pcb     = miniSO_free;
	miniSO_free = miniSO_thread[miniSO_free].next;
	miniSO_thread[pcb].pid = pid;
	miniSO_thread[pcb].ppid = miniSO_thread[miniSO_ready].pid;
	/* Cria pilha da thread */
	stack=(unsigned far *)MK_FP(miniSO_INITSTACKS+(miniSO_STACKSIZE>>4)*(miniSO_MAXTHREADS-1-pcb),miniSO_STACKSIZE);
	/* Empilha o endereco da funcao sc_exit, de modo que se    */
	/*  a thread sair da funcao sem chamar sc_exit, a thread */
	/*  seja automaticamente excluida */
	*(--stack)=0; /* Empilha código de fim a ser enviado para sc_exit */
	*(--stack)=miniSO_CODESEGMENT;
	*(--stack)=(unsigned)sc_exit;
	*(--stack)=0x0200 ;       /* FLAGS */
	*(--stack)=cs;            /* CS */
	*(--stack)=ip;            /* IP */
	*(--stack)=0;             /* AX */
	*(--stack)=0;             /* BX */
	*(--stack)=0;             /* CX */
	*(--stack)=0;             /* DX */
	*(--stack)=0;             /* ES */
	*(--stack)=miniSO_DATASEGMENT;/* DS */
	*(--stack)=0;             /* SI */
	*(--stack)=0;             /* DI */
	*(--stack)=0;             /* BP */
	*(--stack)=(unsigned)miniSO_return_addr;
	*(--stack)=0;             /* BP */
	/* Inicializa campos da nova thread */
	miniSO_thread[pcb].ss       = FP_SEG(stack);
	miniSO_thread[pcb].sp       = FP_OFF(stack);
	miniSO_thread[pcb].status   = READY;
	miniSO_thread[pcb].recvsig  = 0;
	miniSO_thread[pcb].waitsig  = 0;
	miniSO_thread[pcb].wait     = -1;
	miniSO_thread[pcb].waitfor  = -1;
	miniSO_thread[pcb].zombies  = -1;
	/* Descobre qual a ultima thread */
	last = miniSO_thread[miniSO_ready].prev;
	/* Acerta links para incluir a nova thread */
	miniSO_thread[pcb].prev      = last;
	miniSO_thread[pcb].next      = miniSO_ready;
	miniSO_thread[last].next     = pcb;
	miniSO_thread[miniSO_ready].prev = pcb;
	enable();
	return pid;
}


/* Função sc_kill() */
int sc_kill(pid_t pid)
{
	pcb_t pcb,pcbw,last,prevthread,nextthread,pai,i,ant;

	disable();
	/* Se remover a thread 0 ... */
	if	(pid==0)
		end_mso("kill(): thread 0 excluida!");
	/* Tem que verificar se existe a thread */
	pcb = get_pcb(pid);
	/* Se nao existe uma thread com este numero, entao retorna */
	if	(pcb==-1)  {
		enable();
		return miniSO_ERROR;
	}
	/* Trata os zumbis do processo, colocando-os na lista de livres */
	i = miniSO_thread[pcb].zombies;
	while	(i!= -1)  {
		miniSO_thread[pcb].zombies = miniSO_thread[i].next;
		miniSO_thread[i].next   = miniSO_free;
		miniSO_free             = i;
		miniSO_thread[i].status = FREE;
		i = miniSO_thread[pcb].zombies;
	}
	/* Passa os filhos do processo para o avo */
	for	(i=0;i<miniSO_MAXTHREADS;++i)  {
		if	(miniSO_thread[i].status!=FREE && miniSO_thread[i].ppid == miniSO_thread[pcb].pid)
			miniSO_thread[i].ppid = miniSO_thread[pcb].ppid;
	}
	/* Salva anterior e proximo da thread que sera deletada */
	prevthread = miniSO_thread[pcb].prev;
	nextthread = miniSO_thread[pcb].next;
	/* A thread pode estar em um de varios estados... */
	switch	(miniSO_thread[pcb].status)  {
		case	READY:
		case	RUNNING:
			/* Exclui o nodo da lista de prontos */
			miniSO_thread[prevthread].next=nextthread;
			miniSO_thread[nextthread].prev=prevthread;
			if	(pcb==miniSO_ready)  {
				if	(nextthread==miniSO_ready)
					end_mso("kill(): nao ha' mais threads executando!");
				else  {
					miniSO_nextthread=nextthread;
					miniSO_delcurthread=1;
				}
			}
			break;
		case	WAITSEM:
			/* Exclui o nodo da lista do semaforo */
			break;
		case	WAIT:
		case	WAITSIG:
        case    STOPPED:
			break;
		case	ZOMBIE:
		default:
			enable();
			return miniSO_ERROR;
	}
	/* Coloca o BCP da thread na lista de filhos zumbis do pai */
	pai = get_pcb(miniSO_thread[pcb].ppid);
	if	(pai==-1) { /* Se nao encontrou o pai, */
		/* coloca o processo na lista de livres */
		miniSO_thread[pcb].status = FREE;
		miniSO_thread[pcb].next = miniSO_free;
		miniSO_free=pcb;
	}
	else  {
		/* senao, coloca o processo na lista de zumbis do pai */
		miniSO_thread[pcb].status = ZOMBIE;
		if	(miniSO_thread[pai].zombies==-1) { /* Se a lista esta vazia */
			/* Insere no inicio */
			miniSO_thread[pai].zombies = pcb;
			miniSO_thread[pcb].prev = -1;
		}
		else {
			/* Senao insere no final */
			i = miniSO_thread[pai].zombies;
			while	(miniSO_thread[i].next!=-1)
				i = miniSO_thread[i].next;
			miniSO_thread[i].next = pcb;
			miniSO_thread[pcb].prev = i;
		}
		miniSO_thread[pcb].next = -1;
	}
	if	(miniSO_thread[pai].status==WAIT) {
	}
	/* REVISAR */
  /* Se o processo-pai esta' esperando em wait, coloca ele na lista de prontos */
  nextthread = miniSO_thread[pcb].wait;
  if (nextthread != -1)  {
     /* Descobre qual a ultima thread */
     last = miniSO_thread[miniSO_ready].prev;
     /* Acerta links para incluir a thread no final da lista de prontos*/
     miniSO_thread[nextthread].prev    = last;
     miniSO_thread[nextthread].next    = miniSO_ready;
     miniSO_thread[last].next          = nextthread;
     miniSO_thread[miniSO_ready].prev  = nextthread;
     miniSO_thread[nextthread].exitcode = miniSO_ERROR;
     miniSO_thread[nextthread].status  = READY;
  }

	enable();
	if	(miniSO_delcurthread)
		while	(1)
			;
	return miniSO_OK;
}



/* Função sc_waitpid() */
int sc_waitpid(pid_t pid,unsigned seg,unsigned off)
{
	pcb_t pcb,pcbw,prevthread,nextthread,atual;
	int far	*p_ref;

	disable();
	/* Tem que verificar se existe a thread */
	pcb = get_pcb(pid);
	/* Se nao existe uma thread com este numero ou se não é pai da thread, entao retorna */
	if	(pcb==-1 || miniSO_thread[pcb].ppid != miniSO_thread[miniSO_ready].pid)  {
		enable();
		return miniSO_ERROR;
	}
	if	(miniSO_thread[pcb].status!=ZOMBIE)  {
		/* O processo-filho ainda esta em execucao... */
		atual = miniSO_ready;
		prevthread = miniSO_thread[atual].prev;
		nextthread = miniSO_thread[atual].next;
		/* Se eh a ultima thread ... */
		if	(atual == nextthread)
			end_mso("waitpid(): nao ha' mais threads executando!");
		/* Vincula o BCP da thread atual ao BCP da thread "destino" */
		miniSO_thread[pcb].wait = atual;
		miniSO_thread[atual].prev = -1;
		miniSO_thread[atual].next = -1;
		miniSO_thread[atual].waitfor = pcb;
		miniSO_thread[atual].status = WAIT;
		/* Exclui o nodo da lista de prontos */
		miniSO_thread[prevthread].next=nextthread;
		miniSO_thread[nextthread].prev=prevthread;
		miniSO_nextthread=nextthread;
		enable();
		while	(miniSO_thread[atual].status == WAIT)
			;
		disable();
	}
	/* O processo filho ja terminou... */
	/* Retira o processo filho da lista de zumbis do pai */
	atual = pcb;
	prevthread = miniSO_thread[atual].prev;
	nextthread = miniSO_thread[atual].next;
	if	(prevthread == -1)  { /* E o primeiro da lista */
		miniSO_thread[miniSO_ready].zombies = nextthread;
		if	(nextthread != -1)
			miniSO_thread[nextthread].prev = -1;
	}
	else
		miniSO_thread[prevthread].next = nextthread;
	if	(nextthread != -1)
		miniSO_thread[nextthread].prev = prevthread;
	p_ref = MK_FP(seg,off);
	*p_ref = miniSO_thread[pcb].exitcode;
	/* Insere o processo na lista de BCPs livres */
	miniSO_thread[pcb].next = miniSO_free;
	miniSO_free = pcb;
	miniSO_thread[pcb].status = FREE;
	enable();
	return pid;
}



/* Função sc_wait() */
int sc_wait(unsigned seg,unsigned off)
{
	pcb_t	zombie,next,atual,prevthread,nextthread;
	int far	*p_ref;

	disable();
	atual =miniSO_ready;
	if	(miniSO_thread[miniSO_ready].zombies==-1) {
		/* O pai nao tem filhos-zumbi e vai bloquear */
		prevthread = miniSO_thread[atual].prev;
		nextthread = miniSO_thread[atual].next;
		/* Se eh a ultima thread ... */
		if	(miniSO_ready == nextthread)
			end_mso("wait(): nao ha' mais threads executando!");
		/* Vincula o BCP da thread atual ao BCP da thread "destino" */
		miniSO_thread[atual].prev = -1;
		miniSO_thread[atual].next = -1;
		miniSO_thread[atual].waitfor = -1;
		miniSO_thread[atual].status = WAIT;
		/* Exclui o nodo da lista de prontos */
		miniSO_thread[atual].next=nextthread;
		miniSO_thread[atual].prev=prevthread;
		miniSO_nextthread=nextthread;
		enable();
		while	(miniSO_thread[atual].status == WAIT)
			;
		disable();
	}
	/* O pai tem pelo menos um filho zumbi... */
	zombie = miniSO_thread[atual].zombies;
	miniSO_thread[atual].zombies = miniSO_thread[zombie].next;
	if	(miniSO_thread[atual].zombies!=-1)
		miniSO_thread[miniSO_thread[atual].zombies].prev = -1;
	miniSO_thread[zombie].next = miniSO_free;
	miniSO_thread[zombie].status = FREE;
	miniSO_free = zombie;
	p_ref = MK_FP(seg,off);
	*p_ref = miniSO_thread[zombie].exitcode;
	enable();
	return miniSO_thread[zombie].pid;
}


/* Função sc_exit() */
void sc_exit(int codfim)
{
	pcb_t pai,i,last,prevthread,nextthread;

	disable();
	/* Verifica se não esta' encerrando a thread 0 */
	if	(miniSO_ready == 0)
		end_mso("exit(): thread 0 encerrada!");
	/* Trata os zumbis do processo atual, colocando-os na lista de livres */
	i = miniSO_thread[miniSO_ready].zombies;
	while	(i!= -1)  {
		miniSO_thread[miniSO_ready].zombies = miniSO_thread[i].next;
		miniSO_thread[i].next   = miniSO_free;
		miniSO_thread[i].status = FREE;
		miniSO_free             = i;
		i = miniSO_thread[miniSO_ready].zombies;
	}
	/* Passa os filhos do atual para o processo 0 */
	for	(i=0;i<miniSO_MAXTHREADS;++i)  {
		if	(miniSO_thread[i].status!=FREE && miniSO_thread[i].ppid == miniSO_thread[miniSO_ready].pid)
			miniSO_thread[i].ppid = 0;
	}
	pai = get_pcb(miniSO_thread[miniSO_ready].ppid);
	if	(pai==-1)
		end_mso("exit(): pai nao encontrado!");
	/* Se o processo-pai esta' esperando em wait/waitpid, coloca ele na lista de prontos */
	if	( miniSO_thread[pai].status==WAIT && 
		  (miniSO_thread[pai].waitfor==-1 || miniSO_thread[pai].waitfor==miniSO_ready) ) {
		/* Descobre qual a ultima thread */
		last = miniSO_thread[miniSO_ready].prev;
		/* Acerta links para incluir a thread no final da lista de prontos*/
		miniSO_thread[pai].prev           = last;
		miniSO_thread[pai].next           = miniSO_ready;
		miniSO_thread[last].next          = pai;
		miniSO_thread[miniSO_ready].prev  = pai;
		miniSO_thread[pai].status         = READY;
	}
	/* Salva anterior e proximo da thread que sera deletada */
	prevthread = miniSO_thread[miniSO_ready].prev;
	nextthread = miniSO_thread[miniSO_ready].next;
	if	(miniSO_ready == nextthread)
		end_mso("exit(): nao ha' mais threads executando!");
	/* Exclui o nodo da lista de prontos */
	miniSO_thread[prevthread].next=nextthread;
	miniSO_thread[nextthread].prev=prevthread;
	if	(miniSO_thread[pai].zombies==-1) {
		miniSO_thread[pai].zombies = miniSO_ready;
		miniSO_thread[miniSO_ready].prev = -1;
	}
	else	{
		i = miniSO_thread[pai].zombies;
		while	(miniSO_thread[i].next!=-1)
			i = miniSO_thread[i].next;
		miniSO_thread[i].next = miniSO_ready;
		miniSO_thread[miniSO_ready].prev = i;
	}
	miniSO_thread[miniSO_ready].next = -1;
	miniSO_thread[miniSO_ready].status = ZOMBIE;
	miniSO_thread[miniSO_ready].exitcode = codfim;
	miniSO_nextthread=nextthread;
	miniSO_delcurthread=1;
	enable();
	while	(1)
		;
}



/* Função sc_getpid() */
pid_t sc_getpid()
{
	return miniSO_thread[miniSO_ready].pid;
}



/* Função sc_getppid() */
pid_t sc_getppid()
{
	return miniSO_thread[miniSO_ready].ppid;
}



/* Função sc_sendsignal() */
int sc_sendsignal(pid_t pid, signal_t signal)
{
	pcb_t	pcb,last;

	disable();
	/* Tem que verificar se existe a thread */
	pcb = get_pcb(pid);
	/* Se nao existe uma thread com este numero, entao retorna */
	if	(pcb==-1)  {
		enable();
		return miniSO_ERROR;
	}
	/* Seta os sinais recebidos */
	miniSO_thread[pcb].recvsig |= signal;
	/* A thread pode estar esperando pelos sinais ou nao */
	if	(miniSO_thread[pcb].status == WAITSIG)  {
		/* Verifica se a thread estava esperando pelo sinal */
		if	( (miniSO_thread[pcb].recvsig & miniSO_thread[pcb].waitsig) == miniSO_thread[pcb].waitsig )  {
			/* O sinal recebido e' suficiente para tirar a thread da espera */
			last = miniSO_thread[miniSO_ready].prev;
			miniSO_thread[pcb].prev = last;
			miniSO_thread[last].next=pcb;
			miniSO_thread[miniSO_ready].prev=pcb;
			miniSO_thread[pcb].next=miniSO_ready;
			miniSO_thread[pcb].status = READY;
			/* Seta sinais recebidos e sinais esperados */
			miniSO_thread[pcb].recvsig ^= miniSO_thread[pcb].waitsig;
			miniSO_thread[pcb].waitsig = 0;
		}
	}
	enable();
	return miniSO_OK;
}



/* Função sc_waitsignal() */
int sc_waitsignal(signal_t signal)
{
	pcb_t	pcb,prevthread,nextthread;
	int	waitint=0;

	disable();
	pcb = miniSO_ready;
	/* Verifica se ja' nao recebeu os sinais */
	if	( (miniSO_thread[pcb].recvsig & signal) == signal )  {
		/* Ele ja' recebeu os sinais */
		miniSO_thread[pcb].recvsig ^= signal;
		miniSO_thread[pcb].waitsig = 0;
	}
	else	{
		/* Ele ainda nao recebeu os sinais e vai para a lista de espera */
		miniSO_thread[pcb].waitsig = signal;
		/* Se eh a ultima thread ... */
		prevthread = miniSO_thread[pcb].prev;
		nextthread = miniSO_thread[pcb].next;
		if	(pcb == nextthread)
			end_mso("waitsignal(): nao ha' mais threads executando!");
		/* Retira o BCP da thread corrente da lista de prontos */
		miniSO_thread[pcb].next = -1;
		miniSO_thread[pcb].prev  = -1;
		/* Exclui o nodo da lista de prontos */
		miniSO_thread[prevthread].next=nextthread;
		miniSO_thread[nextthread].prev=prevthread;
		miniSO_thread[pcb].status = WAITSIG;
		miniSO_nextthread=nextthread;
		waitint=1;
	}
	enable();
	if	(waitint)
		while	(miniSO_thread[pcb].status == WAITSIG)
			;
	return 0;
}


static int get_sem_pos(semid_t s)
{
	int i;

	for	(i=0;i<miniSO_MAXSEMAPHORES;++i)
	  	if	(miniSO_sem[i].status!=FREE && miniSO_sem[i].semid==s)
			return i;
	return miniSO_ERROR;
}


semid_t sc_semcreate (int value)
{
	int i;
	semid_t s;

	for	(i=0;i<miniSO_MAXSEMAPHORES;++i)
		if	(miniSO_sem[i].status==FREE) {
			/* Gera um semid */
			while	(get_sem_pos(nextsemid)!=miniSO_ERROR) {
				if	(nextsemid==32767)
					nextsemid = 0;
				else
					nextsemid++;
			}
			miniSO_sem[i].status=READY;
			miniSO_sem[i].semid=nextsemid++;
			miniSO_sem[i].value=value;
			miniSO_sem[i].queue=-1;
			return miniSO_sem[i].semid;
		}
	return miniSO_ERROR;
}


int sc_semset (semid_t s,int value)
{
	int sem;

	sem = get_sem_pos(s);
	if	(sem==miniSO_ERROR || miniSO_sem[sem].queue!=-1)
		return miniSO_ERROR;
	miniSO_sem[sem].value = value;
	return miniSO_OK;
}


int sc_semup (semid_t s)
{
	int sem;
	pcb_t pcb,last,prevthread,nextthread;

	disable();
	sem = get_sem_pos(s);
	if	(sem==miniSO_ERROR) {
		enable();
		return miniSO_ERROR;
	}
	miniSO_sem[sem].value++;
	if	(miniSO_sem[sem].queue!=-1) {
		pcb = miniSO_sem[sem].queue;
		miniSO_sem[sem].queue = miniSO_thread[pcb].next;
		if	(miniSO_sem[sem].queue!=-1)
			miniSO_thread[miniSO_sem[sem].queue].prev = -1;
		last = miniSO_thread[miniSO_ready].prev;
		miniSO_thread[pcb].prev = last;
		miniSO_thread[last].next=pcb;
		miniSO_thread[miniSO_ready].prev=pcb;
		miniSO_thread[pcb].next=miniSO_ready;
		miniSO_thread[pcb].status = READY;
	}
	enable();
	return miniSO_OK;
}
	

int sc_semdown (semid_t s)
{
	int sem;
	pcb_t pcb,ant,i,prevthread,nextthread;

	disable();
	sem = get_sem_pos(s);
	if	(sem==miniSO_ERROR) {
		enable();
		return miniSO_ERROR;
	}
	miniSO_sem[sem].value--;
	if	(miniSO_sem[sem].value<0) {
		pcb = miniSO_ready;
		prevthread = miniSO_thread[pcb].prev;
		nextthread = miniSO_thread[pcb].next;
		/* Se eh a ultima thread ... */
		if	(pcb == nextthread)
			end_mso("semdown(): nao ha' mais threads executando!");
		/* Coloca o BCP da thread no final da lista de espera do semaforo */
		ant = -1;
		i = miniSO_sem[sem].queue;
		while	(i!=-1) {
			ant = i;
			i = miniSO_thread[i].next;
		}
		if	(ant==-1) {
			miniSO_sem[sem].queue = pcb;
			miniSO_thread[pcb].prev = -1;
		}
		else {
			miniSO_thread[ant].next = pcb;
			miniSO_thread[pcb].prev = ant;
		}
		miniSO_thread[pcb].next = -1;
		/* Exclui o nodo da lista de prontos */
		miniSO_thread[prevthread].next=nextthread;
		miniSO_thread[nextthread].prev=prevthread;
		miniSO_thread[pcb].status = WAITSEM;
		miniSO_nextthread=nextthread;
		enable();
		while	(miniSO_thread[pcb].status == WAITSEM)
			;
	}
	else
		enable();
	return miniSO_OK;
}


int sc_semdestroy (semid_t s)					
{
	int sem;

	sem = get_sem_pos(s);
	if	(sem==miniSO_ERROR || miniSO_sem[sem].queue!=-1)
		return miniSO_ERROR;
	miniSO_sem[sem].status = FREE;
	return miniSO_OK;
}

int sc_stop(pid_t pid){
    pcb_t pcb,prevthread,nextthread;
    disable();
    /* Tem que verificar se existe a thread */
    pcb = get_pcb(pid);
    /* Se nao existe uma thread com este numero ou se o estado dela n
    READY, retorna erro */
    if(pcb==-1||miniSO_thread[pcb].status!=READY){
    enable();
    return miniSO_ERROR;
    }
    prevthread = miniSO_thread[pcb].prev;
    nextthread = miniSO_thread[pcb].next;
    miniSO_thread[pcb].next =-1;
    miniSO_thread[pcb].prev = -1;
    /* Exclui o nodo da lista de prontos */
    miniSO_thread[prevthread].next=nextthread;
    miniSO_thread[nextthread].prev=prevthread;
    miniSO_thread[pcb].status = STOPPED;
    enable();
    return miniSO_OK;
}

int sc_resume(pid_t pid) {
    pcb_t pcb,prevthread,nextthread,last;
    disable();
    /* Tem que verificar se existe a thread */
    pcb = get_pcb(pid);
    /* Se nao existe uma thread com este numero ou se o estado dela não  
    é
    STOPPED */
    if(pcb==-1 || miniSO_thread[pcb].status != STOPPED)  {
    enable();
    return miniSO_ERROR;
    }
    last = miniSO_thread[miniSO_ready].prev;
    miniSO_thread[pcb].prev = last;
    miniSO_thread[last].next=pcb;
    miniSO_thread[miniSO_ready].prev=pcb;
    miniSO_thread[pcb].next=miniSO_ready;
    miniSO_thread[pcb].status = READY;
    enable();
    return miniSO_OK;
}

