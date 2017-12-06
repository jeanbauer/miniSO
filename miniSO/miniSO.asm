 ;
 ; Universidade Luterana do Brasil
 ; Curso de Bacharelado em Ciência da Computação
 ; Disciplina: Projeto de Sistemas Operacionais
 ; Professor: Roland Teodorowitsch
 ;
 ; Arquivo: scall.asm
 ; Assunto: Implementação do ponto de entrada de chamadas de sistema:
 ;          void miniSO_systemcall  (void);
 ;          Esta função recebe o número do serviço em AH e retorna com a instrução IRET
 ;


_TEXT	segment byte public 'CODE'

	assume	cs:_TEXT


_miniSO_systemcall	proc	near
	sti
        push    dx
        push    cx
        push    bx
        mov     al,ah
        xor     ah,ah
        push    ax
        call    near ptr _scall
        add     sp,8
        iret
_miniSO_systemcall	endp


_miniSO_clockhandler	proc	near
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	push	ds
	push	si
	push	di
	push	bp
	mov	bp,miniSO_DATASEGMENT
	mov	ds,bp
;        mov     bp,sp
        call	near ptr _miniSO_contextswitch
_miniSO_return_addr:
        mov     dx,0020h
        mov     al,20h
        out     dx,al
	pop	bp
	pop	di
	pop	si
	pop	ds
	pop	es
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	iret	
_miniSO_clockhandler	endp


_setvect	proc	near
	; void setvect  (unsigned num,unsigned seg, unsigned des);
	; Esta função recebe o número da interrupção e o endereço  (segmento
	; e deslocamento) de uma função, e define esta função como rotina de
	; atendimento desta interrupção.
	; [BP+8]  -  segmento da rotina de atendimento
	; [BP+6]  -  deslocamento da rotina de atendimento
	; [BP+4]  -  número da interrupção
	; Salva BP e faz BP apontar para a pilha
	push	bp
	mov	bp,sp

	; Salva SI e AX
	push	si
	push	ax

	; AX recebe o número da interrupção
	mov	ax,word ptr [bp+4]
	; "Multiplica" AX por 4
	shl	ax,2
	; SI recebe o endereço do vetor de interrupção
	mov	si,ax

	; Desabilita interrupções
	cli

	; Salva DS original
	push	 ds

	; Atribui 0 para DS
	xor	 ax,ax
	mov	 ds,ax

	; Define o deslocamento no vetor de interrupção
	mov	ax,word ptr [bp+6]
	mov	word ptr [si],ax

	; Incrementa SI
	add	si,2

	; Define o segmento no vetor de interrupção
	mov	ax,word ptr [bp+8]
	mov	word ptr [si],ax

	; Restaura valor de DS
	pop	ds

	; Habilita interrupções
	sti

	; Restaura AX e SI
	pop	ax
	pop	si

	; Restaura BP
	pop	bp

	; Retorna da função
	ret

_setvect	endp


_getvect	proc	near
	; [BP+4]  -  número da interrupção
	; Salva BP e faz BP apontar para a pilha
	push	bp
	mov	bp,sp

	; Restaura BP
	pop	bp

	; Salva SI
	push	si

	; AX recebe o número da interrupção
	mov	ax,word ptr [bp+4]
	; "Multiplica" AX por 4
	shl	ax,2
	; SI recebe o endereço do vetor de interrupção
	mov	si,ax

	; Salva DS original
	push	 ds

	; Atribui 0 para DS
	xor	 ax,ax
	mov	 ds,ax

	; Define o deslocamento no vetor de interrupção
	mov	ax,word ptr [si]

	; Incrementa SI
	add	si,2

	; Define o segmento no vetor de interrupção
	mov	dx,word ptr [si]

	; Restaura valor de DS
	pop	ds

	; Restaura SI
	pop	si

	; Retorna da função
	ret

_getvect	endp


_enable	proc	near
	sti
	ret
_enable	endp


_disable	proc	near
	cli
	ret
_disable	endp


_MK_FP	proc	near
	; [bp+6] = deslocamento
	; [bp+4] = segmento
	; [bp+2] = IP
	; [bp+0] = BP
	push	bp
	mov	bp,sp
	; retira os valores da pilha
	mov	ax,[bp+6] ; deslocamento
	mov	dx,[bp+4] ; segmento
	; retira bp da pilha e retorna
	pop	bp
	ret
_MK_FP	endp


_FP_SEG	proc	near
	; [bp+6] = segmento
	; [bp+4] = deslocamento
	; [bp+2] = IP
	; [bp+0] = BP
	push	bp
	mov	bp,sp
	; retira os valores da pilha
	mov	ax,[bp+6]
	; retira bp da pilha e retorna
	pop	bp
	ret
_FP_SEG	endp


_FP_OFF	proc	near
	; [bp+6] = segmento
	; [bp+4] = deslocamento
	; [bp+2] = IP
	; [bp+0] = BP
	push	bp
	mov	bp,sp
	; retira os valores da pilha
	mov	ax,[bp+4]
	; retira bp da pilha e retorna
	pop	bp
	ret
_FP_OFF	endp


_init_ds	proc	near

	push	bp
	mov	bp,sp
	mov	ax,word ptr [bp+4]
	mov	ds,ax
	pop	bp
	ret

_init_ds	endp


_init_stack	proc	near
	; [bp+6] = SP
	; [bp+4] = SS
	; [bp+2] = IP
	; [bp+0] = BP
	push	bp
	mov	bp,sp
	; retira os valores da pilha
	mov	ax,[bp+6]
	mov	bx,[bp+4]
	mov	cx,[bp+2]
	mov	dx,[bp]
	; desabilita as interrupções
	cli
	; define a nova pilha
	mov	ss,bx
	mov	sp,ax
	; coloca os valores na nova pilha
	push	ax
	push	bx
	push	cx
	push	dx
	; habilita as interrupções
	sti
	; retira bp da pilha e retorna
	pop	bp
	ret
_init_stack	endp


N_LXMUL@	proc	far
		mov    ds:[miniSO_aux],ax    
		pop    ax
		push   cs
		push   ax
		mov    ax,ds:[miniSO_aux]
N_LXMUL@	endp

LXMUL@		proc	far
		push   si
		xchg   si,ax
		xchg   dx,ax
		test   ax,ax
		je     LXMUL1
		mul    bx
LXMUL1:		jcxz   LXMUL2
		xchg   cx,ax
		mul    si
		add    ax,cx
LXMUL2:		xchg   si,ax
		mul    bx
		add    dx,si
		pop    si
		retf
LXMUL@		endp


N_LDIV@		proc	far
		pop    cx
		push   cs
		push   cx
N_LDIV@		endp

LDIV@		proc	far
		xor    cx,cx
		jmp    LUMOD1
LDIV@		endp

N_LUDIV@	proc	far
		pop    cx
		push   cs
		push   cx
N_LUDIV@	endp

LUDIV@		proc	far
		mov    cx,0001h
		jmp    LUMOD1
LUDIV@		endp

N_LMOD@		proc	far
		pop    cx
		push   cs
		push   cx
N_LMOD@		endp

LMOD@		proc	far
		mov    cx,0002h
		jmp    LUMOD1
LMOD@		endp

N_LUMOD@	proc	far
		pop    cx
		push   cs
		push   cx
N_LUMOD@	endp

LUMOD@		proc	far
		mov    cx,0003h
LUMOD1:		push   bp
		push   si
		push   di
		mov    bp,sp
		mov    di,cx
		mov    ax,[bp+0Ah]
		mov    dx,[bp+0Ch]
		mov    bx,[bp+0Eh]
		mov    cx,[bp+10h]
		or     cx,cx
		jne    LUMOD2
		or     dx,dx
		je     LUMOD3
		or     bx,bx
		je     LUMOD3
LUMOD2:		test   di,0001
		jne    LUMOD4
		or     dx,dx
		jns    LUMOD5
		neg    dx
		neg    ax
		sbb    dx,0000h
		or     di,000Ch
LUMOD5:		or     cx,cx
		jns    LUMOD4
		neg    cx
		neg    bx
		sbb    cx,0000h
		xor    di,0004h
LUMOD4:		mov    bp,cx
		mov    cx,0020h
		push   di
		xor    di,di
		xor    si,si
LUMOD8:		shl    ax,1
		rcl    dx,1
		rcl    si,1
		rcl    di,1
		cmp    di,bp
		jb     LUMOD6
		ja     LUMOD7
		cmp    si,bx
		jb     LUMOD6
LUMOD7:		sub    si,bx
		sbb    di,bp
		inc    ax
LUMOD6:		loop   LUMOD8
		pop    bx
		test   bx,0002h
		je     LUMOD9
		mov    ax,si
		mov    dx,di
		shr    bx,1
LUMOD9:		test   bx,0004h
		je     LUMODA
		neg    dx
		neg    ax
		sbb    dx,0000h
LUMODA:		pop    di
		pop    si
		pop    bp
		retf   0008h
LUMOD3:		div    bx
		test   di,0002h
		je     LUMODB
		xchg   dx,ax
LUMODB:		xor    dx,dx
		jmp    LUMODA
LUMOD@		endp


N_LXLSH@	proc	far
		pop    bx
		push   cs
		push   bx
N_LXLSH@	endp

LXLSH@		proc	far
		cmp    cl,10h
		jnb    LXLSH1
		mov    bx,ax
		shl    ax,cl
		shl    dx,cl
		neg    cl
		add    cl,10h
		shr    bx,cl
		or     dx,bx
		retf
LXLSH1:		sub    cl,10h
		xchg   dx,ax
		xor    ax,ax
		shl    dx,cl
		retf
LXLSH@		endp


_TEXT	ends	


_DATA	segment word public 'DATA'

miniSO_aux	dw	0000h	; auxiliar para armazenar valor da pilha

_DATA	ends

	extrn  _miniSO_contextswitch
	extrn	_scall:near

	public	_miniSO_systemcall
	public	_miniSO_clockhandler
	public	_miniSO_return_addr
	public	_setvect
	public	_getvect
	public	_enable
	public	_disable
	public	_MK_FP
	public	_FP_SEG
	public	_FP_OFF
	public	_init_ds
	public  _init_stack

	public	N_LXMUL@
	public	LXMUL@
	public	N_LDIV@
	public	LDIV@
	public	N_LUDIV@
	public	LUDIV@
	public	N_LMOD@
	public	LMOD@
	public	N_LUMOD@
	public	LUMOD@
	public	N_LXLSH@
	public	LXLSH@

	end
