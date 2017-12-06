	ifndef	??version
?debug	macro
	endm
publicdll macro	name
	public	name
	endm
$comm	macro	name,dist,size,count
	comm	dist name:BYTE:count*size
	endm
	else
$comm	macro	name,dist,size,count
	comm	dist name[size]:BYTE:count
	endm
	endif
	?debug	V 300h
	?debug	S "init.c"
	?debug	C E92554844106696E69742E63
	?debug	C E98FA6684B086D696E69534F2E68
	?debug	C E9D2A4684B056C69622E68
_TEXT	segment byte public 'CODE'
_TEXT	ends
DGROUP	group	_DATA,_BSS
	assume	cs:_TEXT,ds:DGROUP
_DATA	segment word public 'DATA'
d@	label	byte
d@w	label	word
_DATA	ends
_BSS	segment word public 'BSS'
b@	label	byte
b@w	label	word
_BSS	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	void main()
   ;	
	assume	cs:_TEXT
_main	proc	near
	push	bp
	mov	bp,sp
	sub	sp,8
	push	si
   ;	
   ;	{
   ;		unsigned val,car;
   ;		void interrupt (*systemcalls)();
   ;		void interrupt (*clockhandler)();
   ;		int i;
   ;		extern void interrupt (*miniSO_oldisr)();
   ;		extern void interrupt miniSO_clockhandler();
   ;	
   ;		/* Inicializa a pilha */
   ;		init_stack(miniSO_INITSTACKS+(miniSO_STACKSIZE>>4)*(miniSO_MAXTHREADS-1-0),miniSO_STACKSIZE);
   ;	
	mov	ax,1536
	push	ax
	mov	ax,4768
	push	ax
	call	near ptr _init_stack
	pop	cx
	pop	cx
   ;	
   ;		/* Inicializa o registrador DS */
   ;		init_ds(miniSO_DATASEGMENT);
   ;	
	mov	ax,2971
	push	ax
	call	near ptr _init_ds
	pop	cx
   ;	
   ;		/* Instala chamada de sistemas */
   ;		systemcalls = MK_FP(miniSO_CODESEGMENT,(unsigned)miniSO_systemcall);
   ;	
	mov	ax,offset _miniSO_systemcall
	push	ax
	mov	ax,2016
	push	ax
	call	near ptr _MK_FP
	pop	cx
	pop	cx
	mov	word ptr [bp-2],dx
	mov	word ptr [bp-4],ax
   ;	
   ;		for	(i=0x20;i<=0xff;++i)
   ;	
	mov	si,32
	jmp	short @1@114
@1@58:
   ;	
   ;			setvect(i,systemcalls);
   ;	
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	push	si
	call	near ptr _setvect
	add	sp,6
	inc	si
@1@114:
	cmp	si,255
	jle	short @1@58
   ;	
   ;		/* Inicializa a tabela de threads */
   ;		miniSO_init_proctable();
   ;	
	call	near ptr _miniSO_init_proctable
   ;	
   ;		/* Captura interrupção original do relógio */
   ;		miniSO_oldisr = getvect(miniSO_CLOCKINT);
   ;	
	mov	ax,28
	push	ax
	call	near ptr _getvect
	pop	cx
	mov	word ptr DGROUP:_miniSO_oldisr+2,dx
	mov	word ptr DGROUP:_miniSO_oldisr,ax
   ;	
   ;		/* Instala interrupção do relógio */
   ;		clockhandler = MK_FP(miniSO_CODESEGMENT,(unsigned)miniSO_clockhandler);
   ;	
	mov	ax,offset _miniSO_clockhandler
	push	ax
	mov	ax,2016
	push	ax
	call	near ptr _MK_FP
	pop	cx
	pop	cx
	mov	word ptr [bp-6],dx
	mov	word ptr [bp-8],ax
   ;	
   ;		setvect(miniSO_CLOCKINT,clockhandler);
   ;	
	push	word ptr [bp-6]
	push	word ptr [bp-8]
	mov	ax,28
	push	ax
	call	near ptr _setvect
	add	sp,6
   ;	
   ;		/* Inicia o interpretador de comandos */
   ;		command();
   ;	
	call	near ptr _command
   ;	
   ;		/* Restaura a interrupção do relógio original */
   ;		setvect(miniSO_CLOCKINT,miniSO_oldisr);
   ;	
	push	word ptr DGROUP:_miniSO_oldisr+2
	push	word ptr DGROUP:_miniSO_oldisr
	mov	ax,28
	push	ax
	call	near ptr _setvect
	add	sp,6
   ;	
   ;		putstr("\n\n");
   ;	
	push	ds
	mov	ax,offset DGROUP:s@
	push	ax
	call	near ptr _putstr
	pop	cx
	pop	cx
   ;	
   ;		putstr("minisSistema Operacional encerrado!");
   ;	
	push	ds
	mov	ax,offset DGROUP:s@+3
	push	ax
	call	near ptr _putstr
	pop	cx
	pop	cx
   ;	
   ;		putch('\n');
   ;	
	mov	ax,10
	push	ax
	call	near ptr _putch
	pop	cx
   ;	
   ;		putstr("Pressione uma tecla para reiniciar...\n");
   ;	
	push	ds
	mov	ax,offset DGROUP:s@+39
	push	ax
	call	near ptr _putstr
	pop	cx
	pop	cx
   ;	
   ;		getch();
   ;	
	call	near ptr _getch
   ;	
   ;		/* Reinicializa a máquina */
   ;		reboot();
   ;	
	call	near ptr _reboot
   ;	
   ;	}
   ;	
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_main	endp
	?debug	C E9
	?debug	C FA00000000
_TEXT	ends
_DATA	segment word public 'DATA'
s@	label	byte
	db	10
	db	10
	db	0
	db	'minisSistema Operacional encerrado!'
	db	0
	db	'Pressione uma tecla para reiniciar...'
	db	10
	db	0
_DATA	ends
_TEXT	segment byte public 'CODE'
_TEXT	ends
	extrn	_miniSO_clockhandler:far
	extrn	_miniSO_oldisr:dword
	extrn	_reboot:near
	extrn	_putstr:near
	extrn	_getch:near
	extrn	_putch:near
	extrn	_miniSO_init_proctable:near
	extrn	_command:near
	public	_main
	extrn	_init_stack:near
	extrn	_init_ds:near
	extrn	_MK_FP:near
	extrn	_getvect:near
	extrn	_setvect:near
	extrn	_miniSO_systemcall:near
_s@	equ	s@
	end
