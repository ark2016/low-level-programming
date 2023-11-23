assume cs: code, ds: data

data segment
first db 255, 254 dup (0)
operator db 2, 0
second db 255, 254 dup (0)
result db 0, 255, 255 dup (0)
number_err db "SyntaxError: illegal character $"
op_err db "SyntaxError: illegal character $"
data ends

code segment

scan_input_string proc
	push bp
	mov bp, sp
	
	mov dx, [bp+4]
	xor ax, ax
	mov ah, 0Ah
	int 21h
	
	mov dx, [bp+4]
	inc dx
	mov si, dx
	mov cx, [si]
	xor ch, ch
	add si, cx
	mov [si+1], '$'
	inc dx
	
	pop bp
	ret
scan_input_string endp

print_output_string proc
	push bp
	mov bp, sp
	
	mov dx, [bp+4]
	xor ax, ax
	mov ah, 09h
	int 21h
	
	pop bp
	ret
print_output_string endp

newline proc
	mov ah, 02h
	mov dl, 0Ah
	int 21h
	ret
newline endp

str_to_int proc
	push bp
	mov bp, sp
	
	;знак результата
	mov si, [bp+4]
	mov al, [si]
	mov bl, [si+2]
	cmp bl, '-'
	jne str_to_int_sign_else
		dec al
		sub [si+1], 1
		mov di, si
		add di, 2
		xor bx, bx
		mov bl, [si+1]
		add bx, si
		inc bx
		str_to_int_sign_loop:
			mov cl, [di+1]
			sub cl, [di]
			add [di], cl
			
			inc di
			cmp di, bx
			jle str_to_int_sign_loop
	str_to_int_sign_else:
	sub [si], al
	
	;преобразование ASCII-кодов в цифры
	xor bx, bx
	mov bl, [si+1]
	add bx, si
	inc bx
	mov di, si
	add di, 2
	str_to_int_proc_loop:
		mov al, [di]
		cmp al, '0'
		jl number_error
		cmp al, 'f'
		jg number_error
		cmp al, '9'
		jle str_to_int_proc_else
			cmp al, 'a'
			jl number_error
			mov al, 'a'
			sub al, 0ah
			jmp str_to_int_proc_else_pass
		str_to_int_proc_else:
			mov al, '0'
		str_to_int_proc_else_pass:
		sub [di], al
		
		inc di
		cmp di, bx
		jle str_to_int_proc_loop
	
	;проверка на ошибку ввода (числа от 0 до f (заглавные не подходят))
	jmp number_ok
	number_error:
		dec di
		mov al, [di]
		sub [di], al
		add [di], ' '
		;number_error_loop:
		;	dec di
		;	mov al, [di]
		;	sub [di], al
		;	add [di], '>'
		;	cmp di, si
		;	jge number_error_loop
		dec di
		mov al, [di]
		sub [di], al
		add [di], '('
		dec di
		mov al, [di]
		sub [di], al
		add [di], '='
		pop bp
		pop bx
		push si
		push offset number_err 
		push 1
		push bx
		ret
	number_ok:
	
	pop bp
	pop bx
	push 0
	push 0
	push 0
	push bx
	ret
str_to_int endp

string_to_opp proc
	push bp
	mov bp, sp
	
	mov si, [bp+4]
	mov al, [si]
	sub [si], al
	
	;определение оператора
	xor ax, ax
	mov al, [si+2]
	cmp ax, '+'
	je op_error_pass
	cmp ax, '*'
	jne string_to_opp_else
		inc [si]
		jmp op_error_pass
	string_to_opp_else:
	jmp op_error
	
	;подготовка возврата при ошибке (операторы только + и *)
	jmp op_error_pass
	op_error:
		pop bp
		pop bx
		push si
		push offset op_err
		push 1
		push bx
		ret
	op_error_pass:
	
	pop bp
	pop bx
	push 0
	push 0
	push 0
	push bx
	ret
string_to_opp endp

int_to_string proc
	push bp
	mov bp, sp
	
	;знак числа
	mov si, [bp+4]
	xor ax, ax
	mov al, [si]
	cmp al, 0
	je int_to_string_sign_else
		add [si], '-'
		dec [si]
	int_to_string_sign_else:
	add ax, si
	mov di, ax
	
	;преобразование цифр числа в их ASCII-коды
	xor ax, ax
	mov al, [si+1]
	add ax, si
	inc ax
	add si, 2
	xor bx, bx
	int_to_string_loop:
		mov bl, [di]
		sub [di], bl
		mov bl, [si]
		cmp bx, 9
		jle int_to_string_else_1
			add bl, 'a'
			sub bl, 0ah
			jmp int_to_string_else_1_pass
		int_to_string_else_1:
			add bl, '0'
		int_to_string_else_1_pass:
		
		add [di], bl
		
		inc di
		inc si
		cmp si, ax
		jle int_to_string_loop	
	mov [di], '$'
	pop bp
	ret
int_to_string endp

;сумма двух чисел
my_sum_ proc
	push bp
	mov bp, sp
	
	;определение операции
	mov si, [bp+6]
	mov al, [si]
	mov si, [bp+8]
	mov ah, [si]
	cmp al, ah
	jne my_sum_op_else
		;сложение
		
		;определение знака результата
		mov si, [bp+4]
		add [si], al
		
		;прибавление первого числа
		xor bh, bh
		mov si, [bp+4]
		inc si
		mov bl, [si]
		add si, bx
		mov di, [bp+8]
		inc di
		mov ax, di
		mov bl, [di]
		add di, bx
		my_sum_add1_loop:
			mov bl, [di]
			add [si], bl
			
			dec si
			dec di
			cmp di, ax
			jne my_sum_add1_loop
		
		;прибавление второго числа
		xor bh, bh
		mov si, [bp+4]
		inc si
		mov bl, [si]
		add si, bx
		mov di, [bp+6]
		inc di
		mov ax, di
		mov bl, [di]
		add di, bx
		my_sum_add2_loop:
			mov bl, [di]
			add [si], bl
			
			dec si
			dec di
			cmp di, ax
			jne my_sum_add2_loop
		
		jmp my_sum_op_else_pass
	my_sum_op_else:
		;вычитание
		
		;определение большего по модулю числа
		mov si, [bp+6]
		mov di, [bp+8]
		my_sum_max_loop:
			inc si
			inc di
			
			mov al, [si]
			mov ah, [di]
			
			cmp al, ah
			je my_sum_max_loop
			mov cx, [bp+6]
			mov dx, [bp+8]
			jg my_sum_max_else
				mov cx, [bp+8]
				mov dx, [bp+6]
			my_sum_max_else:
		
		;знак результата
		mov si, cx
		mov al, [si]
		mov si, [bp+4]
		add [si], al
		
		;прибавление первого числа
		xor bh, bh
		mov si, [bp+4]
		inc si
		mov bl, [si]
		add si, bx
		mov di, cx
		inc di
		mov ax, di
		mov bl, [di]
		add di, bx
		my_sum_sub1_loop:
			mov bl, [di]
			add [si], bl
			
			dec si
			dec di
			cmp di, ax
			jne my_sum_sub1_loop
		
		;вычитание второго числа
		xor bh, bh
		xor ch, ch
		mov si, [bp+4]
		inc si
		mov bl, [si]
		add si, bx
		mov di, dx
		inc di
		mov ax, di
		mov bl, [di]
		add di, bx
		my_sum_sub2_loop_0:
			;заём в случае вычитания из меньшего большего
			mov bl, [di]
			mov cl, [si]
			cmp bl, cl
			jle my_sum_sub2_else
				xor bl, bl
				add [si], 10h
				my_sum_sub2_loop_1:
					mov cl, [si-1]
					cmp cl, 0
					jne my_sum_sub1_else
						add [si-1], 0fh
						inc bl
						dec si
						dec di
						jmp my_sum_sub2_loop_1
					my_sum_sub1_else:
					dec [si-1]
				add si, bx
				add di, bx
			my_sum_sub2_else:
			
			mov bl, [di]
			sub [si], bl
			
			dec si
			dec di
			cmp di, ax
			jne my_sum_sub2_loop_0
	my_sum_op_else_pass:
	
	;нормирование результата
	mov si, [bp+4]
	inc si
	mov ax, si
	inc ax
	add si, [si]
	my_sum_norm_loop:
		mov bl, [si]
		cmp bl, 10h
		jl my_sum_norm_else
			sub [si], 10h
			inc [si-1]
		my_sum_norm_else:
		dec si
		cmp si, ax
		jne my_sum_norm_loop
	
	;сдвиг до первой значащей цифры
	mov si, [bp+4]
	inc si
	xor ax, ax
	mov al, [si]
	inc si
	my_sum_shift_loop_0:
		mov bl, [si]
		cmp bl, 0
		je my_sum_shift_else_0
			mov di, [bp+4]
			inc di
			sub [di], ah
			inc di
			my_sum_shift_loop_1:
				mov bl, [si]
				add [di], bl
				sub [si], bl
				inc ah
				inc si
				inc di
				cmp ah, al
				jne my_sum_shift_loop_1
			jmp my_sum_shift_loop_0_pass
		my_sum_shift_else_0:
		inc ah
		inc si
		cmp ah, al
		jne my_sum_shift_loop_0
	jne my_sum_shift_else_1
		mov si, [bp+4]
		mov al, [si]
		sub [si], al
		mov al, [si+1]
		dec al
		sub [si+1], al
	my_sum_shift_else_1:
	my_sum_shift_loop_0_pass:
	
	pop bp
	ret
my_sum_ endp

;функция вычисления произведения двух чисел
my_mul_ proc
	push bp
	mov bp, sp
	
	;главный процесс познакового умножения
	xor dh, dh
	mov si, [bp+8]
	mov al, [si+1]
	my_mul_proc_loop_0:
		dec al
		
		mov si, [bp+6]
		mov ah, [si+1]
		my_mul_proc_loop_1:
			dec ah
			
			;взятие цифры из первого числа
			mov si, [bp+8]
			mov dl, [si+1]
			add si, dx
			mov dl, al
			sub si, dx
			mov bl, [si+1]
			
			;взятие цифры из второго числа
			mov si, [bp+6]
			mov dl, [si+1]
			add si, dx
			mov dl, ah
			sub si, dx
			mov cl, [si+1]
			
			;подготовка индекса для числа результата
			mov si, [bp+4]
			mov dl, [si+1]
			add si, dx
			mov dl, al
			sub si, dx
			mov dl, ah
			sub si, dx
			inc si
			
			;умножение малых чисел через циклическое сложение
			my_mul_proc_loop_2:
				cmp bl, 0
				je my_mul_proc_loop_2_pass
				
				add [si], cl
				dec bl
				
				mov dl, [si]
				cmp dl, 10h
				jl my_mul_proc_else
					sub [si], 10h
					inc [si-1]
				my_mul_proc_else:
				jmp my_mul_proc_loop_2
			my_mul_proc_loop_2_pass:
			
			cmp ah, 0
			jne my_mul_proc_loop_1
		cmp al, 0
		jne my_mul_proc_loop_0
	
	;нормирование результата
	mov si, [bp+4]
	inc si
	mov ax, si
	inc ax
	add si, [si]
	my_mul_norm_loop:
		mov bl, [si]
		cmp bl, 10h
		jl my_mul_norm_else
			sub [si], 10h
			inc [si-1]
			jmp my_mul_norm_loop
		my_mul_norm_else:
		dec si
		cmp si, ax
		jne my_mul_norm_loop
	
	;определение знака результата
	mov si, [bp+8]
	mov al, [si]
	mov si, [bp+6]
	mov ah, [si]
	mov si, [bp+4]
	cmp ah, al
	je my_mul_sign_else
		inc [si]
	my_mul_sign_else:
	
	;сдвиг до первой значащей цифры
	mov si, [bp+4]
	inc si
	xor ax, ax
	mov al, [si]
	inc si
	my_mul_shift_loop_0:
		mov bl, [si]
		cmp bl, 0
		je my_mul_shift_else_0
			mov di, [bp+4]
			inc di
			sub [di], ah
			inc di
			my_mul_shift_loop_1:
				mov bl, [si]
				add [di], bl
				sub [si], bl
				inc ah
				inc si
				inc di
				cmp ah, al
				jne my_mul_shift_loop_1
			jmp my_mul_shift_loop_0_pass
		my_mul_shift_else_0:
		inc ah
		inc si
		cmp ah, al
		jne my_mul_shift_loop_0
	jne my_mul_shift_else_1
		mov si, [bp+4]
		mov al, [si]
		sub [si], al
		mov al, [si+1]
		dec al
		sub [si+1], al
	my_mul_shift_else_1:
	my_mul_shift_loop_0_pass:
	
	pop bp
	ret
my_mul_ endp

;обработка ошибки после выполнения функции
chek_error proc
	push bp
	mov bp, sp
	
	cmp [bp+4], 0
	je chek_error_else
		push [bp+6]
		call print_output_string
		mov ax, [bp+8]
		add ax, 2
		push ax
		call print_output_string
		call newline
		
		xor ax, ax
		mov ah, 4ch
		int 21h
	chek_error_else:
	
	pop bp
	ret
chek_error endp

;главная функция
main:	mov ax, data
		mov ds, ax
		
		push offset first
		call scan_input_string
		call newline
		call str_to_int
		call chek_error
		
		push offset operator
		call scan_input_string
		call newline
		call string_to_opp
		call chek_error
		
		push offset second
		call scan_input_string
		call newline
		call str_to_int
		call chek_error
		
		push offset first
		push offset second
		push offset result
		cmp operator[0], 0
		jne main_else
			call my_sum_
			jmp main_else_pass
		main_else:
			call my_mul_
		main_else_pass:
		
		push offset result
		call int_to_string
		call print_output_string
		;call newline
		
		mov ah, 4ch
		int 21h
code ends
end main











