reset:
	rjmp main

main:
	nop

loop:
	; ввод 
	in r18, OCR0A
	in r19, OCR0B
	; выполнение операции
	mul r18, r19
	; вывод 
	out OCR0A, r1
	out OCR0B, r0
rjmp loop