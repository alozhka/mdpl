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
		PORTB = (1 << i);
	}
	else
	{
		PORTB = 0;
	}
	
	
	if ((8 <= i) & (i <= 13))
	{
		PORTC = (1 << (i - 8));
	}
	else
	{
		PORTC = 0;
	}
	
	
	if ((14 <= i) & (i <= 16))
	{
		if ((14 <= off_lights_counter) & (off_lights_counter <= 16))
		{
			PORTD |= (1 << (i - 14)) | (1 << PIND3);
		}
		else
		{
			PORTD = (1 << (i - 14)) | (1 << PIND3);
		}
	}
	if (i == 17)
	{
		if(off_lights_counter == 18)
		{
			PORTD = (1 << PIND4) | (1 << PIND3);
		}
		else
		{
			PORTD |= (1 << PIND4);
		}
	}
	
	
	i++;
	if(i == off_lights_counter)
	{
		 i = 0;
		 off_lights_counter--;
	}
	if(off_lights_counter == 0) off_lights_counter = 18;
	_delay_ms(250);
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

