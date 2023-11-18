setup:
	nop

loop:
	; ввод
	in r18,OCR0A
	; изменения флагов,
	; записываем первый бит регистра r18 в SREG на место флага T
	bst r18,1
	brtc flag_is_cleared
	; флаг установлен
	ldi r18,1
	rjmp output

flag_is_cleared:
	ldi r18,0
	nop

output:
	out OCR0A,r18

rjmp loop
