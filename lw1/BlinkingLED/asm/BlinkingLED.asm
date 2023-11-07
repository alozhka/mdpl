main:
	//setup
	sbi DDRC,0
	ldi r24,1

loop:
	eor r24,r24
	//if
	breq clear_bit
	//then
	sbi PORTC,0
	rjmp delay
	//
clear_bit:
	//else
	cbi PORTC,0

delay:
	ldi r17,0
	ldi r18,53
	ldi r19,12
delay_loop:
	subi r17,1
	sbci r18,0
	sbci r19,0
	brne delay_loop

rjmp loop
