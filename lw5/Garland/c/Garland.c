#define F_CPU 1000000UL

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

/**
Режимы работы:
1. Накопление
2.
3.
4.
5.
6.
7.
*/
volatile int state = 0;
volatile int i = 0;
volatile int off_lights_counter = 18;


ISR(INT1_vect)
{
	state++;
	if(state == 6) state = 0;
}


void draw_accumulation()
{
	if ((0 <= i) & (i <= 7))
	{
		PORTB &= ~(1 << (i - 1));	// очищаем предыдущий
		PORTB |= (1 << i);			// ставим текущий
	}
	if (i == 8) PORTB &= ~(1 << PINB7);
	
	if ((8 <= i) & (i <= 13))
	{
		PORTC &= ~(1 << (i - 8 - 1));	// очищаем предыдущий
		PORTC |= (1 << (i - 8));
	}
	if (i == 14) PORTC &= ~(1 << PINC5);
	
	if((14 <= i) && (i <= 16))
	{
		PORTD &= ~(1 << (i - 14 - 1));	// очищаем предыдущий
		PORTD |= (1 << (i - 14));
	}
	if (i == 17)
	{
		PORTD &= ~(1 << PIND2);
		PORTD |= (1 << PIND4);
	}
	
	
	i++;
	
	if(off_lights_counter == 0)
	{
		i = 0;
		PORTB = 0;
		PORTC = 0;
		PORTD = (1 << PIND3);
		off_lights_counter = 18;
	}
	if(i == off_lights_counter)
	{
		i = 0;
		off_lights_counter--;
	}
	_delay_ms(100);
}


void setup(void)
{
	DDRB = 0xFF;		// все 8
	DDRC = 0b01111111;	// + 6
	DDRD = 0b00011111;	// PIND2 на прерывание по изменению состояения, оставшиеся 4 на гирлянду
	
	PORTD |= (1 << PIND3);
	
	EIMSK |= (1 << INT1);
	EICRA |= (1 << ISC11);
	sei();
}


int main(void)
{
	setup();
	
	while (1)
	{
		switch (state)
		{
			case 0:
			draw_accumulation();
			break;
			case 1:
			PORTB = 0xFF;
			break;
		}
	}
}

