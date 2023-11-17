loop:
	nop
	; ввожу второй аргумент нативно, 
	; так как команда по своей сути создана, 
	; для того чтобы сразу вычитать значение,
	; а не записывать его предварительно в регистр

	; ввод 16
	in r18, OCR0A
	sbci r18,1
	out OCR0A, r18
	
	; ввод 128
	in r18, OCR0A
	sbci r18,0
	out OCR0A, r18
	
	; ввод 128
	in r18, OCR0A
	sbci r18,1
	out OCR0A, r18
	
	; ввод 0
	in r18, OCR0A
	sbci r18,0
	out OCR0A, r18
	
	; ввод 256
	in r18, OCR0A
	sbci r18,1
	out OCR0A, r18
	
	; ввод 0
	in r18, OCR0A
	sbci r18,0
	out OCR0A, r18

	; ввод 127
	in r18, OCR0A
	sbci r18,-1
	out OCR0A, r18
rjmp loop
