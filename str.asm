ideal
dosseg
model small

codeseg

public astrlen, astrupr, aatoi, aitoa
; Parámetros:
;
; SI = cadena
;
; Regresa:
;
; CX = strlen(cadena)
proc astrlen
 push ax ; Preserva AX, DI
 push di
 mov di, si ; DI = SI
 xor al, al ; AL = 0
 cld ; Autoincrementa DI
@@whi: scasb ; while([DI++]);
 jnz @@whi
 mov cx, di ; CX = DI - SI – 1
 sub cx, si
 dec cx
 pop di ; Restaura DI, AX
 pop ax
 ret
endp astrlen


; Parámetros:
;
; SI = cadena
;
; Regresa:
;
; SI = scadena

proc astrupr
 push ax ; Preserva AX, CX, SI, DI
 push cx
 push si
 push di
 call astrlen ; CX = strlen(cadena)
 jcxz @@fin ; if(!CX) goto @@fin
 mov di, si ; DI = SI
 cld ; Autoincrementa SI, DI
@@do: ; do
 ; {
 lodsb ; AL = [SI++]
 cmp al, 'a' ; if(AL < 'a' ||
 jb @@sig ; AL > 'z')
 cmp al, 'z'
 ja @@sig
 sub al, 'a'-'A' ; AL = toupper(AL)
@@sig: stosb ; [DI++] = AL
 loop @@do ; }
 ; while(--CX > 0)
@@fin: pop di ; Restaura DI, SI, CX, AX
 pop si
 pop cx
 pop ax
 ret
endp astrupr


;Parámetros:
;
; SI = cadena con el número
;
; Regresa:
;
; AX = número en binario
;
; int aatoi(char *s)
; {
; astrup(cadena)
; l = astrlen(s)
; signo = obtenSigno(&s, &l)
; base = obtenBase(s, &l)
; n = atou(s, base, l)
; if(signo) n *= -1
; return n
; }
proc aatoi
 push bx ; Preserva BX, CX, DX, SI
 push cx
 push dx
 push si

 call astrupr ; strup(cadena)
 call astrlen ; CX = strlen(cadena)
 call obtenSigno ; DX = [SI] == '-',
 ; SI++, CX--
 call obtenBase ; BX = base, CX--
 call atou ; AX = atou(cadena)
 cmp dx, 0 ; if(dx == 0)
 je @@sig ; goto @@sig
 neg ax ; ax = -ax

@@sig: pop si ; Restaura SI, DX, CX, BX
 pop dx
 pop cx
 pop bx
 ret
endp aatoi

;
; Parámetros:
;
; SI = cadena con el número
; CX = Longitud de la cadena
;
; Regresa:
;
; CX : if([si] == '+' || [si] == '-') CX--
; DX = [si] == '-'
; SI : if([si] == '+' || [si] == '-') SI++
; 0 -> positivo
; 1 -> negativo
proc obtenSigno
 xor dx, dx ; dx = 0
 cmp [byte si], '+' ; if([si] == '+')
 je @@pos ; goto @@pos
 cmp [byte si], '-' ; if([si] == '-')
 je @@neg ; goto @@neg
 jmp @@fin ; goto @@fin
@@neg: mov dx, 1 ; Dx = 1
@@pos: inc si ; SI++
 dec cx ; CX--
@@fin: ret
endp obtenSigno

; Parámetros:
;
; SI = cadena con el número
; CX = Longitud de la cadena
;
; Regresa:
;
; BX : if([si+cx-1] == 'B') BX = 2
; else if([si+cx-1] == 'H') BX = 16
; else BX = 10
; CX : if([si+cx-1] == 'B' || [si+cx-1] == 'H' ||
; [si+cx-1] == 'D') CX—
proc obtenBase
 push si ; Preserva SI
 add si, cx ; SI = cadena + strlen(
 dec si ; cadena) – 1

 mov bx, 10 ; base = 10
 cmp [byte si], 'B' ; if([si] == 'B')
 je @@bin 
 cmp [byte si], 'H' ; if([si] == 'H')
 je @@hex ; goto @@hex
 cmp [byte si], 'D' ; if([si] == 'D')
 je @@dec ; goto @@dec
 jmp @@fin ; goto @@fin

@@bin: mov bx, 2 ; base = 2
 jmp @@dec ; goto @@dec
@@hex: mov bx,16 ; Base = 16
@@dec: dec cx ; CX--

@@fin:
 pop si ; Restaura SI
 ret
endp obtenBase

;Parámetros:
;
; SI = cadena con el número
; BX = 2, 10, 16, base del número
; CX = strlen(cadena)
;
; Regresa:
;
; AX = número en binario
proc atou
 push dx ; Preserva DX, DI
 push di
 xor ax, ax ; n = 0
 jcxz @@fin ; if(!CX) goto @@fin
 xor di, di ; n = 0
@@do: ; do
 ; {
 mov ax, di ; AX = base*n
 mul bx
 mov dl, [byte si] ; DX = [SI]
 xor dh, dh
 call valC ; DX = val([SI])
 add ax, dx ; AX = base*n + DX
 mov di, ax ; n = AX
 inc si ; SI++
 loop @@do ; }
 ; while(--CX > 0)

 mov ax, di
@@fin: pop di ; Restaura DI, DX
 pop dx
 ret
endp atou


; Parámetros:
;
; DX = carácter
;
; Regresa:
;
; DX = número
proc valC
 cmp dx, '9'
 ja @@hex
 sub dx, '0'
 ret
;@@hex: sub dx, 'A' – 10
@@hex: sub dx, 55
 ret
endp valC

;Parámetros:
;
; DI = cadena para guardar el num 
; BX = 2, 10, 16, base del número
; AX = número
;
; Regresa:
; DI = cadena completa
proc aitoa
push cx
push dx
push ax
push bx
push di


xor cx, cx
xor dx, dx

call charB
push dx
inc cx

cmp bx, 10
jne @@iter
cmp ax, 0
jge @@iter
neg ax

@@iter:
    cwd
    xor dx, dx
    div bx
    call charV
    push dx
    inc cx

    cmp ax, 0
    je @@ciclo
jmp @@iter

@@ciclo:
    pop ax
    stosb
loop @@ciclo

@@end:
mov al, 13
stosb
mov al, 10
stosb
mov [byte di], 0

pop di
pop bx
pop ax
pop dx
pop cx
endp aitoa


proc charB 
mov dl, 'D'
cmp bx, 16
je @@hex
cmp bx, 2 
je @@bin
ret

@@hex:
mov dl, 'H'
ret
@@bin:
mov dl, 'B'
ret

endp charB

; dx: número
; dx -> carácter
proc charV
    cmp dx, 9
    ja @@hex
    add dx, '0' 
    ret
    @@hex: add dx, 55 
    ret
endp charV

end