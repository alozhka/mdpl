#define F_CPU 1000000UL

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


uint8_t segments[] = 
{
	// GFEDCBA
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
volatile uint8_t bcd_buffer[] = { 0, 0, 0, 0 };
volatile uint16_t display_val = 0;
volatile uint8_t input_char_counter = 0;
volatile char command[10] = "";
volatile char* commandPtr = command;
volatile uint8_t selectADC = 0;
volatile uint8_t ADC_buffer[] = { 0, 0, 0, 0 };


void InitPorts();
void InitTimer1();
void Bin2Dec(uint16_t data);
void SendData(uint8_t data);
void DisplayData(uint16_t data);
void InitSPI();
void InitADC();
void InitUSART();
void SendChar(char symbol);
void SendString(volatile char* buffer);

void clearCommand();
void handleCommand(volatile const char* command);

char* getSubstring(volatile const char* str, int startIndex, int length);
void ADCbin2Dec(volatile uint16_t data);
void setADC0();
void setADC1();


int main()
{
	InitPorts();
	InitSPI();
	InitTimer1();
	EIMSK |= (1 << INT0);
	EICRA |= (1 << ISC01);
	InitADC();
	InitUSART();
	sei();
	PORTB &= ~(1 << PINB0); //OE = low (active)
	DisplayData(0);
	SendString("Welcome to terminal!\r\n");
	while(1)
	{
		DisplayData(display_val);
	}
}

//--------------------------------------------

ISR(TIMER1_COMPB_vect)
{
}

ISR(INT0_vect)
{
	SendString("Value = ");
	SendChar(0x30 + bcd_buffer[3]);
	SendChar(0x30 + bcd_buffer[2]);
	SendChar(0x30 + bcd_buffer[1]);
	SendChar(0x30 + bcd_buffer[0]);
	SendString("\r\n");
}

ISR(ADC_vect)
{
	ADCbin2Dec(ADC);
}

ISR(USART_RX_vect)
{
	uint8_t reseivedData = UDR0;
	input_char_counter++;
	
	
	if (reseivedData == 0x0D)
	{
		SendString("\r\n");
		handleCommand(command);
		clearCommand();
	}
	else if (reseivedData == 0x08)
	{
		input_char_counter--;
		commandPtr--;
		SendChar(0x08);
	}
	else if (input_char_counter == 11)
	{
		SendString("\r\nMax string length must be less than 11 characters!\r\n");
		clearCommand();
	}
	else
	{
		SendChar(reseivedData); //echo
		*commandPtr++ = reseivedData;
	}
}

void clearCommand()
{
	input_char_counter = 0;
	memset(command, 0, sizeof(command));
	commandPtr = command;
}

void handleCommand(volatile const char command[])
{
	if (strcmp(getSubstring(command, 0, 4), "set ") == 0) //set data to register
	{
		display_val = atoi(getSubstring(command, 4, 4));
		
		/*
		int data = atoi(getSubstring(command, 4, 6));
		if (data < 9999)
		{
			SendString("Set value must be less than 10000!\r\n");
		}
		else
		{
			display_val = atoi(getSubstring(command, 4, 4));
		}
		*/
	}
	
	if (strcmp(getSubstring(command, 0, 7), "select ") == 0)
	{
		selectADC = atoi(getSubstring(command, 7, 1));
		switch(selectADC)
		{
			case 0:
				setADC0();
				SendString("Selected ADC: ");
				SendString(getSubstring(command, 7, 1));
				SendString("\r\n");
				break;
			case 1:
				setADC1();
				SendString("Selected ADC: ");
				SendString(getSubstring(command, 7, 1));
				SendString("\r\n");
				break;
			default:
				SendString("Invalid number of ADC!\r\n");
		}
		
	}
	
	if (strcmp(getSubstring(command, 0, 7), "showADC") == 0)
	{
		SendString("Value of ADC ");
		SendChar('0' + selectADC);
		SendString(" = ");
		SendChar('0' + ADC_buffer[0]);
		SendChar('0' + ADC_buffer[1]);
		SendChar('0' + ADC_buffer[2]);
		SendChar('0' + ADC_buffer[3]);
		SendString("\r\n");
	}
}

char* getSubstring(volatile const char* str, int startIndex, int length)
{
	char* sub = (char*) malloc(length + 1); // Выделяем память для подстроки плюс один символ для завершающего нуля
	if (sub == NULL) 
	{
		return NULL; // Проверка на случай неудачного выделения памяти
	}

	strncpy(sub, &str[startIndex], length); // Копируем нужное количество символов из строки
	sub[length] = '\0'; // Добавляем завершающий нуль-символ

	return sub;
}

//--------------------------------------------

void ADCbin2Dec(volatile uint16_t data)
{
	ADC_buffer[3] = (uint8_t)(data / 1000);
	data = data % 1000;
	ADC_buffer[2] = (uint8_t)(data / 100);
	data = data % 100;
	ADC_buffer[1] = (uint8_t)(data / 10);
	data = data % 10;
	ADC_buffer[0] = (uint8_t) data;
}

void Bin2Dec(uint16_t data)
{
	bcd_buffer[3] = (uint8_t)(data / 1000);
	data = data % 1000;
	bcd_buffer[2] = (uint8_t)(data / 100);
	data = data % 100;
	bcd_buffer[1] = (uint8_t)(data / 10);
	data = data % 10;
	bcd_buffer[0] = (uint8_t) data;
}

void SendChar(char symbol)
{
	while (!(UCSR0A & (1 << UDRE0)));
	UDR0 = symbol;
}

void SendString(volatile char * buffer)
{
	while(*buffer != 0)
	{
		SendChar(*buffer++);
	}
}

void SendData (uint8_t data)
{
	SPDR = data;
	while(!(SPSR & (1 << SPIF)));
}

void DisplayData (uint16_t data)
{
	Bin2Dec(data);
	PORTB &= ~(1 << PINB1);
	//clk_out = 0
	SendData(segments[bcd_buffer[0]]);
	SendData(segments[bcd_buffer[1]]);
	SendData(segments[bcd_buffer[2]]);
	SendData(segments[bcd_buffer[3]]);
	PORTB |= (1 << PINB1);
	//clk_out = 1
}

//--------------------------------------------

void InitPorts()
{
	DDRB = (1 << PINB0 | 1 << PINB1 | 1 << PINB3 | 1 << PINB5);
	DDRD = (0 << PIND2);
	PORTD |= (1 << PIND2);
}

void InitTimer1()
{
	TCCR1A = 0;
	//CTC mode - Clear Timer on Compare
	//prescaler = sys_clk / 64
	TCCR1B = (1 << CS11 | 1 << CS10 | 1 << WGM12);
	TCNT1 = 0;
	//start value of counter
	TIMSK1 |= (1 << OCIE1B);
	OCR1A = 1562;
	OCR1B = 1562;
}

void InitSPI()
{
	DDRB |= (1 << PINB3 | 1 << PINB5);//configure MOSI and CLK as out
	SPSR |= (1 << SPI2X); //Fclk = Fosc/2
	//SPI enable, master mode, MSB first, CPOL = 0, CPHA = 0
	SPCR = (1 << SPE | 1 << MSTR);
	//init values - DAT low, CLK low
	PORTB &= ~(1 << PINB3 | 1 << PINB5);
}

void setADC0()
{
	ADMUX = 0;
}
void setADC1()
{
	ADMUX = (1 << MUX0);
}

void InitADC()
{
	ADMUX = (1 << MUX0); //Align left, ADC1
	ADCSRB = (1 << ADTS2 | 1 << ADTS0); //Start on Timer1 COMPB
	//Enable, auto update, IRQ enable
	ADCSRA = (1 << ADEN | 1 << ADATE | 1 << ADIE);
}

void InitUSART()
{
	UCSR0B = (1 << RXEN0 | 1 << TXEN0 | 1 << RXCIE0);
	UCSR0C = (1 << UCSZ01 | 1 << UCSZ00);
	UBRR0H = 0;
	UBRR0L = 0x0C;
}
