setup:
	nop
loop:
	; ввод
	in r18,OCR0A
	in r19,OCR0B
	; изменения флагов
	add r18,r19
	brcc carry_is_cleared
	; carry is setted
	ldi r18,1
	rjmp output

carry_is_cleared:
	ldi r18,0
	; выравниваю, чтобы было одинаковое количество тактов
	; и при С==0 и при С==1
	nop

output:
	out OCR0A,r18

rjmp loop