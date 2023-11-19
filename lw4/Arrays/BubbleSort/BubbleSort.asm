.set ARR_SIZE = 10

.def TEMP = r16
.def COUNT_NEGATIVE_NUMS = r17
.def NUM_ITEMS = r18
.def HAS_SWAP = r19
.def LEFT_WORD_L = r20
.def LEFT_WORD_H = r21
.def RIGHT_WORD_L = r22
.def RIGHT_WORD_H = r23

.dseg
arr: .BYTE ARR_SIZE

.cseg

reset:
	rjmp main
main:
	ldi ZH,High(src * 2)
	ldi ZL,Low(src * 2)
	ldi YH,High(arr)
	ldi YL,Low(arr)
	ldi NUM_ITEMS,ARR_SIZE	
arr_copy:
	lpm r0,Z+
	lpm r1,Z+
	st Y+,r0
	st Y+,r1
	subi NUM_ITEMS,1
	brne arr_copy


loop:
	ldi HAS_SWAP,0
	ldi NUM_ITEMS,ARR_SIZE - 1 ; нам не надо доходить ровно до последнего элемента
	cpi NUM_ITEMS,1 ; выходим, если количество смежных пар < 1
	brlo exit

	; загрузка начальных значений
	ldi YH,High(arr)
	ldi YL,Low(arr)
	; загрузка следующего элемента в массиве
	ldi ZH,High(arr + 2)
	ldi ZL,Low(arr + 2)
	

	load_words:
		ldi COUNT_NEGATIVE_NUMS,0
		; загрузка данных
		ld LEFT_WORD_L,Y+
		ld LEFT_WORD_H,Y+
		ld RIGHT_WORD_L,Z+
		ld RIGHT_WORD_H,Z+

	; считаем количество отрицательных чисел
		sbrc LEFT_WORD_H,7
		inc COUNT_NEGATIVE_NUMS
		sbrc RIGHT_WORD_H,7
		inc COUNT_NEGATIVE_NUMS

		cpi COUNT_NEGATIVE_NUMS,1
		; переход, если оба >=0 или оба < 0
		brne common_comparison

	; сравнение при одном числе < 0
		cp RIGHT_WORD_H,LEFT_WORD_H ; сравниваем со знаком
		brlt swap_words
		rjmp continue


	common_comparison:
	; обычное сравнение (оба >= 0 или оба < 0)
		cp RIGHT_WORD_H,LEFT_WORD_H ; сравниваем со знаком
		brlt swap_words
		brne continue
		cp RIGHT_WORD_L,LEFT_WORD_L ; сравниваем без знака (так как в младшем байте знак числа не учитывается)
		brlo swap_words

	continue:
		; делаем, пока всех не пройдём все смежные пары
		dec NUM_ITEMS
		brne load_words

		;  после прохода по всему массиву проверяем, были ли перестановки
		cpi HAS_SWAP,1
		breq loop
		; если нет, то завершаем
		brne exit

	; перестановки слов
	swap_words:
		ldi HAS_SWAP,1
		; перемещаем указатель на текущие элементы
		sbiw Y,2
		sbiw Z,2
		; загружаем в ОЗУ, меняя местами
		st Z+,LEFT_WORD_L
		st Z+,LEFT_WORD_H
		st Y+,RIGHT_WORD_L
		st Y+,RIGHT_WORD_H
		rjmp continue

rjmp loop

exit:
	nop
	rjmp exit

.cseg
src: .dw   14, -1, -16384, -12, 10213, -7,-4097, 0, 6544, 3