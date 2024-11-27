ideal 
dosseg
model small
stack 256
 
dataseg
codsal db 0
welc   db 'Ingresa la operacion'
       db  13, 10, 0   
prompt db '> '
       db 0
input  db  100 dup(?)
cad1   db 40 dup(?)
cad2   db 40 dup(?)
resul  db 10 dup(?)

macro cursor
    mov cl, 7
    mov ah, 1
    int 10h
endm

macro clear
  mov ah, 0
  mov al, 3  ; text mode 80x25 16 colours
  int 10h
endm

codeseg
extrn aputs:proc, agets:proc, aputsc:proc, aatoi:proc, aitoa:proc, astrlen:proc


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


; params 
; cl -> operator
; [ax, bx] -> numbers
proc calc

cmp cl, '+'
je @@suma
cmp cl, '-'
je @@resta
cmp cl, '*'
je @@mult
cmp cl, '/'
je @@divi


@@suma:
add ax, bx
jmp @@fin
@@resta:
sub ax, bx
jmp @@fin
@@mult:
imul bx
jmp @@fin
@@divi:
cwd
idiv bx
jmp @@fin

@@fin:
    ret
endp


inicio:
mov ax, @data 
mov ds, ax
mov es, ax

mov ch, 0
cursor

clear
main:
mov si, offset welc
mov bl, 6
call aputsc
mov si, offset prompt
mov bl, 3
call aputsc

mov di, offset input
call agets

mov si, offset input
call parser

mov si, offset cad1
call aatoi
mov bx, ax
mov si, offset cad2
call aatoi
xchg ax, bx

cmp ax, 0
jz exit

call calc
mov di, offset resul

mov bx, 2
call aitoa
mov si, di
mov bl, 4
call aputsc

mov bx, 16
call aitoa
mov si, di
mov bl, 9
call aputsc

mov bx, 10
call aitoa
mov si, di
mov bl, 2
call aputsc

mov ax, 0
mov bx, 0
jmp main
;mov si, offset cad2
;call aputs

exit:
mov ch, 6
cursor

fin:
mov ah, 04Ch
mov al, [codsal]
int 21h

end inicio


