.equ ARR_SIZE = 10
.def IS_BUTTON_PRESSED = r16
.def COUNTER = r17
.def TEMP = r18
.def NUM_ITEMS = r19


.dseg

segments: .BYTE ARR_SIZE


.cseg

.org 0x0000
rjmp main

.org INT0addr
rjmp button_handler

button_handler:
		cpi IS_BUTTON_PRESSED,0
		brne first_press
		ldi IS_BUTTON_PRESSED,1
		rjmp handler_finish

	first_press:
	; сбросился и остановился
		ldi COUNTER,0
		ldi IS_BUTTON_PRESSED,0

	handler_finish: 
reti


reset:
	rjmp main
main:
	ldi ZH,High(segments_flash * 2)
	ldi ZL,Low(segments_flash * 2)
	ldi YH,High(segments)
	ldi YL,Low(segments)
	ldi NUM_ITEMS,ARR_SIZE
arr_copy:
	lpm TEMP,Z+
	st Y+,TEMP
	subi NUM_ITEMS,1
	brne arr_copy

; установка
	ldi TEMP,0xFF
	out DDRB,TEMP
	sbi PORTD,2
	; найстройка прерываний
	sbi EIMSK,INT0
	lds r24,EICRA
	ori r24,0x02
	sts EICRA,r24
	sei
	; настройка указателя
	ldi YH,High(segments)
	ldi YL,Low(segments)
	ldi TEMP,0

loop:
		cpi IS_BUTTON_PRESSED,0
		brne loop

		cpi COUNTER,10
		brlo outer
		ldi COUNTER,0

	outer:
	; установка числа в регистр
		add YL,COUNTER
		adc YH,TEMP
		; вывод
		ld r24,Y
		out PORTB,r24
		; возвращение указателя обратно
		sub YL,COUNTER
		sbc YH,TEMP

		inc COUNTER

	; задержка на 1 сек
		ldi	r18, 0x3F ; 63
		ldi	r24, 0x0D
		ldi	r25, 0x03
	delay_loop:
		subi	r18, 0x01
		sbci	r24, 0x00
		sbci	r25, 0x00
		brne	delay_loop
rjmp loop

.cseg
segments_flash: .db 0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110, 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01101111

