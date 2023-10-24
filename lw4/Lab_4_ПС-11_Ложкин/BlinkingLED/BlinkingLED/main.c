/*
 * BlinkingLED.c
 *
 * Created: 24.10.2023 22:25:29
 * Author : Сергей
 */ 

#include <avr/io.h>
#define F_CPU 16000000

#include <util/delay.h>


int main(void)
{
	DDRC |= (1 << PORTC0);
    while (1) 
    {
		PORTC |= (1 << PORTC0);
		_delay_ms(250);
		PORTC &= ~(1 << PORTC0);
		_delay_ms(250);
	}
}

