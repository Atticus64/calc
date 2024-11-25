ideal 
dosseg
model small
stack 256
 
dataseg
codsal db 0
input    db  100 dup(?)
cad1 db 40 dup(?)
cad2 db 40 dup(?)

macro cursor
    mov cl, 7
    mov ah, 1
    int 10h
endm

codeseg
extrn aputs:proc, agets:proc


; input: si -> cadena a parsear
; ret: en si y di las 2 cadenas y cx el operador
proc parser
    mov di, offset cad1
    
    lodsb
    stosb

@@first:
    lodsb 
    cmp al, '+'
    je @@token
    cmp al, '-'
    je @@token
    cmp al, '*'
    je @@token
    cmp al, '/'
    je @@token

    stosb
    jmp @@first

@@token:
    mov [byte di], 0
    mov di, offset cad2
    mov cl, al

    @@iter:
        lodsb 
        cmp al, 0
        je @@salir

        stosb
        jmp @@iter
     
@@salir:
    mov [byte di], 0
    ret

endp


inicio:
mov ax, @data 
mov ds, ax
mov es, ax

mov ch, 0
cursor
mov di, offset input
call agets




mov si, offset input
call parser

mov si, offset cad2
call aputs

mov ch, 6
cursor

fin:
mov ah, 04Ch
mov al, [codsal]
int 21h

end inicio


