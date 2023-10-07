assume CS:code, DS:data

data segment
res1 dw 0
res2 db ?
vec1 dw 2,2,2
vec2 dw 1,2,3
stringdec db ?,?,?,'$'
data ends

code segment
start:
mov AX, data
mov DS, AX

xor si,si
xor cx, cx

loop1:
  mov ax, vec1[si]
  mov bx, vec2[si]
  mul bx
  add res1, ax
  add si, 2
  cmp si, 6
  jge exit
  jmp loop1

exit:

mov cx, res1

mov ax, cx
mov bl, 0Ah
div bl
mov si, 2
add ah, '0'
mov stringdec[si], ah

mov res2, al
xor ax, ax
mov al, res2
;mov bl, 0Ah
div bl
dec si
add ah, '0'
mov stringdec[si], ah

mov res2, al
xor ax, ax
mov al, res2
div bl
dec si
add ah,'0'
mov stringdec[si], ah

mov dx,offset  stringdec
mov ah,09h
int 21h
mov ah,04Ch
mov al,1h
int 21h

code ends
end start
