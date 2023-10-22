assume cs: code, ds: data

data segment
dummy db 0Dh, 0Ah, '$'
;msg db '_','_','$'
string1 db 100, 99 dup ('$')
string2 db 100, 99 dup ('$')
dest db 100 dup(0)
s db '_', '_', '$'
;res1 db ?
data ends

code segment

strcmp proc
    push bp
    mov bp, sp

    mov si, [bp + 6];string1
    mov di, [bp + 4];string2

    xor cx, cx
    ;mov cl, [si + 1]
    mov ax, 1; результат
    ;mov dx, si
    add si, 2
    add di, 2
    
    mov cx, 98
    loop1:
        mov ah, [si]
	mov al, [di]
	;cmp ah, '$'

	cmp ah, al
	jne endloop2

	inc si
	inc di
	;add si, 2
	;add di, 2
	loop loop1   
	;jmp loop1
    ;jmp endloop1

    ;endloop1:
    xor ax, ax
    jmp exit

    endloop2:
    ;sub ah, al
    ;mov al, ah
    ;xor ah, ah
    cmp ah, al
    jg positive
    mov ah, '-'
    jmp exit

    positive:
    mov ah, '+'
    
    exit:
    mov al, 1
    cmp cx, 0
    jne e
    xor ax, ax
    e:
    pop bp
    pop bx
    push ax
    push bx
    ret
strcmp endp

start: 
    mov ax, data
    mov ds, ax

    ;считывание первой строки
    mov dx, offset string1
    mov ax, 0
    mov ah, 0Ah
    int 21h
    mov bl, [string1 + 1]
    inc bl
    mov si, bx
    mov byte[string1 + si],'$'
    push dx

    mov dx, offset dummy ; перевод строки
    mov ah, 09h
    int 21h

    ;считывание второй строки
    xor bx, bx
    mov dx, offset string2
    mov ax, 0
    mov ah, 0Ah
    int 21h
    mov bl, [string2 + 1]
    inc bl
    mov si, bx
    mov byte[string2 + si],'$'
    push dx

    mov dx, offset dummy ; перевод строки
    mov ah, 09h
    int 21h

    call strcmp

    pop dx
    
    xor si, si
    add dl, '0'
    ;sub dh, 'd'
    mov s[si], dh
    inc si
    mov s[si], dl
    
    mov ah, 09h
    mov dx, offset s
    ;mov ah, 09h
    int 21h
    mov ax, 4C00h
    ;mov al, 1h
    int 21h
code ends
end start
