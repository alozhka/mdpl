#define F_CPU 1000000UL

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>


/**
Режимы работы:
0. Накопление слева направо
1. Накопление вцентр
2. Накопление рандомное
*/
volatile int state = 2;
volatile int i = 0;
volatile int off_lights_counter = 18;


void reset_garland()
{
	PORTB = 0;
	PORTC = 0;
	PORTD = (1 << PIND2);
}
void fill_garland()
{
	PORTB = 0xFF;
	PORTC = 0xFF;
	PORTD = 0b11111100;
}

void draw_accumulation_to_right()
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
	
	if((14 <= i) && (i <= 17))
	{
		PORTD &= ~(1 << (i - 10 - 1));	// с пина 4 по пин 7
		PORTD |= (1 << (i - 10));
	}
	
	i++;
	if(off_lights_counter == 0)
	{
		i = 0;
		off_lights_counter = 18;
		reset_garland();
	}
	if(i == off_lights_counter)
	{
		i = 0;
		off_lights_counter--;
	}
	_delay_ms(250);
}

void draw_accumulation_to_center()
{
	//
	// правая сторона
	//
	if ((0 <= i) & (i <= 3))
	{
		PORTD &= ~(0x80 >> (i - 1)); // 0b10000000
		PORTD |= (0x80 >> i);
	}
	if (i == 4) PORTD &= ~(1 << PIND4);
	
	if((4 <= i) & (i <= 8))
	{
		PORTC &= ~(0x20 >> (i - 4 - 1)); // 0b00100000
		PORTC |= (0x20 >> (i - 4));
	}
	
	//
	// левая сторона
	//
	if((0 <= i) & (i <= 7))
	{
		PORTB &= ~(1 << (i - 1)); // 0b00100000
		PORTB |= (1 << i);
	}
	if (i == 8)
	{
		PORTB &= ~(1 << PINB7);
		PORTC |= (1 << PINC0);
	}
	
	
	i++;
	if (off_lights_counter == 0)
	{
		i = 0;
		off_lights_counter = 18;
		reset_garland();
	}
	if (i == off_lights_counter / 2)
	{
		i = 0;
		off_lights_counter -= 2;
	}
	_delay_ms(250);
}

void draw_decreasing_to_left()
{
	if ((0 <= i) & (i <= 3))
	{
		PORTD |= (0x80 >> (i - 1));
		PORTD &= ~(0x80 >> i); // 0b10000000
	}
	if(i == 4) PORTD |= (1 << PIND4);
	if ((4 <= i) & (i <= 9))
	{
		PORTC |= (0x20 >> (i - 4 - 1));
		PORTC &= ~(0x20 >> (i - 4)); // 0b0010000
	}
	if (i == 10) PORTC |= (1 << PINC0);
	if ((10 <= i) & (i <= 17))
	{
		PORTB |= (0x80 >> (i - 10 - 1));
		PORTB &= ~(0x80 >> (i - 10)); // 0b10000000
	}
	
	i++;
	if(off_lights_counter == 0)
	{
		i = 0;
		off_lights_counter = 18;
		fill_garland();
	}
	if(i == off_lights_counter)
	{
		i = 0;
		off_lights_counter--;
	}
	_delay_ms(250);
	
}

ISR(INT0_vect)
{
	i = 0;
	off_lights_counter = 18;
	PORTB = 0;
	PORTC = 0;
	PORTD = (1 << PIND2);
	
	
	state++;
	if(state == 3) 
		state = 0;
	if (state == 2)
		fill_garland();
}

void setup(void)
{
	DDRB = 0xFF;		// все 8
	DDRC = 0b01111111;	// + 6
	DDRD = 0b11111100;	// PIND3 на прерывание по изменению состояения, оставшиеся 4 на гирлянду
	
	PORTD |= (1 << PIND2);
	
	EIMSK |= (1 << INT0);
	EICRA |= (1 << ISC01);
	sei();
}

int main(void)
{
	setup();
	PORTB = 0xff;
	PORTC = 0xff;
	PORTD = 0xff;
	
	while (1)
	{
		switch (state)
		{
			case 0:
				draw_accumulation_to_right();
				break;
			case 1:
				draw_accumulation_to_center();
				break;
			case 2:
				draw_decreasing_to_left();
		}
	}
}

