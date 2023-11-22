.equ ARR_SIZE = 10
.def COUNTER = r17
.def TEMP = r18
.def NUM_ITEMS = r19
.def ADAPTED_COUNTER = r20



.dseg

segments: .BYTE ARR_SIZE


.cseg

.org 0x0000
rjmp main

.org INT0addr
rjmp button_handler

button_handler:
	ldi COUNTER,0
	out PORTB,TEMP
	out PORTC,TEMP
	cbi PORTD,3
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
	ldi TEMP,0b01111111
	out DDRB,TEMP
	out DDRC,TEMP
	cbi DDRD,2
	sbi DDRD,3
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

		cpi COUNTER,100
		brlo outer
		ldi COUNTER,0

	outer:
	
		rcall print_dozens
		rcall print_digits

		inc COUNTER

	; задержка на 1 сек
		ldi	r23, 0x3F ; 63
		ldi	r24, 0x0D
		ldi	r25, 0x03
	delay_loop:
		subi	r23, 0x01
		sbci	r24, 0x00
		sbci	r25, 0x00
		brne	delay_loop
rjmp loop

.cseg
segments_flash: .db 0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110, 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01101111


find_dozens:
		mov ADAPTED_COUNTER,COUNTER
		clr r22
	dozens_loop:
		cpi ADAPTED_COUNTER,10
		brlo find_dozens_finish

		subi ADAPTED_COUNTER,10
		inc r22
	rjmp dozens_loop

	find_dozens_finish:
	mov ADAPTED_COUNTER,r22
ret


find_digits:
		mov ADAPTED_COUNTER,COUNTER
	digits_loop:
		cpi ADAPTED_COUNTER,10
		brlo find_digits_finish ; переход если < 10
		subi ADAPTED_COUNTER,10
	rjmp digits_loop

	find_digits_finish:
ret

print_7_bit:
	andi r24,0b01000000
	; сдвигаю под пин d3
	lsr r24
	lsr r24
	lsr r24
	; для кнопки
	ori r24,0b00000100
	out PORTD,r24
ret


print_dozens:
	; установка десятков
		rcall find_dozens
		add YL,ADAPTED_COUNTER
		adc YH,TEMP
		; получили сегмент
		ld r24,Y
		out PORTB,r24
		; возвращение указателя обратно
		sub YL,ADAPTED_COUNTER
		sbc YH,TEMP
ret

print_digits:
	; установка единиц
		rcall find_digits
		add YL,ADAPTED_COUNTER
		adc YH,TEMP
		; получили сегмент
		ld r24,Y
		out PORTC,r24
		rcall print_7_bit
		; возвращение указателя обратно
		sub YL,ADAPTED_COUNTER
		sbc YH,TEMP
ret