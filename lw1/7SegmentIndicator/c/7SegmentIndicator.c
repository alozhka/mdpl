#define F_CPU 1000000UL
#include <avr/io.h>
#include <util/delay.h>

int main(void)
{
	DDRB = 0xFF;
	while(1)
	{
		PORTB = (1 << 0);
		_delay_ms(250);
		PORTB = (1 << 1);
		_delay_ms(250);
		PORTB = (1 << 2);
		_delay_ms(250);
		PORTB = (1 << 3);
		_delay_ms(250);
		PORTB = (1 << 4);
		_delay_ms(250);
		PORTB = (1 << 5);
		_delay_ms(250);
	}
}

