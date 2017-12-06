/*
 * Universidade Luterana do Brasil
 * Curso de Bacharelado em Ciência da Computação
 * Disciplina: Projeto de Sistemas Operacionais
 * Professor: Roland Teodorowitsch
 *
 * Arquivo: command.h
 * Assunto: Definições do Interpretador de comandos
 *
 */


/* --- CONSTANTES ----------------------------------------*/

/* Número máximo de caracteres na linha de comandos */
#define MAXLINE    30
/* Número máximo de itens no histórico */
#define MAXHISTORY 10
/* Cor do sinal de pronto */
#define PROMPTCOLOR 0x09
/* Cor do logotipo */
#define LOGOCOLOR 0x01
/* Número máximo de comandos */
#define MAXCOMMANDS	28
/* Número máximo de argumentos na linha de comandos */
#define MAXARGS (MAXLINE/2 + 1)
/* Número máximo de caracteres do nome de variáveis */
#define VAR_NOME_TAM 12
/* Número máximo de caracteres no conteúdo de variáveis */
#define VAR_VALOR_TAM 36
/* Número máximo de variáveis */
#define VAR_MAX 10
/* Cor das variaveis */
#define VARCOLOR 0x0E


/* --- TIPOS ---------------------------------------------*/
typedef struct {
  char *name;
  char *help;
  int (*code)(int argc,char far *argv[]);
} command_t;

typedef struct {
  char name[VAR_NOME_TAM+1];
  char value[VAR_VALOR_TAM+1];
} variable_t;


/* --- PROTOTIPOS ----------------------------------------*/
       void      command          (void);
static void      command_backspace    (void);
static void      command_showprompt   (void);
static void      command_var_init     (void);
static int       command_var_nextfree (void);
static void      command_var_list     (void);
static int       command_var_search   (char far *nome);
static int       command_var_unset    (char far *nome);
static char far *command_var_value    (char far *nome); 
static int       command_var_set      (char far *nome,char far *valor);


/* Comandos internos */
int	cmd_exit	(int argc, char far *argv[]);
int	cmd_reboot	(int argc, char far *argv[]);
int	cmd_help	(int argc, char far *argv[]);
int	cmd_date	(int argc, char far *argv[]);
int	cmd_time	(int argc, char far *argv[]);
int	cmd_cls		(int argc, char far *argv[]);
int	cmd_ver		(int argc, char far *argv[]);
int	cmd_prompt	(int argc, char far *argv[]);
int	cmd_ps		(int argc, char far *argv[]);
int	cmd_kill	(int argc, char far *argv[]);
int	cmd_demo	(int argc, char far *argv[]);
int	cmd_set		(int argc, char far *argv[]);
int	cmd_unset	(int argc, char far *argv[]);
int	cmd_echo	(int argc, char far *argv[]);
int	cmd_wait	(int argc, char far *argv[]);
int	cmd_waitpid	(int argc, char far *argv[]);
int	cmd_semls	(int argc, char far *argv[]);
int	cmd_semcreate	(int argc, char far *argv[]);
int	cmd_semtest	(int argc, char far *argv[]);
int	cmd_semup	(int argc, char far *argv[]);
int	cmd_semdestroy	(int argc, char far *argv[]);
int cmd_stop (int argc, char far *argv[]);
int cmd_resume (int argc, char far *argv[]);
int cmd_prodcons (int argc, char far *argv[]);
int cmd_tcons (int argc, char far *argv[]);
int cmd_tprod (int argc, char far *argv[]);


