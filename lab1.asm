assume CS:code, DS:data

data segment
a db 1
b db 4
c db 5
d db 1
res1 db ?
res2 db ?
;res3 db ?
;msg db "Hello, world!$"
stringhex db "__h", 0ah, "$"
stringdec db "___$"
data ends

code segment;13
start:
mov AX, data
mov DS, AX
mov AH,0
mov Al,a   
shl Al, 1; mul 2
mov res1, Al
mov AX, 0
mov Al, b
mov cl, 2
shr Al, cl;mov bl, 4
;div bl;24
add AL, res1
mov res1, Al
mov Al, c
mov bl, d
mul bl
add Al, res1
mov res1, Al

;вывод в hex
mov al, 0B1h
mov bl, 10h
div bl
xor si, si
cmp al, 10
jl a1
add al, '0'
jmp exit1
a1: add al, 41h
exit1: mov stringhex[si], al
;mov stringhex[si], al
inc si
;cmp ah, 0Ah
;jl a2
add ah, '0'
;jmp exit2
;a2: add ah, 37h
;exit2: mov stringhex[si], ah
mov stringhex[si], ah

;вывод в dec от младших к старшим изменения в строчке
mov res1, 0FFh
xor ax, ax
mov al, res1
mov bl, 0Ah
div bl; error
inc si
;mov si, 2
add ah, '0'
mov stringdec[si], ah

mov res2, al
xor ax, ax
mov al, res2
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

mov dx,offset stringhex           
mov ah,09h
int 21h
mov dx,offset  stringdec
mov ah,09h
int 21h
mov ah,04Ch
mov al,1h
int 21h

code ends
end start
