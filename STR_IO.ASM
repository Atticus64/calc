ideal
dosseg
model small

codeseg
public aputs, agets

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

proc agets  ; PROCEDIMIENTO QUE LEE UNA CADENA DE CARACTERES
    local len: word, bk: word = tamVarsLoc
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

    mov ah, 0Eh
    int 10h ;INTERRUPCION ESCRIBIR
 
    cmp al, 8
    je @@del    

    cmp al, 13
    je @@endwhi

    inc [len]

    stosb ; guardar
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
    jmp @@while

@@del:
    ; es backspace
    cmp [len], 0
    je @@while

    dec [len]
    mov al, 20h         ; A space to clear old character 
    int 10h
    mov al, 08h
    int 10h
    dec di
    jmp @@while

@@endwhi:
    mov [byte di], 0

    mov al, 10
    mov ah, 0Eh
    int 10h ;INTERRUPCION ESCRIBIR

    pop di
    pop bx
    pop ax
    mov sp, bp ; Elimina variables locales
    pop bp

    ret

endp agets
    
    end
