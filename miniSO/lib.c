/*
 * Universidade Luterana do Brasil
 * Curso de Bacharelado em Ciencia da Computacao
 * Disciplina: Projeto de Sistemas Operacionais
 * Professor: Roland Teodorowitsch
 *
 * Arquivo: lib.c
 * Assunto: Implementacao das funções da biblioteca do minisSistema Operacional
 *
 */


#include "miniSO.h"
#include "lib.h"
#include "scall.h"


/* Funcao putch() */
void putch(int car)
{
  _BX = car;
  asm {
     mov  ah,SC_PUTCH
     int  22h
  }
}


/* Funcao getch() */
int getch()
{
  asm {
    mov  ah,SC_GETCH
    int  22h
  }
  return (_AX);
}


/* Funcao clrscr() */
void clrscr()
{
  asm {
    mov  ah,SC_CLRSCR
    int  22h
  }
}



/* Funcao putstr() */
void putstr (char far *str)
{
  while (*str!='\0')
        putch(*str++);
}



/* Funcao putstrxy() */
void putstrxy (int x, int y, char far *string)
{
  char far *pv;

  pv=(char far *)(0xB8000000L+(y-1)*160+(x-1)*2);
  while (*string != '\0')  {
	*pv++=*string++;
	pv++;
  }
}



/* Funcao getcolor() */
int getcolor ()
{
  asm {
    mov ah,SC_GETCOLOR
    int 22h
  }
  return _AX;
}



/* Funcao setcolor() */
void setcolor (int cor)
{
  _BX = cor; 
  asm {
    mov ah,SC_SETCOLOR
    int 22h
  }
}



/* Funcao wherex() */
int  wherex()
{
  asm {
	mov	ah,SC_WHEREX
	int	22h
  }
  return _AX;
}



/* Funcao wherey() */
int  wherey()
{
  asm {
	mov	ah,SC_WHEREY
	int	22h
  }
  return _AX;
}



/* Funcao gotoxy() */
void gotoxy (int x,int y)
{
  _BX = x;
  _CX = y;
  asm {
	mov	ah,SC_GOTOXY
	int	22h
  }
}


/* Funcao getdate() */
void getdate(struct date far *dt)
{
  _BX = FP_SEG(dt);
  _CX = FP_OFF(dt);
  asm {
	mov	ah,SC_GETDATE
	int	22h
  }
}


/* Funcao gettime() */
void gettime(struct time far *tm)
{
  _BX = FP_SEG(tm);
  _CX = FP_OFF(tm);
  asm {
	mov	ah,SC_GETTIME
	int	22h
  }
}


/* Funcao strcpy() */
char far *strcpy (char far *dest,char far *orig)
{
  char far *res;

  res = dest;
  while (*orig!='\0')
        *dest++ = *orig++;
  *dest='\0';
  return(res);
}



/* Funcao strncpy() */
char far *strncpy (char far *dest,char far *orig, size_t maxlen)
{
  char far *res;
  size_t i = 0;

  res = dest;
  while (*orig!='\0' && i<maxlen)  {
        *dest++ = *orig++;
        ++i;
  }
  if (i<maxlen)
     *dest='\0';
  return(res);
}



/* Funcao strupr() */
char far *strupr (char far *str)
{
  char far *res;

  res = str;
  while (*str!='\0')  {
        if (*str>='a' && *str<='z')
           *str -= ('a'-'A');
        ++str;
  }
  return(res);
}



/* Funcao strlwr() */
char far *strlwr (char far *str)
{
  char far *res;

  res = str;
  while (*str!='\0')  {
        if (*str>='A' && *str<='Z')
           *str += ('a'-'A');
        ++str;
  }
  return(res);
}


/* Funcao strcmp() */
int strcmp (char far *s1,char far *s2)
{
  while (*s1 == *s2)  {
        if (*s1=='\0')
           return(0);
        ++s1;
        ++s2;
  }
  if (*s1<*s2)
     return(-1);
  else
     return(1); 
}



/* Funcao strlen() */
size_t strlen (char far *str)
{
  size_t res=0;

  while (*str++!='\0')
        ++res;
  return(res);
}



/* Funcao isdigit() */
int isdigit (char caracter)
{
  if (caracter<'0' || caracter>'9')
     return(0);
  else
     return(1);
}



/* Funcao isalpha() */
int isalpha (char caracter)
{
  if ( (caracter>='A' && caracter<='Z') || (caracter>='a' && caracter<='z') )
     return(1);
  else
     return(0);
}



/* Funcao atoi() */
int atoi (char far *str)
{
  int val=0;
  int sinal=1;

  /* Pula espaços e tabulações */
  while (*str!='\0' && (*str==9 || *str==' '))
        ++str;
  /* Verifica o sinal opcional */
  if (*str=='-')  {
     sinal=-1;
     ++str;
  }
  if (*str=='+')
     ++str;
  while (isdigit(*str))  {
        val=val*10+(*str-'0');
        ++str;
  }
  return (sinal*val);
}



void unsignedtostr(char far *str,unsigned i,unsigned tam,char c)
{
  unsigned dig,div=1,tamreal,x=0;

  if (i>9999)
     tamreal = 5;
  else
     if (i>999)
        tamreal = 4;
     else
        if (i>99)
           tamreal = 3;
        else
           if (i>9)
              tamreal = 2;
           else
              tamreal = 1;
  if (tam>5)
     tam = 5;
  if (tamreal>tam)
     tam = tamreal;
  for (dig=0;dig<tam-1;++dig)
      div*=10;
  while (div>1)  {
       if (i<div)  {
          if (!x)
	     *str++=c;
          else
             *str++='0';
       }
       else  {
          x = 1;
          dig   = i / div;
          *str++= (dig+'0');
          i = i % div;
       }
       div = div/10;
  }
  *str++= (i+'0');
  *str = '\0';
}



void unsignedlongtostr(char far *str,unsigned long i,unsigned tam,char c)
{
  unsigned tamreal,dig,x=0;
  unsigned long div=1;

  if (i>999999999)
     tamreal = 10;
  else
     if (i>99999999)
	tamreal = 9;
     else
	if (i>9999999)
	   tamreal = 8;
	else
	   if (i>999999)
	      tamreal = 7;
	   else
	      if (i>99999)
		 tamreal = 6;
	      else
		 if (i>9999)
		    tamreal = 5;
		 else
		    if (i>999)
		       tamreal = 4;
		    else
		       if (i>99)
			  tamreal = 3;
		       else
			  if (i>9)
			     tamreal = 2;
			  else
			     tamreal = 1;
  if (tam>10)
     tam = 10;
  if (tamreal>tam)
     tam = tamreal;
  for (dig=0;dig<tam-1;++dig)
      div*=10;
  while (div>1)  {
       if (i<div)  {
          if (!x)
	     *str++=c;
          else
             *str++='0';
       }
       else  {
          x = 1;
	  dig   = i / div;
	  *str++= (dig+'0');
	  i = i % div;
       }
       div = div/10;
  }
  *str++= (i+'0');
  *str = '\0';
}



void unsignedtostrhexa(char far *str,unsigned i)
{
  unsigned dig,div=4096;

  while (div>1)  {
       if (i<div)
          *str++='0';
       else  {
          dig   = i / div;
          if (dig<10)
             *str++= (dig+'0');
          else
             *str++= (dig-10+'A');
          i = i % div;
       }
       div = div/16;
  }
  if (i<10)
     *str++= (i+'0');
  else
     *str++= (i-10+'A');
  *str = '\0';
}



void inttostr(char far *str,int i)
{
  int dig,div=10000,fimzeroesq=0;

  if (i==-32768)  {
     *str++='-';
     *str++='3';
     *str++='2';
     *str++='7';
     *str++='6';
     *str++='8';
  }
  else  {
     if (i<0)  {
        *str++='-';
        i = -i;
     }
     while (div>1)  {
           if (i<div)  {
              if (fimzeroesq!=0)
                 *str++='0';
           }
           else  {
              fimzeroesq=1;
              dig   = i / div;
              *str++= (dig+'0');
              i = i % div;
           }
           div = div/10;
      }
      *str++= (i+'0');
  }
  *str = '\0';
}


/* Funcao reboot() */
void reboot()
{
  asm {
    mov  ah,SC_REBOOT
    int  22h
  }
}


/* Funções para gerencia de processos */

/* Funcao fork() */
pid_t fork(void (*fun)())
{
  _BX = miniSO_CODESEGMENT;
  _CX = (unsigned)fun;
  asm {
     mov  ah,SC_FORK
     int  22h
  }
  return _AX; 
}



/* Funcao kill() */
int kill(pid_t pid)
{
  _BX = pid;
  asm {
    mov ah,SC_KILL
    int 22h
  }
  return _AX;
}



/* Funcao wait() */
pid_t wait(int far *status)
{
	_BX = FP_SEG(status);
	_CX = FP_OFF(status);
	asm	{
		mov	ah,SC_WAIT
		int	22h
	}
	return _AX;
}



/* Funcao waitpid() */
pid_t waitpid(pid_t pid,int far *status)
{
	_BX = pid;
	_CX = FP_SEG(status);
	_DX = FP_OFF(status);
	asm	{
		mov	ah,SC_WAITPID
		int	22h
	}
	return _AX;
}

/* Funcao exit() */
void exit(int codfim)
{
  _BX = codfim;
  asm {
    mov ah,SC_EXIT
    int 22h
  }
}



/* Funcao getpid() */
pid_t getpid()
{
  asm {
    mov ah,SC_GETPID
    int 22h
  }
  return _AX;
}



/* Funcao getppid() */
pid_t getppid()
{
  asm {
    mov ah,SC_GETPPID
    int 22h
  }
  return _AX;
}



/* Funcao sendsignal() */
int sendsignal(pid_t pid, signal_t signal)
{

  _BX = pid;
  _CX = signal;
  asm {
     mov  ah,SC_SENDSIGNAL
     int  22h
  }
  return _AX; 
}




/* Funcao waitsignal() */
void waitsignal(signal_t signal)
{
  _BX = signal;
  asm {
     mov  ah,SC_WAITSIGNAL
     int  22h
  }
}


semid_t semcreate (int value)
{
	_BX = value;
	asm	{
		mov  ah,SC_SEMCREATE
		int  22h
	}
	return _AX;
}


int semset (semid_t s,int value)
{
	_BX = s;
	_CX = value;
	asm	{
		mov  ah,SC_SEMSET
		int  22h
	}
	return _AX;
}


int semup (semid_t s)
{
	_BX = s;
	asm	{
		mov  ah,SC_SEMUP
		int  22h
	}
	return _AX;
}


int semdown (semid_t s)
{
	_BX = s;
	asm	{
		mov  ah,SC_SEMDOWN
		int  22h
	}
	return _AX;
}


int semdestroy (semid_t s)
{
	_BX = s;
	asm	{
		mov  ah,SC_SEMDESTROY
		int  22h
	}
	return _AX;
}
int stop(pid_t pid){
_BX = pid;
asm {
mov ah,SC_STOP
int 22h
}
return _AX;
}
int resume(pid_t pid){
_BX = pid;
asm {
mov ah,SC_RESUME
int 22h
}
return _AX;
}
