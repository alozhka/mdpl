#include <avr/io.h>

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
volatile uint16_t cnt = 0;
volatile uint8_t switch_state = 0;
volatile uint8_t bcd_buffer[] = { 0, 0, 0, 0 };


void initSPI(void)
{
	DDRB |= (1 << PINB0 | 1 << PINB1 | 1 << PINB3 | 1 << PINB5);//настроить MOSI и CLK как выходы
	SPSR |= (1 << SPI2X);
	SPCR = (1 << SPE | 1 << MSTR); //SPI включен, мастер, MSB первый, CPOL=0, CPHA=0
	PORTB &= ~(1 << PINB3 | 1 << PINB5); //инициализация: DAT=0, CLK=0
	PORTB |= 1 << PINB0; // OE = 1
}

void sendSPI (uint8_t data)
{
	SPDR = data;
	while(!(SPSR & (1 << SPIF)));
}

void setup(void)
{
	initSPI();
}


int main(void)
{
	setup();
	PORTB &= ~(1 << PINB0);
	PORTB |= 1 << PINB1;
	sendSPI(segments[0]);
	PORTB &= ~(1 << PINB1);
	PORTB |= (1 << PINB0);
	
    while (1) 
    {
    }
}

