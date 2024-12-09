ideal 
dosseg
model small
stack 256
 
dataseg
codsal db 0
welc   db 'Ingresa la operacion o "salir"'
       db  13, 10, 0   
errorm db 'Datos invalidos'
       db  13, 10, 0   
exitk  db 'salir'
       db 0
prompt db '> '
       db 0
equal  db '=', 0
input  db 100 dup(?)
cad1   db 40 dup(?)
cad2   db 40 dup(?)
bin    db 10 dup(?)
hex    db 10 dup(?)
deci   db 10 dup(?)
resul  db 10 dup(?)
cadf   db 50 dup(?)

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
extrn aputs:proc, agets:proc, aputsc:proc 
extrn aatoi:proc, aitoa:proc
extrn astrlen:proc, astrcat:proc
extrn astrcmp:proc, astrupr:proc


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
    cmp al, '%'
    je @@token
    cmp al, '&'
    je @@token
    cmp al, '|'
    je @@token

    cmp al, ' '
    je @@first

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

        cmp al, ' '
        je @@iter

        stosb
        jmp @@iter
     
@@salir:
    mov [byte di], 0
    ret

endp

proc menu
    push si
    push bx
    push di
    mov si, offset welc
    mov bl, 6
    call aputsc
    mov si, offset prompt
    mov bl, 3
    call aputsc
    mov di, offset input
    call agets
    pop di
    pop bx
    pop si
    ret
endp

; dx 0 | 1
proc isnvalue 
    cmp al, '9'
    ja @@hex
    je @@num
    cmp al, '0'
    ja @@num
    je @@num
    jmp @@inv

    @@hex: ; al >= 'A' or al <= 'F' 
    cmp al, 'A' 
    jb @@inv
    je @@num 
    cmp al, 'F'
    jg @@inv
    jmp @@num

    @@num:
    mov dx, 1
    jmp @@fin

    @@inv:
    mov dx, 0

    @@fin:
    ret
endp

; dx 
    ; 0 invalid symbol
    ; 1 symbol
proc issymbol 
    cmp al, '+'
    je @@sym
    cmp al, '-'
    je @@sym
    cmp al, '/'
    je @@sym
    cmp al, '*'
    je @@sym
    cmp al, '%'
    je @@sym
    cmp al, '&'
    je @@sym
    cmp al, '|'
    je @@sym
    cmp al, ' '
    je @@sym
    cmp al, 'H'
    je @@sym
    cmp al, 'D'
    je @@sym
    cmp al, 'B'
    je @@sym
    cmp al, 'O'
    je @@sym

    @@inv:
    mov dx, 0
    jmp @@fin

    @@sym:
    mov dx, 1

    @@fin:
    ret
endp

; si -> cadena a validar
; cx 
;   -> 0 operation valid
;   -> 1 invalid operation
proc invalid
    push si
    push bx 
    push dx 
    push ax 
    mov cx, 0

    @@iter:
        lodsb 
        cmp al, 0
        je @@salir

        call isnvalue
        cmp dx, 1
        je @@iter
        call issymbol
        cmp dx, 1
        je @@iter

        jmp @@error


    @@error:
    mov cx, 1

    @@salir:
    pop ax
    pop dx 
    pop bx
    pop si
    ret
endp 


proc show 
    push bx
    push cx
    push si
    push di
    ; binario
    mov di, offset bin
    mov bx, 2
    mov cx, 0
    call aitoa
    mov si, di
    mov di, offset cadf
    call astrcat
    mov bl, 4
    call aputsc

    mov si, offset equal
    mov di, offset cadf
    call astrcat
    call aputs

    ; hex
    mov di, offset hex
    mov bx, 16
    mov cx, 0
    call aitoa
    mov si, offset hex
    mov di, offset cadf
    call astrcat
    mov bl, 9
    call aputsc

    mov si, offset equal
    mov di, offset cadf
    call astrcat
    call aputs
    mov di, offset resul
    mov si, di

    ; octal
    mov di, offset resul
    mov bx, 8
    mov cx, 0
    call aitoa
    mov si, offset resul
    mov di, offset cadf
    call astrcat
    mov bl, 5
    call aputsc

    ; =
    mov si, offset equal
    mov di, offset cadf
    call astrcat
    call aputs

    ; dec
    mov di, offset deci
    mov si, di
    mov bx, 10
    mov cx, 1
    call aitoa
    mov si, di
    mov di, offset cadf
    call astrcat
    mov bl, 2
    call aputsc

    mov si, offset cadf
    call aputs

    pop di
    pop si
    pop cx
    pop bx
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
    cmp cl, '%'
    je @@mod
    cmp cl, '&'
    je @@andl
    cmp cl, '|'
    je @@orl

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
    @@mod:
    cwd
    idiv bx
    xchg dx, ax
    jmp @@fin
    @@andl:
    and ax, bx
    jmp @@fin
    @@orl:
    or ax, bx

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
    call menu
    mov si, offset input

    mov di, offset exitk
    call astrcmp
    cmp ax, 0
    je exit

    call astrupr
    mov cx, 0

    call invalid
    cmp cx, 1
    je badinput

    call parser

    mov si, offset cad1
    call aatoi
    mov bx, ax
    mov si, offset cad2
    call aatoi
    xchg ax, bx

    call calc
    ;mov di, offset resul

    call show

    mov si, offset cadf+1 ; Salta el primer byte (longitud máxima)
    mov cx, [si-1]          ; Usa el primer byte como longitud leída
    xor al, al              ; Limpia con 0
    rep stosb               ; Reinicia los datos

    mov ax, 0
    mov bx, 0
    jmp main

    badinput:
    mov si, offset cadf+1 ; Salta el primer byte (longitud máxima)
    mov cx, [si-1]          ; Usa el primer byte como longitud leída
    xor al, al              ; Limpia con 0
    rep stosb               ; Reinicia los datos

    mov si, offset errorm
    call aputs

    jmp main

    exit:
    mov ch, 6
    cursor

    fin:
    mov ah, 04Ch
    mov al, [codsal]
    int 21h

end inicio


