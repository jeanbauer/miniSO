CODIGO          SEGMENT
                ASSUME CS:CODIGO

                ORG 0h

INICIO:
                jmp short fat0000
                nop
                db 'miniSO  '
                dw 0200h
                db 01h
                dw 0001h
                db 02h
                dw 00e0h
                dw 0b40h
                db 0f0h
                dw 0009h
                dw 0012h
                dw 0002h
                dd 00000000h
                dd 00000000h
                db 00h
                db 00h
                db 29h
                dd 00000000h
                db 'BOOTDISK   '
                db 'FAT12   '

fat0000:
                mov     ax,07c0h
                mov     ds,ax

                cli
                xor     ax,ax
                mov     ss,ax
                mov     ax,7c00h
                mov     sp,ax
                sti

                mov     ax,0007h
                push    ax
                call    _setcolor
                pop     ax

                mov     ax,offset str00000
                push    ax
                call    _putstr
                pop     ax

                mov     dx,0100h
                mov     cx,0010h
                mov     ax,0203h
                mov     bx,07e0h
                mov     es,bx
                xor     bx,bx
                int     13h

                xor     dx,dx
                mov     cx,0101h
                mov     ax,0212h
                mov     bx,0840h
                mov     es,bx
                xor     bx,bx
                int     13h

                mov     dx,0100h
                mov     cx,0101h
                mov     ax,0212h
                mov     bx,0a80h
                mov     es,bx
                xor     bx,bx
                int     13h

                xor     dx,dx
                mov     cx,0201h
                mov     ax,0212h
                mov     bx,0cc0h
                mov     es,bx
                xor     bx,bx
                int     13h

                db      0eah,00h,00h,0e0h,07h

laco:           jmp     laco

; Recebe em SS:[BP+4] o caracter a ser impresso ser impresso
_putchar:       push    bp
                mov     bp,sp
                push    ax
                mov     ax,[BP+4]
                push    bx
                push    cx
                push    dx
                mov     ah,09h
                mov     bl,DS:[color]
                mov     bh,DS:[pagina]
                mov     cx,1
                int     10h
                mov     ah,03h
                mov     bh,DS:[pagina]
                int     10h
                inc     dl
                cmp     dl,DS:[cols]
                jnz     putchar_defcur
                xor     dl,dl
                inc     dh
                cmp     dh,25
                jnz     putchar_defcur
                dec     dh
                push    dx
                ; Tem que fazer scroll
                mov     ax,0601h
                mov     cx,0000h
                mov     dh,24
                mov     dl,DS:[cols]
                dec     dl
                mov     bh,DS:[color]
                int     10h
                pop     dx
putchar_defcur: mov     bh,DS:[pagina]
                mov     ah,02h
                int     10h
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                pop     bp
                ret

_setcolor:      push    bp
                mov     bp,sp
                push    bx
                push    cx
                mov     bh,[bp+4]
                mov     DS:[color],bh
                mov     bl,bh
                and     bh,70h
                mov     cl,04h
                ror     bh,cl
                mov     DS:[bgcolor],bh
                and     bl,0fh
                mov     DS:[fgcolor],bl
                pop     cx
                pop     bx
                pop     bp
                ret

_putstr:        push    bp
                mov     bp,sp
                push    ax
                push    bx
                mov     bx,[bp+4]
putstr_laco:    mov     al,DS:[bx]
                or      al,al
                jnz     putstr_cont
                pop     bx
                pop     ax
                pop     bp
                ret
putstr_cont:    cmp     al,10
                jnz     putstr_cont2
                call    _newline
                inc     bx
                jmp     putstr_laco
putstr_cont2:   cmp     al,1
                jnz     putstr_cont3
                inc     bx
                mov     al,DS:[bx]
                push    ax
                call    _setcolor
                pop     ax
                inc     bx
                jmp     putstr_laco
putstr_cont3:   push    ax
                call    _putchar
                pop     ax
                inc     bx
                jmp     putstr_laco

_newline:       push    ax
                push    bx
                push    cx
                push    dx
                mov     ah,03h
                mov     bh,DS:[pagina]
                int     10h
                xor     dl,dl
                inc     dh
                cmp     dh,25
                jnz     newline_defcur
                dec     dh
                push    dx
                ; Tem que fazer scroll
                mov     ax,0601h
                xor     cx,cx
                mov     dh,24
                mov     dl,DS:[cols]
                dec     dl
                mov     bh,DS:[color]
                int     10h
                pop     dx
newline_defcur: mov     bh,DS:[pagina]
                mov     ah,02h
                int     10h
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret

; VARIAVEIS DO SISTEMA DE VIDEO
mode            db      02h
cols            db      50h
color           db      07h
bgcolor         db      00h
fgcolor         db      07h
pagina          db      00h

; STRINGS
str00000        db      'Carregando minisSistema Operacional...',0

FIM             db      (510 - (FIM-INICIO)) dup (0)

                dw      0aa55h

CODIGO          ENDS

                END     INICIO
