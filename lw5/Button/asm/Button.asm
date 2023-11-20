.def BUTTON = r16
.def I = r17

reset:
    rjmp setup
setup:
	ldi r16,0b01111111
	out DDRC,r16 ; все на выход, 7 бит на вход
	sbi PORTC,7 ; подтягиваем резистор к 7 биту
	ldi BUTTON,0 ; 

loop:
	sbis PORTC,7
	ldi button,1

	inc I
	cpi I,6
	brlo loop ; I < 6 => переход

; задержка
	ldi	r30, 0x23	; 35
	ldi	r31, 0xF4	; 244
delay:
	sbiw r30, 0x01	; вычиаем из слова(r31:r30)
	brne delay


rjmp loop
