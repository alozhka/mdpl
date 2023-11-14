setup:
	sbi DDRC,0
	ldi r16,1
	ldi r17,0

loop:
	or r16,r17
	; if
	breq clear_bit
	; then
	sbi PORTC,0
	ldi r16,0x00
	rjmp delay
	;
clear_bit:
	; else
	cbi PORTC,0
	ldi r16,0x01


delay:
	ldi	r30,35	; 35
	ldi	r31,244	; 244
delay_loop:
	sbiw	r30,1
	brne	delay_loop 	


rjmp loop
cli
