ideal 
dosseg
model small
stack 256
 
dataseg
codsal db 0
cad    db  100 dup(?)

macro cursor
    mov ch, 0
    mov cl, 7
    mov ah, 1
    int 10h
endm

codeseg
extrn aputs:proc, agets:proc
inicio:
mov ax, @data 
mov ds, ax
mov es, ax

cursor
mov di, offset cad 
call agets

mov si, offset cad
call aputs

mov ch, 6
mov cl, 7
mov ah, 1
int 10h

mov ah, 04Ch
mov al, [codsal]
int 21h

end inicio

