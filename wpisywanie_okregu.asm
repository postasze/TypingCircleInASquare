# projekt 1 MIPS
# zadanie 8: wspisywanie okregu w kwadrat

	.globl main
	.data
	
rozmiar:	.space 4	# calkowity rozmiar pliku bmp (ilosc bajtow)
szerokosc:	.space 4	# szerokosc tablicy pikseli (bez paddingu)
wysokosc:	.space 4	# wysokosc tablicy pikseli
offset:		.space 4	# offset - adres poczatku tablicy pikseli
bufor:		.space 4	# bufor wczytywania tymczasowych danych
srodek:		.space 4 	# srodek okregu
promien:	.space 4	# promien okregu
padding:	.space 4	# ilosc bajtow paddingowych w wierszu

start:		.asciiz	"Projekt 1 - wpisywanie okregu w kwadrat\n"
input:		.asciiz	"kwadrat80.bmp"
output:		.asciiz "out.bmp"
error:		.asciiz "Blad podczas otwierania pliku bmp\n"
		.text
		
main:	la $a0, start	# wypisywanie napisu powitalnego
	li $v0, 4
	syscall
	
wczytywanie_pliku:	# wczytujemy naglowek pliku bmp
	la $a0, input	
	li $a1, 0	# flaga otwarcia ustawiona na 0 aby moc czytac z pliku
	li $a2, 0	 
	li $v0, 13	# otwieranie pliku
	syscall		# w $v0 znajduje sie deskryptor pliku
	
	move $t0, $v0	# skopiowanie deskryptora pliku do rejestru t0
	
	bltz $t0, blad_otwarcia
	
	move $a0, $t0	# wczytujemy z pliku bmp pierwsze 2 bajty "BM"
	la $a1, bufor
	li $a2, 2	# wczytujemy 2 bajty
	li $v0, 14	# wczytywanie z pliku
	syscall		
	
	move $a0, $t0
	la $a1, rozmiar
	li $a2, 4	# wczytujemy 4 bajty
	li $v0, 14	# wczytywanie z pliku
	syscall		# wczytanie rozmiaru pliku do rozmiar
	
	lw $t7, rozmiar	# skopiowanie rozmiaru pliku do rejestru t7
	
	move $a0, $t7	# skopiowanie rozmiaru pliku do rejestru a0
	li $v0, 9
	syscall		# alokacja pamieci na bitmape
	move $t1, $v0	# skopiowanie adesu zaalokowanej pamieci do rejestru t1
	
	move $a0, $t0	# ponizej przeskakujemy 4 bajty zarezerwowane
	la $a1, bufor
	li $a2, 4
	li $v0, 14	# wczytywanie z pliku
	syscall
	
	move $a0, $t0
	la $a1, offset
	li $a2, 4	# wczytujemy 4 bajty offsetu
	li $v0, 14	# wczytywanie z pliku
	syscall
	
	move $a0, $t0	# ponizej przeskakujemy 4 bajty naglowka informacyjnego
	la $a1, bufor
	li $a2, 4	# wczytujemy 4 bajty
	li $v0, 14	# wczytywanie z pliku
	syscall
	
	move $a0, $t0	# skopiowanie deskryptora pliku do a0
	la $a1, szerokosc
	li $a2, 4	# wczytujemy 4 bajty
	li $v0, 14	# wczytywanie z pliku
	syscall
	
	lw $t2, szerokosc
	
	move $a0, $t0	# skopiowanie deskryptora do a0
	la $a1, wysokosc
	li $a2, 4	# wczytujemy 4 bajty
	li $v0, 14	# wczytywanie z pliku
	syscall
	
	lw $t3, wysokosc
	
	move $a0, $t0	# skopiowanie deskryptora pliku do a0
	li $v0, 16	# zamkniecie pliku
	syscall		# zamykamy plik zeby wskaznik czytania ustawil sie na poczatku
	
kopiowanie_pliku_do_pamieci:
	la $a0, input
	li $a1, 0	# flaga otwarcia ustawiona na 0 aby moc czytac z pliku
	li $a2, 0
	li $v0, 13	# otwieranie pliku
	syscall		# w $v0 znajduje sie deskryptor pliku
	
	move $t0, $v0	# skopiowanie deskryptora do rejestru t0
	
	bltz $t0, blad_otwarcia	# przeskocz do blad_otwarcia jesli wczytywanie sie nie powiodlo
	
	move $a0, $t0
	la $a1, ($t1)	# adres zaalokowanej pamieci
	la $a2, ($t7)	# wczytujemy tyle bajtow, jaki jest rozmiar pliku
	li $v0, 14	# wczytywanie z pliku
	syscall
	
	move $a0, $t0
	li $v0, 16	# zamkniecie pliku
	syscall
				# ponizej ustawiamy wskaznik t9 na adres, w ktorym jest
	lw $t9, offset		# poczatek tablicy pikseli. W t1 jest adres poczatku pliku bmp,
	addu $t9, $t9, $t1	# a offset przesuwa wskaznik t9 na poczatek tablicy pikseli

padding_sprawdzenie:	# ponizsze dwie instrukcje powoduja ze w t6 znajduje sie 
	mul $t6, $t2, 3		# reszta z dzielenia szerokosci*3 przez 4 
	andi $t6, $t6, 0x00000003	# 3*szerokosc to sumaryczna liczba bajtow w wierszu bez paddingu 

	li $s7, 1	# w s7 znajduje sie licznik wczytanych pikseli w danym wierszu				
			# potrzebny do znalezienia krawedzi kwadratu w tablicy pikseli

	beq $t6, 0, padding_0	# reszta = 0, szerokosc*3 jest wielokrotnoscia 4
	beq $t6, 1, padding_1	# reszta = 1, brakuje jeszcze 3 bajtow paddingowych
	beq $t6, 2, padding_2	# reszta = 2, brakuje jeszcze 2 bajtow paddingowych
	beq $t6, 3, padding_3	# reszta = 3, brakuje jeszcze 1 bajta paddingowego
	
padding_0:
	li $t6, 0
	sw $t6, padding
	b szukaj_poczatek

padding_1:
	li $t6, 3
	sw $t6, padding
	b szukaj_poczatek
	
padding_2:
	li $t6, 2
	sw $t6, padding
	b szukaj_poczatek
	
padding_3:
	li $t6, 1
	sw $t6, padding
	b szukaj_poczatek
	
szukaj_poczatek:
	jal wczytaj_piksel
				
	bne $s0, 255, poczatek_kwadratu	# szukamy pierwszego czarnego piksela 
	bne $s1, 255, poczatek_kwadratu	# (poczatek boku kwadratu) 
	bne $s2, 255, poczatek_kwadratu # czarny piksel ma wszystkie skladowe rowne 0
	
	jal nastepny_piksel
	bgt $s7, $t2, nastepna_linijka
	
	j szukaj_poczatek
	
poczatek_kwadratu:
	li $s6, 1 	# inicjalizacja licznika, ktory liczy ile pikseli ma bok kwadratu
szukaj_koniec:	
	jal nastepny_piksel
	
	jal wczytaj_piksel
	
	bne $s0, 0, koniec_kwadratu	# szukamy pierwszego bialego piksela 
	bne $s1, 0, koniec_kwadratu	# (koniec boku kwadratu)
	bne $s2, 0, koniec_kwadratu	# bialy piksel ma wszystkie skladowe rowne 255
	
	addi $s6, $s6, 1	# kolejny piksel boku kwadratu
	
	j szukaj_koniec
	
koniec_kwadratu:
	blt $s6, 3, zapisz_plik	# jesli kwadrat jest zbyt maly (bok<3) to nic nie robimy
	
	sra $s6 $s6, 1		# w s6 bedzie przechowywany promien okregu	
	sw $s6, promien

	mul $s2, $s6, 3		# mnozymy przez 3 - tyle ile bajtow przypada na piksel
	subu $t9, $t9, $s2	# cofamy sie wskaznikiem do srodka boku kwadratu
	subu $t9, $t9, 3	# idziemy jeszcze o jedno pole bo na poczatku t9 pokazywal na piksel poza kwadratem
	lw $t8, szerokosc	# ponizsze instrukcje ustawiaja wskaznik w srodku okregu
	mulu $t8, $t8, $s2	# mnozymy przez promien (pomnozony przez 3, bo 3 bajty na piksel)
	addu $t9, $t9, $t8	
	mul $t8, $t6, $s6	# dodajemy padding pomnozony przez promien
	addu $t9, $t9, $t8	# wskaznik t9 znajduje sie teraz w srodku okregu

	sw $t9, srodek		# zapamietujemy pozycje srodka kola w tablicy pikseli		
	
	j cwiartka_I
	
nastepna_linijka:
	addu $t9, $t9, $t6	# dodajemy padding, 
				# wtedy nastepuje przejscie do nastepnej linijki
	li $s7, 1		# resetujemy licznik pikseli w linijce
	
	j szukaj_poczatek

nastepny_piksel:
	addiu $t9, $t9, 3
	addiu $s7, $s7, 1	# zwiekszamy licznik pikseli w wierszu o 1
	
	jr $ra

wczytaj_piksel:
	lbu $s0, ($t9)		# wczytujemy skladowa blue danego piksela do s0
	addiu $t9, $t9, 1

	lbu $s1, ($t9)		# wczytujemy skladowa green danego piksela do s1
	addiu $t9, $t9, 1
	
	lbu $s2, ($t9)		# wczytujemy skladowa red danego piksela do s2
	
	subiu $t9, $t9, 2	# powrot wskaznika na poczatek piksela 

	jr $ra

cwiartka_I:
	li $t4, 0 		# wspolrzedne poczatkowe to (0, R)
	move $t5, $s6
petla:
	blt $t5, $t4, zapisz_plik
	
	addi $t7, $t4, 1
	mul $t8, $t7, $t7	# obliczanie wyniku rownania (x+1)^2 + y^2 - r^2
	add $s0, $zero, $t8	# dla piksela lezacego na prawo od obecnego piksela
	mul $t8, $t5, $t5
	add $s0, $s0, $t8
	mul $t8, $s6, $s6
	sub $s0, $s0, $t8
	
	addi $t7, $t4, 1
	mul $t8, $t7, $t7	# obliczanie wyniku rownania (x+1)^2 + (y-1)^2 - r^2
	add $s1, $zero, $t8	# dla piksela lezacego na dol i na prawo od obecnego piksela
	subi $t7, $t5, 1
	mul $t8, $t7, $t7
	add $s1, $s1, $t8	
	mul $t8, $s6, $s6
	sub $s1, $s1, $t8
	
	bgtz $s1, wiekszy_od_zera # ponizej obliczamy wartosc bezwzgledna s1
	sub $s1, $zero, $s1 	# jesli wartosc s1 ujemna to zamieniamy ja na dodatnia

wiekszy_od_zera:	
	blt $s0, $s1, idz_w_prawo	# piksel z prawej strony jest blizej krzywej
	b idz_w_dol_i_w_prawo 	# piksel na ukos w dol i w prawo jest blizej krzywej 

idz_w_prawo:
	addi $t4, $t4, 1
	jal pokoloruj_8_pikseli										
	j petla	

idz_w_dol_i_w_prawo:
	addi $t4, $t4, 1
	subi $t5, $t5, 1
	jal pokoloruj_8_pikseli											
	j petla

pokoloruj_8_pikseli:
	move $s3, $ra		# zaraz bedzie podwojne zaglebienie rekurencji
				# wiec zapisujemy adres powrotu w rejestrze $s3
	move $s4, $t4	
	move $s5, $t5
	jal pokoloruj		# kolorujemy piksel (x,y)
	
	sub $s5, $zero, $t5
	jal pokoloruj		# kolorujemy piksel (x,-y)

	sub $s4, $zero, $t4
	jal pokoloruj		# kolorujemy piksel (-x,-y)	

	move $s5, $t5
	jal pokoloruj		# kolorujemy piksel (-x, y)
	
				# ponizej kolorujemy kolejna czworke pikseli
	move $s4, $t5
	move $s5, $t4
	jal pokoloruj		# kolorujemy piksel (y,x)
	
	sub $s5, $zero, $t4
	jal pokoloruj		# kolorujemy piksel (y,-x)
	
	sub $s4, $zero, $t5
	jal pokoloruj		# kolorujemy piksel (-y,-x)	

	move $s5, $t4
	jal pokoloruj		# kolorujemy piksel (-y, x)
	
	jr $s3	
											
pokoloruj:
	bge $s4, $s6, powrot	# najpierw sprawdzamy czy ktoras z obecnych wspolrzednych
	bge $s5, $s6, powrot	# jest >= R (promien okregu), jesli tak to nie kolorujemy piksela
	sub $t8, $zero, $s6	# bo gdy jestesmy na krawedzi kwadratu to nie trzeba kolorowac piksela
	ble $s4, $t8, powrot	# tutaj sprawdzamy czy wspolrzedne sa <= -R (promien okregu)
	ble $s4, $t8, powrot
	
	lw $t9, srodek		# ustawiamy wskaznik t9 w odpowiednim miejscu w tablicy pikseli
	mul $t8, $s4, 3		# ktory nastepnie pokolorujemy na czarno
	add $t9, $t9, $t8	# najpierw dodajemy wspolrzedna x potem y
	lw $t8, szerokosc		
	mul $t8, $t8, $s5
	mul $t8, $t8, 3
	add $t9, $t9, $t8
	mul $t8, $t6, $s5	
	add $t9, $t9, $t8	# wskaznik t9 znajduje sie teraz we wlasciwym punkcie	
	
	sb $zero, ($t9)		# ponizej kolorujemy piksel na czarno
	addi $t9, $t9, 1
	sb $zero, ($t9)
	addi $t9, $t9, 1
	sb $zero, ($t9)	
	
powrot:	jr $ra	

zapisz_plik:
	la $a0, output
	li $a1, 1	# flaga otwarcia ustawiona na 1 - zapisywanie do pliku
	li $a2, 0
	li $v0, 13	# otwarcie pliku
	syscall		# w $v0 znajduje sie deskryptor pliku
	
	move $t0, $v0	# skopiowanie deskryptora do rejestru t0
	lw $t7, rozmiar
	
	bltz $t0, blad_otwarcia
	
	move $a0, $t0
	la $a1, ($t1)	# zapisujemy do pliku dane spod adresu t1 - poczatek pliku bmp w pamieci RAM
	la $a2, ($t7)	# kopiujemy do pliku tyle bajtow ile wynosi rozmiar pliku
	li $v0, 15	# zapisywanie do pliku
	syscall
	
	b zamknij_plik
	
blad_otwarcia:
	la $a0, error
	li $v0, 4
	syscall
	b koniec

zamknij_plik:
	move $a0, $t0
	li $v0, 16	# zamkniecie pliku
	syscall

koniec:	li $v0, 10	# wyjscie z programu
	syscall
