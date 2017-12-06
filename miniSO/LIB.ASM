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
	?debug	S "lib.c"
	?debug	C E98AA5684B056C69622E63
	?debug	C E98FA6684B086D696E69534F2E68
	?debug	C E9D2A4684B056C69622E68
	?debug	C E9FBA5684B077363616C6C2E68
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
   ;	void putch(int car)
   ;	
	assume	cs:_TEXT
_putch	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  _BX = car;
   ;	
	mov	bx,word ptr [bp+4]
   ;	
   ;	  asm {
   ;	     mov  ah,SC_PUTCH
   ;	
	mov	  ah,0
   ;	
   ;	     int  22h
   ;	
	int	  22h
   ;	
   ;	  }
   ;	}
   ;	
	pop	bp
	ret	
_putch	endp
   ;	
   ;	int getch()
   ;	
	assume	cs:_TEXT
_getch	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  asm {
   ;	    mov  ah,SC_GETCH
   ;	
	mov	  ah,1
   ;	
   ;	    int  22h
   ;	
	int	  22h
   ;	
   ;	  }
   ;	  return (_AX);
   ;	
	jmp	short @2@114
@2@114:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_getch	endp
   ;	
   ;	void clrscr()
   ;	
	assume	cs:_TEXT
_clrscr	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  asm {
   ;	    mov  ah,SC_CLRSCR
   ;	
	mov	  ah,2
   ;	
   ;	    int  22h
   ;	
	int	  22h
   ;	
   ;	  }
   ;	}
   ;	
	pop	bp
	ret	
_clrscr	endp
   ;	
   ;	void putstr (char far *str)
   ;	
	assume	cs:_TEXT
_putstr	proc	near
	push	bp
	mov	bp,sp
	jmp	short @4@86
@4@58:
   ;	
   ;	{
   ;	  while (*str!='\0')
   ;	        putch(*str++);
   ;	
	les	bx,dword ptr [bp+4]
	inc	word ptr [bp+4]
	mov	al,byte ptr es:[bx]
	cbw	
	push	ax
	call	near ptr _putch
	pop	cx
@4@86:
	les	bx,dword ptr [bp+4]
	cmp	byte ptr es:[bx],0
	jne	short @4@58
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_putstr	endp
   ;	
   ;	void putstrxy (int x, int y, char far *string)
   ;	
	assume	cs:_TEXT
_putstrxy	proc	near
	push	bp
	mov	bp,sp
	sub	sp,4
   ;	
   ;	{
   ;	  char far *pv;
   ;	
   ;	  pv=(char far *)(0xB8000000L+(y-1)*160+(x-1)*2);
   ;	
	mov	ax,word ptr [bp+6]
	dec	ax
	mov	dx,160
	imul	dx
	cwd	
	push	ax
	mov	ax,word ptr [bp+4]
	dec	ax
	shl	ax,1
	push	dx
	cwd	
	pop	bx
	pop	cx
	add	cx,ax
	adc	bx,dx
	add	cx,0
	adc	bx,-18432
	mov	word ptr [bp-2],bx
	mov	word ptr [bp-4],cx
	jmp	short @5@86
@5@58:
   ;	
   ;	  while (*string != '\0')  {
   ;		*pv++=*string++;
   ;	
	les	bx,dword ptr [bp+8]
	mov	al,byte ptr es:[bx]
	les	bx,dword ptr [bp-4]
	mov	byte ptr es:[bx],al
	inc	word ptr [bp+8]
	inc	word ptr [bp-4]
   ;	
   ;		pv++;
   ;	
	inc	word ptr [bp-4]
@5@86:
	les	bx,dword ptr [bp+8]
	cmp	byte ptr es:[bx],0
	jne	short @5@58
   ;	
   ;	  }
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_putstrxy	endp
   ;	
   ;	int getcolor ()
   ;	
	assume	cs:_TEXT
_getcolor	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  asm {
   ;	    mov ah,SC_GETCOLOR
   ;	
	mov	 ah,3
   ;	
   ;	    int 22h
   ;	
	int	 22h
   ;	
   ;	  }
   ;	  return _AX;
   ;	
	jmp	short @6@114
@6@114:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_getcolor	endp
   ;	
   ;	void setcolor (int cor)
   ;	
	assume	cs:_TEXT
_setcolor	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  _BX = cor; 
   ;	
	mov	bx,word ptr [bp+4]
   ;	
   ;	  asm {
   ;	    mov ah,SC_SETCOLOR
   ;	
	mov	 ah,4
   ;	
   ;	    int 22h
   ;	
	int	 22h
   ;	
   ;	  }
   ;	}
   ;	
	pop	bp
	ret	
_setcolor	endp
   ;	
   ;	int  wherex()
   ;	
	assume	cs:_TEXT
_wherex	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  asm {
   ;		mov	ah,SC_WHEREX
   ;	
	mov		ah,5
   ;	
   ;		int	22h
   ;	
	int		22h
   ;	
   ;	  }
   ;	  return _AX;
   ;	
	jmp	short @8@114
@8@114:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_wherex	endp
   ;	
   ;	int  wherey()
   ;	
	assume	cs:_TEXT
_wherey	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  asm {
   ;		mov	ah,SC_WHEREY
   ;	
	mov		ah,6
   ;	
   ;		int	22h
   ;	
	int		22h
   ;	
   ;	  }
   ;	  return _AX;
   ;	
	jmp	short @9@114
@9@114:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_wherey	endp
   ;	
   ;	void gotoxy (int x,int y)
   ;	
	assume	cs:_TEXT
_gotoxy	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  _BX = x;
   ;	
	mov	bx,word ptr [bp+4]
   ;	
   ;	  _CX = y;
   ;	
	mov	cx,word ptr [bp+6]
   ;	
   ;	  asm {
   ;		mov	ah,SC_GOTOXY
   ;	
	mov		ah,7
   ;	
   ;		int	22h
   ;	
	int		22h
   ;	
   ;	  }
   ;	}
   ;	
	pop	bp
	ret	
_gotoxy	endp
   ;	
   ;	void getdate(struct date far *dt)
   ;	
	assume	cs:_TEXT
_getdate	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  _BX = FP_SEG(dt);
   ;	
	push	word ptr [bp+6]
	push	word ptr [bp+4]
	call	near ptr _FP_SEG
	pop	cx
	pop	cx
	mov	bx,ax
   ;	
   ;	  _CX = FP_OFF(dt);
   ;	
	push	word ptr [bp+6]
	push	word ptr [bp+4]
	call	near ptr _FP_OFF
	pop	cx
	pop	cx
	mov	cx,ax
   ;	
   ;	  asm {
   ;		mov	ah,SC_GETDATE
   ;	
	mov		ah,8
   ;	
   ;		int	22h
   ;	
	int		22h
   ;	
   ;	  }
   ;	}
   ;	
	pop	bp
	ret	
_getdate	endp
   ;	
   ;	void gettime(struct time far *tm)
   ;	
	assume	cs:_TEXT
_gettime	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  _BX = FP_SEG(tm);
   ;	
	push	word ptr [bp+6]
	push	word ptr [bp+4]
	call	near ptr _FP_SEG
	pop	cx
	pop	cx
	mov	bx,ax
   ;	
   ;	  _CX = FP_OFF(tm);
   ;	
	push	word ptr [bp+6]
	push	word ptr [bp+4]
	call	near ptr _FP_OFF
	pop	cx
	pop	cx
	mov	cx,ax
   ;	
   ;	  asm {
   ;		mov	ah,SC_GETTIME
   ;	
	mov		ah,9
   ;	
   ;		int	22h
   ;	
	int		22h
   ;	
   ;	  }
   ;	}
   ;	
	pop	bp
	ret	
_gettime	endp
   ;	
   ;	char far *strcpy (char far *dest,char far *orig)
   ;	
	assume	cs:_TEXT
_strcpy	proc	near
	push	bp
	mov	bp,sp
	sub	sp,4
   ;	
   ;	{
   ;	  char far *res;
   ;	
   ;	  res = dest;
   ;	
	mov	ax,word ptr [bp+6]
	mov	dx,word ptr [bp+4]
	mov	word ptr [bp-2],ax
	mov	word ptr [bp-4],dx
	jmp	short @13@86
@13@58:
   ;	
   ;	  while (*orig!='\0')
   ;	        *dest++ = *orig++;
   ;	
	les	bx,dword ptr [bp+8]
	mov	al,byte ptr es:[bx]
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],al
	inc	word ptr [bp+8]
	inc	word ptr [bp+4]
@13@86:
	les	bx,dword ptr [bp+8]
	cmp	byte ptr es:[bx],0
	jne	short @13@58
   ;	
   ;	  *dest='\0';
   ;	
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],0
   ;	
   ;	  return(res);
   ;	
	mov	dx,word ptr [bp-2]
	mov	ax,word ptr [bp-4]
	jmp	short @13@142
@13@142:
   ;	
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_strcpy	endp
   ;	
   ;	char far *strncpy (char far *dest,char far *orig, size_t maxlen)
   ;	
	assume	cs:_TEXT
_strncpy	proc	near
	push	bp
	mov	bp,sp
	sub	sp,4
	push	si
	mov	si,word ptr [bp+12]
   ;	
   ;	{
   ;	  char far *res;
   ;	  size_t i = 0;
   ;	
	xor	cx,cx
   ;	
   ;	
   ;	  res = dest;
   ;	
	mov	ax,word ptr [bp+6]
	mov	dx,word ptr [bp+4]
	mov	word ptr [bp-2],ax
	mov	word ptr [bp-4],dx
	jmp	short @14@86
@14@58:
   ;	
   ;	  while (*orig!='\0' && i<maxlen)  {
   ;	        *dest++ = *orig++;
   ;	
	les	bx,dword ptr [bp+8]
	mov	al,byte ptr es:[bx]
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],al
	inc	word ptr [bp+8]
	inc	word ptr [bp+4]
   ;	
   ;	        ++i;
   ;	
	inc	cx
@14@86:
	les	bx,dword ptr [bp+8]
	cmp	byte ptr es:[bx],0
	je	short @14@142
	cmp	cx,si
	jb	short @14@58
@14@142:
   ;	
   ;	  }
   ;	  if (i<maxlen)
   ;	
	cmp	cx,si
	jae	short @14@198
   ;	
   ;	     *dest='\0';
   ;	
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],0
@14@198:
   ;	
   ;	  return(res);
   ;	
	mov	dx,word ptr [bp-2]
	mov	ax,word ptr [bp-4]
	jmp	short @14@226
@14@226:
   ;	
   ;	}
   ;	
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_strncpy	endp
   ;	
   ;	char far *strupr (char far *str)
   ;	
	assume	cs:_TEXT
_strupr	proc	near
	push	bp
	mov	bp,sp
	sub	sp,4
   ;	
   ;	{
   ;	  char far *res;
   ;	
   ;	  res = str;
   ;	
	mov	ax,word ptr [bp+6]
	mov	dx,word ptr [bp+4]
	mov	word ptr [bp-2],ax
	mov	word ptr [bp-4],dx
	jmp	short @15@170
@15@58:
   ;	
   ;	  while (*str!='\0')  {
   ;	        if (*str>='a' && *str<='z')
   ;	
	les	bx,dword ptr [bp+4]
	cmp	byte ptr es:[bx],97
	jl	short @15@142
	les	bx,dword ptr [bp+4]
	cmp	byte ptr es:[bx],122
	jg	short @15@142
   ;	
   ;	           *str -= ('a'-'A');
   ;	
	les	bx,dword ptr [bp+4]
	mov	al,byte ptr es:[bx]
	add	al,224
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],al
@15@142:
   ;	
   ;	        ++str;
   ;	
	inc	word ptr [bp+4]
@15@170:
	les	bx,dword ptr [bp+4]
	cmp	byte ptr es:[bx],0
	jne	short @15@58
   ;	
   ;	  }
   ;	  return(res);
   ;	
	mov	dx,word ptr [bp-2]
	mov	ax,word ptr [bp-4]
	jmp	short @15@226
@15@226:
   ;	
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_strupr	endp
   ;	
   ;	char far *strlwr (char far *str)
   ;	
	assume	cs:_TEXT
_strlwr	proc	near
	push	bp
	mov	bp,sp
	sub	sp,4
   ;	
   ;	{
   ;	  char far *res;
   ;	
   ;	  res = str;
   ;	
	mov	ax,word ptr [bp+6]
	mov	dx,word ptr [bp+4]
	mov	word ptr [bp-2],ax
	mov	word ptr [bp-4],dx
	jmp	short @16@170
@16@58:
   ;	
   ;	  while (*str!='\0')  {
   ;	        if (*str>='A' && *str<='Z')
   ;	
	les	bx,dword ptr [bp+4]
	cmp	byte ptr es:[bx],65
	jl	short @16@142
	les	bx,dword ptr [bp+4]
	cmp	byte ptr es:[bx],90
	jg	short @16@142
   ;	
   ;	           *str += ('a'-'A');
   ;	
	les	bx,dword ptr [bp+4]
	mov	al,byte ptr es:[bx]
	add	al,32
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],al
@16@142:
   ;	
   ;	        ++str;
   ;	
	inc	word ptr [bp+4]
@16@170:
	les	bx,dword ptr [bp+4]
	cmp	byte ptr es:[bx],0
	jne	short @16@58
   ;	
   ;	  }
   ;	  return(res);
   ;	
	mov	dx,word ptr [bp-2]
	mov	ax,word ptr [bp-4]
	jmp	short @16@226
@16@226:
   ;	
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_strlwr	endp
   ;	
   ;	int strcmp (char far *s1,char far *s2)
   ;	
	assume	cs:_TEXT
_strcmp	proc	near
	push	bp
	mov	bp,sp
	jmp	short @17@170
@17@58:
   ;	
   ;	{
   ;	  while (*s1 == *s2)  {
   ;	        if (*s1=='\0')
   ;	
	les	bx,dword ptr [bp+4]
	cmp	byte ptr es:[bx],0
	jne	short @17@142
   ;	
   ;	           return(0);
   ;	
	xor	ax,ax
@17@114:
	jmp	short @17@310
@17@142:
   ;	
   ;	        ++s1;
   ;	
	inc	word ptr [bp+4]
   ;	
   ;	        ++s2;
   ;	
	inc	word ptr [bp+8]
@17@170:
	les	bx,dword ptr [bp+4]
	mov	al,byte ptr es:[bx]
	les	bx,dword ptr [bp+8]
	cmp	al,byte ptr es:[bx]
	je	short @17@58
   ;	
   ;	  }
   ;	  if (*s1<*s2)
   ;	
	les	bx,dword ptr [bp+4]
	mov	al,byte ptr es:[bx]
	les	bx,dword ptr [bp+8]
	cmp	al,byte ptr es:[bx]
	jge	short @17@282
   ;	
   ;	     return(-1);
   ;	
	mov	ax,-1
	jmp	short @17@114
	jmp	short @17@310
@17@282:
   ;	
   ;	  else
   ;	     return(1); 
   ;	
	mov	ax,1
	jmp	short @17@114
@17@310:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_strcmp	endp
   ;	
   ;	size_t strlen (char far *str)
   ;	
	assume	cs:_TEXT
_strlen	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  size_t res=0;
   ;	
	xor	dx,dx
	jmp	short @18@86
@18@58:
   ;	
   ;	
   ;	  while (*str++!='\0')
   ;	        ++res;
   ;	
	inc	dx
@18@86:
	les	bx,dword ptr [bp+4]
	inc	word ptr [bp+4]
	cmp	byte ptr es:[bx],0
	jne	short @18@58
   ;	
   ;	  return(res);
   ;	
	mov	ax,dx
	jmp	short @18@142
@18@142:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_strlen	endp
   ;	
   ;	int isdigit (char caracter)
   ;	
	assume	cs:_TEXT
_isdigit	proc	near
	push	bp
	mov	bp,sp
	mov	dl,byte ptr [bp+4]
   ;	
   ;	{
   ;	  if (caracter<'0' || caracter>'9')
   ;	
	cmp	dl,48
	jl	short @19@86
	cmp	dl,57
	jle	short @19@170
@19@86:
   ;	
   ;	     return(0);
   ;	
	xor	ax,ax
@19@114:
	jmp	short @19@198
	jmp	short @19@198
@19@170:
   ;	
   ;	  else
   ;	     return(1);
   ;	
	mov	ax,1
	jmp	short @19@114
@19@198:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_isdigit	endp
   ;	
   ;	int isalpha (char caracter)
   ;	
	assume	cs:_TEXT
_isalpha	proc	near
	push	bp
	mov	bp,sp
	mov	dl,byte ptr [bp+4]
   ;	
   ;	{
   ;	  if ( (caracter>='A' && caracter<='Z') || (caracter>='a' && caracter<='z') )
   ;	
	cmp	dl,65
	jl	short @20@86
	cmp	dl,90
	jle	short @20@142
@20@86:
	cmp	dl,97
	jl	short @20@226
	cmp	dl,122
	jg	short @20@226
@20@142:
   ;	
   ;	     return(1);
   ;	
	mov	ax,1
@20@170:
	jmp	short @20@254
	jmp	short @20@254
@20@226:
   ;	
   ;	  else
   ;	     return(0);
   ;	
	xor	ax,ax
	jmp	short @20@170
@20@254:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_isalpha	endp
   ;	
   ;	int atoi (char far *str)
   ;	
	assume	cs:_TEXT
_atoi	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
   ;	
   ;	{
   ;	  int val=0;
   ;	
	xor	si,si
   ;	
   ;	  int sinal=1;
   ;	
	mov	di,1
	jmp	short @21@86
@21@58:
   ;	
   ;	
   ;	  /* Pula espaços e tabulações */
   ;	  while (*str!='\0' && (*str==9 || *str==' '))
   ;	        ++str;
   ;	
	inc	word ptr [bp+4]
@21@86:
	les	bx,dword ptr [bp+4]
	cmp	byte ptr es:[bx],0
	je	short @21@170
	les	bx,dword ptr [bp+4]
	cmp	byte ptr es:[bx],9
	je	short @21@58
	les	bx,dword ptr [bp+4]
	cmp	byte ptr es:[bx],32
	je	short @21@58
@21@170:
   ;	
   ;	  /* Verifica o sinal opcional */
   ;	  if (*str=='-')  {
   ;	
	les	bx,dword ptr [bp+4]
	cmp	byte ptr es:[bx],45
	jne	short @21@226
   ;	
   ;	     sinal=-1;
   ;	
	mov	di,-1
   ;	
   ;	     ++str;
   ;	
	inc	word ptr [bp+4]
@21@226:
   ;	
   ;	  }
   ;	  if (*str=='+')
   ;	
	les	bx,dword ptr [bp+4]
	cmp	byte ptr es:[bx],43
	jne	short @21@282
   ;	
   ;	     ++str;
   ;	
	inc	word ptr [bp+4]
@21@282:
	jmp	short @21@338
@21@310:
   ;	
   ;	  while (isdigit(*str))  {
   ;	        val=val*10+(*str-'0');
   ;	
	les	bx,dword ptr [bp+4]
	mov	al,byte ptr es:[bx]
	cbw	
	push	ax
	mov	ax,si
	mov	dx,10
	imul	dx
	pop	dx
	add	dx,ax
	add	dx,-48
	mov	si,dx
   ;	
   ;	        ++str;
   ;	
	inc	word ptr [bp+4]
@21@338:
	les	bx,dword ptr [bp+4]
	mov	al,byte ptr es:[bx]
	push	ax
	call	near ptr _isdigit
	pop	cx
	or	ax,ax
	jne	short @21@310
   ;	
   ;	  }
   ;	  return (sinal*val);
   ;	
	mov	ax,di
	imul	si
	jmp	short @21@394
@21@394:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_atoi	endp
   ;	
   ;	void unsignedtostr(char far *str,unsigned i,unsigned tam,char c)
   ;	
	assume	cs:_TEXT
_unsignedtostr	proc	near
	push	bp
	mov	bp,sp
	sub	sp,4
	push	si
	push	di
	mov	cx,word ptr [bp+8]
   ;	
   ;	{
   ;	  unsigned dig,div=1,tamreal,x=0;
   ;	
	mov	si,1
	mov	word ptr [bp-4],0
   ;	
   ;	
   ;	  if (i>9999)
   ;	
	cmp	cx,9999
	jbe	short @22@86
   ;	
   ;	     tamreal = 5;
   ;	
	mov	di,5
	jmp	short @22@282
@22@86:
   ;	
   ;	  else
   ;	     if (i>999)
   ;	
	cmp	cx,999
	jbe	short @22@142
   ;	
   ;	        tamreal = 4;
   ;	
	mov	di,4
	jmp	short @22@282
@22@142:
   ;	
   ;	     else
   ;	        if (i>99)
   ;	
	cmp	cx,99
	jbe	short @22@198
   ;	
   ;	           tamreal = 3;
   ;	
	mov	di,3
	jmp	short @22@282
@22@198:
   ;	
   ;	        else
   ;	           if (i>9)
   ;	
	cmp	cx,9
	jbe	short @22@254
   ;	
   ;	              tamreal = 2;
   ;	
	mov	di,2
	jmp	short @22@282
@22@254:
   ;	
   ;	           else
   ;	              tamreal = 1;
   ;	
	mov	di,1
@22@282:
   ;	
   ;	  if (tam>5)
   ;	
	cmp	word ptr [bp+10],5
	jbe	short @22@338
   ;	
   ;	     tam = 5;
   ;	
	mov	word ptr [bp+10],5
@22@338:
   ;	
   ;	  if (tamreal>tam)
   ;	
	cmp	di,word ptr [bp+10]
	jbe	short @22@394
   ;	
   ;	     tam = tamreal;
   ;	
	mov	word ptr [bp+10],di
@22@394:
   ;	
   ;	  for (dig=0;dig<tam-1;++dig)
   ;	
	mov	word ptr [bp-2],0
	jmp	short @22@478
@22@422:
   ;	
   ;	      div*=10;
   ;	
	mov	dx,10
	mov	ax,si
	imul	dx
	mov	si,ax
	inc	word ptr [bp-2]
@22@478:
	mov	ax,word ptr [bp+10]
	dec	ax
	cmp	ax,word ptr [bp-2]
	ja	short @22@422
	jmp	short @22@758
@22@534:
   ;	
   ;	  while (div>1)  {
   ;	       if (i<div)  {
   ;	
	cmp	cx,si
	jae	short @22@702
   ;	
   ;	          if (!x)
   ;	
	cmp	word ptr [bp-4],0
	jne	short @22@618
   ;	
   ;		     *str++=c;
   ;	
	les	bx,dword ptr [bp+4]
	mov	al,byte ptr [bp+12]
	mov	byte ptr es:[bx],al
	jmp	short @22@646
@22@618:
   ;	
   ;	          else
   ;	             *str++='0';
   ;	
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],48
@22@646:
	inc	word ptr [bp+4]
   ;	
   ;	       }
   ;	
	jmp	short @22@730
@22@702:
   ;	
   ;	       else  {
   ;	          x = 1;
   ;	
	mov	word ptr [bp-4],1
   ;	
   ;	          dig   = i / div;
   ;	
	mov	ax,cx
	xor	dx,dx
	div	si
	mov	word ptr [bp-2],ax
   ;	
   ;	          *str++= (dig+'0');
   ;	
	mov	al,byte ptr [bp-2]
	add	al,48
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],al
	inc	word ptr [bp+4]
   ;	
   ;	          i = i % div;
   ;	
	mov	ax,cx
	xor	dx,dx
	div	si
	mov	cx,dx
@22@730:
   ;	
   ;	       }
   ;	       div = div/10;
   ;	
	mov	ax,si
	mov	bx,10
	xor	dx,dx
	div	bx
	mov	si,ax
@22@758:
	cmp	si,1
	ja	short @22@534
   ;	
   ;	  }
   ;	  *str++= (i+'0');
   ;	
	mov	al,cl
	add	al,48
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],al
	inc	word ptr [bp+4]
   ;	
   ;	  *str = '\0';
   ;	
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],0
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_unsignedtostr	endp
   ;	
   ;	void unsignedlongtostr(char far *str,unsigned long i,unsigned tam,char c)
   ;	
	assume	cs:_TEXT
_unsignedlongtostr	proc	near
	push	bp
	mov	bp,sp
	sub	sp,8
	push	si
	push	di
	mov	di,word ptr [bp+12]
   ;	
   ;	{
   ;	  unsigned tamreal,dig,x=0;
   ;	
	mov	word ptr [bp-4],0
   ;	
   ;	  unsigned long div=1;
   ;	
	mov	word ptr [bp-6],0
	mov	word ptr [bp-8],1
   ;	
   ;	
   ;	  if (i>999999999)
   ;	
	cmp	word ptr [bp+10],15258
	jb	short @23@142
	ja	short @23@114
	cmp	word ptr [bp+8],-13825
	jbe	short @23@142
@23@114:
   ;	
   ;	     tamreal = 10;
   ;	
	mov	si,10
	jmp	@23@1066
@23@142:
   ;	
   ;	  else
   ;	     if (i>99999999)
   ;	
	cmp	word ptr [bp+10],1525
	jb	short @23@254
	ja	short @23@226
	cmp	word ptr [bp+8],-7937
	jbe	short @23@254
@23@226:
   ;	
   ;		tamreal = 9;
   ;	
	mov	si,9
	jmp	@23@1066
@23@254:
   ;	
   ;	     else
   ;		if (i>9999999)
   ;	
	cmp	word ptr [bp+10],152
	jb	short @23@366
	ja	short @23@338
	cmp	word ptr [bp+8],-27009
	jbe	short @23@366
@23@338:
   ;	
   ;		   tamreal = 8;
   ;	
	mov	si,8
	jmp	@23@1066
@23@366:
   ;	
   ;		else
   ;		   if (i>999999)
   ;	
	cmp	word ptr [bp+10],15
	jb	short @23@478
	ja	short @23@450
	cmp	word ptr [bp+8],16959
	jbe	short @23@478
@23@450:
   ;	
   ;		      tamreal = 7;
   ;	
	mov	si,7
	jmp	short @23@1066
@23@478:
   ;	
   ;		   else
   ;		      if (i>99999)
   ;	
	cmp	word ptr [bp+10],1
	jb	short @23@590
	ja	short @23@562
	cmp	word ptr [bp+8],-31073
	jbe	short @23@590
@23@562:
   ;	
   ;			 tamreal = 6;
   ;	
	mov	si,6
	jmp	short @23@1066
@23@590:
   ;	
   ;		      else
   ;			 if (i>9999)
   ;	
	cmp	word ptr [bp+10],0
	jb	short @23@702
	ja	short @23@674
	cmp	word ptr [bp+8],9999
	jbe	short @23@702
@23@674:
   ;	
   ;			    tamreal = 5;
   ;	
	mov	si,5
	jmp	short @23@1066
@23@702:
   ;	
   ;			 else
   ;			    if (i>999)
   ;	
	cmp	word ptr [bp+10],0
	jb	short @23@814
	ja	short @23@786
	cmp	word ptr [bp+8],999
	jbe	short @23@814
@23@786:
   ;	
   ;			       tamreal = 4;
   ;	
	mov	si,4
	jmp	short @23@1066
@23@814:
   ;	
   ;			    else
   ;			       if (i>99)
   ;	
	cmp	word ptr [bp+10],0
	jb	short @23@926
	ja	short @23@898
	cmp	word ptr [bp+8],99
	jbe	short @23@926
@23@898:
   ;	
   ;				  tamreal = 3;
   ;	
	mov	si,3
	jmp	short @23@1066
@23@926:
   ;	
   ;			       else
   ;				  if (i>9)
   ;	
	cmp	word ptr [bp+10],0
	jb	short @23@1038
	ja	short @23@1010
	cmp	word ptr [bp+8],9
	jbe	short @23@1038
@23@1010:
   ;	
   ;				     tamreal = 2;
   ;	
	mov	si,2
	jmp	short @23@1066
@23@1038:
   ;	
   ;				  else
   ;				     tamreal = 1;
   ;	
	mov	si,1
@23@1066:
   ;	
   ;	  if (tam>10)
   ;	
	cmp	di,10
	jbe	short @23@1122
   ;	
   ;	     tam = 10;
   ;	
	mov	di,10
@23@1122:
   ;	
   ;	  if (tamreal>tam)
   ;	
	cmp	si,di
	jbe	short @23@1178
   ;	
   ;	     tam = tamreal;
   ;	
	mov	di,si
@23@1178:
   ;	
   ;	  for (dig=0;dig<tam-1;++dig)
   ;	
	mov	word ptr [bp-2],0
	jmp	short @23@1262
@23@1206:
   ;	
   ;	      div*=10;
   ;	
	xor	cx,cx
	mov	bx,10
	mov	dx,word ptr [bp-6]
	mov	ax,word ptr [bp-8]
	call	near ptr N_LXMUL@
	mov	word ptr [bp-6],dx
	mov	word ptr [bp-8],ax
	inc	word ptr [bp-2]
@23@1262:
	mov	ax,di
	dec	ax
	cmp	ax,word ptr [bp-2]
	ja	short @23@1206
	jmp	@23@1598
@23@1318:
   ;	
   ;	  while (div>1)  {
   ;	       if (i<div)  {
   ;	
	mov	ax,word ptr [bp+10]
	mov	dx,word ptr [bp+8]
	cmp	ax,word ptr [bp-6]
	ja	short @23@1542
	jb	short @23@1402
	cmp	dx,word ptr [bp-8]
	jae	short @23@1542
@23@1402:
   ;	
   ;	          if (!x)
   ;	
	cmp	word ptr [bp-4],0
	jne	short @23@1458
   ;	
   ;		     *str++=c;
   ;	
	les	bx,dword ptr [bp+4]
	mov	al,byte ptr [bp+14]
	mov	byte ptr es:[bx],al
	jmp	short @23@1486
@23@1458:
   ;	
   ;	          else
   ;	             *str++='0';
   ;	
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],48
@23@1486:
	inc	word ptr [bp+4]
   ;	
   ;	       }
   ;	
	jmp	short @23@1570
@23@1542:
   ;	
   ;	       else  {
   ;	          x = 1;
   ;	
	mov	word ptr [bp-4],1
   ;	
   ;		  dig   = i / div;
   ;	
	push	word ptr [bp-6]
	push	word ptr [bp-8]
	push	word ptr [bp+10]
	push	word ptr [bp+8]
	call	near ptr N_LUDIV@
	mov	word ptr [bp-2],ax
   ;	
   ;		  *str++= (dig+'0');
   ;	
	mov	al,byte ptr [bp-2]
	add	al,48
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],al
	inc	word ptr [bp+4]
   ;	
   ;		  i = i % div;
   ;	
	push	word ptr [bp-6]
	push	word ptr [bp-8]
	push	word ptr [bp+10]
	push	word ptr [bp+8]
	call	near ptr N_LUMOD@
	mov	word ptr [bp+10],dx
	mov	word ptr [bp+8],ax
@23@1570:
   ;	
   ;	       }
   ;	       div = div/10;
   ;	
	xor	ax,ax
	mov	dx,10
	push	ax
	push	dx
	push	word ptr [bp-6]
	push	word ptr [bp-8]
	call	near ptr N_LUDIV@
	mov	word ptr [bp-6],dx
	mov	word ptr [bp-8],ax
@23@1598:
	cmp	word ptr [bp-6],0
	jbe	@@0
	jmp	@23@1318
@@0:
	jne	short @23@1682
	cmp	word ptr [bp-8],1
	jbe	@@1
	jmp	@23@1318
@@1:
@23@1682:
   ;	
   ;	  }
   ;	  *str++= (i+'0');
   ;	
	mov	al,byte ptr [bp+8]
	add	al,48
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],al
	inc	word ptr [bp+4]
   ;	
   ;	  *str = '\0';
   ;	
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],0
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_unsignedlongtostr	endp
   ;	
   ;	void unsignedtostrhexa(char far *str,unsigned i)
   ;	
	assume	cs:_TEXT
_unsignedtostrhexa	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
	push	si
   ;	
   ;	{
   ;	  unsigned dig,div=4096;
   ;	
	mov	si,4096
	jmp	short @24@282
@24@58:
   ;	
   ;	
   ;	  while (div>1)  {
   ;	       if (i<div)
   ;	
	cmp	word ptr [bp+8],si
	jae	short @24@114
   ;	
   ;	          *str++='0';
   ;	
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],48
	inc	word ptr [bp+4]
	jmp	short @24@254
@24@114:
   ;	
   ;	       else  {
   ;	          dig   = i / div;
   ;	
	mov	ax,word ptr [bp+8]
	xor	dx,dx
	div	si
	mov	word ptr [bp-2],ax
   ;	
   ;	          if (dig<10)
   ;	
	cmp	word ptr [bp-2],10
	jae	short @24@170
   ;	
   ;	             *str++= (dig+'0');
   ;	
	mov	al,byte ptr [bp-2]
	add	al,48
	jmp	short @24@198
@24@170:
   ;	
   ;	          else
   ;	             *str++= (dig-10+'A');
   ;	
	mov	al,byte ptr [bp-2]
	add	al,55
@24@198:
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],al
	inc	word ptr [bp+4]
   ;	
   ;	          i = i % div;
   ;	
	mov	ax,word ptr [bp+8]
	xor	dx,dx
	div	si
	mov	word ptr [bp+8],dx
@24@254:
   ;	
   ;	       }
   ;	       div = div/16;
   ;	
	mov	ax,si
	mov	cl,4
	shr	ax,cl
	mov	si,ax
@24@282:
	cmp	si,1
	ja	short @24@58
   ;	
   ;	  }
   ;	  if (i<10)
   ;	
	cmp	word ptr [bp+8],10
	jae	short @24@366
   ;	
   ;	     *str++= (i+'0');
   ;	
	mov	al,byte ptr [bp+8]
	add	al,48
	jmp	short @24@394
@24@366:
   ;	
   ;	  else
   ;	     *str++= (i-10+'A');
   ;	
	mov	al,byte ptr [bp+8]
	add	al,55
@24@394:
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],al
	inc	word ptr [bp+4]
   ;	
   ;	  *str = '\0';
   ;	
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],0
   ;	
   ;	}
   ;	
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_unsignedtostrhexa	endp
   ;	
   ;	void inttostr(char far *str,int i)
   ;	
	assume	cs:_TEXT
_inttostr	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
	push	si
	push	di
	mov	cx,word ptr [bp+8]
   ;	
   ;	{
   ;	  int dig,div=10000,fimzeroesq=0;
   ;	
	mov	si,10000
	xor	di,di
   ;	
   ;	
   ;	  if (i==-32768)  {
   ;	
	cmp	cx,-32768
	jne	short @25@86
   ;	
   ;	     *str++='-';
   ;	
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],45
	inc	word ptr [bp+4]
   ;	
   ;	     *str++='3';
   ;	
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],51
	inc	word ptr [bp+4]
   ;	
   ;	     *str++='2';
   ;	
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],50
	inc	word ptr [bp+4]
   ;	
   ;	     *str++='7';
   ;	
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],55
	inc	word ptr [bp+4]
   ;	
   ;	     *str++='6';
   ;	
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],54
	inc	word ptr [bp+4]
   ;	
   ;	     *str++='8';
   ;	
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],56
	jmp	short @25@394
@25@86:
   ;	
   ;	  }
   ;	  else  {
   ;	     if (i<0)  {
   ;	
	or	cx,cx
	jge	short @25@142
   ;	
   ;	        *str++='-';
   ;	
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],45
	inc	word ptr [bp+4]
   ;	
   ;	        i = -i;
   ;	
	mov	ax,cx
	neg	ax
	mov	cx,ax
@25@142:
	jmp	short @25@338
@25@170:
   ;	
   ;	     }
   ;	     while (div>1)  {
   ;	           if (i<div)  {
   ;	
	cmp	cx,si
	jge	short @25@282
   ;	
   ;	              if (fimzeroesq!=0)
   ;	
	or	di,di
	je	short @25@254
   ;	
   ;	                 *str++='0';
   ;	
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],48
	inc	word ptr [bp+4]
@25@254:
   ;	
   ;	           }
   ;	
	jmp	short @25@310
@25@282:
   ;	
   ;	           else  {
   ;	              fimzeroesq=1;
   ;	
	mov	di,1
   ;	
   ;	              dig   = i / div;
   ;	
	mov	ax,cx
	cwd	
	idiv	si
	mov	word ptr [bp-2],ax
   ;	
   ;	              *str++= (dig+'0');
   ;	
	mov	al,byte ptr [bp-2]
	add	al,48
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],al
	inc	word ptr [bp+4]
   ;	
   ;	              i = i % div;
   ;	
	mov	ax,cx
	cwd	
	idiv	si
	mov	cx,dx
@25@310:
   ;	
   ;	           }
   ;	           div = div/10;
   ;	
	mov	ax,si
	mov	bx,10
	cwd	
	idiv	bx
	mov	si,ax
@25@338:
	cmp	si,1
	jg	short @25@170
   ;	
   ;	      }
   ;	      *str++= (i+'0');
   ;	
	mov	al,cl
	add	al,48
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],al
@25@394:
	inc	word ptr [bp+4]
   ;	
   ;	  }
   ;	  *str = '\0';
   ;	
	les	bx,dword ptr [bp+4]
	mov	byte ptr es:[bx],0
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_inttostr	endp
   ;	
   ;	void reboot()
   ;	
	assume	cs:_TEXT
_reboot	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  asm {
   ;	    mov  ah,SC_REBOOT
   ;	
	mov	  ah,10
   ;	
   ;	    int  22h
   ;	
	int	  22h
   ;	
   ;	  }
   ;	}
   ;	
	pop	bp
	ret	
_reboot	endp
   ;	
   ;	pid_t fork(void (*fun)())
   ;	
	assume	cs:_TEXT
_fork	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  _BX = miniSO_CODESEGMENT;
   ;	
	mov	bx,2016
   ;	
   ;	  _CX = (unsigned)fun;
   ;	
	mov	cx,word ptr [bp+4]
   ;	
   ;	  asm {
   ;	     mov  ah,SC_FORK
   ;	
	mov	  ah,11
   ;	
   ;	     int  22h
   ;	
	int	  22h
   ;	
   ;	  }
   ;	  return _AX; 
   ;	
	jmp	short @27@142
@27@142:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_fork	endp
   ;	
   ;	int kill(pid_t pid)
   ;	
	assume	cs:_TEXT
_kill	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  _BX = pid;
   ;	
	mov	bx,word ptr [bp+4]
   ;	
   ;	  asm {
   ;	    mov ah,SC_KILL
   ;	
	mov	 ah,12
   ;	
   ;	    int 22h
   ;	
	int	 22h
   ;	
   ;	  }
   ;	  return _AX;
   ;	
	jmp	short @28@142
@28@142:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_kill	endp
   ;	
   ;	pid_t wait(int far *status)
   ;	
	assume	cs:_TEXT
_wait	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;		_BX = FP_SEG(status);
   ;	
	push	word ptr [bp+6]
	push	word ptr [bp+4]
	call	near ptr _FP_SEG
	pop	cx
	pop	cx
	mov	bx,ax
   ;	
   ;		_CX = FP_OFF(status);
   ;	
	push	word ptr [bp+6]
	push	word ptr [bp+4]
	call	near ptr _FP_OFF
	pop	cx
	pop	cx
	mov	cx,ax
   ;	
   ;		asm	{
   ;			mov	ah,SC_WAIT
   ;	
	mov		ah,14
   ;	
   ;			int	22h
   ;	
	int		22h
   ;	
   ;		}
   ;		return _AX;
   ;	
	jmp	short @29@142
@29@142:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_wait	endp
   ;	
   ;	pid_t waitpid(pid_t pid,int far *status)
   ;	
	assume	cs:_TEXT
_waitpid	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;		_BX = pid;
   ;	
	mov	bx,word ptr [bp+4]
   ;	
   ;		_CX = FP_SEG(status);
   ;	
	push	word ptr [bp+8]
	push	word ptr [bp+6]
	call	near ptr _FP_SEG
	pop	cx
	pop	cx
	mov	cx,ax
   ;	
   ;		_DX = FP_OFF(status);
   ;	
	push	word ptr [bp+8]
	push	word ptr [bp+6]
	call	near ptr _FP_OFF
	pop	cx
	pop	cx
	mov	dx,ax
   ;	
   ;		asm	{
   ;			mov	ah,SC_WAITPID
   ;	
	mov		ah,13
   ;	
   ;			int	22h
   ;	
	int		22h
   ;	
   ;		}
   ;		return _AX;
   ;	
	jmp	short @30@142
@30@142:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_waitpid	endp
   ;	
   ;	void exit(int codfim)
   ;	
	assume	cs:_TEXT
_exit	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  _BX = codfim;
   ;	
	mov	bx,word ptr [bp+4]
   ;	
   ;	  asm {
   ;	    mov ah,SC_EXIT
   ;	
	mov	 ah,15
   ;	
   ;	    int 22h
   ;	
	int	 22h
   ;	
   ;	  }
   ;	}
   ;	
	pop	bp
	ret	
_exit	endp
   ;	
   ;	pid_t getpid()
   ;	
	assume	cs:_TEXT
_getpid	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  asm {
   ;	    mov ah,SC_GETPID
   ;	
	mov	 ah,16
   ;	
   ;	    int 22h
   ;	
	int	 22h
   ;	
   ;	  }
   ;	  return _AX;
   ;	
	jmp	short @32@114
@32@114:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_getpid	endp
   ;	
   ;	pid_t getppid()
   ;	
	assume	cs:_TEXT
_getppid	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  asm {
   ;	    mov ah,SC_GETPPID
   ;	
	mov	 ah,17
   ;	
   ;	    int 22h
   ;	
	int	 22h
   ;	
   ;	  }
   ;	  return _AX;
   ;	
	jmp	short @33@114
@33@114:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_getppid	endp
   ;	
   ;	int sendsignal(pid_t pid, signal_t signal)
   ;	
	assume	cs:_TEXT
_sendsignal	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	
   ;	  _BX = pid;
   ;	
	mov	bx,word ptr [bp+4]
   ;	
   ;	  _CX = signal;
   ;	
	mov	cx,word ptr [bp+6]
   ;	
   ;	  asm {
   ;	     mov  ah,SC_SENDSIGNAL
   ;	
	mov	  ah,18
   ;	
   ;	     int  22h
   ;	
	int	  22h
   ;	
   ;	  }
   ;	  return _AX; 
   ;	
	jmp	short @34@142
@34@142:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_sendsignal	endp
   ;	
   ;	void waitsignal(signal_t signal)
   ;	
	assume	cs:_TEXT
_waitsignal	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	  _BX = signal;
   ;	
	mov	bx,word ptr [bp+4]
   ;	
   ;	  asm {
   ;	     mov  ah,SC_WAITSIGNAL
   ;	
	mov	  ah,19
   ;	
   ;	     int  22h
   ;	
	int	  22h
   ;	
   ;	  }
   ;	}
   ;	
	pop	bp
	ret	
_waitsignal	endp
   ;	
   ;	semid_t semcreate (int value)
   ;	
	assume	cs:_TEXT
_semcreate	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;		_BX = value;
   ;	
	mov	bx,word ptr [bp+4]
   ;	
   ;		asm	{
   ;			mov  ah,SC_SEMCREATE
   ;	
	mov	  ah,20
   ;	
   ;			int  22h
   ;	
	int	  22h
   ;	
   ;		}
   ;		return _AX;
   ;	
	jmp	short @36@142
@36@142:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_semcreate	endp
   ;	
   ;	int semset (semid_t s,int value)
   ;	
	assume	cs:_TEXT
_semset	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;		_BX = s;
   ;	
	mov	bx,word ptr [bp+4]
   ;	
   ;		_CX = value;
   ;	
	mov	cx,word ptr [bp+6]
   ;	
   ;		asm	{
   ;			mov  ah,SC_SEMSET
   ;	
	mov	  ah,21
   ;	
   ;			int  22h
   ;	
	int	  22h
   ;	
   ;		}
   ;		return _AX;
   ;	
	jmp	short @37@142
@37@142:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_semset	endp
   ;	
   ;	int semup (semid_t s)
   ;	
	assume	cs:_TEXT
_semup	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;		_BX = s;
   ;	
	mov	bx,word ptr [bp+4]
   ;	
   ;		asm	{
   ;			mov  ah,SC_SEMUP
   ;	
	mov	  ah,22
   ;	
   ;			int  22h
   ;	
	int	  22h
   ;	
   ;		}
   ;		return _AX;
   ;	
	jmp	short @38@142
@38@142:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_semup	endp
   ;	
   ;	int semdown (semid_t s)
   ;	
	assume	cs:_TEXT
_semdown	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;		_BX = s;
   ;	
	mov	bx,word ptr [bp+4]
   ;	
   ;		asm	{
   ;			mov  ah,SC_SEMDOWN
   ;	
	mov	  ah,23
   ;	
   ;			int  22h
   ;	
	int	  22h
   ;	
   ;		}
   ;		return _AX;
   ;	
	jmp	short @39@142
@39@142:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_semdown	endp
   ;	
   ;	int semdestroy (semid_t s)
   ;	
	assume	cs:_TEXT
_semdestroy	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;		_BX = s;
   ;	
	mov	bx,word ptr [bp+4]
   ;	
   ;		asm	{
   ;			mov  ah,SC_SEMDESTROY
   ;	
	mov	  ah,24
   ;	
   ;			int  22h
   ;	
	int	  22h
   ;	
   ;		}
   ;		return _AX;
   ;	
	jmp	short @40@142
@40@142:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_semdestroy	endp
   ;	
   ;	int stop(pid_t pid){
   ;	
	assume	cs:_TEXT
_stop	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	_BX = pid;
   ;	
	mov	bx,word ptr [bp+4]
   ;	
   ;	asm {
   ;	mov ah,SC_STOP
   ;	
	mov	 ah,25
   ;	
   ;	int 22h
   ;	
	int	 22h
   ;	
   ;	}
   ;	return _AX;
   ;	
	jmp	short @41@142
@41@142:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_stop	endp
   ;	
   ;	int resume(pid_t pid){
   ;	
	assume	cs:_TEXT
_resume	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	_BX = pid;
   ;	
	mov	bx,word ptr [bp+4]
   ;	
   ;	asm {
   ;	mov ah,SC_RESUME
   ;	
	mov	 ah,26
   ;	
   ;	int 22h
   ;	
	int	 22h
   ;	
   ;	}
   ;	return _AX;
   ;	
	jmp	short @42@142
@42@142:
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_resume	endp
	?debug	C E9
	?debug	C FA00000000
_TEXT	ends
_DATA	segment word public 'DATA'
s@	label	byte
_DATA	ends
_TEXT	segment byte public 'CODE'
_TEXT	ends
	extrn	N_LUMOD@:far
	extrn	N_LUDIV@:far
	extrn	N_LXMUL@:far
	public	_isalpha
	public	_resume
	public	_stop
	public	_semdestroy
	public	_semdown
	public	_semup
	public	_semset
	public	_semcreate
	public	_waitsignal
	public	_sendsignal
	public	_getppid
	public	_getpid
	public	_exit
	public	_waitpid
	public	_wait
	public	_kill
	public	_fork
	public	_reboot
	public	_inttostr
	public	_unsignedtostrhexa
	public	_unsignedlongtostr
	public	_unsignedtostr
	public	_atoi
	public	_isdigit
	public	_strlen
	public	_strcmp
	public	_strlwr
	public	_strupr
	public	_strncpy
	public	_strcpy
	public	_gettime
	public	_getdate
	public	_gotoxy
	public	_wherey
	public	_wherex
	public	_setcolor
	public	_getcolor
	public	_putstrxy
	public	_putstr
	public	_clrscr
	public	_getch
	public	_putch
	extrn	_FP_OFF:near
	extrn	_FP_SEG:near
_s@	equ	s@
	end
