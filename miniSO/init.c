/*
 * Universidade Luterana do Brasil
 * Curso de Bacharelado em Ci�ncia da Computa��o
 * Disciplina: Projeto de Sistemas Operacionais
 * Professor: Roland Teodorowitsch
 *
 * Arquivo: init.c
 * Assunto: Procedimentos de inicializa��o e fun��o init()
 *
 */


#include "miniSO.h"
#include "lib.h"


void main()
{
	unsigned val,car;
	void interrupt (*systemcalls)();
	void interrupt (*clockhandler)();
	int i;
	extern void interrupt (*miniSO_oldisr)();
	extern void interrupt miniSO_clockhandler();

	/* Inicializa a pilha */
	init_stack(miniSO_INITSTACKS+(miniSO_STACKSIZE>>4)*(miniSO_MAXTHREADS-1-0),miniSO_STACKSIZE);
	/* Inicializa o registrador DS */
	init_ds(miniSO_DATASEGMENT);
	/* Instala chamada de sistemas */
	systemcalls = MK_FP(miniSO_CODESEGMENT,(unsigned)miniSO_systemcall);
	for	(i=0x20;i<=0xff;++i)
		setvect(i,systemcalls);
	/* Inicializa a tabela de threads */
	miniSO_init_proctable();
	/* Captura interrup��o original do rel�gio */
	miniSO_oldisr = getvect(miniSO_CLOCKINT);
	/* Instala interrup��o do rel�gio */
	clockhandler = MK_FP(miniSO_CODESEGMENT,(unsigned)miniSO_clockhandler);
	setvect(miniSO_CLOCKINT,clockhandler);
	/* Inicia o interpretador de comandos */
	command();
	/* Restaura a interrup��o do rel�gio original */
	setvect(miniSO_CLOCKINT,miniSO_oldisr);
	putstr("\n\n");
	putstr("minisSistema Operacional encerrado!");
	putch('\n');
	putstr("Pressione uma tecla para reiniciar...\n");
	getch();
	/* Reinicializa a m�quina */
	reboot();
}
