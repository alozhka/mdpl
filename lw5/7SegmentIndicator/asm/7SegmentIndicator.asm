setup:
    ldi r16,0xFF
	out	DDRB,r16    ; весь DDRB на выход
	
	ldi	r16, 0b00000001	; 1 (1 << 0)
  	ldi	r17, 0b00000010	; 2 (1 << 1)
   	ldi	r18, 0b00000100	; 4 (1 << 2)
  	ldi	r19, 0b00001000	; 8 (1 << 3)
 	ldi	r20, 0b00010000	; 16(1 << 4)
  	ldi	r21, 0b00100000	; 32(1 << 5)


main:
  	out	PORTB, r16	; PORTB (1 << 0)
	//задержка
	ldi	r30, 0x23	; 35
	ldi	r31, 0xF4	; 244
delay1:
	sbiw r30, 0x01	; вычиаем сразу их двух
	brne delay1


 	out	PORTB,r17	; PORTB (1 << 1)
	//задержка
	ldi	r30, 0x23	; 35
	ldi	r31, 0xF4	; 244
delay2:
	sbiw r30, 0x01	; вычиаем сразу их двух
	brne delay2


	out	PORTB,r18	; PORTB (1 << 2)
	//задержка
	ldi	r30, 0x23	; 35
	ldi	r31, 0xF4	; 244
delay3:
	sbiw r30, 0x01	; вычиаем сразу их двух
	brne delay3


	out	PORTB,r19	; PORTB (1 << 3)
	//задержка
	ldi	r30, 0x23	; 35
	ldi	r31, 0xF4	; 244
delay4:
	sbiw r30, 0x01	; вычиаем сразу их двух
	brne delay4


	out	PORTB,r20	; PORTB (1 << 4)
	//задержка
	ldi	r30, 0x23	; 35
	ldi	r31, 0xF4	; 244
delay5:
	sbiw r30, 0x01	; вычиаем сразу их двух
	brne delay5


	out	PORTB,r21	; PORTB (1 << 5)
	//задержка
	ldi	r30, 0x23	; 35
	ldi	r31, 0xF4	; 244
delay6:
	sbiw r30, 0x01	; вычиаем сразу их двух
	brne delay6


rjmp main
