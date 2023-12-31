#define F_CPU 16000000UL

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include <stdint.h>


/**
Режимы работы:
0. Накопление слева направо
1. Накопление в центр
2. Уменьшение налево
*/
volatile uint8_t state = 0;
volatile uint8_t i = 0;
volatile uint8_t off_lights_counter = 18;

volatile uint32_t garland_value = 0;


void reset_garland()
{
	garland_value = 0;
	PORTB &= 0b11000000;
	PORTC &= 0b11000000;
	PORTD &= 0b11000100;
}
void fill_garland()
{
	garland_value = 0xFFFFF;
	PORTB |= 0b00111111;
	PORTC |= 0b00111111;
	PORTD |= 0b01111111;
}
void draw_garland()
{
	PORTB = garland_value & 0b00111111;
	PORTC = (garland_value >> 6) & 0b00111111;
	
	int temp = (garland_value >> 12) & 0b00111111;
	PORTD = ((temp & 0b11111100) << 1) | (1 << PIND2) | (temp & 0b00000011);
	
}

void generate_accumulation_to_right()
{
	garland_value &= ~(1ul << (i - 1));	// убираю предыдущий
	garland_value |= (1ul << i);		// рисую текущий
	
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
}

void generate_accumulation_to_center()
{
	//
	// правая сторона
	//
	garland_value &= ~(0x20000 >> (i - 1)); // 1 на 17 бите
	garland_value |= (0x20000 >> i);
	//
	// левая сторона
	//
	garland_value &= ~(1ul << (i - 1));
	garland_value |= (1ul << i);
	
	
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
}

void generate_decreasing_to_left()
{
	garland_value |= (0x20000 >> (i - 1));
	garland_value &= ~(0x20000 >> i); // 0b10000000
	
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
}

ISR(INT0_vect)
{
	i = 0;
	off_lights_counter = 18;
	reset_garland();
	
	
	state++;
	if(state == 3) 
		state = 0;
	if (state == 2) fill_garland();
}

void setup(void)
{
	DDRB = 0b00111111;	// все 6
	DDRC = 0b00111111;	// + 6
	DDRD = 0b01111011;	// PIND2 на прерывание по изменению состояения и ещё 6 на гирлянду
	
	PORTD |= (1 << PIND2);
	
	EIMSK |= (1 << INT0);
	EICRA |= (1 << ISC01);
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
				generate_accumulation_to_right();
				break;
			case 1:
				generate_accumulation_to_center();
				break;
			case 2:
				generate_decreasing_to_left();
		}
		draw_garland();
		_delay_ms(200);
	}
}

