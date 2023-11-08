#define F_CPU 1000000UL

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>


uint8_t segments[] =
{
	0b00111111, // 0 - A, B, C, D, E, F
	0b00000110, // 1 - B, C
	0b01011011, // 2 - A, B, D, E, G
	0b01001111, // 3 - A, B, C, D, G
	0b01100110, // 4 - B, C, F, G
	0b01101101, // 5 - A, C, D, F, G
	0b01111101, // 6 - A, C, D, E, F, G
	0b00000111, // 7 - A, B, C
	0b01111111, // 8 - A, B, C, D, E, F, G
	0b01101111, // 9 - A, B, C, D, F, G
};
volatile int is_button_pressed = 0;
volatile int counter = 0;

ISR(INT0_vect)
{
	if(is_button_pressed == 0)
	{
		is_button_pressed = 1;
	}
	else
	{
		is_button_pressed = 0;
		counter = 0;
	}
}


void setup()
{
	DDRB = 0xFF;
	PORTD |= (1<<PD2);
	EIMSK |= (1<<INT0);
	EICRA |= (1<<ISC01);
	sei();
}

int main(void)
{
	setup();
	while(1)
	{
		if(is_button_pressed == 0)
		{
			if(counter >= 10)
			{
				counter = 0;
			}
			PORTB = segments[counter++];
			_delay_ms(1000);
		}
	}
}