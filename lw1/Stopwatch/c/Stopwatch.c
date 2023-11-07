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
volatile int counterC = 0;
volatile int counterB = 0;


void reset_timer()
{
	PORTB = segments[0];
	PORTC = segments[0];
	PORTD &= ~(1 << PIND3);
}

ISR(INT0_vect)
{
	counterB = 0;
	counterC = 0;
	reset_timer();
}

void draw_timer(int counterB, int counterC)
{
	PORTB = segments[counterB];
	PORTC = segments[counterC];
	int bit_to_set = segments[counterC] & 0b01000000; // маска для индикатора 7
	if(bit_to_set)
	{
		PORTD |= (1 << PIND3);
	}
	else
	{
		PORTD &= ~(1 << PIND3);
	}
}



void setup(void)
{
	DDRB = 0b01111111;
	DDRC = 0b11111111;
	DDRD = 0b00001100; // PIND3 & PIND2
	
	PORTD |= (1 << PIND2);
	
	EIMSK |= (1<<INT0);
	EICRA |= (1<<ISC01);
	sei();
}


int main(void)
{
	setup();
	
	while(1)
	{
		if(counterB == 10)
		{
			counterB = 0;
			counterC = 0;
		}
		if(counterC == 10)
		{
			counterB++;
			counterC = 0;
		}
		
		draw_timer(counterB, counterC);
		_delay_ms(1000);
		counterC++;
	}
}