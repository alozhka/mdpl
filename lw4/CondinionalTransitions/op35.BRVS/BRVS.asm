setup:
	nop
loop:
	; ����
	in r18,OCR0A
	in r19,OCR0B
	; ��������� ������
	add r18,r19
	brvs overflow_is_setted
	; overflow is not setted
	ldi r18,0
	rjmp output

overflow_is_setted:
	ldi r18,1
	; ����������, ����� ���� ���������� ���������� ������
	; � ��� V==0 � ��� V==1
	nop

output:
	out OCR0A,r18

rjmp loop