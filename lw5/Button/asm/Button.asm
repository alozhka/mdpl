.def I = r17
.def TEMP = r18
.def SHIFT_I = r19


reset:
    rjmp setup
setup:
	ldi TEMP,0b01111111
	out DDRB,TEMP ; все на выход, 7 бит на вход
	sbi PORTB,7 ; подтягиваем резистор к 7 биту

loop:
	ldi I,0

	for_loop:
	; пропуск если кнопка не нажата
		sbis PINB,7
		rjmp button_pressed

	; не нажата
		ldi TEMP,1
	;сдвиг
		mov SHIFT_I,I
		inc SHIFT_I
	shift_not_pressed:
		lsl TEMP
		dec SHIFT_I
		brne shift_not_pressed

		lsr TEMP
		rjmp outer

	;нажата
	button_pressed:
	;сдвиг
		ldi TEMP,0b01000000
		mov SHIFT_I,I
		inc SHIFT_I
	shift_pressed:
		lsr TEMP
		dec SHIFT_I
		brne shift_pressed

	outer:
		out PORTB,TEMP
		sbi PORTB,7 ; для кнопки

		; задержка
			ldi	r30, 0x23	; 35
			ldi	r31, 0xF4	; 244
		delay:
			sbiw r30, 0x01	; вычиаем из слова(r31:r30)
			brne delay

		inc I
		cpi I,6
		brlo for_loop ; I < 6 => переход

	

rjmp loop
