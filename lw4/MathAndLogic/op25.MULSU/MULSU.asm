reset:
	rjmp main

main:

loop:
	; ввод 
	in r18, OCR0A
	in r19, OCR0B
	; выполнение операции
	mulsu r18, r19
	; вывод 
	out OCR0A, r0
	out OCR0B, r1
rjmp loop