setup:
	nop

loop:
	; ввод
	in r18,OCR0A
	in r19,OCR0B
	; изменения флагов
	add r18,r19
	brpl negative_is_cleared
	; N установлен
	ldi r18,1
	rjmp output

negative_is_cleared:
	ldi r18,0
	nop

output:
	out OCR0A,r18

rjmp loop