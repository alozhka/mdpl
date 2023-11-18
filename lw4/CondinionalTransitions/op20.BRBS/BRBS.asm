setup:
	nop
loop:
	; ввод
	in r18,OCR0A
	in r19,OCR0B
	; изменения флагов
	add r18,r19
	brbs 1,flag_is_setted // проверка на флаг нуля
	; флаг нуля очищен
	ldi r18,0
	rjmp output

flag_is_setted:
	ldi r18,1
	nop

output:
	out OCR0A,r18

rjmp loop