setup:
	nop
loop:
	; ввод
	in r18,OCR0A
	in r19,OCR0B
	; изменения флагов
	add r18,r19
	brvs overflow_is_setted
	; overflow is not setted
	ldi r18,0
	rjmp output

overflow_is_setted:
	ldi r18,1
	; выравниваю, чтобы было одинаковое количество тактов
	; и при V==0 и при V==1
	nop

output:
	out OCR0A,r18

rjmp loop