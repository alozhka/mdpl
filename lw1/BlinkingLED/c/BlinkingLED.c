#define F_CPU 1000000UL
#include <avr/io.h>
#include <util/delay.h>

int main(void)
{
	DDRC |= (1 << PORTC0);

	int dir = 1;
	while (1)
	{
		if (dir)
		{
			PORTC |= (1 << PORTC0);
			dir = 0;
		}
		else
		{
			PORTC &= ~(1 << PORTC0);
			dir = 1;
		}
		_delay_ms(250);
	}
}

