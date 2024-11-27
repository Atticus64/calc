ideal
dosseg
model small

codeseg
public aputs, agets, aputsc


macro write
mov ah, 0Eh
int 10h 
endm

proc getp
    push bx
    push cx

    mov ah, 03h
    int 10h 

    pop cx
    pop bx
    ret
endp getp

proc asetp
    push bx
    push ax
    mov bh, 0
    mov ah, 2
    int 10h
    pop ax
    pop bx
    ret
endp asetp

proc aputs  ; PROCEDIMIENTO QUE IMPRIME UNA CADENA DE CARACTERES
    push ax
    push bx

    mov ah, 0Eh
    mov bh, 0

    cld

@@while:
    lodsb
    cmp al, 0
    je @@endwhi

    int 10h
    jmp @@while

@@endwhi:
    pop bx
    pop ax
    ret

endp aputs


proc aputsc
    push ax
    push bx
    push cx

    cld

@@while:
    lodsb
    cmp al, 0
    je @@endwhi

    cmp al, 13    
    je @@ctrl
    cmp al, 10
    je @@ctrl

    jmp @@print

@@ctrl:
    mov ah, 0Eh
    mov bh, 0
    int 10h
    jmp @@while

@@print:
    mov ah, 09h
    mov bh, 0
    mov cx, 1
    int 10h
    call getp
    inc dl
    call asetp
    jmp @@while

@@endwhi:
    pop cx
    pop bx
    pop ax
    ret

endp aputsc


proc agets  ; PROCEDIMIENTO QUE LEE UNA CADENA DE CARACTERES
    local len: word, bk: word, inp: byte = tamVarsLoc
    push bp
    mov  bp, sp
    sub sp, tamVarsLoc

    mov [len], 0
    mov [bk], 0
    push ax
    push bx
    push di

    mov bh, 0
    cld

@@while:
    mov ah, 10h
    int 16h ;INTERRUPCION LEER

    cmp ah, 75
    je @@izq

    cmp ah, 77
    je @@der

    cmp al, 8
    je @@del    

    write
   
    cmp al, 13
    je @@endwhi

    inc [len]
    cmp [bk], 0
    ja @@insert

    mov si, di
    stosb ; guardar
    jmp @@while

@@insert:
    call insert
    jmp @@while


@@izq:
    mov dx, [len]
    cmp dx, [bk]
    je @@while

    call getp
    dec dl
    call asetp
    inc [bk]

    jmp @@while

@@der:
    cmp [bk], 0
    je @@while

    call getp
    inc dl
    call asetp
    dec [bk]
    ;pop ax
    jmp @@while

@@del:
    cmp [len], 0
    je @@while

    write

    call delete
    jmp @@while

@@endwhi:
    mov [byte di], 0

    mov al, 10
    write

    pop di
    pop bx
    pop ax
    mov sp, bp ; Elimina variables locales
    pop bp

    ret

endp agets

proc insert 

    mov [inp], al
    mov cx, [bk]
    mov si, di
    dec si
    
    @@iter:
        lodsb
        sub si, 2
        push ax
    loop @@iter

    mov cx, [bk]
    mov si, di

    push si 
    sub si, [bk]
    mov di, si
    pop si

    mov al, [inp]
    stosb
    inc [len]

    @@restore:
        pop ax
        write
        stosb ; guardar
    loop @@restore


    mov cx, [bk]
    @@back:
        call getp
        dec dl
        call asetp
    loop @@back
    ret

endp insert

proc delete
    cmp [bk], 0
    je @@ulti

    mov cx, [bk]
    mov si, di
    dec si
    
    @@fill:
        lodsb
        sub si, 2
        push ax
    loop @@fill

    mov cx, [bk]
    mov si, di
    push si 
    sub si, [bk]
    mov di, si
    pop si
    dec di

    @@out:
        pop ax
        write
        stosb ; guardar
    loop @@out

    mov di, si

@@ulti:
    cmp [len], 0
    je @@exit

    dec [len]
    mov al, 20h         
    int 10h
    mov al, 08h
    int 10h
    dec di

    cmp [bk], 0
    je @@exit

    mov cx, [bk]
    @@back:
        call getp
        dec dl
        call asetp
    loop @@back

@@exit:
    ret

endp

    
    end
