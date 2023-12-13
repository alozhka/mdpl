﻿#define F_CPU 1000000UL

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
volatile uint8_t counter = 0;
volatile uint8_t state = 0;
volatile uint8_t bcd_buffer[] = { 0, 0 };

void InitPorts(void);
void Bin2Dec(uint8_t data);
void InitTimer1(void);
void StartTimer1(void);
void StopTimer1(void);
void SendData(uint8_t data);
void DisplayData(uint8_t data);

int main(void)
{
	InitPorts();
	InitTimer1();
	DisplayData(0);
	while(1)
	{
	}
}

//--------------------------------------------
ISR(TIMER1_COMPA_vect)
{
	DisplayData(counter);
	counter++;
	if (counter == 100)
	{
		counter = 0;
	}
}
ISR(INT0_vect)
{
	if(state == 0)
	{
		state = 1;
		StartTimer1();
	}
	else
	{
		StopTimer1();
		DisplayData(counter);
		state = 0;
		counter = 0;
	}
}
//--------------------------------------------
void InitPorts(void)
{
	DDRB = (1 << PINB0 | 1 << PINB1 | 1 << PINB3 | 1 << PINB5);
	DDRD &= ~(1 << PIND2);
	PORTD |= (1 << PIND2);
	EIMSK |= (1 << INT0); //разрешить прерывание INT0
	EICRA |= (1 << ISC01);//Запуск по заднему фронту INT0
	sei(); //Разрешение прерываний
	PORTB &= ~(1 << PINB0); //OE = low (active)
}

void InitTimer1(void)
{
	TCCR1A = 0;
	TCCR1B = (1 << CS11 | 1 << CS10 | 1 << WGM12);
	TCNT1 = 0;
	OCR1A = 15624;
}

void StartTimer1(void)
{
	TCNT1 = 0;
	TIMSK1 |= (1 << OCIE1A);
}

void StopTimer1(void)
{
	TIMSK1 &= ~(1 << OCIE1A);
}

void Bin2Dec(uint8_t data)
{
	bcd_buffer[0] = data / 10;
	bcd_buffer[1] = data % 10;
}

void SendData(uint8_t data)
{
	for(uint8_t i = 1; i < 9; i++)
	{
		PORTB &= ~(1 << PINB5); //CLK = 0
		if(0x80 & (data << i))
		{
			PORTB |= 1 << PINB3; //DAT high
		}
		else
		{
			PORTB &= ~(1 << PINB3); //DAT low
		}
		PORTB |= (1 << PINB5); //CLK = 1
	}
}

void DisplayData(uint8_t data)
{
	Bin2Dec(data);
	PORTB &= ~(1 << PINB1); // le = 0
	SendData(segments[bcd_buffer[0]]);
	SendData(segments[bcd_buffer[1]]);
	PORTB |= (1 << PINB1); // le = 1
}
