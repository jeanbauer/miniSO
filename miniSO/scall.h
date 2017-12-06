/*
 * Universidade Luterana do Brasil
 * Curso de Bacharelado em Ciência da Computação
 * Disciplina: Projeto de Sistemas Operacionais
 * Professor: Roland Teodorowitsch
 *
 * Arquivo: scall.h
 * Assunto: Chamadas de sistema basicas
 *
 */


/* Numero de chamadas de sistema */
#define miniSO_NUMSCALL 27

#define SC_PUTCH        0
#define SC_GETCH        1
#define SC_CLRSCR       2
#define SC_GETCOLOR     3
#define SC_SETCOLOR     4
#define SC_WHEREX       5
#define SC_WHEREY       6
#define SC_GOTOXY       7
#define SC_GETDATE      8
#define SC_GETTIME      9
#define SC_REBOOT	10
#define SC_FORK		11
#define SC_KILL		12
#define SC_WAITPID	13
#define SC_WAIT		14
#define SC_EXIT		15
#define SC_GETPID	16
#define SC_GETPPID	17
#define SC_SENDSIGNAL	18
#define SC_WAITSIGNAL	19
#define SC_SEMCREATE	20
#define SC_SEMSET	21
#define SC_SEMUP	22
#define SC_SEMDOWN	23
#define SC_SEMDESTROY	24
#define SC_STOP 25
#define SC_RESUME 26 


typedef int	(*scfun0_t)(void);
typedef int	(*scfun1_t)(int bx);
typedef int	(*scfun2_t)(int bx,int cx);
typedef int	(*scfun3_t)(int bx,int cx,int dx);
typedef union  {
	scfun0_t p0;
	scfun1_t p1;
	scfun2_t p2;
	scfun3_t p3;
}	scfun_t;

typedef struct  {
  char     ah;
  int      numparam;
  scfun_t  function;
} scall_t;

int	sc_putch        (int car);
int	sc_getch        (void);
int	sc_clrscr       (void);
int	sc_getcolor     (void);
int	sc_setcolor     (int cor);
int	sc_wherex       (void);
int	sc_wherey       (void);
int	sc_gotoxy       (int x, int y);
int	sc_getdate      (unsigned seg, unsigned off);
int	sc_gettime      (unsigned seg,unsigned off);
int	sc_reboot	(void);
int	sc_fork		(unsigned cs, unsigned ip);
int	sc_kill		(pid_t pid);
int	sc_wait		(unsigned seg,unsigned off);
int	sc_waitpid	(pid_t pid,unsigned seg,unsigned off);
void	sc_exit		(int codfim);
pid_t	sc_getpid	(void);
pid_t	sc_getppid      (void);
int	sc_sendsignal   (pid_t pid, signal_t signal);
int	sc_waitsignal	(signal_t signal);
semid_t	sc_semcreate	(int value);
int	sc_semset	(semid_t s,int value);
int	sc_semup	(semid_t s);
int	sc_semdown	(semid_t s);
int	sc_semdestroy	(semid_t s);
int sc_stop(pid_t pid);
int sc_resume(pid_t pid);

