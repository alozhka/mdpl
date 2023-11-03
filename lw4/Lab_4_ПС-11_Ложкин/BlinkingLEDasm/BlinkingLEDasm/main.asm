;
; BlinkingLEDasm.asm
;
; Created: 03.11.2023 18:00:59
; Author : Сергей
;

main:
    ;setup
	sbi DDRC,0

loop:
	sbi PORTC,0

	;delay setup
	ldi r17,0
	ldi r18,53
	ldi r19,12
delay_loop1:
	subi r17,1
	sbci r18,0
	sbci r19,0
	brne delay_loop1

	cbi PORTC,0
	;delay setup
	ldi r17,0
	ldi r18,53 
	ldi r19,12
delay_loop2:
	subi r17,1
	sbci r18,0
	sbci r19,0
	brne delay_loop2


rjmp loop
