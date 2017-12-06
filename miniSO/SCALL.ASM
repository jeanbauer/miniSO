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
	?debug	S "scall.c"
	?debug	C E920A9684B077363616C6C2E63
	?debug	C E98FA6684B086D696E69534F2E68
	?debug	C E9FBA5684B077363616C6C2E68
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
_DATA	segment word public 'DATA'
miniSO_col	label	byte
	db	80
miniSO_cor	label	byte
	db	7
miniSO_pag	label	byte
	db	0
miniSO_iskey	label	byte
	db	0
miniSO_key	label	byte
	db	0
nextsemid	label	word
	db	0
	db	0
_miniSO_ready	label	word
	db	255
	db	255
_miniSO_free	label	word
	db	255
	db	255
_miniSO_scall_table	label	word
	db	0
	db	1
	db	0
	dw	_sc_putch
	db	1
	db	0
	db	0
	dw	_sc_getch
	db	2
	db	0
	db	0
	dw	_sc_clrscr
	db	3
	db	0
	db	0
	dw	_sc_getcolor
	db	4
	db	1
	db	0
	dw	_sc_setcolor
	db	5
	db	0
	db	0
	dw	_sc_wherex
	db	6
	db	0
	db	0
	dw	_sc_wherey
	db	7
	db	2
	db	0
	dw	_sc_gotoxy
	db	8
	db	2
	db	0
	dw	_sc_getdate
	db	9
	db	2
	db	0
	dw	_sc_gettime
	db	10
	db	0
	db	0
	dw	_sc_reboot
	db	11
	db	2
	db	0
	dw	_sc_fork
	db	12
	db	1
	db	0
	dw	_sc_kill
	db	13
	db	3
	db	0
	dw	_sc_waitpid
	db	14
	db	2
	db	0
	dw	_sc_wait
	db	15
	db	1
	db	0
	dw	_sc_exit
	db	16
	db	0
	db	0
	dw	_sc_getpid
	db	17
	db	0
	db	0
	dw	_sc_getppid
	db	18
	db	2
	db	0
	dw	_sc_sendsignal
	db	19
	db	1
	db	0
	dw	_sc_waitsignal
	db	20
	db	1
	db	0
	dw	_sc_semcreate
	db	21
	db	2
	db	0
	dw	_sc_semset
	db	22
	db	1
	db	0
	dw	_sc_semup
	db	23
	db	1
	db	0
	dw	_sc_semdown
	db	24
	db	1
	db	0
	dw	_sc_semdestroy
	db	25
	db	1
	db	0
	dw	_sc_stop
	db	26
	db	1
	db	0
	dw	_sc_resume
_DATA	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	int scall(unsigned servico,unsigned bx,unsigned cx,unsigned dx)
   ;	
	assume	cs:_TEXT
_scall	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
	mov	di,word ptr [bp+6]
   ;	
   ;	{
   ;		int	i;
   ;	
   ;		for	(i=0;i<miniSO_NUMSCALL;++i) {
   ;	
	xor	si,si
	jmp	@1@338
@1@58:
   ;	
   ;			if	(servico==(unsigned)miniSO_scall_table[i].ah) {
   ;	
	mov	ax,si
	mov	dx,5
	imul	dx
	mov	bx,ax
	mov	al,byte ptr DGROUP:_miniSO_scall_table[bx]
	cbw	
	cmp	ax,word ptr [bp+4]
	jne	short @1@310
   ;	
   ;				switch	(miniSO_scall_table[i].numparam)  {
   ;	
	mov	ax,si
	mov	dx,5
	imul	dx
	mov	bx,ax
	mov	bx,word ptr DGROUP:_miniSO_scall_table[bx+1]
	cmp	bx,3
	ja	short @1@310
	shl	bx,1
	jmp	word ptr cs:@1@C434[bx]
@1@170:
   ;	
   ;					case	0:
   ;						return miniSO_scall_table[i].function.p0();
   ;	
	mov	ax,si
	mov	dx,5
	imul	dx
	mov	bx,ax
	call	word ptr DGROUP:_miniSO_scall_table[bx+3]
@1@198:
	jmp	short @1@394
@1@226:
   ;	
   ;					case	1:
   ;						return miniSO_scall_table[i].function.p1(bx);
   ;	
	push	di
	mov	ax,si
	mov	dx,5
	imul	dx
	mov	bx,ax
	call	word ptr DGROUP:_miniSO_scall_table[bx+3]
	pop	cx
	jmp	short @1@198
@1@254:
   ;	
   ;					case	2:
   ;						return miniSO_scall_table[i].function.p2(bx,cx);
   ;	
	push	word ptr [bp+8]
	push	di
	mov	ax,si
	mov	dx,5
	imul	dx
	mov	bx,ax
	call	word ptr DGROUP:_miniSO_scall_table[bx+3]
	pop	cx
	pop	cx
	jmp	short @1@198
@1@282:
   ;	
   ;					case	3:
   ;						return miniSO_scall_table[i].function.p3(bx,cx,dx);
   ;	
	push	word ptr [bp+10]
	push	word ptr [bp+8]
	push	di
	mov	ax,si
	mov	dx,5
	imul	dx
	mov	bx,ax
	call	word ptr DGROUP:_miniSO_scall_table[bx+3]
	add	sp,6
	jmp	short @1@198
@1@310:
	inc	si
@1@338:
	cmp	si,27
	jge	@@0
	jmp	@1@58
@@0:
   ;	
   ;				}
   ;			}
   ;		}
   ;		return 0;
   ;	
	xor	ax,ax
	jmp	short @1@198
@1@394:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_scall	endp
@1@C434	label	word
	dw	@1@170
	dw	@1@226
	dw	@1@254
	dw	@1@282
   ;	
   ;	void setCursorPosition(int pos)
   ;	
	assume	cs:_TEXT
setCursorPosition	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;		mov_dx(pos);
   ;	
	mov	dx,word ptr [bp+4]
   ;	
   ;		mov_bh(miniSO_pag);
   ;	
	mov	bh,byte ptr DGROUP:miniSO_pag
   ;	
   ;		mov_ah(2);
   ;	
	mov	ah,2
   ;	
   ;		int_10h();
   ;	
 	int	 10h 
   ;	
   ;	}
   ;	
	pop	bp
	ret	
setCursorPosition	endp
   ;	
   ;	int getCursorPosition()
   ;	
	assume	cs:_TEXT
getCursorPosition	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;		mov_bh(miniSO_pag);
   ;	
	mov	bh,byte ptr DGROUP:miniSO_pag
   ;	
   ;		mov_ah(3);
   ;	
	mov	ah,3
   ;	
   ;		int_10h();
   ;	
 	int	 10h 
   ;	
   ;		return _DX;
   ;	
	mov	ax,dx
	jmp	short @3@114
@3@114:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
getCursorPosition	endp
   ;	
   ;	void scroll()
   ;	
	assume	cs:_TEXT
scroll	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;		mov_al(1); /* número de linhas para scroll */
   ;	
	mov	al,1
   ;	
   ;		mov_cx(0);
   ;	
	xor	cx,cx
   ;	
   ;		mov_ah(6);
   ;	
	mov	ah,6
   ;	
   ;		mov_dh(24);
   ;	
	mov	dh,24
   ;	
   ;		mov_dl(miniSO_col);
   ;	
	mov	dl,byte ptr DGROUP:miniSO_col
   ;	
   ;		dec_dl();
   ;	
 	dec	 dl 
   ;	
   ;		mov_bh(miniSO_cor);
   ;	
	mov	bh,byte ptr DGROUP:miniSO_cor
   ;	
   ;		int_10h();
   ;	
 	int	 10h 
   ;	
   ;	}
   ;	
	pop	bp
	ret	
scroll	endp
   ;	
   ;	int sc_putch(int car)
   ;	
	assume	cs:_TEXT
_sc_putch	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
	push	si
	push	di
   ;	
   ;	{
   ;		int	curpos,lin,col;
   ;	
   ;		car = car & 0x00ff;
   ;	
	mov	ax,word ptr [bp+4]
	and	ax,255
	mov	word ptr [bp+4],ax
   ;	
   ;		if	(car==10)  {
   ;	
	cmp	word ptr [bp+4],10
	jne	short @5@170
   ;	
   ;			curpos = getCursorPosition();
   ;	
	call	near ptr getCursorPosition
	mov	di,ax
   ;	
   ;			lin = (curpos >> 8) & 0x00ff;
   ;	
	mov	ax,di
	mov	cl,8
	sar	ax,cl
	and	ax,255
	mov	si,ax
   ;	
   ;			col = 0;
   ;	
	mov	word ptr [bp-2],0
   ;	
   ;			if	(lin<24)
   ;	
	cmp	si,24
	jge	short @5@114
   ;	
   ;				++lin;
   ;	
	inc	si
	jmp	short @5@142
@5@114:
   ;	
   ;			else
   ;				scroll();
   ;	
	call	near ptr scroll
@5@142:
   ;	
   ;		}
   ;	
	jmp	short @5@338
@5@170:
   ;	
   ;		else	{
   ;			/* Imprime o caracter */
   ;			mov_bl(miniSO_cor);
   ;	
	mov	bl,byte ptr DGROUP:miniSO_cor
   ;	
   ;			mov_bh(miniSO_pag);
   ;	
	mov	bh,byte ptr DGROUP:miniSO_pag
   ;	
   ;			mov_cx(1);
   ;	
	mov	cx,1
   ;	
   ;			mov_ah(0x9);
   ;	
	mov	ah,9
   ;	
   ;			int_10h();
   ;	
 	int	 10h 
   ;	
   ;			curpos = getCursorPosition();
   ;	
	call	near ptr getCursorPosition
	mov	di,ax
   ;	
   ;			lin = (curpos >> 8) & 0x00ff;
   ;	
	mov	ax,di
	mov	cl,8
	sar	ax,cl
	and	ax,255
	mov	si,ax
   ;	
   ;			col = curpos & 0x00ff;
   ;	
	mov	ax,di
	and	ax,255
	mov	word ptr [bp-2],ax
   ;	
   ;			++col;
   ;	
	inc	word ptr [bp-2]
   ;	
   ;			if	(col==miniSO_col)  {
   ;	
	mov	al,byte ptr DGROUP:miniSO_col
	cbw	
	cmp	ax,word ptr [bp-2]
	jne	short @5@338
   ;	
   ;				col = 0;
   ;	
	mov	word ptr [bp-2],0
   ;	
   ;				if	(lin<24)
   ;	
	cmp	si,24
	jge	short @5@310
   ;	
   ;					++lin;
   ;	
	inc	si
	jmp	short @5@338
@5@310:
   ;	
   ;				else
   ;					scroll();
   ;	
	call	near ptr scroll
@5@338:
   ;	
   ;			}
   ;		}
   ;		curpos = (lin << 8)|col;
   ;	
	mov	ax,si
	mov	cl,8
	shl	ax,cl
	or	ax,word ptr [bp-2]
	mov	di,ax
   ;	
   ;		setCursorPosition(curpos);
   ;	
	push	di
	call	near ptr setCursorPosition
	pop	cx
   ;	
   ;		return 0;
   ;	
	xor	ax,ax
	jmp	short @5@366
@5@366:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_sc_putch	endp
   ;	
   ;	int sc_getch()
   ;	
	assume	cs:_TEXT
_sc_getch	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
   ;	
   ;	{
   ;	  int ax,al,ah;
   ;	
   ;	  if (miniSO_iskey!=0)  {
   ;	
	cmp	byte ptr DGROUP:miniSO_iskey,0
	je	short @6@114
   ;	
   ;	     miniSO_iskey = 0;
   ;	
	mov	byte ptr DGROUP:miniSO_iskey,0
   ;	
   ;	     return miniSO_key;
   ;	
	mov	al,byte ptr DGROUP:miniSO_key
	cbw	
@6@86:
	jmp	short @6@282
@6@114:
   ;	
   ;	  }
   ;	
   ;	  mov_ah(0x10);
   ;	
	mov	ah,16
   ;	
   ;	  int_16h();
   ;	
 	int	 16h 
   ;	
   ;	
   ;	  ax = get_ax();
   ;	
	mov	bx,ax
   ;	
   ;	  ah = (ax >> 8) & 0x00ff;
   ;	
	mov	ax,bx
	mov	cl,8
	sar	ax,cl
	and	ax,255
	mov	word ptr [bp-2],ax
   ;	
   ;	  al = 0x00ff & ax;
   ;	
	mov	ax,255
	and	ax,bx
	mov	dx,ax
   ;	
   ;	
   ;	  if (al==0xe0 || al==0x00)  {
   ;	
	cmp	dx,224
	je	short @6@226
	or	dx,dx
	jne	short @6@254
@6@226:
   ;	
   ;	     miniSO_iskey = 1;
   ;	
	mov	byte ptr DGROUP:miniSO_iskey,1
   ;	
   ;	     miniSO_key = ah;
   ;	
	mov	al,byte ptr [bp-2]
	mov	byte ptr DGROUP:miniSO_key,al
   ;	
   ;	     al = 0;
   ;	
	xor	dx,dx
@6@254:
   ;	
   ;	  }
   ;	  return al;
   ;	
	mov	ax,dx
	jmp	short @6@86
@6@282:
   ;	
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_sc_getch	endp
   ;	
   ;	int sc_clrscr()
   ;	
	assume	cs:_TEXT
_sc_clrscr	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  mov_al(0);
   ;	
	mov	al,0
   ;	
   ;	  mov_cx(0);
   ;	
	xor	cx,cx
   ;	
   ;	  mov_dh(24);
   ;	
	mov	dh,24
   ;	
   ;	  mov_dl(miniSO_col);
   ;	
	mov	dl,byte ptr DGROUP:miniSO_col
   ;	
   ;	  dec_dl();
   ;	
 	dec	 dl 
   ;	
   ;	  mov_ah(6);
   ;	
	mov	ah,6
   ;	
   ;	  mov_bh(7);
   ;	
	mov	bh,7
   ;	
   ;	  int_10h();
   ;	
 	int	 10h 
   ;	
   ;	  setCursorPosition(0);
   ;	
	xor	ax,ax
	push	ax
	call	near ptr setCursorPosition
	pop	cx
   ;	
   ;	  return 0;
   ;	
	xor	ax,ax
	jmp	short @7@170
@7@170:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_sc_clrscr	endp
   ;	
   ;	int sc_getcolor()
   ;	
	assume	cs:_TEXT
_sc_getcolor	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  return miniSO_cor;
   ;	
	mov	al,byte ptr DGROUP:miniSO_cor
	cbw	
	jmp	short @8@58
@8@58:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_sc_getcolor	endp
   ;	
   ;	int sc_setcolor(int cor)
   ;	
	assume	cs:_TEXT
_sc_setcolor	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  miniSO_cor = cor;
   ;	
	mov	al,byte ptr [bp+4]
	mov	byte ptr DGROUP:miniSO_cor,al
   ;	
   ;	  return 0;
   ;	
	xor	ax,ax
	jmp	short @9@58
@9@58:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_sc_setcolor	endp
   ;	
   ;	int sc_wherex()
   ;	
	assume	cs:_TEXT
_sc_wherex	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  return getCursorPosition() & 0x00ff;
   ;	
	call	near ptr getCursorPosition
	and	ax,255
	jmp	short @10@58
@10@58:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_sc_wherex	endp
   ;	
   ;	int sc_wherey()
   ;	
	assume	cs:_TEXT
_sc_wherey	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  return (getCursorPosition()>>8) & 0x00ff;
   ;	
	call	near ptr getCursorPosition
	mov	cl,8
	sar	ax,cl
	and	ax,255
	jmp	short @11@58
@11@58:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_sc_wherey	endp
   ;	
   ;	int sc_gotoxy(int x, int y)
   ;	
	assume	cs:_TEXT
_sc_gotoxy	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
	mov	si,word ptr [bp+4]
	mov	di,word ptr [bp+6]
   ;	
   ;	{
   ;	  x = x & 0x00ff;
   ;	
	mov	ax,si
	and	ax,255
	mov	si,ax
   ;	
   ;	  y = (y<<8) & 0xff00;
   ;	
	mov	ax,di
	mov	cl,8
	shl	ax,cl
	and	ax,-256
	mov	di,ax
   ;	
   ;	  setCursorPosition(x|y);
   ;	
	mov	ax,si
	or	ax,di
	push	ax
	call	near ptr setCursorPosition
	pop	cx
   ;	
   ;	  return 0;
   ;	
	xor	ax,ax
	jmp	short @12@58
@12@58:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_sc_gotoxy	endp
   ;	
   ;	int sc_getdate(unsigned seg, unsigned off)
   ;	
	assume	cs:_TEXT
_sc_getdate	proc	near
	push	bp
	mov	bp,sp
	sub	sp,8
	push	si
   ;	
   ;	{
   ;	  struct date far *dt;
   ;	  unsigned d,m,a;
   ;	
   ;	  dt = MK_FP(seg,off);
   ;	
	push	word ptr [bp+6]
	push	word ptr [bp+4]
	call	near ptr _MK_FP
	pop	cx
	pop	cx
	mov	word ptr [bp-2],dx
	mov	word ptr [bp-4],ax
   ;	
   ;	  mov_ah(4);
   ;	
	mov	ah,4
   ;	
   ;	  int_1ah();
   ;	
 	int	 1ah 
   ;	
   ;	  d=get_dl();
   ;	
	mov	al,dl
	mov	ah,0
	mov	word ptr [bp-6],ax
   ;	
   ;	  m=get_dh();
   ;	
	mov	al,dh
	mov	ah,0
	mov	word ptr [bp-8],ax
   ;	
   ;	  a=get_cx();
   ;	
	mov	si,cx
   ;	
   ;	  dt->da_day  = 10*((d & 0xf0)>>4) + (d & 0x0f);
   ;	
	mov	ax,word ptr [bp-6]
	and	ax,240
	mov	cl,4
	shr	ax,cl
	mov	dx,10
	imul	dx
	mov	dl,byte ptr [bp-6]
	and	dl,15
	add	al,dl
	les	bx,dword ptr [bp-4]
	mov	byte ptr es:[bx+2],al
   ;	
   ;	  dt->da_mon  = 10*((m & 0xf0)>>4) + (m & 0x0f);
   ;	
	mov	ax,word ptr [bp-8]
	and	ax,240
	mov	cl,4
	shr	ax,cl
	mov	dx,10
	imul	dx
	mov	dl,byte ptr [bp-8]
	and	dl,15
	add	al,dl
	les	bx,dword ptr [bp-4]
	mov	byte ptr es:[bx+3],al
   ;	
   ;	  dt->da_year = 1000*((a & 0xf000)>>12) + 100*((a & 0x0f00)>>8) + 10*((a & 0x00f0)>>4) + (a & 0x000f);
   ;	
	mov	ax,si
	and	ax,-4096
	mov	cl,12
	shr	ax,cl
	mov	dx,1000
	imul	dx
	push	ax
	mov	ax,si
	and	ax,3840
	mov	cl,8
	shr	ax,cl
	mov	dx,100
	imul	dx
	pop	dx
	add	dx,ax
	mov	ax,si
	and	ax,240
	mov	cl,4
	shr	ax,cl
	mov	bx,10
	push	dx
	imul	bx
	pop	dx
	add	dx,ax
	mov	ax,si
	and	ax,15
	add	dx,ax
	les	bx,dword ptr [bp-4]
	mov	word ptr es:[bx],dx
   ;	
   ;	  return 0;
   ;	
	xor	ax,ax
	jmp	short @13@114
@13@114:
   ;	
   ;	}
   ;	
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_sc_getdate	endp
   ;	
   ;	int sc_gettime(unsigned seg,unsigned off)
   ;	
	assume	cs:_TEXT
_sc_gettime	proc	near
	push	bp
	mov	bp,sp
	sub	sp,10
   ;	
   ;	{
   ;	  struct time far *tm;
   ;	  unsigned h,m,s;
   ;	
   ;	  tm = MK_FP(seg,off);
   ;	
	push	word ptr [bp+6]
	push	word ptr [bp+4]
	call	near ptr _MK_FP
	pop	cx
	pop	cx
	mov	word ptr [bp-2],dx
	mov	word ptr [bp-4],ax
   ;	
   ;	  mov_ah(2);
   ;	
	mov	ah,2
   ;	
   ;	  int_1ah();
   ;	
 	int	 1ah 
   ;	
   ;	  h=get_ch();
   ;	
	mov	al,ch
	mov	ah,0
	mov	word ptr [bp-6],ax
   ;	
   ;	  m=get_cl();
   ;	
	mov	al,cl
	mov	ah,0
	mov	word ptr [bp-8],ax
   ;	
   ;	  s=get_dh();
   ;	
	mov	al,dh
	mov	ah,0
	mov	word ptr [bp-10],ax
   ;	
   ;	  tm->ti_hour = 10*((h & 0xf0)>>4) + (h & 0x0f);
   ;	
	mov	ax,word ptr [bp-6]
	and	ax,240
	mov	cl,4
	shr	ax,cl
	mov	dx,10
	imul	dx
	mov	dl,byte ptr [bp-6]
	and	dl,15
	add	al,dl
	les	bx,dword ptr [bp-4]
	mov	byte ptr es:[bx+1],al
   ;	
   ;	  tm->ti_min  = 10*((m & 0xf0)>>4) + (m & 0x0f);
   ;	
	mov	ax,word ptr [bp-8]
	and	ax,240
	mov	cl,4
	shr	ax,cl
	mov	dx,10
	imul	dx
	mov	dl,byte ptr [bp-8]
	and	dl,15
	add	al,dl
	les	bx,dword ptr [bp-4]
	mov	byte ptr es:[bx],al
   ;	
   ;	  tm->ti_sec  = 10*((s & 0xf0)>>4) + (s & 0x0f);
   ;	
	mov	ax,word ptr [bp-10]
	and	ax,240
	mov	cl,4
	shr	ax,cl
	mov	dx,10
	imul	dx
	mov	dl,byte ptr [bp-10]
	and	dl,15
	add	al,dl
	les	bx,dword ptr [bp-4]
	mov	byte ptr es:[bx+3],al
   ;	
   ;	  tm->ti_hund = 0;
   ;	
	les	bx,dword ptr [bp-4]
	mov	byte ptr es:[bx+2],0
   ;	
   ;	  return 0;
   ;	
	xor	ax,ax
	jmp	short @14@114
@14@114:
   ;	
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_sc_gettime	endp
   ;	
   ;	void miniSO_contextswitch ()
   ;	
	assume	cs:_TEXT
_miniSO_contextswitch	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  if ( miniSO_nextthread == miniSO_NONE )
   ;	
	cmp	word ptr DGROUP:_miniSO_nextthread,-1
	jne	short @15@86
   ;	
   ;	     miniSO_nextthread=miniSO_thread[miniSO_ready].next;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+24]
	mov	word ptr DGROUP:_miniSO_nextthread,ax
@15@86:
   ;	
   ;	  /* Se houve alteracao de thread corrente ... */
   ;	  if (miniSO_nextthread!=miniSO_ready)  {
   ;	
	mov	ax,word ptr DGROUP:_miniSO_nextthread
	cmp	ax,word ptr DGROUP:_miniSO_ready
	jne	@@1
	jmp	@15@254
@@1:
   ;	
   ;	     if (miniSO_delcurthread)          /* Se a thread corrente foi excluida ... */
   ;	
	cmp	byte ptr DGROUP:_miniSO_delcurthread,0
	je	short @15@170
   ;	
   ;		miniSO_delcurthread=0;        /* zera o flag para deletado e nao captura SS:SP */
   ;	
	mov	byte ptr DGROUP:_miniSO_delcurthread,0
	jmp	short @15@226
@15@170:
   ;	
   ;	     else  {
   ;		/* Salva SS:SP da thread corrente no BCP */
   ;		miniSO_thread[miniSO_ready].ss=_SS;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+6],ss
   ;	
   ;		miniSO_thread[miniSO_ready].sp=_SP;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+8],sp
   ;	
   ;	        if (miniSO_thread[miniSO_ready].status==RUNNING)
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+4],1
	jne	short @15@226
   ;	
   ;	           miniSO_thread[miniSO_ready].status=READY;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],0
@15@226:
   ;	
   ;	     }
   ;	     /* Atualiza thread corrente */
   ;	     miniSO_ready=miniSO_nextthread;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_nextthread
	mov	word ptr DGROUP:_miniSO_ready,ax
   ;	
   ;	     miniSO_thread[miniSO_ready].status=RUNNING;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],1
   ;	
   ;	     /* Define SS:SP para a thread corrente */
   ;	     _SS=miniSO_thread[miniSO_ready].ss;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ss,word ptr DGROUP:_miniSO_thread[bx+6]
   ;	
   ;	     _SP=miniSO_thread[miniSO_ready].sp;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	sp,word ptr DGROUP:_miniSO_thread[bx+8]
@15@254:
   ;	
   ;	
   ;	  }
   ;	  miniSO_nextthread = miniSO_NONE;
   ;	
	mov	word ptr DGROUP:_miniSO_nextthread,-1
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_miniSO_contextswitch	endp
   ;	
   ;	static void end_mso(char *msg)
   ;	
	assume	cs:_TEXT
end_mso	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  /* Restaura a interrupção do relógio original */
   ;	  setvect(miniSO_CLOCKINT,miniSO_oldisr);
   ;	
	push	word ptr DGROUP:_miniSO_oldisr+2
	push	word ptr DGROUP:_miniSO_oldisr
	mov	ax,28
	push	ax
	call	near ptr _setvect
	add	sp,6
   ;	
   ;	  enable();
   ;	
	call	near ptr _enable
   ;	
   ;	  putstr("\n\n");
   ;	
	push	ds
	mov	ax,offset DGROUP:s@
	push	ax
	call	near ptr _putstr
	pop	cx
	pop	cx
   ;	
   ;	  putstr(msg);
   ;	
	push	ds
	push	word ptr [bp+4]
	call	near ptr _putstr
	pop	cx
	pop	cx
   ;	
   ;	  putch('\n');
   ;	
	mov	ax,10
	push	ax
	call	near ptr _putch
	pop	cx
   ;	
   ;	  putstr("Pressione uma tecla para reiniciar...\n");
   ;	
	push	ds
	mov	ax,offset DGROUP:s@+3
	push	ax
	call	near ptr _putstr
	pop	cx
	pop	cx
   ;	
   ;	  getch();
   ;	
	call	near ptr _getch
   ;	
   ;	  /* Reinicializa a máquina */
   ;	  sc_reboot();
   ;	
	call	near ptr _sc_reboot
   ;	
   ;	}
   ;	
	pop	bp
	ret	
end_mso	endp
   ;	
   ;	static pcb_t get_pcb(pid_t pid)
   ;	
	assume	cs:_TEXT
get_pcb	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;		pcb_t	pcb;
   ;	
   ;		for	(pcb=0;pcb<miniSO_MAXTHREADS;++pcb)  {
   ;	
	xor	cx,cx
	jmp	short @17@198
@17@58:
   ;	
   ;			if	( miniSO_thread[pcb].status!=FREE && miniSO_thread[pcb].pid==pid )
   ;	
	mov	ax,cx
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+4],-1
	je	short @17@170
	mov	ax,cx
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx]
	cmp	ax,word ptr [bp+4]
	jne	short @17@170
   ;	
   ;				return pcb;
   ;	
	mov	ax,cx
@17@142:
	jmp	short @17@254
@17@170:
	inc	cx
@17@198:
	cmp	cx,16
	jl	short @17@58
   ;	
   ;		}
   ;		return -1;
   ;	
	mov	ax,-1
	jmp	short @17@142
@17@254:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
get_pcb	endp
   ;	
   ;	void miniSO_init_semtable()
   ;	
	assume	cs:_TEXT
_miniSO_init_semtable	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;		int i;
   ;	
   ;		for	(i=0;i<miniSO_MAXSEMAPHORES;++i)
   ;	
	xor	ax,ax
	jmp	short @18@114
@18@58:
   ;	
   ;			miniSO_sem[i].status = FREE;
   ;	
	mov	bx,ax
	mov	cl,3
	shl	bx,cl
	mov	word ptr DGROUP:_miniSO_sem[bx],-1
	inc	ax
@18@114:
	cmp	ax,10
	jl	short @18@58
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_miniSO_init_semtable	endp
   ;	
   ;	void miniSO_init_proctable()
   ;	
	assume	cs:_TEXT
_miniSO_init_proctable	proc	near
	push	bp
	mov	bp,sp
	push	si
   ;	
   ;	{
   ;	  pcb_t i;
   ;	
   ;	  disable();
   ;	
	call	near ptr _disable
   ;	
   ;	
   ;	  /* Inicializa a tabela de semaforos */
   ;	  miniSO_init_semtable();
   ;	
	call	near ptr _miniSO_init_semtable
   ;	
   ;	  /* Inicializa tabela de threads */
   ;	  miniSO_ready =  0;
   ;	
	mov	word ptr DGROUP:_miniSO_ready,0
   ;	
   ;	  miniSO_thread[miniSO_ready].pid      = 0;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx],0
   ;	
   ;	  miniSO_thread[miniSO_ready].ppid     = -1;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+2],-1
   ;	
   ;	  miniSO_thread[miniSO_ready].next     = miniSO_ready;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	dx,word ptr DGROUP:_miniSO_ready
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;	  miniSO_thread[miniSO_ready].prev     = miniSO_ready;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	dx,word ptr DGROUP:_miniSO_ready
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],dx
   ;	
   ;	  miniSO_thread[miniSO_ready].status   = RUNNING;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],1
   ;	
   ;	  miniSO_thread[miniSO_ready].recvsig  = 0;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+10],0
   ;	
   ;	  miniSO_thread[miniSO_ready].wait     = -1;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+14],-1
   ;	
   ;	  miniSO_thread[miniSO_ready].zombies  = -1;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+20],-1
   ;	
   ;	  /* O resto dos BCPs permanece na lista de livres */
   ;	  miniSO_free  =  1;
   ;	
	mov	word ptr DGROUP:_miniSO_free,1
   ;	
   ;	  for ( i=1 ; i<miniSO_MAXTHREADS-1 ; ++i)  {
   ;	
	mov	si,1
	jmp	short @19@114
@19@58:
   ;	
   ;	      miniSO_thread[i].next   = i+1;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	dx,si
	inc	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;	      miniSO_thread[i].status = FREE;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],-1
	inc	si
@19@114:
	cmp	si,15
	jl	short @19@58
   ;	
   ;	  }
   ;	  miniSO_thread[miniSO_MAXTHREADS-1].next   = -1;
   ;	
	mov	word ptr DGROUP:_miniSO_thread+414,-1
   ;	
   ;	  miniSO_thread[miniSO_MAXTHREADS-1].status = FREE;
   ;	
	mov	word ptr DGROUP:_miniSO_thread+394,-1
   ;	
   ;	  /* Zera tempos do sistema */
   ;	  miniSO_delcurthread  = 0;
   ;	
	mov	byte ptr DGROUP:_miniSO_delcurthread,0
   ;	
   ;	  miniSO_nextthread = miniSO_NONE;
   ;	
	mov	word ptr DGROUP:_miniSO_nextthread,-1
   ;	
   ;	  /* Habilita as interrupcoes e retorna */
   ;	  enable();
   ;	
	call	near ptr _enable
   ;	
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_miniSO_init_proctable	endp
   ;	
   ;	int sc_reboot()
   ;	
	assume	cs:_TEXT
_sc_reboot	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
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
   ;		enable();
   ;	
	call	near ptr _enable
   ;	
   ;		asm	{
   ;			int	19h
   ;	
	int		19h
   ;	
   ;		}
   ;		return 0;
   ;	
	xor	ax,ax
	jmp	short @20@114
@20@114:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_sc_reboot	endp
_TEXT	ends
_DATA	segment word public 'DATA'
	db	1
	db	0
_DATA	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	int sc_fork(unsigned cs, unsigned ip)
   ;	
	assume	cs:_TEXT
_sc_fork	proc	near
	push	bp
	mov	bp,sp
	sub	sp,6
	push	si
	push	di
   ;	
   ;	{
   ;		pid_t		pid;
   ;		pcb_t		pcb,last;
   ;		unsigned far *	stack;
   ;		static pid_t	nextpid=1; /* Número do próximo pid */
   ;		extern void	miniSO_return_addr(void);
   ;	
   ;		/* Se o nucleo esta' instalado e existem BCPs livres insere no fim da lista ... */
   ;		if	(miniSO_free == -1)
   ;	
	cmp	word ptr DGROUP:_miniSO_free,-1
	jne	short @21@114
   ;	
   ;			return miniSO_ERROR;
   ;	
	mov	ax,-1
@21@86:
	jmp	@21@338
@21@114:
   ;	
   ;		disable();
   ;	
	call	near ptr _disable
   ;	
   ;		/* Gera um pid para a thread */
   ;		pcb = 0;
   ;	
	xor	si,si
	jmp	short @21@282
@21@142:
   ;	
   ;		while	(pcb!=-1)  {
   ;			pcb = get_pcb (nextpid);
   ;	
	push	word ptr DGROUP:d@w+146
	call	near ptr get_pcb
	pop	cx
	mov	si,ax
   ;	
   ;			if	(pcb==-1)
   ;	
	cmp	si,-1
	jne	short @21@198
   ;	
   ;				pid = nextpid;
   ;	
	mov	di,word ptr DGROUP:d@w+146
@21@198:
   ;	
   ;			if	(nextpid==32767)
   ;	
	cmp	word ptr DGROUP:d@w+146,32767
	jne	short @21@254
   ;	
   ;				nextpid=1;
   ;	
	mov	word ptr DGROUP:d@w+146,1
	jmp	short @21@282
@21@254:
   ;	
   ;			else
   ;				nextpid++;
   ;	
	inc	word ptr DGROUP:d@w+146
@21@282:
	cmp	si,-1
	jne	short @21@142
   ;	
   ;		}
   ;		/* Retira um BCP da lista de BCPs livres */
   ;		pcb     = miniSO_free;
   ;	
	mov	si,word ptr DGROUP:_miniSO_free
   ;	
   ;		miniSO_free = miniSO_thread[miniSO_free].next;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_free
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+24]
	mov	word ptr DGROUP:_miniSO_free,ax
   ;	
   ;		miniSO_thread[pcb].pid = pid;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx],di
   ;	
   ;		miniSO_thread[pcb].ppid = miniSO_thread[miniSO_ready].pid;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx]
	push	ax
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	pop	ax
	mov	word ptr DGROUP:_miniSO_thread[bx+2],ax
   ;	
   ;		/* Cria pilha da thread */
   ;		stack=(unsigned far *)MK_FP(miniSO_INITSTACKS+(miniSO_STACKSIZE>>4)*(miniSO_MAXTHREADS-1-pcb),miniSO_STACKSIZE);
   ;	
	mov	ax,1536
	push	ax
	mov	ax,15
	sub	ax,si
	mov	dx,96
	imul	dx
	add	ax,3328
	push	ax
	call	near ptr _MK_FP
	pop	cx
	pop	cx
	mov	word ptr [bp-4],dx
	mov	word ptr [bp-6],ax
   ;	
   ;		/* Empilha o endereco da funcao sc_exit, de modo que se    */
   ;		/*  a thread sair da funcao sem chamar sc_exit, a thread */
   ;		/*  seja automaticamente excluida */
   ;		*(--stack)=0; /* Empilha código de fim a ser enviado para sc_exit */
   ;	
	sub	word ptr [bp-6],2
	les	bx,dword ptr [bp-6]
	mov	word ptr es:[bx],0
   ;	
   ;		*(--stack)=miniSO_CODESEGMENT;
   ;	
	sub	word ptr [bp-6],2
	les	bx,dword ptr [bp-6]
	mov	word ptr es:[bx],2016
   ;	
   ;		*(--stack)=(unsigned)sc_exit;
   ;	
	sub	word ptr [bp-6],2
	les	bx,dword ptr [bp-6]
	mov	word ptr es:[bx],offset _sc_exit
   ;	
   ;		*(--stack)=0x0200 ;       /* FLAGS */
   ;	
	sub	word ptr [bp-6],2
	les	bx,dword ptr [bp-6]
	mov	word ptr es:[bx],512
   ;	
   ;		*(--stack)=cs;            /* CS */
   ;	
	sub	word ptr [bp-6],2
	les	bx,dword ptr [bp-6]
	mov	ax,word ptr [bp+4]
	mov	word ptr es:[bx],ax
   ;	
   ;		*(--stack)=ip;            /* IP */
   ;	
	sub	word ptr [bp-6],2
	les	bx,dword ptr [bp-6]
	mov	ax,word ptr [bp+6]
	mov	word ptr es:[bx],ax
   ;	
   ;		*(--stack)=0;             /* AX */
   ;	
	sub	word ptr [bp-6],2
	les	bx,dword ptr [bp-6]
	mov	word ptr es:[bx],0
   ;	
   ;		*(--stack)=0;             /* BX */
   ;	
	sub	word ptr [bp-6],2
	les	bx,dword ptr [bp-6]
	mov	word ptr es:[bx],0
   ;	
   ;		*(--stack)=0;             /* CX */
   ;	
	sub	word ptr [bp-6],2
	les	bx,dword ptr [bp-6]
	mov	word ptr es:[bx],0
   ;	
   ;		*(--stack)=0;             /* DX */
   ;	
	sub	word ptr [bp-6],2
	les	bx,dword ptr [bp-6]
	mov	word ptr es:[bx],0
   ;	
   ;		*(--stack)=0;             /* ES */
   ;	
	sub	word ptr [bp-6],2
	les	bx,dword ptr [bp-6]
	mov	word ptr es:[bx],0
   ;	
   ;		*(--stack)=miniSO_DATASEGMENT;/* DS */
   ;	
	sub	word ptr [bp-6],2
	les	bx,dword ptr [bp-6]
	mov	word ptr es:[bx],2971
   ;	
   ;		*(--stack)=0;             /* SI */
   ;	
	sub	word ptr [bp-6],2
	les	bx,dword ptr [bp-6]
	mov	word ptr es:[bx],0
   ;	
   ;		*(--stack)=0;             /* DI */
   ;	
	sub	word ptr [bp-6],2
	les	bx,dword ptr [bp-6]
	mov	word ptr es:[bx],0
   ;	
   ;		*(--stack)=0;             /* BP */
   ;	
	sub	word ptr [bp-6],2
	les	bx,dword ptr [bp-6]
	mov	word ptr es:[bx],0
   ;	
   ;		*(--stack)=(unsigned)miniSO_return_addr;
   ;	
	sub	word ptr [bp-6],2
	les	bx,dword ptr [bp-6]
	mov	word ptr es:[bx],offset _miniSO_return_addr
   ;	
   ;		*(--stack)=0;             /* BP */
   ;	
	sub	word ptr [bp-6],2
	les	bx,dword ptr [bp-6]
	mov	word ptr es:[bx],0
   ;	
   ;		/* Inicializa campos da nova thread */
   ;		miniSO_thread[pcb].ss       = FP_SEG(stack);
   ;	
	push	word ptr [bp-4]
	push	word ptr [bp-6]
	call	near ptr _FP_SEG
	pop	cx
	pop	cx
	push	ax
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	pop	ax
	mov	word ptr DGROUP:_miniSO_thread[bx+6],ax
   ;	
   ;		miniSO_thread[pcb].sp       = FP_OFF(stack);
   ;	
	push	word ptr [bp-4]
	push	word ptr [bp-6]
	call	near ptr _FP_OFF
	pop	cx
	pop	cx
	push	ax
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	pop	ax
	mov	word ptr DGROUP:_miniSO_thread[bx+8],ax
   ;	
   ;		miniSO_thread[pcb].status   = READY;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],0
   ;	
   ;		miniSO_thread[pcb].recvsig  = 0;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+10],0
   ;	
   ;		miniSO_thread[pcb].waitsig  = 0;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+12],0
   ;	
   ;		miniSO_thread[pcb].wait     = -1;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+14],-1
   ;	
   ;		miniSO_thread[pcb].waitfor  = -1;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+16],-1
   ;	
   ;		miniSO_thread[pcb].zombies  = -1;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+20],-1
   ;	
   ;		/* Descobre qual a ultima thread */
   ;		last = miniSO_thread[miniSO_ready].prev;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+22]
	mov	word ptr [bp-2],ax
   ;	
   ;		/* Acerta links para incluir a nova thread */
   ;		miniSO_thread[pcb].prev      = last;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-2]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],dx
   ;	
   ;		miniSO_thread[pcb].next      = miniSO_ready;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	dx,word ptr DGROUP:_miniSO_ready
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;		miniSO_thread[last].next     = pcb;
   ;	
	mov	ax,word ptr [bp-2]
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],si
   ;	
   ;		miniSO_thread[miniSO_ready].prev = pcb;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],si
   ;	
   ;		enable();
   ;	
	call	near ptr _enable
   ;	
   ;		return pid;
   ;	
	mov	ax,di
	jmp	@21@86
@21@338:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_sc_fork	endp
   ;	
   ;	int sc_kill(pid_t pid)
   ;	
	assume	cs:_TEXT
_sc_kill	proc	near
	push	bp
	mov	bp,sp
	sub	sp,8
	push	si
	push	di
   ;	
   ;	{
   ;		pcb_t pcb,pcbw,last,prevthread,nextthread,pai,i,ant;
   ;	
   ;		disable();
   ;	
	call	near ptr _disable
   ;	
   ;		/* Se remover a thread 0 ... */
   ;		if	(pid==0)
   ;	
	cmp	word ptr [bp+4],0
	jne	short @22@86
   ;	
   ;			end_mso("kill(): thread 0 excluida!");
   ;	
	mov	ax,offset DGROUP:s@+42
	push	ax
	call	near ptr end_mso
	pop	cx
@22@86:
   ;	
   ;		/* Tem que verificar se existe a thread */
   ;		pcb = get_pcb(pid);
   ;	
	push	word ptr [bp+4]
	call	near ptr get_pcb
	pop	cx
	mov	si,ax
   ;	
   ;		/* Se nao existe uma thread com este numero, entao retorna */
   ;		if	(pcb==-1)  {
   ;	
	cmp	si,-1
	jne	short @22@170
@22@114:
   ;	
   ;			enable();
   ;	
	call	near ptr _enable
   ;	
   ;			return miniSO_ERROR;
   ;	
	mov	ax,-1
@22@142:
	jmp	@22@1206
@22@170:
	jmp	short @22@226
@22@198:
   ;	
   ;		}
   ;		/* Trata os zumbis do processo, colocando-os na lista de livres */
   ;		i = miniSO_thread[pcb].zombies;
   ;		while	(i!= -1)  {
   ;			miniSO_thread[pcb].zombies = miniSO_thread[i].next;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+24]
	push	ax
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	pop	ax
	mov	word ptr DGROUP:_miniSO_thread[bx+20],ax
   ;	
   ;			miniSO_thread[i].next   = miniSO_free;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	dx,word ptr DGROUP:_miniSO_free
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;			miniSO_free             = i;
   ;	
	mov	word ptr DGROUP:_miniSO_free,di
   ;	
   ;			miniSO_thread[i].status = FREE;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],-1
   ;	
   ;			i = miniSO_thread[pcb].zombies;
   ;	
@22@226:
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	di,word ptr DGROUP:_miniSO_thread[bx+20]
	cmp	di,-1
	jne	short @22@198
   ;	
   ;		}
   ;		/* Passa os filhos do processo para o avo */
   ;		for	(i=0;i<miniSO_MAXTHREADS;++i)  {
   ;	
	xor	di,di
	jmp	short @22@422
@22@310:
   ;	
   ;			if	(miniSO_thread[i].status!=FREE && miniSO_thread[i].ppid == miniSO_thread[pcb].pid)
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+4],-1
	je	short @22@394
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+2]
	push	ax
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	pop	ax
	cmp	ax,word ptr DGROUP:_miniSO_thread[bx]
	jne	short @22@394
   ;	
   ;				miniSO_thread[i].ppid = miniSO_thread[pcb].ppid;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+2]
	push	ax
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	pop	ax
	mov	word ptr DGROUP:_miniSO_thread[bx+2],ax
@22@394:
	inc	di
@22@422:
	cmp	di,16
	jl	short @22@310
   ;	
   ;		}
   ;		/* Salva anterior e proximo da thread que sera deletada */
   ;		prevthread = miniSO_thread[pcb].prev;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+22]
	mov	word ptr [bp-4],ax
   ;	
   ;		nextthread = miniSO_thread[pcb].next;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+24]
	mov	word ptr [bp-6],ax
   ;	
   ;		/* A thread pode estar em um de varios estados... */
   ;		switch	(miniSO_thread[pcb].status)  {
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	bx,word ptr DGROUP:_miniSO_thread[bx+4]
	cmp	bx,6
	ja	short @22@758
	shl	bx,1
	jmp	word ptr cs:@22@C1266[bx]
@22@562:
   ;	
   ;			case	READY:
   ;			case	RUNNING:
   ;				/* Exclui o nodo da lista de prontos */
   ;				miniSO_thread[prevthread].next=nextthread;
   ;	
	mov	ax,word ptr [bp-4]
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-6]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;				miniSO_thread[nextthread].prev=prevthread;
   ;	
	mov	ax,word ptr [bp-6]
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-4]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],dx
   ;	
   ;				if	(pcb==miniSO_ready)  {
   ;	
	cmp	si,word ptr DGROUP:_miniSO_ready
	jne	short @22@674
   ;	
   ;					if	(nextthread==miniSO_ready)
   ;	
	mov	ax,word ptr [bp-6]
	cmp	ax,word ptr DGROUP:_miniSO_ready
	jne	short @22@646
   ;	
   ;						end_mso("kill(): nao ha' mais threads executando!");
   ;	
	mov	ax,offset DGROUP:s@+69
	push	ax
	call	near ptr end_mso
	pop	cx
	jmp	short @22@674
@22@646:
   ;	
   ;					else  {
   ;						miniSO_nextthread=nextthread;
   ;	
	mov	ax,word ptr [bp-6]
	mov	word ptr DGROUP:_miniSO_nextthread,ax
   ;	
   ;						miniSO_delcurthread=1;
   ;	
	mov	byte ptr DGROUP:_miniSO_delcurthread,1
@22@674:
   ;	
   ;					}
   ;				}
   ;				break;
   ;	
	jmp	short @22@786
@22@702:
   ;	
   ;			case	WAITSEM:
   ;				/* Exclui o nodo da lista do semaforo */
   ;				break;
   ;	
	jmp	short @22@786
@22@730:
   ;	
   ;			case	WAIT:
   ;			case	WAITSIG:
   ;	        case    STOPPED:
   ;				break;
   ;	
	jmp	short @22@786
@22@758:
	jmp	@22@114
@22@786:
   ;	
   ;			case	ZOMBIE:
   ;			default:
   ;				enable();
   ;				return miniSO_ERROR;
   ;		}
   ;		/* Coloca o BCP da thread na lista de filhos zumbis do pai */
   ;		pai = get_pcb(miniSO_thread[pcb].ppid);
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	push	word ptr DGROUP:_miniSO_thread[bx+2]
	call	near ptr get_pcb
	pop	cx
	mov	word ptr [bp-8],ax
   ;	
   ;		if	(pai==-1) { /* Se nao encontrou o pai, */
   ;	
	cmp	word ptr [bp-8],-1
	jne	short @22@842
   ;	
   ;			/* coloca o processo na lista de livres */
   ;			miniSO_thread[pcb].status = FREE;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],-1
   ;	
   ;			miniSO_thread[pcb].next = miniSO_free;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	dx,word ptr DGROUP:_miniSO_free
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;			miniSO_free=pcb;
   ;	
	mov	word ptr DGROUP:_miniSO_free,si
   ;	
   ;		}
   ;	
	jmp	@22@1038
@22@842:
   ;	
   ;		else  {
   ;			/* senao, coloca o processo na lista de zumbis do pai */
   ;			miniSO_thread[pcb].status = ZOMBIE;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],2
   ;	
   ;			if	(miniSO_thread[pai].zombies==-1) { /* Se a lista esta vazia */
   ;	
	mov	ax,word ptr [bp-8]
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+20],-1
	jne	short @22@898
   ;	
   ;				/* Insere no inicio */
   ;				miniSO_thread[pai].zombies = pcb;
   ;	
	mov	ax,word ptr [bp-8]
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+20],si
   ;	
   ;				miniSO_thread[pcb].prev = -1;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],-1
   ;	
   ;			}
   ;	
	jmp	short @22@1010
@22@898:
   ;	
   ;			else {
   ;				/* Senao insere no final */
   ;				i = miniSO_thread[pai].zombies;
   ;	
	mov	ax,word ptr [bp-8]
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	di,word ptr DGROUP:_miniSO_thread[bx+20]
	jmp	short @22@954
@22@926:
   ;	
   ;				while	(miniSO_thread[i].next!=-1)
   ;					i = miniSO_thread[i].next;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	di,word ptr DGROUP:_miniSO_thread[bx+24]
@22@954:
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+24],-1
	jne	short @22@926
   ;	
   ;				miniSO_thread[i].next = pcb;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],si
   ;	
   ;				miniSO_thread[pcb].prev = i;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],di
@22@1010:
   ;	
   ;			}
   ;			miniSO_thread[pcb].next = -1;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],-1
@22@1038:
   ;	
   ;		}
   ;		if	(miniSO_thread[pai].status==WAIT) {
   ;	
	mov	ax,word ptr [bp-8]
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+4],3
	jne	short @22@1066
@22@1066:
   ;	
   ;		}
   ;		/* REVISAR */
   ;	  /* Se o processo-pai esta' esperando em wait, coloca ele na lista de prontos */
   ;	  nextthread = miniSO_thread[pcb].wait;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+14]
	mov	word ptr [bp-6],ax
   ;	
   ;	  if (nextthread != -1)  {
   ;	
	cmp	word ptr [bp-6],-1
	jne	@@2
	jmp	@22@1122
@@2:
   ;	
   ;	     /* Descobre qual a ultima thread */
   ;	     last = miniSO_thread[miniSO_ready].prev;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+22]
	mov	word ptr [bp-2],ax
   ;	
   ;	     /* Acerta links para incluir a thread no final da lista de prontos*/
   ;	     miniSO_thread[nextthread].prev    = last;
   ;	
	mov	ax,word ptr [bp-6]
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-2]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],dx
   ;	
   ;	     miniSO_thread[nextthread].next    = miniSO_ready;
   ;	
	mov	ax,word ptr [bp-6]
	mov	dx,26
	imul	dx
	mov	dx,word ptr DGROUP:_miniSO_ready
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;	     miniSO_thread[last].next          = nextthread;
   ;	
	mov	ax,word ptr [bp-2]
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-6]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;	     miniSO_thread[miniSO_ready].prev  = nextthread;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-6]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],dx
   ;	
   ;	     miniSO_thread[nextthread].exitcode = miniSO_ERROR;
   ;	
	mov	ax,word ptr [bp-6]
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+18],-1
   ;	
   ;	     miniSO_thread[nextthread].status  = READY;
   ;	
	mov	ax,word ptr [bp-6]
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],0
@22@1122:
   ;	
   ;	  }
   ;	
   ;		enable();
   ;	
	call	near ptr _enable
   ;	
   ;		if	(miniSO_delcurthread)
   ;	
	cmp	byte ptr DGROUP:_miniSO_delcurthread,0
	je	short @22@1178
@22@1150:
	jmp	short @22@1150
@22@1178:
   ;	
   ;			while	(1)
   ;				;
   ;		return miniSO_OK;
   ;	
	mov	ax,1
	jmp	@22@142
@22@1206:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_sc_kill	endp
@22@C1266	label	word
	dw	@22@562
	dw	@22@562
	dw	@22@758
	dw	@22@730
	dw	@22@730
	dw	@22@702
	dw	@22@730
   ;	
   ;	int sc_waitpid(pid_t pid,unsigned seg,unsigned off)
   ;	
	assume	cs:_TEXT
_sc_waitpid	proc	near
	push	bp
	mov	bp,sp
	sub	sp,8
	push	si
	push	di
   ;	
   ;	{
   ;		pcb_t pcb,pcbw,prevthread,nextthread,atual;
   ;		int far	*p_ref;
   ;	
   ;		disable();
   ;	
	call	near ptr _disable
   ;	
   ;		/* Tem que verificar se existe a thread */
   ;		pcb = get_pcb(pid);
   ;	
	push	word ptr [bp+4]
	call	near ptr get_pcb
	pop	cx
	mov	word ptr [bp-2],ax
   ;	
   ;		/* Se nao existe uma thread com este numero ou se não é pai da thread, entao retorna */
   ;		if	(pcb==-1 || miniSO_thread[pcb].ppid != miniSO_thread[miniSO_ready].pid)  {
   ;	
	cmp	word ptr [bp-2],-1
	je	short @23@86
	mov	ax,word ptr [bp-2]
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+2]
	push	ax
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	pop	ax
	cmp	ax,word ptr DGROUP:_miniSO_thread[bx]
	je	short @23@142
@23@86:
   ;	
   ;			enable();
   ;	
	call	near ptr _enable
   ;	
   ;			return miniSO_ERROR;
   ;	
	mov	ax,-1
@23@114:
	jmp	@23@534
@23@142:
   ;	
   ;		}
   ;		if	(miniSO_thread[pcb].status!=ZOMBIE)  {
   ;	
	mov	ax,word ptr [bp-2]
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+4],2
	jne	@@3
	jmp	@23@310
@@3:
   ;	
   ;			/* O processo-filho ainda esta em execucao... */
   ;			atual = miniSO_ready;
   ;	
	mov	si,word ptr DGROUP:_miniSO_ready
   ;	
   ;			prevthread = miniSO_thread[atual].prev;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+22]
	mov	word ptr [bp-4],ax
   ;	
   ;			nextthread = miniSO_thread[atual].next;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	di,word ptr DGROUP:_miniSO_thread[bx+24]
   ;	
   ;			/* Se eh a ultima thread ... */
   ;			if	(atual == nextthread)
   ;	
	cmp	si,di
	jne	short @23@226
   ;	
   ;				end_mso("waitpid(): nao ha' mais threads executando!");
   ;	
	mov	ax,offset DGROUP:s@+110
	push	ax
	call	near ptr end_mso
	pop	cx
@23@226:
   ;	
   ;			/* Vincula o BCP da thread atual ao BCP da thread "destino" */
   ;			miniSO_thread[pcb].wait = atual;
   ;	
	mov	ax,word ptr [bp-2]
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+14],si
   ;	
   ;			miniSO_thread[atual].prev = -1;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],-1
   ;	
   ;			miniSO_thread[atual].next = -1;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],-1
   ;	
   ;			miniSO_thread[atual].waitfor = pcb;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-2]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+16],dx
   ;	
   ;			miniSO_thread[atual].status = WAIT;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],3
   ;	
   ;			/* Exclui o nodo da lista de prontos */
   ;			miniSO_thread[prevthread].next=nextthread;
   ;	
	mov	ax,word ptr [bp-4]
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],di
   ;	
   ;			miniSO_thread[nextthread].prev=prevthread;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-4]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],dx
   ;	
   ;			miniSO_nextthread=nextthread;
   ;	
	mov	word ptr DGROUP:_miniSO_nextthread,di
   ;	
   ;			enable();
   ;	
	call	near ptr _enable
	jmp	short @23@254
@23@254:
   ;	
   ;			while	(miniSO_thread[atual].status == WAIT)
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+4],3
	je	short @23@254
   ;	
   ;				;
   ;			disable();
   ;	
	call	near ptr _disable
@23@310:
   ;	
   ;		}
   ;		/* O processo filho ja terminou... */
   ;		/* Retira o processo filho da lista de zumbis do pai */
   ;		atual = pcb;
   ;	
	mov	si,word ptr [bp-2]
   ;	
   ;		prevthread = miniSO_thread[atual].prev;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+22]
	mov	word ptr [bp-4],ax
   ;	
   ;		nextthread = miniSO_thread[atual].next;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	di,word ptr DGROUP:_miniSO_thread[bx+24]
   ;	
   ;		if	(prevthread == -1)  { /* E o primeiro da lista */
   ;	
	cmp	word ptr [bp-4],-1
	jne	short @23@422
   ;	
   ;			miniSO_thread[miniSO_ready].zombies = nextthread;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+20],di
   ;	
   ;			if	(nextthread != -1)
   ;	
	cmp	di,-1
	je	short @23@394
   ;	
   ;				miniSO_thread[nextthread].prev = -1;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],-1
@23@394:
   ;	
   ;		}
   ;	
	jmp	short @23@450
@23@422:
   ;	
   ;		else
   ;			miniSO_thread[prevthread].next = nextthread;
   ;	
	mov	ax,word ptr [bp-4]
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],di
@23@450:
   ;	
   ;		if	(nextthread != -1)
   ;	
	cmp	di,-1
	je	short @23@506
   ;	
   ;			miniSO_thread[nextthread].prev = prevthread;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-4]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],dx
@23@506:
   ;	
   ;		p_ref = MK_FP(seg,off);
   ;	
	push	word ptr [bp+8]
	push	word ptr [bp+6]
	call	near ptr _MK_FP
	pop	cx
	pop	cx
	mov	word ptr [bp-6],dx
	mov	word ptr [bp-8],ax
   ;	
   ;		*p_ref = miniSO_thread[pcb].exitcode;
   ;	
	mov	ax,word ptr [bp-2]
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+18]
	les	bx,dword ptr [bp-8]
	mov	word ptr es:[bx],ax
   ;	
   ;		/* Insere o processo na lista de BCPs livres */
   ;		miniSO_thread[pcb].next = miniSO_free;
   ;	
	mov	ax,word ptr [bp-2]
	mov	dx,26
	imul	dx
	mov	dx,word ptr DGROUP:_miniSO_free
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;		miniSO_free = pcb;
   ;	
	mov	ax,word ptr [bp-2]
	mov	word ptr DGROUP:_miniSO_free,ax
   ;	
   ;		miniSO_thread[pcb].status = FREE;
   ;	
	mov	ax,word ptr [bp-2]
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],-1
   ;	
   ;		enable();
   ;	
	call	near ptr _enable
   ;	
   ;		return pid;
   ;	
	mov	ax,word ptr [bp+4]
	jmp	@23@114
@23@534:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_sc_waitpid	endp
   ;	
   ;	int sc_wait(unsigned seg,unsigned off)
   ;	
	assume	cs:_TEXT
_sc_wait	proc	near
	push	bp
	mov	bp,sp
	sub	sp,8
	push	si
	push	di
   ;	
   ;	{
   ;		pcb_t	zombie,next,atual,prevthread,nextthread;
   ;		int far	*p_ref;
   ;	
   ;		disable();
   ;	
	call	near ptr _disable
   ;	
   ;		atual =miniSO_ready;
   ;	
	mov	si,word ptr DGROUP:_miniSO_ready
   ;	
   ;		if	(miniSO_thread[miniSO_ready].zombies==-1) {
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+20],-1
	je	@@4
	jmp	@24@198
@@4:
   ;	
   ;			/* O pai nao tem filhos-zumbi e vai bloquear */
   ;			prevthread = miniSO_thread[atual].prev;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+22]
	mov	word ptr [bp-2],ax
   ;	
   ;			nextthread = miniSO_thread[atual].next;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+24]
	mov	word ptr [bp-4],ax
   ;	
   ;			/* Se eh a ultima thread ... */
   ;			if	(miniSO_ready == nextthread)
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	cmp	ax,word ptr [bp-4]
	jne	short @24@114
   ;	
   ;				end_mso("wait(): nao ha' mais threads executando!");
   ;	
	mov	ax,offset DGROUP:s@+154
	push	ax
	call	near ptr end_mso
	pop	cx
@24@114:
   ;	
   ;			/* Vincula o BCP da thread atual ao BCP da thread "destino" */
   ;			miniSO_thread[atual].prev = -1;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],-1
   ;	
   ;			miniSO_thread[atual].next = -1;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],-1
   ;	
   ;			miniSO_thread[atual].waitfor = -1;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+16],-1
   ;	
   ;			miniSO_thread[atual].status = WAIT;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],3
   ;	
   ;			/* Exclui o nodo da lista de prontos */
   ;			miniSO_thread[atual].next=nextthread;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-4]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;			miniSO_thread[atual].prev=prevthread;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-2]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],dx
   ;	
   ;			miniSO_nextthread=nextthread;
   ;	
	mov	ax,word ptr [bp-4]
	mov	word ptr DGROUP:_miniSO_nextthread,ax
   ;	
   ;			enable();
   ;	
	call	near ptr _enable
	jmp	short @24@142
@24@142:
   ;	
   ;			while	(miniSO_thread[atual].status == WAIT)
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+4],3
	je	short @24@142
   ;	
   ;				;
   ;			disable();
   ;	
	call	near ptr _disable
@24@198:
   ;	
   ;		}
   ;		/* O pai tem pelo menos um filho zumbi... */
   ;		zombie = miniSO_thread[atual].zombies;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	di,word ptr DGROUP:_miniSO_thread[bx+20]
   ;	
   ;		miniSO_thread[atual].zombies = miniSO_thread[zombie].next;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+24]
	push	ax
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	pop	ax
	mov	word ptr DGROUP:_miniSO_thread[bx+20],ax
   ;	
   ;		if	(miniSO_thread[atual].zombies!=-1)
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+20],-1
	je	short @24@254
   ;	
   ;			miniSO_thread[miniSO_thread[atual].zombies].prev = -1;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+20]
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],-1
@24@254:
   ;	
   ;		miniSO_thread[zombie].next = miniSO_free;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	dx,word ptr DGROUP:_miniSO_free
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;		miniSO_thread[zombie].status = FREE;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],-1
   ;	
   ;		miniSO_free = zombie;
   ;	
	mov	word ptr DGROUP:_miniSO_free,di
   ;	
   ;		p_ref = MK_FP(seg,off);
   ;	
	push	word ptr [bp+6]
	push	word ptr [bp+4]
	call	near ptr _MK_FP
	pop	cx
	pop	cx
	mov	word ptr [bp-6],dx
	mov	word ptr [bp-8],ax
   ;	
   ;		*p_ref = miniSO_thread[zombie].exitcode;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+18]
	les	bx,dword ptr [bp-8]
	mov	word ptr es:[bx],ax
   ;	
   ;		enable();
   ;	
	call	near ptr _enable
   ;	
   ;		return miniSO_thread[zombie].pid;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx]
	jmp	short @24@282
@24@282:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_sc_wait	endp
   ;	
   ;	void sc_exit(int codfim)
   ;	
	assume	cs:_TEXT
_sc_exit	proc	near
	push	bp
	mov	bp,sp
	sub	sp,6
	push	si
	push	di
   ;	
   ;	{
   ;		pcb_t pai,i,last,prevthread,nextthread;
   ;	
   ;		disable();
   ;	
	call	near ptr _disable
   ;	
   ;		/* Verifica se não esta' encerrando a thread 0 */
   ;		if	(miniSO_ready == 0)
   ;	
	cmp	word ptr DGROUP:_miniSO_ready,0
	jne	short @25@86
   ;	
   ;			end_mso("exit(): thread 0 encerrada!");
   ;	
	mov	ax,offset DGROUP:s@+195
	push	ax
	call	near ptr end_mso
	pop	cx
@25@86:
	jmp	short @25@142
@25@114:
   ;	
   ;		/* Trata os zumbis do processo atual, colocando-os na lista de livres */
   ;		i = miniSO_thread[miniSO_ready].zombies;
   ;		while	(i!= -1)  {
   ;			miniSO_thread[miniSO_ready].zombies = miniSO_thread[i].next;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+24]
	push	ax
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	pop	ax
	mov	word ptr DGROUP:_miniSO_thread[bx+20],ax
   ;	
   ;			miniSO_thread[i].next   = miniSO_free;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	dx,word ptr DGROUP:_miniSO_free
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;			miniSO_thread[i].status = FREE;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],-1
   ;	
   ;			miniSO_free             = i;
   ;	
	mov	word ptr DGROUP:_miniSO_free,si
   ;	
   ;			i = miniSO_thread[miniSO_ready].zombies;
   ;	
@25@142:
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	si,word ptr DGROUP:_miniSO_thread[bx+20]
	cmp	si,-1
	jne	short @25@114
   ;	
   ;		}
   ;		/* Passa os filhos do atual para o processo 0 */
   ;		for	(i=0;i<miniSO_MAXTHREADS;++i)  {
   ;	
	xor	si,si
	jmp	short @25@338
@25@226:
   ;	
   ;			if	(miniSO_thread[i].status!=FREE && miniSO_thread[i].ppid == miniSO_thread[miniSO_ready].pid)
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+4],-1
	je	short @25@310
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+2]
	push	ax
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	pop	ax
	cmp	ax,word ptr DGROUP:_miniSO_thread[bx]
	jne	short @25@310
   ;	
   ;				miniSO_thread[i].ppid = 0;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+2],0
@25@310:
	inc	si
@25@338:
	cmp	si,16
	jl	short @25@226
   ;	
   ;		}
   ;		pai = get_pcb(miniSO_thread[miniSO_ready].ppid);
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	push	word ptr DGROUP:_miniSO_thread[bx+2]
	call	near ptr get_pcb
	pop	cx
	mov	di,ax
   ;	
   ;		if	(pai==-1)
   ;	
	cmp	di,-1
	jne	short @25@422
   ;	
   ;			end_mso("exit(): pai nao encontrado!");
   ;	
	mov	ax,offset DGROUP:s@+223
	push	ax
	call	near ptr end_mso
	pop	cx
@25@422:
   ;	
   ;		/* Se o processo-pai esta' esperando em wait/waitpid, coloca ele na lista de prontos */
   ;		if	( miniSO_thread[pai].status==WAIT && 
   ;	
   ;	
   ;			  (miniSO_thread[pai].waitfor==-1 || miniSO_thread[pai].waitfor==miniSO_ready) ) {
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+4],3
	je	@@5
	jmp	@25@534
@@5:
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+16],-1
	je	short @25@506
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+16]
	cmp	ax,word ptr DGROUP:_miniSO_ready
	jne	short @25@534
@25@506:
   ;	
   ;			/* Descobre qual a ultima thread */
   ;			last = miniSO_thread[miniSO_ready].prev;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+22]
	mov	word ptr [bp-2],ax
   ;	
   ;			/* Acerta links para incluir a thread no final da lista de prontos*/
   ;			miniSO_thread[pai].prev           = last;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-2]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],dx
   ;	
   ;			miniSO_thread[pai].next           = miniSO_ready;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	dx,word ptr DGROUP:_miniSO_ready
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;			miniSO_thread[last].next          = pai;
   ;	
	mov	ax,word ptr [bp-2]
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],di
   ;	
   ;			miniSO_thread[miniSO_ready].prev  = pai;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],di
   ;	
   ;			miniSO_thread[pai].status         = READY;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],0
@25@534:
   ;	
   ;		}
   ;		/* Salva anterior e proximo da thread que sera deletada */
   ;		prevthread = miniSO_thread[miniSO_ready].prev;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+22]
	mov	word ptr [bp-4],ax
   ;	
   ;		nextthread = miniSO_thread[miniSO_ready].next;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+24]
	mov	word ptr [bp-6],ax
   ;	
   ;		if	(miniSO_ready == nextthread)
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	cmp	ax,word ptr [bp-6]
	jne	short @25@590
   ;	
   ;			end_mso("exit(): nao ha' mais threads executando!");
   ;	
	mov	ax,offset DGROUP:s@+251
	push	ax
	call	near ptr end_mso
	pop	cx
@25@590:
   ;	
   ;		/* Exclui o nodo da lista de prontos */
   ;		miniSO_thread[prevthread].next=nextthread;
   ;	
	mov	ax,word ptr [bp-4]
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-6]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;		miniSO_thread[nextthread].prev=prevthread;
   ;	
	mov	ax,word ptr [bp-6]
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-4]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],dx
   ;	
   ;		if	(miniSO_thread[pai].zombies==-1) {
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+20],-1
	jne	short @25@646
   ;	
   ;			miniSO_thread[pai].zombies = miniSO_ready;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	dx,word ptr DGROUP:_miniSO_ready
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+20],dx
   ;	
   ;			miniSO_thread[miniSO_ready].prev = -1;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],-1
   ;	
   ;		}
   ;	
	jmp	short @25@758
@25@646:
   ;	
   ;		else	{
   ;			i = miniSO_thread[pai].zombies;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	si,word ptr DGROUP:_miniSO_thread[bx+20]
	jmp	short @25@702
@25@674:
   ;	
   ;			while	(miniSO_thread[i].next!=-1)
   ;				i = miniSO_thread[i].next;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	si,word ptr DGROUP:_miniSO_thread[bx+24]
@25@702:
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+24],-1
	jne	short @25@674
   ;	
   ;			miniSO_thread[i].next = miniSO_ready;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	dx,word ptr DGROUP:_miniSO_ready
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;			miniSO_thread[miniSO_ready].prev = i;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],si
@25@758:
   ;	
   ;		}
   ;		miniSO_thread[miniSO_ready].next = -1;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],-1
   ;	
   ;		miniSO_thread[miniSO_ready].status = ZOMBIE;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],2
   ;	
   ;		miniSO_thread[miniSO_ready].exitcode = codfim;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp+4]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+18],dx
   ;	
   ;		miniSO_nextthread=nextthread;
   ;	
	mov	ax,word ptr [bp-6]
	mov	word ptr DGROUP:_miniSO_nextthread,ax
   ;	
   ;		miniSO_delcurthread=1;
   ;	
	mov	byte ptr DGROUP:_miniSO_delcurthread,1
   ;	
   ;		enable();
   ;	
	call	near ptr _enable
@25@786:
	jmp	short @25@786
   ;	
   ;		while	(1)
   ;			;
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_sc_exit	endp
   ;	
   ;	pid_t sc_getpid()
   ;	
	assume	cs:_TEXT
_sc_getpid	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;		return miniSO_thread[miniSO_ready].pid;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx]
	jmp	short @26@58
@26@58:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_sc_getpid	endp
   ;	
   ;	pid_t sc_getppid()
   ;	
	assume	cs:_TEXT
_sc_getppid	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;		return miniSO_thread[miniSO_ready].ppid;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+2]
	jmp	short @27@58
@27@58:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_sc_getppid	endp
   ;	
   ;	int sc_sendsignal(pid_t pid, signal_t signal)
   ;	
	assume	cs:_TEXT
_sc_sendsignal	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
   ;	
   ;	{
   ;		pcb_t	pcb,last;
   ;	
   ;		disable();
   ;	
	call	near ptr _disable
   ;	
   ;		/* Tem que verificar se existe a thread */
   ;		pcb = get_pcb(pid);
   ;	
	push	word ptr [bp+4]
	call	near ptr get_pcb
	pop	cx
	mov	si,ax
   ;	
   ;		/* Se nao existe uma thread com este numero, entao retorna */
   ;		if	(pcb==-1)  {
   ;	
	cmp	si,-1
	jne	short @28@114
   ;	
   ;			enable();
   ;	
	call	near ptr _enable
   ;	
   ;			return miniSO_ERROR;
   ;	
	mov	ax,-1
@28@86:
	jmp	@28@226
@28@114:
   ;	
   ;		}
   ;		/* Seta os sinais recebidos */
   ;		miniSO_thread[pcb].recvsig |= signal;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp+6]
	mov	bx,ax
	or	word ptr DGROUP:_miniSO_thread[bx+10],dx
   ;	
   ;		/* A thread pode estar esperando pelos sinais ou nao */
   ;		if	(miniSO_thread[pcb].status == WAITSIG)  {
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+4],4
	je	@@6
	jmp	@28@198
@@6:
   ;	
   ;			/* Verifica se a thread estava esperando pelo sinal */
   ;			if	( (miniSO_thread[pcb].recvsig & miniSO_thread[pcb].waitsig) == miniSO_thread[pcb].waitsig )  {
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+10]
	push	ax
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	pop	ax
	and	ax,word ptr DGROUP:_miniSO_thread[bx+12]
	push	ax
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	pop	ax
	cmp	ax,word ptr DGROUP:_miniSO_thread[bx+12]
	je	@@7
	jmp	@28@198
@@7:
   ;	
   ;				/* O sinal recebido e' suficiente para tirar a thread da espera */
   ;				last = miniSO_thread[miniSO_ready].prev;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	di,word ptr DGROUP:_miniSO_thread[bx+22]
   ;	
   ;				miniSO_thread[pcb].prev = last;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],di
   ;	
   ;				miniSO_thread[last].next=pcb;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],si
   ;	
   ;				miniSO_thread[miniSO_ready].prev=pcb;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],si
   ;	
   ;				miniSO_thread[pcb].next=miniSO_ready;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	dx,word ptr DGROUP:_miniSO_ready
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;				miniSO_thread[pcb].status = READY;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],0
   ;	
   ;				/* Seta sinais recebidos e sinais esperados */
   ;				miniSO_thread[pcb].recvsig ^= miniSO_thread[pcb].waitsig;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+12]
	push	ax
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	pop	ax
	xor	word ptr DGROUP:_miniSO_thread[bx+10],ax
   ;	
   ;				miniSO_thread[pcb].waitsig = 0;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+12],0
@28@198:
   ;	
   ;			}
   ;		}
   ;		enable();
   ;	
	call	near ptr _enable
   ;	
   ;		return miniSO_OK;
   ;	
	mov	ax,1
	jmp	@28@86
@28@226:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_sc_sendsignal	endp
   ;	
   ;	int sc_waitsignal(signal_t signal)
   ;	
	assume	cs:_TEXT
_sc_waitsignal	proc	near
	push	bp
	mov	bp,sp
	sub	sp,6
	push	si
	push	di
	mov	di,word ptr [bp+4]
   ;	
   ;	{
   ;		pcb_t	pcb,prevthread,nextthread;
   ;		int	waitint=0;
   ;	
	mov	word ptr [bp-6],0
   ;	
   ;	
   ;		disable();
   ;	
	call	near ptr _disable
   ;	
   ;		pcb = miniSO_ready;
   ;	
	mov	si,word ptr DGROUP:_miniSO_ready
   ;	
   ;		/* Verifica se ja' nao recebeu os sinais */
   ;		if	( (miniSO_thread[pcb].recvsig & signal) == signal )  {
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+10]
	and	ax,di
	cmp	ax,di
	jne	short @29@86
   ;	
   ;			/* Ele ja' recebeu os sinais */
   ;			miniSO_thread[pcb].recvsig ^= signal;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	xor	word ptr DGROUP:_miniSO_thread[bx+10],di
   ;	
   ;			miniSO_thread[pcb].waitsig = 0;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+12],0
   ;	
   ;		}
   ;	
	jmp	@29@170
@29@86:
   ;	
   ;		else	{
   ;			/* Ele ainda nao recebeu os sinais e vai para a lista de espera */
   ;			miniSO_thread[pcb].waitsig = signal;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+12],di
   ;	
   ;			/* Se eh a ultima thread ... */
   ;			prevthread = miniSO_thread[pcb].prev;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+22]
	mov	word ptr [bp-2],ax
   ;	
   ;			nextthread = miniSO_thread[pcb].next;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+24]
	mov	word ptr [bp-4],ax
   ;	
   ;			if	(pcb == nextthread)
   ;	
	cmp	si,word ptr [bp-4]
	jne	short @29@142
   ;	
   ;				end_mso("waitsignal(): nao ha' mais threads executando!");
   ;	
	mov	ax,offset DGROUP:s@+292
	push	ax
	call	near ptr end_mso
	pop	cx
@29@142:
   ;	
   ;			/* Retira o BCP da thread corrente da lista de prontos */
   ;			miniSO_thread[pcb].next = -1;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],-1
   ;	
   ;			miniSO_thread[pcb].prev  = -1;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],-1
   ;	
   ;			/* Exclui o nodo da lista de prontos */
   ;			miniSO_thread[prevthread].next=nextthread;
   ;	
	mov	ax,word ptr [bp-2]
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-4]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;			miniSO_thread[nextthread].prev=prevthread;
   ;	
	mov	ax,word ptr [bp-4]
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-2]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],dx
   ;	
   ;			miniSO_thread[pcb].status = WAITSIG;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],4
   ;	
   ;			miniSO_nextthread=nextthread;
   ;	
	mov	ax,word ptr [bp-4]
	mov	word ptr DGROUP:_miniSO_nextthread,ax
   ;	
   ;			waitint=1;
   ;	
	mov	word ptr [bp-6],1
@29@170:
   ;	
   ;		}
   ;		enable();
   ;	
	call	near ptr _enable
   ;	
   ;		if	(waitint)
   ;	
	cmp	word ptr [bp-6],0
	je	short @29@254
	jmp	short @29@226
@29@226:
   ;	
   ;			while	(miniSO_thread[pcb].status == WAITSIG)
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+4],4
	je	short @29@226
@29@254:
   ;	
   ;				;
   ;		return 0;
   ;	
	xor	ax,ax
	jmp	short @29@282
@29@282:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_sc_waitsignal	endp
   ;	
   ;	static int get_sem_pos(semid_t s)
   ;	
	assume	cs:_TEXT
get_sem_pos	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;		int i;
   ;	
   ;		for	(i=0;i<miniSO_MAXSEMAPHORES;++i)
   ;	
	xor	dx,dx
	jmp	short @30@198
@30@58:
   ;	
   ;		  	if	(miniSO_sem[i].status!=FREE && miniSO_sem[i].semid==s)
   ;	
	mov	bx,dx
	mov	cl,3
	shl	bx,cl
	cmp	word ptr DGROUP:_miniSO_sem[bx],-1
	je	short @30@170
	mov	bx,dx
	mov	cl,3
	shl	bx,cl
	mov	ax,word ptr DGROUP:_miniSO_sem[bx+2]
	cmp	ax,word ptr [bp+4]
	jne	short @30@170
   ;	
   ;				return i;
   ;	
	mov	ax,dx
@30@142:
	jmp	short @30@254
@30@170:
	inc	dx
@30@198:
	cmp	dx,10
	jl	short @30@58
   ;	
   ;		return miniSO_ERROR;
   ;	
	mov	ax,-1
	jmp	short @30@142
@30@254:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
get_sem_pos	endp
   ;	
   ;	semid_t sc_semcreate (int value)
   ;	
	assume	cs:_TEXT
_sc_semcreate	proc	near
	push	bp
	mov	bp,sp
	push	si
   ;	
   ;	{
   ;		int i;
   ;		semid_t s;
   ;	
   ;		for	(i=0;i<miniSO_MAXSEMAPHORES;++i)
   ;	
	xor	si,si
	jmp	@31@310
@31@58:
   ;	
   ;			if	(miniSO_sem[i].status==FREE) {
   ;	
	mov	bx,si
	mov	cl,3
	shl	bx,cl
	cmp	word ptr DGROUP:_miniSO_sem[bx],-1
	jne	short @31@282
	jmp	short @31@198
@31@114:
   ;	
   ;				/* Gera um semid */
   ;				while	(get_sem_pos(nextsemid)!=miniSO_ERROR) {
   ;					if	(nextsemid==32767)
   ;	
	cmp	word ptr DGROUP:nextsemid,32767
	jne	short @31@170
   ;	
   ;						nextsemid = 0;
   ;	
	mov	word ptr DGROUP:nextsemid,0
	jmp	short @31@198
@31@170:
   ;	
   ;					else
   ;						nextsemid++;
   ;	
	inc	word ptr DGROUP:nextsemid
@31@198:
	push	word ptr DGROUP:nextsemid
	call	near ptr get_sem_pos
	pop	cx
	cmp	ax,-1
	jne	short @31@114
   ;	
   ;				}
   ;				miniSO_sem[i].status=READY;
   ;	
	mov	bx,si
	mov	cl,3
	shl	bx,cl
	mov	word ptr DGROUP:_miniSO_sem[bx],0
   ;	
   ;				miniSO_sem[i].semid=nextsemid++;
   ;	
	mov	bx,si
	mov	cl,3
	shl	bx,cl
	mov	ax,word ptr DGROUP:nextsemid
	mov	word ptr DGROUP:_miniSO_sem[bx+2],ax
	inc	word ptr DGROUP:nextsemid
   ;	
   ;				miniSO_sem[i].value=value;
   ;	
	mov	bx,si
	mov	cl,3
	shl	bx,cl
	mov	ax,word ptr [bp+4]
	mov	word ptr DGROUP:_miniSO_sem[bx+4],ax
   ;	
   ;				miniSO_sem[i].queue=-1;
   ;	
	mov	bx,si
	mov	cl,3
	shl	bx,cl
	mov	word ptr DGROUP:_miniSO_sem[bx+6],-1
   ;	
   ;				return miniSO_sem[i].semid;
   ;	
	mov	bx,si
	mov	cl,3
	shl	bx,cl
	mov	ax,word ptr DGROUP:_miniSO_sem[bx+2]
@31@254:
	jmp	short @31@366
@31@282:
	inc	si
@31@310:
	cmp	si,10
	jge	@@8
	jmp	@31@58
@@8:
   ;	
   ;			}
   ;		return miniSO_ERROR;
   ;	
	mov	ax,-1
	jmp	short @31@254
@31@366:
   ;	
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_sc_semcreate	endp
   ;	
   ;	int sc_semset (semid_t s,int value)
   ;	
	assume	cs:_TEXT
_sc_semset	proc	near
	push	bp
	mov	bp,sp
	push	si
   ;	
   ;	{
   ;		int sem;
   ;	
   ;		sem = get_sem_pos(s);
   ;	
	push	word ptr [bp+4]
	call	near ptr get_sem_pos
	pop	cx
	mov	si,ax
   ;	
   ;		if	(sem==miniSO_ERROR || miniSO_sem[sem].queue!=-1)
   ;	
	cmp	si,-1
	je	short @32@86
	mov	bx,si
	mov	cl,3
	shl	bx,cl
	cmp	word ptr DGROUP:_miniSO_sem[bx+6],-1
	je	short @32@142
@32@86:
   ;	
   ;			return miniSO_ERROR;
   ;	
	mov	ax,-1
@32@114:
	jmp	short @32@170
@32@142:
   ;	
   ;		miniSO_sem[sem].value = value;
   ;	
	mov	bx,si
	mov	cl,3
	shl	bx,cl
	mov	ax,word ptr [bp+6]
	mov	word ptr DGROUP:_miniSO_sem[bx+4],ax
   ;	
   ;		return miniSO_OK;
   ;	
	mov	ax,1
	jmp	short @32@114
@32@170:
   ;	
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_sc_semset	endp
   ;	
   ;	int sc_semup (semid_t s)
   ;	
	assume	cs:_TEXT
_sc_semup	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
	push	si
	push	di
   ;	
   ;	{
   ;		int sem;
   ;		pcb_t pcb,last,prevthread,nextthread;
   ;	
   ;		disable();
   ;	
	call	near ptr _disable
   ;	
   ;		sem = get_sem_pos(s);
   ;	
	push	word ptr [bp+4]
	call	near ptr get_sem_pos
	pop	cx
	mov	si,ax
   ;	
   ;		if	(sem==miniSO_ERROR) {
   ;	
	cmp	si,-1
	jne	short @33@114
   ;	
   ;			enable();
   ;	
	call	near ptr _enable
   ;	
   ;			return miniSO_ERROR;
   ;	
	mov	ax,-1
@33@86:
	jmp	@33@254
@33@114:
   ;	
   ;		}
   ;		miniSO_sem[sem].value++;
   ;	
	mov	bx,si
	mov	cl,3
	shl	bx,cl
	inc	word ptr DGROUP:_miniSO_sem[bx+4]
   ;	
   ;		if	(miniSO_sem[sem].queue!=-1) {
   ;	
	mov	bx,si
	mov	cl,3
	shl	bx,cl
	cmp	word ptr DGROUP:_miniSO_sem[bx+6],-1
	jne	@@9
	jmp	@33@226
@@9:
   ;	
   ;			pcb = miniSO_sem[sem].queue;
   ;	
	mov	bx,si
	mov	cl,3
	shl	bx,cl
	mov	di,word ptr DGROUP:_miniSO_sem[bx+6]
   ;	
   ;			miniSO_sem[sem].queue = miniSO_thread[pcb].next;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+24]
	mov	bx,si
	mov	cl,3
	shl	bx,cl
	mov	word ptr DGROUP:_miniSO_sem[bx+6],ax
   ;	
   ;			if	(miniSO_sem[sem].queue!=-1)
   ;	
	mov	bx,si
	mov	cl,3
	shl	bx,cl
	cmp	word ptr DGROUP:_miniSO_sem[bx+6],-1
	je	short @33@198
   ;	
   ;				miniSO_thread[miniSO_sem[sem].queue].prev = -1;
   ;	
	mov	bx,si
	mov	cl,3
	shl	bx,cl
	mov	ax,word ptr DGROUP:_miniSO_sem[bx+6]
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],-1
@33@198:
   ;	
   ;			last = miniSO_thread[miniSO_ready].prev;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+22]
	mov	word ptr [bp-2],ax
   ;	
   ;			miniSO_thread[pcb].prev = last;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-2]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],dx
   ;	
   ;			miniSO_thread[last].next=pcb;
   ;	
	mov	ax,word ptr [bp-2]
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],di
   ;	
   ;			miniSO_thread[miniSO_ready].prev=pcb;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],di
   ;	
   ;			miniSO_thread[pcb].next=miniSO_ready;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	dx,word ptr DGROUP:_miniSO_ready
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;			miniSO_thread[pcb].status = READY;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],0
@33@226:
   ;	
   ;		}
   ;		enable();
   ;	
	call	near ptr _enable
   ;	
   ;		return miniSO_OK;
   ;	
	mov	ax,1
	jmp	@33@86
@33@254:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_sc_semup	endp
   ;	
   ;	int sc_semdown (semid_t s)
   ;	
	assume	cs:_TEXT
_sc_semdown	proc	near
	push	bp
	mov	bp,sp
	sub	sp,8
	push	si
	push	di
   ;	
   ;	{
   ;		int sem;
   ;		pcb_t pcb,ant,i,prevthread,nextthread;
   ;	
   ;		disable();
   ;	
	call	near ptr _disable
   ;	
   ;		sem = get_sem_pos(s);
   ;	
	push	word ptr [bp+4]
	call	near ptr get_sem_pos
	pop	cx
	mov	di,ax
   ;	
   ;		if	(sem==miniSO_ERROR) {
   ;	
	cmp	di,-1
	jne	short @34@114
   ;	
   ;			enable();
   ;	
	call	near ptr _enable
   ;	
   ;			return miniSO_ERROR;
   ;	
	mov	ax,-1
@34@86:
	jmp	@34@534
@34@114:
   ;	
   ;		}
   ;		miniSO_sem[sem].value--;
   ;	
	mov	bx,di
	mov	cl,3
	shl	bx,cl
	dec	word ptr DGROUP:_miniSO_sem[bx+4]
   ;	
   ;		if	(miniSO_sem[sem].value<0) {
   ;	
	mov	bx,di
	mov	cl,3
	shl	bx,cl
	cmp	word ptr DGROUP:_miniSO_sem[bx+4],0
	jl	@@10
	jmp	@34@478
@@10:
   ;	
   ;			pcb = miniSO_ready;
   ;	
	mov	si,word ptr DGROUP:_miniSO_ready
   ;	
   ;			prevthread = miniSO_thread[pcb].prev;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+22]
	mov	word ptr [bp-6],ax
   ;	
   ;			nextthread = miniSO_thread[pcb].next;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+24]
	mov	word ptr [bp-8],ax
   ;	
   ;			/* Se eh a ultima thread ... */
   ;			if	(pcb == nextthread)
   ;	
	cmp	si,word ptr [bp-8]
	jne	short @34@198
   ;	
   ;				end_mso("semdown(): nao ha' mais threads executando!");
   ;	
	mov	ax,offset DGROUP:s@+339
	push	ax
	call	near ptr end_mso
	pop	cx
@34@198:
   ;	
   ;			/* Coloca o BCP da thread no final da lista de espera do semaforo */
   ;			ant = -1;
   ;	
	mov	word ptr [bp-2],-1
   ;	
   ;			i = miniSO_sem[sem].queue;
   ;	
	mov	bx,di
	mov	cl,3
	shl	bx,cl
	mov	ax,word ptr DGROUP:_miniSO_sem[bx+6]
	jmp	short @34@254
@34@226:
   ;	
   ;			while	(i!=-1) {
   ;				ant = i;
   ;	
	mov	ax,word ptr [bp-4]
	mov	word ptr [bp-2],ax
   ;	
   ;				i = miniSO_thread[i].next;
   ;	
	mov	ax,word ptr [bp-4]
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+24]
@34@254:
	mov	word ptr [bp-4],ax
	cmp	word ptr [bp-4],-1
	jne	short @34@226
   ;	
   ;			}
   ;			if	(ant==-1) {
   ;	
	cmp	word ptr [bp-2],-1
	jne	short @34@366
   ;	
   ;				miniSO_sem[sem].queue = pcb;
   ;	
	mov	bx,di
	mov	cl,3
	shl	bx,cl
	mov	word ptr DGROUP:_miniSO_sem[bx+6],si
   ;	
   ;				miniSO_thread[pcb].prev = -1;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],-1
   ;	
   ;			}
   ;	
	jmp	short @34@394
@34@366:
   ;	
   ;			else {
   ;				miniSO_thread[ant].next = pcb;
   ;	
	mov	ax,word ptr [bp-2]
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],si
   ;	
   ;				miniSO_thread[pcb].prev = ant;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-2]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],dx
@34@394:
   ;	
   ;			}
   ;			miniSO_thread[pcb].next = -1;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],-1
   ;	
   ;			/* Exclui o nodo da lista de prontos */
   ;			miniSO_thread[prevthread].next=nextthread;
   ;	
	mov	ax,word ptr [bp-6]
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-8]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;			miniSO_thread[nextthread].prev=prevthread;
   ;	
	mov	ax,word ptr [bp-8]
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-6]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],dx
   ;	
   ;			miniSO_thread[pcb].status = WAITSEM;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],5
   ;	
   ;			miniSO_nextthread=nextthread;
   ;	
	mov	ax,word ptr [bp-8]
	mov	word ptr DGROUP:_miniSO_nextthread,ax
   ;	
   ;			enable();
   ;	
	call	near ptr _enable
	jmp	short @34@422
@34@422:
   ;	
   ;			while	(miniSO_thread[pcb].status == WAITSEM)
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+4],5
	je	short @34@422
   ;	
   ;				;
   ;		}
   ;	
	jmp	short @34@506
@34@478:
   ;	
   ;		else
   ;			enable();
   ;	
	call	near ptr _enable
@34@506:
   ;	
   ;		return miniSO_OK;
   ;	
	mov	ax,1
	jmp	@34@86
@34@534:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_sc_semdown	endp
   ;	
   ;	int sc_semdestroy (semid_t s)					
   ;	
	assume	cs:_TEXT
_sc_semdestroy	proc	near
	push	bp
	mov	bp,sp
	push	si
   ;	
   ;	{
   ;		int sem;
   ;	
   ;		sem = get_sem_pos(s);
   ;	
	push	word ptr [bp+4]
	call	near ptr get_sem_pos
	pop	cx
	mov	si,ax
   ;	
   ;		if	(sem==miniSO_ERROR || miniSO_sem[sem].queue!=-1)
   ;	
	cmp	si,-1
	je	short @35@86
	mov	bx,si
	mov	cl,3
	shl	bx,cl
	cmp	word ptr DGROUP:_miniSO_sem[bx+6],-1
	je	short @35@142
@35@86:
   ;	
   ;			return miniSO_ERROR;
   ;	
	mov	ax,-1
@35@114:
	jmp	short @35@170
@35@142:
   ;	
   ;		miniSO_sem[sem].status = FREE;
   ;	
	mov	bx,si
	mov	cl,3
	shl	bx,cl
	mov	word ptr DGROUP:_miniSO_sem[bx],-1
   ;	
   ;		return miniSO_OK;
   ;	
	mov	ax,1
	jmp	short @35@114
@35@170:
   ;	
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_sc_semdestroy	endp
   ;	
   ;	int sc_stop(pid_t pid){
   ;	
	assume	cs:_TEXT
_sc_stop	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
	push	si
	push	di
   ;	
   ;	    pcb_t pcb,prevthread,nextthread;
   ;	    disable();
   ;	
	call	near ptr _disable
   ;	
   ;	    /* Tem que verificar se existe a thread */
   ;	    pcb = get_pcb(pid);
   ;	
	push	word ptr [bp+4]
	call	near ptr get_pcb
	pop	cx
	mov	si,ax
   ;	
   ;	    /* Se nao existe uma thread com este numero ou se o estado dela n
   ;	    READY, retorna erro */
   ;	    if(pcb==-1||miniSO_thread[pcb].status!=READY){
   ;	
	cmp	si,-1
	je	short @36@86
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+4],0
	je	short @36@142
@36@86:
   ;	
   ;	    enable();
   ;	
	call	near ptr _enable
   ;	
   ;	    return miniSO_ERROR;
   ;	
	mov	ax,-1
@36@114:
	jmp	short @36@170
@36@142:
   ;	
   ;	    }
   ;	    prevthread = miniSO_thread[pcb].prev;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	di,word ptr DGROUP:_miniSO_thread[bx+22]
   ;	
   ;	    nextthread = miniSO_thread[pcb].next;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	ax,word ptr DGROUP:_miniSO_thread[bx+24]
	mov	word ptr [bp-2],ax
   ;	
   ;	    miniSO_thread[pcb].next =-1;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],-1
   ;	
   ;	    miniSO_thread[pcb].prev = -1;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],-1
   ;	
   ;	    /* Exclui o nodo da lista de prontos */
   ;	    miniSO_thread[prevthread].next=nextthread;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	dx,word ptr [bp-2]
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;	    miniSO_thread[nextthread].prev=prevthread;
   ;	
	mov	ax,word ptr [bp-2]
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],di
   ;	
   ;	    miniSO_thread[pcb].status = STOPPED;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],6
   ;	
   ;	    enable();
   ;	
	call	near ptr _enable
   ;	
   ;	    return miniSO_OK;
   ;	
	mov	ax,1
	jmp	short @36@114
@36@170:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_sc_stop	endp
   ;	
   ;	int sc_resume(pid_t pid) {
   ;	
	assume	cs:_TEXT
_sc_resume	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
   ;	
   ;	    pcb_t pcb,prevthread,nextthread,last;
   ;	    disable();
   ;	
	call	near ptr _disable
   ;	
   ;	    /* Tem que verificar se existe a thread */
   ;	    pcb = get_pcb(pid);
   ;	
	push	word ptr [bp+4]
	call	near ptr get_pcb
	pop	cx
	mov	si,ax
   ;	
   ;	    /* Se nao existe uma thread com este numero ou se o estado dela não  
   ;	    é
   ;	    STOPPED */
   ;	    if(pcb==-1 || miniSO_thread[pcb].status != STOPPED)  {
   ;	
	cmp	si,-1
	je	short @37@86
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	cmp	word ptr DGROUP:_miniSO_thread[bx+4],6
	je	short @37@142
@37@86:
   ;	
   ;	    enable();
   ;	
	call	near ptr _enable
   ;	
   ;	    return miniSO_ERROR;
   ;	
	mov	ax,-1
@37@114:
	jmp	short @37@170
@37@142:
   ;	
   ;	    }
   ;	    last = miniSO_thread[miniSO_ready].prev;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	di,word ptr DGROUP:_miniSO_thread[bx+22]
   ;	
   ;	    miniSO_thread[pcb].prev = last;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],di
   ;	
   ;	    miniSO_thread[last].next=pcb;
   ;	
	mov	ax,di
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],si
   ;	
   ;	    miniSO_thread[miniSO_ready].prev=pcb;
   ;	
	mov	ax,word ptr DGROUP:_miniSO_ready
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+22],si
   ;	
   ;	    miniSO_thread[pcb].next=miniSO_ready;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	dx,word ptr DGROUP:_miniSO_ready
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+24],dx
   ;	
   ;	    miniSO_thread[pcb].status = READY;
   ;	
	mov	ax,si
	mov	dx,26
	imul	dx
	mov	bx,ax
	mov	word ptr DGROUP:_miniSO_thread[bx+4],0
   ;	
   ;	    enable();
   ;	
	call	near ptr _enable
   ;	
   ;	    return miniSO_OK;
   ;	
	mov	ax,1
	jmp	short @37@114
@37@170:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_sc_resume	endp
_TEXT	ends
_BSS	segment word public 'BSS'
_miniSO_oldisr	label	dword
	db	4 dup (?)
_miniSO_nextthread	label	word
	db	2 dup (?)
_miniSO_delcurthread	label	byte
	db	1 dup (?)
_miniSO_thread	label	word
	db	416 dup (?)
_miniSO_sem	label	word
	db	80 dup (?)
	?debug	C E9
	?debug	C FA00000000
_BSS	ends
_DATA	segment word public 'DATA'
s@	label	byte
	db	10
	db	10
	db	0
	db	'Pressione uma tecla para reiniciar...'
	db	10
	db	0
	db	'kill(): thread 0 excluida!'
	db	0
	db	'kill(): nao ha'
	db	39
	db	' mais threads executando!'
	db	0
	db	'waitpid(): nao ha'
	db	39
	db	' mais threads executando!'
	db	0
	db	'wait(): nao ha'
	db	39
	db	' mais threads executando!'
	db	0
	db	'exit(): thread 0 encerrada!'
	db	0
	db	'exit(): pai nao encontrado!'
	db	0
	db	'exit(): nao ha'
	db	39
	db	' mais threads executando!'
	db	0
	db	'waitsignal(): nao ha'
	db	39
	db	' mais threads executando!'
	db	0
	db	'semdown(): nao ha'
	db	39
	db	' mais threads executando!'
	db	0
_DATA	ends
_TEXT	segment byte public 'CODE'
_TEXT	ends
_get_sem_pos	equ	get_sem_pos
	extrn	_miniSO_return_addr:near
	public	_miniSO_contextswitch
	public	_scall
_get_pcb	equ	get_pcb
_end_mso	equ	end_mso
_scroll	equ	scroll
_getCursorPosition	equ	getCursorPosition
_setCursorPosition	equ	setCursorPosition
	public	_miniSO_scall_table
	public	_miniSO_oldisr
	public	_miniSO_nextthread
	public	_miniSO_delcurthread
	public	_miniSO_free
	public	_miniSO_ready
	public	_miniSO_thread
_nextsemid	equ	nextsemid
	public	_miniSO_sem
_miniSO_key	equ	miniSO_key
_miniSO_iskey	equ	miniSO_iskey
_miniSO_pag	equ	miniSO_pag
_miniSO_cor	equ	miniSO_cor
_miniSO_col	equ	miniSO_col
	extrn	_putstr:near
	extrn	_getch:near
	extrn	_putch:near
	public	_sc_resume
	public	_sc_stop
	public	_sc_semdestroy
	public	_sc_semdown
	public	_sc_semup
	public	_sc_semset
	public	_sc_semcreate
	public	_sc_waitsignal
	public	_sc_sendsignal
	public	_sc_getppid
	public	_sc_getpid
	public	_sc_exit
	public	_sc_waitpid
	public	_sc_wait
	public	_sc_kill
	public	_sc_fork
	public	_sc_reboot
	public	_sc_gettime
	public	_sc_getdate
	public	_sc_gotoxy
	public	_sc_wherey
	public	_sc_wherex
	public	_sc_setcolor
	public	_sc_getcolor
	public	_sc_clrscr
	public	_sc_getch
	public	_sc_putch
	public	_miniSO_init_semtable
	public	_miniSO_init_proctable
	extrn	_FP_OFF:near
	extrn	_FP_SEG:near
	extrn	_MK_FP:near
	extrn	_disable:near
	extrn	_enable:near
	extrn	_setvect:near
_s@	equ	s@
	end
