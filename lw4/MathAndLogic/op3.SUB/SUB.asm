setup:
	nop
loop:
	; ввод 
	in r18, OCR0A
	in r19, OCR0B
	; выполнение операции
	sub r18, r19
	; вывод 
	out OCR0A, r18
	out OCR0B, r19
rjmp loop
