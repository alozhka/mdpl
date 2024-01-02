.equ arr_size = 10

.def comp_const_9999 = r1
.def comp_const_1000 = r2
.def zero = r3
.def buffer0 = r4
.def buffer1 = r5
.def buffer2 = r6
.def buffer3 = r7

.def counter_low = r24
.def counter_high = r25
.def counter_temp_low = r26
.def counter_temp_high = r27
.def timer_temp = r18
.def temp = r19
.def num_items = r20
.def adapted_counter = r21
.def iter = r22
.def state = r23


.dseg

segments: .BYTE arr_size


.cseg

.org 0x0000
rjmp reset

.org INT0addr
rjmp button_interrupt

.org 0x0016 ; TIMER1 COMPA
rjmp timer_interrupt

.org 0x0040

reset:
	rjmp main
main:
	rcall copy_to_mapped
	rcall setup

	rcall display_data
loop:
	nop
rjmp loop


start_timer:
	sts 0x84,zero ; TCNT1 = 0
	lds timer_temp,TIMSK1
	ori timer_temp,2
	sts TIMSK1,timer_temp ; TIMSK1 |= (1 << OCIE1A);
ret

stop_timer:
	lds timer_temp,TIMSK1
	andi timer_temp,0b11111101 ; 1 бит в ноль
	sts TIMSK1,timer_temp ; TIMSK1 |= (1 << OCIE1A);
ret


;; interrupts ;;


button_interrupt:
	cpi state,0
	brne else_stop
		ldi state,1
		ldi counter_low,0
		ldi counter_high,0
		rcall start_timer
		rjmp button_interrupt_exit

	else_stop:
		rcall stop_timer
		rcall display_data
		ldi state,0
		ldi counter_low,0
		ldi counter_high,0

	button_interrupt_exit:
reti

timer_interrupt:

	rcall display_data

	movw counter_temp_low,counter_low

	cpi counter_low,0x0F				; старший байт = 15
	cpc counter_high,comp_const_9999	; младший байт - 39 - C
	brcc timer_load_zero				; if (counter < 9999)

	adiw counter_low,1	; 16-битный счётчик + 1
	rjmp timer_finish

	timer_load_zero:

		ldi counter_low,0
		ldi counter_high,0

	timer_finish:
reti


;; display data ;;


display_data:

	movw counter_temp_low,counter_low	;	это соответсвует переменной data в ф-ии Bin2Dec

	cbi PORTB,1 ; le = 0

	rcall find_thousands
	rcall find_hundred
	rcall find_dozens

	mov buffer0,counter_temp_low

	mov adapted_counter,buffer0
	rcall get_number_from_array
	rcall program_spi

	mov adapted_counter,buffer1
	rcall get_number_from_array
	rcall program_spi

	mov adapted_counter,buffer2
	rcall get_number_from_array
	rcall program_spi

	mov adapted_counter,buffer3
	rcall get_number_from_array
	rcall program_spi

	sbi PORTB,1 ; le = 1
ret


find_thousands:

	ldi adapted_counter,0

	thousands_loop:

	cpi counter_temp_low,0xE9				;
	cpc counter_temp_high,comp_const_1000	; if(data > 1000)

	brcs find_thousands_finish ; переход если < 1000
		
		inc adapted_counter
		subi counter_temp_low,0xE8	;
		sbci counter_temp_high,0x03	; data - 1000
		rjmp thousands_loop

	find_thousands_finish:
	mov buffer3,adapted_counter
ret

find_hundred:
	ldi adapted_counter,0
	
	hundred_loop:
		cpi counter_temp_low,100
		cpc counter_temp_high,zero
		brcs find_hundred_finish

		inc adapted_counter
		subi counter_temp_low,100
		sbc counter_temp_high,zero
		rjmp hundred_loop

	find_hundred_finish:
	mov buffer2,adapted_counter
ret

find_dozens:
	ldi adapted_counter,0

	dozens_loop:
		cpi counter_temp_low,10
		brlo find_dozens_finish

		inc adapted_counter
		subi counter_temp_low,10
		rjmp dozens_loop

	find_dozens_finish:
	mov buffer1,adapted_counter

ret


get_number_from_array:
	; установка по индексу
		add YL,adapted_counter
		adc YH,zero
		; получили сегмент
		ld temp,Y
		; возвращение указателя обратно
		sub YL,adapted_counter
		sbc YH,zero
ret

program_spi:
	ldi iter,8
	program_spi_loop:

		cbi PORTB,5	; clk = 0

		sbrs temp,7
		cbi PORTB,3

		sbrc temp,7
		sbi PORTB,3

		sbi PORTB,5	; clk = 1

		lsl temp

		dec iter
	brne program_spi_loop
ret


;; setup ;;


copy_to_mapped:
	ldi ZH,High(segments_flash * 2)
	ldi ZL,Low(segments_flash * 2)
	ldi YH,High(segments)
	ldi YL,Low(segments)
	ldi num_items,arr_size
	arr_copy:
		lpm temp,Z+
		st Y+,temp
		subi num_items,1
		brne arr_copy
ret

setup:
	ldi temp,0
	mov zero,temp
	ldi temp,0x03				;
	mov comp_const_1000,temp	; для сравнения с 1000
	ldi temp,0x27
	mov comp_const_9999,temp
	; установка
	ldi temp,(1 << PINB5 | 1 << PINB3 | 1 << PINB1 | 1 << PINB0)
	out DDRB,temp
	cbi PORTB,PINB0
	cbi DDRD,PINB2
	sbi PORTD,PINB2

	; найстройка прерываний
	sbi EIMSK,INT0
	lds temp,EICRA
	ori temp,0x02
	sts EICRA,temp
	sei

	; настройка таймера
	ldi temp,0
	sts TCCR1A,temp
	ldi temp,(1 << CS11 | 1 << CS10 | 1 << WGM12)
	sts TCCR1B,temp
	ldi temp,0
	sts 0x84,temp ; TCNT1 = 0
	ldi	temp, 0x3D	;
	sts	0x89, temp	;
	ldi	temp, 0x08	;
	sts	0x88, temp	; OCR1A = 15625

	; настройка указателя
	ldi YH,High(segments)
	ldi YL,Low(segments)

	ldi temp,0
	ldi state,0

	ldi counter_low,0
	ldi counter_high,0
ret


segments_flash: .db 0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110, 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01101111
