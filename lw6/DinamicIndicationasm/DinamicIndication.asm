.def number_high = r16
.def number_low = r17
.def ones = r18
.def hundreds = r19
.def thousands = r20
.def temp = r21

.org 0x0000
    rjmp start

.org 0x0040
start:
    ldi number_high, 0x0d   ; устанавливаем старший байт числа в 10000
    ldi number_low, 0xd5    ; устанавливаем младший байт числа в 10000

loop:
    ; вычисление единиц
    ldi ones, 0     ; устанавливаем начальное значение разряда единиц
    mov ones, number_low  ; загружаем младший байт числа в регистр разряда единиц
    lsr ones        ; сдвигаем вправо, чтобы получить значение единиц
    andi ones, 0b00001111  ; маскируем старшие биты, чтобы получить значение единиц

    ; вычисление сотен
    ldi hundreds, 0     ; устанавливаем начальное значение разряда сотен
    mov hundreds, number_high  ; загружаем старший байт числа в регистр разряда сотен
    lsl hundreds      ; сдвигаем влево, чтобы получить значение сотен
    swap hundreds     ; меняем местами полубайты, чтобы получить значение сотен
    lsr hundreds      ; сдвигаем вправо, чтобы получить значение сотен

    ; вычисление тысяч
    ldi thousands, 0     ; устанавливаем начальное значение разряда тысяч
    ldi temp, 0
    ; проверяем старший байт числа, если он больше 0, то значение тысяч равно 10, иначе 0
    cp number_high, temp
    brge thousands_eq_10
    rjmp thousands_done
thousands_eq_10:
    ldi temp, 10
    mov thousands, temp

    ; ваш код здесь

thousands_done:
    ; код завершения программы
    rjmp done

done:
    ; код завершения программы
	nop
    rjmp loop