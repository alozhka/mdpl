.equ arr_size = 10

.def timer_temp = r16
.def counter = r17
.def temp = r18
.def num_items = r19
.def adapted_counter = r20
.def iter = r21
.def state = r23
.def data = r24


.dseg

segments: .BYTE arr_size


.cseg

.org 0x0000
rjmp main

.org INT0addr
rjmp button_interrupt

.org 0x0016 ; TIMER1 COMPA
rjmp timer_interrupt


reset:
	rjmp main
main:
	rcall copy_to_mapped
	rcall setup

	rcall display_data
loop:
	nop
rjmp loop



.cseg
segments_flash: .db 0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110, 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01101111


start_timer:
	ldi timer_temp,0
	sts 0x84,timer_temp ; TCNT1 = 0
	lds timer_temp,TIMSK1
	ori timer_temp,2
	sts TIMSK1,timer_temp ; TIMSK1 |= (1 << OCIE1A);
ret

stop_timer:
	lds timer_temp,TIMSK1
	andi timer_temp,0b11111011 ; 2 бит в ноль
	sts TIMSK1,timer_temp ; TIMSK1 |= (1 << OCIE1A);
ret


;; interrupts ;;


button_interrupt:
	cpi state,0
	brne else_stop
		ldi state,1
		rcall start_timer
		rjmp button_interrupt_exit

	else_stop:
		rcall stop_timer
		rcall display_data
		ldi state,0
		ldi counter,0

	button_interrupt_exit:
reti

timer_interrupt:
	inc counter
	cpi counter,100
	brlo skip_setter
	ldi counter,0

	skip_setter:
	rcall display_data

reti


;; display data ;;


display_data:
	cbi PORTB,1 ; le = 0

	rcall find_dozens
	rcall get_number_from_array
	rcall program_spi

	rcall find_digits
	rcall get_number_from_array
	rcall program_spi

	sbi PORTB,1 ; le = 1
ret


find_dozens:
		mov adapted_counter,counter
		clr r22
	dozens_loop:
		cpi adapted_counter,10
		brlo find_dozens_finish

		subi adapted_counter,10
		inc r22
	rjmp dozens_loop

	find_dozens_finish:
	mov adapted_counter,r22
ret


find_digits:
		mov adapted_counter,counter
	digits_loop:
		cpi adapted_counter,10
		brlo find_digits_finish ; переход если < 10
		subi adapted_counter,10
	rjmp digits_loop

	find_digits_finish:
ret

get_number_from_array:
	; установка по индексу
		add YL,adapted_counter
		adc YH,temp
		; получили сегмент
		ld data,Y
		; возвращение указателя обратно
		sub YL,adapted_counter
		sbc YH,temp
ret

program_spi:
	ldi iter,9
	program_spi_loop:
		cbi PORTB,5	; clk = 0

		sbrs data,7
		cbi PORTB,3

		sbrc data,7
		sbi PORTB,3

		sbi PORTB,5	; clk = 1

		lsl data
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
	; установка
	ldi temp,0b11101000
	out DDRB,temp
	sbi PORTB,0
	cbi DDRD,2
	sbi PORTD,2

	; найстройка прерываний
	sbi EIMSK,INT0
	lds r24,EICRA
	ori r24,0x02
	sts EICRA,r24
	sei

	; настройка таймера
	ldi temp,0
	out TCCR0A,temp
	sts 0x84,temp ; TCNT1 = 0
	ldi temp, 0b00001011
	sts TCCR1B,temp ; TCCR1B = 0b0001011
	ldi	temp, 0x3D	;
	sts	0x89, temp	;
	ldi	temp, 0x08	;
	sts	0x88, temp	; OCR0A = 15625

	; настройка указателя
	ldi YH,High(segments)
	ldi YL,Low(segments)
	ldi temp,0
ret
