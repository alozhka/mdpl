reset:
	rjmp main

main:
	ldi r16, 0xff
	out DDRB, r16
loop:
	in r15, PINB
	inc r15
	out PORTB, r15
rjmp loop
