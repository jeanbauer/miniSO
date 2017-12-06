/*
 * Universidade Luterana do Brasil
 * Curso de Bacharelado em Ciência da Computação
 * Disciplina: Projeto de Sistemas Operacionais
 * Professor: Roland Teodorowitsch
 *
 * Arquivo: miniSO.h
 * Assunto: Definições do minisSistema Operacional
 *
 */


/* --- CONSTANTES ----------------------------------------*/

/* Segmento inicial da área de pilhas */
#define miniSO_INITSTACKS 0xd00
/* Tamanho máximo da pilha de uma thread */
#define miniSO_STACKSIZE  0x600 /* corresponte ao tamanho (4096) dividido 16 */
/* Número máximo de threads */
#define miniSO_MAXTHREADS 16
/* Número máximo de semáforos */ /*S*/
#define miniSO_MAXSEMAPHORES 10  /*S*/
#define miniSO_NONE       -1

/* Estado retornado pelas funcoes */
#define miniSO_ERROR      -1
#define miniSO_OK          1

/* Estados de um processo */
#define FREE       -1     /* O BCP esta' na lista de livres */
#define READY       0     /* O processo esta' na lista de prontos */
#define RUNNING     1     /* O processo e' o primeiro da lista de prontos */
#define ZOMBIE      2     /* O processo esta' no estado "zumbi" */
#define WAIT        3     /* O processo esta' esperando por algum filho */
#define WAITSIG     4     /* O processo esta' na lista de espera por sinais */
#define WAITSEM     5     /* O processo esta' esperando por semaforos */ /*S*/
#define STOPPED 6 /* O processo esta' suspenso */

/* Strings de estados de processos */
#define strFREE    "FREE   "
#define strREADY   "READY  "
#define strRUNNING "RUNNING"
#define strZOMBIE  "ZOMBIE "
#define strWAIT    "WAIT   "
#define strWAITSIG "WAITSIG"
#define strWAITSEM "WAITSEM"
#define strSTOPPED "STOPPED"

/* Interrupção do relógio */
#define miniSO_CLOCKINT    0x1c


/* --- TIPOS ---------------------------------------------*/

typedef int      pid_t;
typedef int      pcb_t;
typedef unsigned signal_t;

typedef struct {
  pid_t    pid;
  pid_t    ppid;
  int      status;
  unsigned ss;
  unsigned sp;
  signal_t recvsig;
  signal_t waitsig;
  pcb_t    wait;
  pid_t    waitfor;
  int      exitcode;
  pcb_t    zombies;
  pcb_t    prev;
  pcb_t    next;
} miniSO_PCB;

typedef int semid_t;

typedef struct {
	int	status;
	semid_t	semid;
	int	value;
	pcb_t	queue;
} miniSO_SEM;

struct date {
  int  da_year;
  char da_day;
  char da_mon;
};

struct time {
  unsigned char ti_min;
  unsigned char ti_hour;
  unsigned char ti_hund;
  unsigned char ti_sec;
};


/* --- PROTOTIPOS ----------------------------------------*/

/* Prototipos de funções (miniSO.asm) */
void             miniSO_systemcall   (void);
void             setvect    (unsigned interruptno,void interrupt (*isr)(void));
void interrupt (*getvect    (int interruptno) )(void);
void             enable     (void);
void             disable    (void);
void far        *MK_FP      (unsigned, unsigned);
unsigned         FP_SEG     (void far *);
unsigned         FP_OFF     (void far *);
void             bootstrap  (void);
void             init_ds    (unsigned);
void             init_stack (unsigned, unsigned);

/* Prototipos de funções (init.c) */
void main            (void);
/* Prototipos de funcoes (command.c) */
void command         (void);
/* Prototipos de funcoes (scallprc.c) */
void miniSO_init_proctable (void);
void miniSO_init_semtable  (void); /*S*/ 
