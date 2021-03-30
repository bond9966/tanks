data1	segment
video_buf	db	64000 dup(0)	;320*200

shots	db	401 dup(0)	;100 strzalow, 16b-poz_x, 8b-poz_y, 4b-wekt_x, 4b-wekt_y (1 wartosc to ilosc strzalow)

tank_0	dw	1,1	;zajmuje 10x10 pixeli bo 6x6 + z jednej str armata
	dw	0,0	;wektor armaty od srodka czolgu
vector_0	dw	0,0	;wektor przesuniecia
life_0	db	3	;ilosc zyc
shot_0	db	10	;jesli 1 to strzal i zwieksz o 15

tank_1	dw	95,145	;czolg przeciwnika
	dw	1,1	;wektor	armaty
	dw	0,0	;wektor przesuniecia
	db	2	;ilosc zyc
	db	3	;jesli move_0=1 to zwieksz o 2 i mozesz wykonac ruch
	db	10	;jesli 1 to strzal i zwieksz o 20

tank_2	dw	65,105	;wrogi czolg nr 2
	dw	1,1
	dw	0,0
	db	2
	db	3
	db	10

tank_3	dw	125,85	;wrogi czolg nr 3
	dw	1,1
	dw	0,0
	db	2
	db	3
	db	10

tank_4	dw	85,65	;wrogi czolg nr 4
	dw	1,1
	dw	0,0
	db	2
	db	3
	db	10

tank_5	dw	145,85	;wrogi czolg nr 5
	dw	1,1
	dw	0,0
	db	2
	db	3
	db	10

tank_6	dw	145,125	;wrogi czolg nr 6
	dw	1,1
	dw	0,0
	db	2
	db	3
	db	10

tank_7	dw	145,165	;wrogi czolg nr 7
	dw	1,1
	dw	0,0
	db	2
	db	3
	db	10

tank_8	dw	285,105	;wrogi czolg nr 8
	dw	1,1
	dw	0,0
	db	2
	db	3
	db	10

tank_9	dw	155,5	;wrogi czolg nr 9
	dw	1,1
	dw	0,0
	db	2
	db	3
	db	10

tank_10	dw	185,45	;wrogi czolg nr 10
	dw	1,1
	dw	0,0
	db	2
	db	3
	db	10

data1	ends


assume cs:code1
code1	segment

start1:
	;inicjowanie stosu
	mov	sp, offset wstosu
	mov	ax, seg wstosu
	mov	ss, ax
	
	mov	ax, seg data1
	mov	ds, ax	;od teraz ds zawsze bedzie oznaczal ten offset
	
	call	set_keyboard	;usawienie wlasnej obslugi klawiatury
	call	set_video	;ustawienie trybu graficznego
	
;---GLOWNA PETLA-----------------------------------------------
	
	l0:
		call	clear_buf	;wypelnia buf zerami (czarny)
		
		call	print_map	;rysuje mape
		
		call	print_tanks	;rysuje wrogie czolgi
		
		call	set_my_vector	;uzupelnienie wektora ruchu mojego czolgu
		call	set_my_cannon	;uzupelnienie wektora armaty
		
		mov	bx, offset tank_0	;offset mojego czolgu
		mov	cl, 50		;kolor czolgu
		call	print_tank	;narysuj moj czolg
		
		call	my_shot		;strzal mojego czolgu
		
		call	print_shots	;rysuje strzaly w buforze
		
		call	update_enemy_shots	;odejmuje od zmiennej strzalu wroga 1 zeby nie mogl strzelac seriami tylko musial czekac
		
		call	life_count	;wypisuje ile mi zyc zostalo
		
		call	print_buf	;kopiuje buf na ekran
		
		call	if_win		;sprawdza stan gry (al=0 gra sie toczy, al=1 koniec gry[ah=1 wygrana, ah=2 przegrana])
		cmp	al, 1
		jz	l1
	
	cmp	byte ptr cs:[esc_b], 1	;jesli nacisnieto esc to wyjdz z petli nieskonczonej
	jnz	l0
	
;--------------------------------------------------------------
	l1:	;jesli zwyciestwo
	push	ax
	
	call	restore_video	;przywraca tryb tekstowy
	call	restore_keyboard	;przywrocenie starej obslugi klawiatury
	
	pop	ax	;przywrocenie stanu gry (winner czy nie)
	call	show_info	;wypisuje na ekran czy wygrana czy przegrana
	
	mov	ax,4c00h	;zakoncz program i wroc do systemu
	int	21h
	
;---PROCEDURY--------------------------------------------------
;nazwa:	;###komentarz #potrzebne rejestry#zmieniane rejestry#rejestry z wynikami#
;--------------------------------------------------------------
life_count:	;###rysuje moje zycie ####
	
	cmp	byte ptr ds:[tank_0 + 12], 3	;ilosc moich zyc
	jz	life_count_3
	cmp	byte ptr ds:[tank_0 + 12], 2
	jz	life_count_2
	jmp	life_count_1
	life_count_3:	;jesli 3 zycia
	
	mov	cl, 50
	mov	ch, 60
	mov	ax, 26
	mov	bx, 186
	call	set_pixel	;wypelnia zycie zielonym kolorem
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	
	jmp	life_count_4
	
	life_count_2:	;jesli 2 zycia
	
	mov	cl, 42
	mov	ch, 40
	mov	ax, 26
	mov	bx, 186
	call	set_pixel	;wypelnia zycie pomaranczowym kolorem
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	
	jmp	life_count_4
	
	life_count_1:	;jesli 1 zycie
	
	mov	cl, 40
	mov	ch, 20
	mov	ax, 26
	mov	bx, 186
	call	set_pixel	;wypelnia zycie czerwonym kolorem
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	
	life_count_4:
	
	mov	cl, 28	;kolor
	mov	ch, 10
	mov	ax, 25
	mov	bx, 185
	call	set_pixel_y
	
	mov	ch, 60
	call	set_pixel
	
	mov	ax, 85
	mov	ch, 11
	call	set_pixel_y
	
	mov	ax, 25
	mov	bx, 195
	mov	ch, 60
	call	set_pixel
	
	ret
;--------------------------------------------------------------
update_enemy_shots:	;###odejmuje od zmiennych strzalu 1 bo dopiero przy 1 moze moze strzelic ####
	
	;w glownej petli odejmowanie -1 od zmiennej bo to nie wykona sie kazda iteracje
	mov	bx, offset tank_1
	call	update_enemy_shot
	mov	bx, offset tank_2
	call	update_enemy_shot
	mov	bx, offset tank_3
	call	update_enemy_shot
	mov	bx, offset tank_4
	call	update_enemy_shot
	mov	bx, offset tank_5
	call	update_enemy_shot
	mov	bx, offset tank_6
	call	update_enemy_shot
	mov	bx, offset tank_7
	call	update_enemy_shot
	mov	bx, offset tank_8
	call	update_enemy_shot
	mov	bx, offset tank_9
	call	update_enemy_shot
	mov	bx, offset tank_10
	call	update_enemy_shot
	
	ret
;--------------------------------------------------------------
update_enemy_shot:	;###odejmuje il ruchow jesli jest rozna od 1
	
	cmp	byte ptr ds:[bx + 14], 1
	jz	update_enemy_shot_0
	
		dec	byte ptr ds:[bx + 14]
	
	update_enemy_shot_0:
	
	ret
;--------------------------------------------------------------
if_win:	;###sprawdza jaki jest stan gry ###al=0 gra sie toczy, al=1 koniec gry[ah=1 wygrana, ah=2 przegrana]#
	
	xor	al, al
	mov	cl, byte ptr ds:[tank_1 + 12]
	add	cl, byte ptr ds:[tank_2 + 12]
	add	cl, byte ptr ds:[tank_3 + 12]
	add	cl, byte ptr ds:[tank_4 + 12]
	add	cl, byte ptr ds:[tank_5 + 12]
	add	cl, byte ptr ds:[tank_6 + 12]
	add	cl, byte ptr ds:[tank_7 + 12]
	add	cl, byte ptr ds:[tank_8 + 12]
	add	cl, byte ptr ds:[tank_9 + 12]
	add	cl, byte ptr ds:[tank_10 + 12]
	
	dec	cl
	cmp	cl, 0ffh
	jz	if_win_win
	
	mov	cl, byte ptr ds:[tank_0 + 12]
	dec	cl
	cmp	cl, 0ffh
	jz	if_win_defeat
	
	ret
	
	if_win_defeat:	;przegrana
	inc	al
	mov	ah, 2
	
	ret
	
	if_win_win:	;wygrana
	inc	al
	mov	ah, 1
	
	ret
;--------------------------------------------------------------
my_shot:	;###moj strzal #ds-data seg###
	
	cmp	byte ptr ds:[shot_0], 1
	jz	my_shot_0
	
		dec	byte ptr ds:[shot_0]
	
	jmp	my_shot_1
	my_shot_0:
	
		cmp	byte ptr cs:[space_b], 1
		jnz	my_shot_1
		
			add	byte ptr ds:[shot_0], 15
			mov	bx, offset tank_0
			call	new_shot
	
	my_shot_1:
	
	ret
;--------------------------------------------------------------
check_enemy_shot:	;###zmienijsza il zyc konkretnego wroga #ax-x pocisku, cx-y pocisku, bx-offset czolgu###
	
	mov	dx, ax
	inc	dx
	cmp	word ptr ds:[bx], dx
	jnb	check_enemy_shot_end	;jesli x_czolgu - x_pocisku - 1 >=0
	
	mov	dx, word ptr ds:[bx]
	add	dx, 10
	cmp	ax, dx
	jnb	check_enemy_shot_end
	
	mov	dx, cx
	inc	dx
	cmp	word ptr ds:[bx + 2], dx
	jnb	check_enemy_shot_end
	
	mov	dx, word ptr ds:[bx + 2]
	add	dx, 10
	cmp	cx, dx
	jnb	check_enemy_shot_end
	
		mov	dl, byte ptr ds:[bx + 12]
		dec	dl
		cmp	dl, 0ffh
		jz	check_enemy_shot_end	;jesli il_zyc > 0
		
			dec	byte ptr ds:[bx + 12]	;zmniejszenie il zyc
	
	check_enemy_shot_end:
	
;if (cx < x+1 && x < cx+10 && cy < y + 1 && y < cy+10)
;{
;	if (il zyc > 0)
;		il_zyc--
;}
	
	ret
;--------------------------------------------------------------
check_enemy_shots:	;###sprawdza czy pocisk trafil wroga (ewntualne zmniejszenie il zyc) #ax-x pocisku, bx - y pocisku###
	
	mov	cx, bx
	
	mov	bx, offset tank_0
	call	check_enemy_shot
	
	mov	bx, offset tank_1
	call	check_enemy_shot
	
	mov	bx, offset tank_2
	call	check_enemy_shot
	
	mov	bx, offset tank_3
	call	check_enemy_shot
	
	mov	bx, offset tank_4
	call	check_enemy_shot
	
	mov	bx, offset tank_5
	call	check_enemy_shot
	
	mov	bx, offset tank_6
	call	check_enemy_shot
	
	mov	bx, offset tank_7
	call	check_enemy_shot
	
	mov	bx, offset tank_8
	call	check_enemy_shot
	
	mov	bx, offset tank_9
	call	check_enemy_shot
	
	mov	bx, offset tank_10
	call	check_enemy_shot
	
	mov	bx, cx	;przywraca starego bx
	
	ret
;--------------------------------------------------------------
print_shots:	;###rysuje strzaly i dodaje wektory przesuniecia
	
	mov	bx, offset shots
	xor	ah, ah
	mov	al, byte ptr ds:[bx]	;w ax policz przesuniecie za tablice
	mov	cl, 2
	shl	ax, cl
	mov	cx, ax	;w cx jest ustawiony przesuniecie w tablicy
	inc	bx	;ustawienie na poczatek tablicy
	add	cx, bx	;w cx offset za tablica
	
	print_shots_0:
	cmp	cx, bx
	jnz	print_shots_4
	jmp	print_shots_end
	print_shots_4:
	cmp	cx, bx
	jns	print_shots_5
	jmp	print_shots_end
	print_shots_5:
	
		push	cx
		push	bx
		
		mov	al, byte ptr ds:[bx + 3]	;dodanie przesuniecia na ox
		mov	cl, 4
		shr	al, cl
		and	al, 00001111b
		xor	ah, ah
		dec	ax
		add	word ptr ds:[bx], ax
		
		mov	al, byte ptr ds:[bx + 3]	;dodanie przesuniecia na oy
		and	al, 00001111b
		dec	al
		add	byte ptr ds:[bx + 2], al
		
		mov	ax, word ptr ds:[bx]		;x pocisku
		mov	bl, byte ptr ds:[bx + 2]	;y pocisku w bh
		xor	bh, bh
		
		call	check_enemy_shots	;tu trzeba sprawdzic czy pocisk uderzyl w wroga
		
		push	bx
		push	ax	;jesli znajduje sie na ekranie to narysuj punkt
		push	bx
		mov	cl, 2
		shl	bx, cl	;bx = 4*y
		pop	ax
		add	bx, ax	;bx = 5*y
		mov	cl, 6
		shl	bx, cl	;bx = 320*y
		pop	ax
		add	bx, ax	;bx = 320*y + 
		mov	cl, byte ptr ds:[bx]	;pobiera kolor pixela gdzie ma byc narysowany strzal
		pop	bx
		dec	cl
		cmp	cl, 0ffh
		jnz	print_shots_1	;jesli jest jakis obiekt to skasuj
		
		cmp	ax, 0ffffh	;sprawdzenie czy nie wyszlo poza ekran
		jz	print_shots_1
		cmp	ax, 320
		jz	print_shots_1
		cmp	bl, 0ffh
		jz	print_shots_1
		cmp	bx, 200
		jz	print_shots_1
		
		jmp	print_shots_2
		print_shots_1:
		
			mov	al, byte ptr ds:[shots]
			xor	ah, ah
			dec	ax
			mov	cl, 2
			shl	ax, cl
			mov	bx, offset shots
			inc	bx
			add	bx, ax
			mov	dx, bx	;w dx jest adres ostatniego strzalu
			
			pop	bx	;skopiowanie aktualnego adresu struktury
			pop	cx
			sub	cx, 4	;zmniejszenie ilosci iteracji o 1 (struktura ma 4 bajty)
			dec	byte ptr ds:[shots]	;skasowanie strzalu
			push	cx
			push	bx
			
			xchg	bx, dx		;skopiowanie ostatniego strzalu pod obecny adres
			mov	ax, word ptr ds:[bx]	;kopia ostatniego strzalu do ax
			xchg	bx, dx
			mov	word ptr ds:[bx], ax	;wpisanie pod obecny adres
			xchg	bx, dx
			mov	ax, word ptr ds:[bx + 2]
			xchg	bx, dx
			mov	word ptr ds:[bx + 2], ax
		
		jmp	print_shots_3
		print_shots_2:
		
			push	ax	;jesli znajduje sie na ekranie to narysuj punkt
			push	bx
			mov	cl, 2
			shl	bx, cl	;bx = 4*y
			pop	ax
			add	bx, ax	;bx = 5*y
			mov	cl, 6
			shl	bx, cl	;bx = 320*y
			pop	ax
			add	bx, ax	;bx = 320*y + x
			
			mov	al, 40
			mov	byte ptr ds:[bx], al
		
		print_shots_3:
		
		pop	bx
		pop	cx
	
	add	bx, 4
	jmp	print_shots_0
	print_shots_end:
	
	ret
;--------------------------------------------------------------
new_shot:	;###tworzy nowy strzal #bx-offset do struk###
	
	mov	al, byte ptr ds:[shots]	;sprawdza czy mozna dodac strzal
	cmp	al, 100
	js	new_shot_12
	
		ret
	
	new_shot_12:
	
	mov	ax, word ptr ds:[bx + 4]
	dec	ax
	cmp	ax, 0ffffh
	jnz	new_shot_1
	
		mov	ax, word ptr ds:[bx]	;jezeli brak przesuniecia w poziomie
		add	ax, 4
		mov	word ptr cs:[new_shot_x], ax
	
	jmp	new_shot_2
	new_shot_1:
	
		cmp	word ptr ds:[bx + 4], 1
		jnz	new_shot_3
		
			mov	ax, word ptr ds:[bx]	;jezeli w prawo
			add	ax, 10
			mov	word ptr cs:[new_shot_x], ax
		
		jmp	new_shot_2
		new_shot_3:
		
			mov	ax, word ptr ds:[bx]	;jezeli w lewo
			dec	ax
			mov	word ptr cs:[new_shot_x], ax
	
	new_shot_2:
	
	mov	ax, word ptr ds:[bx + 6]
	dec	ax
	cmp	ax, 0ffffh
	jnz	new_shot_4
	
		mov	ax, word ptr ds:[bx + 2]	;jezeli brak przesuniecia w pionie
		add	ax, 4
		mov	byte ptr cs:[new_shot_y], al
	
	jmp	new_shot_5
	new_shot_4:
	
		cmp	word ptr ds:[bx + 6], 1
		jnz	new_shot_6
		
			mov	ax, word ptr ds:[bx + 2]	;jezeli w dol
			add	ax, 10
			mov	byte ptr cs:[new_shot_y], al
		
		jmp	new_shot_5
		new_shot_6:
		
			mov	ax, word ptr ds:[bx + 2]	;jezeli w gore
			dec	ax
			mov	byte ptr cs:[new_shot_y], al
	
	new_shot_5:
	
	cmp	word ptr cs:[new_shot_x], 0ffffh	;sprawdza czy strzal jest na ekranie
	jnz	new_shot_7
	
		ret
	
	new_shot_7:
	
	cmp	word ptr cs:[new_shot_x], 320
	jnz	new_shot_10
	
		ret
	
	new_shot_10:
	
	cmp	byte ptr cs:[new_shot_y], 0ffh	;sprawdza czy strzal jest na ekranie
	jnz	new_shot_8
	
		ret
	
	new_shot_8:
	
	cmp	byte ptr cs:[new_shot_y], 200
	jnz	new_shot_11
	
		ret
	
	new_shot_11:
	
	push	bx
	xor	bh, bh		;wylicza offset pixela
	mov	bl, byte ptr cs:[new_shot_y]
	push	bx
	mov	cl, 2
	shl	bx, cl	;bx = 4*y
	pop	ax
	add	bx, ax	;bx = 5*y
	mov	cl, 6
	shl	bx, cl	;bx = 320*y
	add	bx, word ptr cs:[new_shot_x]	;bx = 320*y + x
	
	mov	al, byte ptr ds:[bx]	;sprawdza czy jest jakis obiekt
	dec	al
	pop	bx
	cmp	al, 0ffh
	jz	new_shot_9
	
		ret
	
	new_shot_9:
	
	mov	ax, word ptr ds:[bx + 4]	;wektor x armaty
	inc	ax
	mov	cl, 4
	shl	al, cl	;w ah jest przesuniecie wektor
	and	al, 11110000b
	mov	byte ptr cs:[new_shot_v], al
	mov	ax, word ptr ds:[bx + 6]	;wektor y armaty
	inc	al
	and	al, 00001111b	;potrzebna jest jedynie prawa czesc al
	add	byte ptr cs:[new_shot_v], al
	
	mov	bx, offset shots	;dodanie w ds strzalu
	xor	ah, ah
	mov	al, byte ptr ds:[bx]
	inc	bx
	mov	cl, 2
	shl	ax, cl	;liczenie offsetu dla nowego strzalu
	add	bx, ax
	mov	ax, word ptr cs:[new_shot_x]
	mov	word ptr ds:[bx], ax
	mov	ah, byte ptr cs:[new_shot_y]
	mov	byte ptr ds:[bx + 2], ah
	mov	al, byte ptr cs:[new_shot_v]
	mov	byte ptr ds:[bx + 3], al
	inc	byte ptr ds:[shots]	;zwiekszenie ilosci strzalow
	
	ret
new_shot_x	dw	0	;poz x nowego strzalu
new_shot_y	db	0	;poz y
new_shot_v	db	0	;wektor strzalu (4b-poz_x, 4b-poz_y)	(0-odejmij, 1-brak przesuniecia, 2-dodaj)
;--------------------------------------------------------------
print_tanks:	;###rysuje wrogie czolgi ####
	
	mov	bx, offset tank_1
	mov	al, byte ptr ds:[bx + 12]	;pobiera il zyc
	dec	al
	cmp	al, 0ffh
	jz	tanks_1
		push	bx	;ustawia armate i przesuniecie wroga na mnie jesli jestem w zasiegu
		call	set_enemy
		pop	bx	;rysowanie wrogow koniecnie przed set_my_vector
		mov	cl, 1
		call	print_tank
	tanks_1:
	
	mov	bx, offset tank_2
	mov	al, byte ptr ds:[bx + 12]	;pobiera il zyc
	dec	al
	cmp	al, 0ffh
	jz	tanks_2
		push	bx	;ustawia armate i przesuniecie wroga na mnie jesli jestem w zasiegu
		call	set_enemy
		pop	bx	;rysowanie wrogow koniecnie przed set_my_vector
		mov	cl, 1
		call	print_tank
	tanks_2:
	
	mov	bx, offset tank_3
	mov	al, byte ptr ds:[bx + 12]	;pobiera il zyc
	dec	al
	cmp	al, 0ffh
	jz	tanks_3
		push	bx	;ustawia armate i przesuniecie wroga na mnie jesli jestem w zasiegu
		call	set_enemy
		pop	bx	;rysowanie wrogow koniecnie przed set_my_vector
		mov	cl, 1
		call	print_tank
	tanks_3:
	
	mov	bx, offset tank_4
	mov	al, byte ptr ds:[bx + 12]	;pobiera il zyc
	dec	al
	cmp	al, 0ffh
	jz	tanks_4
		push	bx	;ustawia armate i przesuniecie wroga na mnie jesli jestem w zasiegu
		call	set_enemy
		pop	bx	;rysowanie wrogow koniecnie przed set_my_vector
		mov	cl, 1
		call	print_tank
	tanks_4:
	
	mov	bx, offset tank_5
	mov	al, byte ptr ds:[bx + 12]	;pobiera il zyc
	dec	al
	cmp	al, 0ffh
	jz	tanks_5
		push	bx	;ustawia armate i przesuniecie wroga na mnie jesli jestem w zasiegu
		call	set_enemy
		pop	bx	;rysowanie wrogow koniecnie przed set_my_vector
		mov	cl, 1
		call	print_tank
	tanks_5:
	
	mov	bx, offset tank_6
	mov	al, byte ptr ds:[bx + 12]	;pobiera il zyc
	dec	al
	cmp	al, 0ffh
	jz	tanks_6
		push	bx	;ustawia armate i przesuniecie wroga na mnie jesli jestem w zasiegu
		call	set_enemy
		pop	bx	;rysowanie wrogow koniecnie przed set_my_vector
		mov	cl, 1
		call	print_tank
	tanks_6:
	
	mov	bx, offset tank_7
	mov	al, byte ptr ds:[bx + 12]	;pobiera il zyc
	dec	al
	cmp	al, 0ffh
	jz	tanks_7
		push	bx	;ustawia armate i przesuniecie wroga na mnie jesli jestem w zasiegu
		call	set_enemy
		pop	bx	;rysowanie wrogow koniecnie przed set_my_vector
		mov	cl, 1
		call	print_tank
	tanks_7:
	
	mov	bx, offset tank_8
	mov	al, byte ptr ds:[bx + 12]	;pobiera il zyc
	dec	al
	cmp	al, 0ffh
	jz	tanks_8
		push	bx	;ustawia armate i przesuniecie wroga na mnie jesli jestem w zasiegu
		call	set_enemy
		pop	bx	;rysowanie wrogow koniecnie przed set_my_vector
		mov	cl, 1
		call	print_tank
	tanks_8:
	
	mov	bx, offset tank_9
	mov	al, byte ptr ds:[bx + 12]	;pobiera il zyc
	dec	al
	cmp	al, 0ffh
	jz	tanks_9
		push	bx	;ustawia armate i przesuniecie wroga na mnie jesli jestem w zasiegu
		call	set_enemy
		pop	bx	;rysowanie wrogow koniecnie przed set_my_vector
		mov	cl, 1
		call	print_tank
	tanks_9:
	
	mov	bx, offset tank_10
	mov	al, byte ptr ds:[bx + 12]	;pobiera il zyc
	dec	al
	cmp	al, 0ffh
	jz	tanks_10
		push	bx	;ustawia armate i przesuniecie wroga na mnie jesli jestem w zasiegu
		call	set_enemy
		pop	bx	;rysowanie wrogow koniecnie przed set_my_vector
		mov	cl, 1
		call	print_tank
	tanks_10:
	
	ret
;--------------------------------------------------------------
set_enemy:	;###ustawia armate wroga #cs-code seg, ds-date seg, bx-offset strukt###
	
	push	ax
	push	cx
	
	push	bx
	call	if_wall	;ustawia cl=1 jesli jest sciana lub cl=0 jesli brak
	pop	bx
	cmp	cl, 1
	jnz	enemy_n	;jesli jest sciana to nie ma sensu wykonywac dalej kodu
		xor	ax, ax
		mov	word ptr ds:[bx + 4], ax
		mov	word ptr ds:[bx + 8], ax
		mov	word ptr ds:[bx + 10], ax
		dec	ax
		mov	word ptr ds:[bx + 6], ax
		pop	cx
		pop	ax
		ret
	enemy_n:
	
	xor	ax, ax
	mov	word ptr ds:[bx + 4], ax
	mov	word ptr ds:[bx + 6], ax
	mov	word ptr ds:[bx + 8], ax
	mov	word ptr ds:[bx + 10], ax
	
	mov	ax, word ptr ds:[tank_0]
	add	ax, 4	;ustawienie na srodek a nie lewy gorny rog
	mov	word ptr cs:[enemy_x], 1
	sub	ax, word ptr ds:[bx]	;tu jest zapisana wspolrzedna x wektora
	jns	enemy_0
	dec	word ptr cs:[enemy_x]
	dec	word ptr cs:[enemy_x]
	neg	ax
enemy_0:
	mov	word ptr cs:[enemy_x + 2], ax
	
	mov	ax, word ptr ds:[tank_0 + 2]	;uzupelnienie znaku i wartosci wektora y
	add	ax, 4	;ustawienie na srodek a nie lewy gorny rog
	mov	word ptr cs:[enemy_y], 1
	sub	ax, word ptr ds:[bx + 2]
	jns	enemy_1
	dec	word ptr cs:[enemy_y]
	dec	word ptr cs:[enemy_y]
	neg	ax
enemy_1:
	mov	word ptr cs:[enemy_y + 2], ax
	
	mov	cl, 1
	shl	ax, cl	;pomnozenie razy 2
	cmp	ax, word ptr cs:[enemy_x + 2]
	jns	enemy_2
	
	mov	ax, word ptr cs:[enemy_x]	;x=sgn(vx), y=0
	mov	word ptr ds:[bx + 4], ax
	mov	word ptr ds:[bx + 8], ax
	jmp	enemy_end0
	
enemy_2:
	mov	ax, word ptr cs:[enemy_x + 2]
	shl	ax, cl
	cmp	ax, word ptr cs:[enemy_y + 2]
	jns	enemy_3
	
	mov	ax, word ptr cs:[enemy_y]
	mov	word ptr ds:[bx + 6], ax
	mov	word ptr ds:[bx + 10], ax
	
	jmp	enemy_end0
enemy_3:
	mov	ax, word ptr cs:[enemy_x]
	mov	word ptr ds:[bx + 4], ax
	mov	word ptr ds:[bx + 8], ax
	mov	ax, word ptr cs:[enemy_y]
	mov	word ptr ds:[bx + 6], ax
	mov	word ptr ds:[bx + 10], ax
	
enemy_end0:
	
	mov	al, byte ptr ds:[bx + 13]	;pobiera il ruchu
	cmp	al, 1
	jz	enemy_m0
	
	xor	ax, ax
	mov	word ptr ds:[bx + 8], ax
	mov	word ptr ds:[bx + 10], ax
	dec	byte ptr ds:[bx + 13]
	jmp	enemy_m1
	
enemy_m0:
	inc	byte ptr ds:[bx + 13]
enemy_m1:
	
	;sprawdzenie czy nie wyjdzie poza ekran
	
	
	mov	ax, word ptr ds:[bx + 8]	;sprawdzenie czy nie ma sciany w poziomie
	cmp	ax, 1
	jz	enemy_v_r
	cmp	ax, 0ffffh
	jz	enemy_v_l
	jmp	enemy_v_3
enemy_v_r:	;na prawo
	
	push	bx
	mov	ax, word ptr ds:[bx]
	mov	bx, word ptr ds:[bx + 2]
	add	ax, 10
	push	ax
	push	bx
	mov	cl, 2
	shl	bx, cl	;bx = 4*y
	pop	ax
	add	bx, ax	;bx = 5*y
	mov	cl, 6
	shl	bx, cl	;bx = 320*y
	pop	ax
	add	bx, ax	;bx = 320*y + x
	mov	ax, offset video_buf
	add	bx, ax
	mov	al, byte ptr ds:[bx]	;dodaje 10 wartosci po prawej
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	dec	al
	pop	bx
	cmp	al, 0ffh
	jz	enemy_v_3
	
	mov	word ptr ds:[bx + 8], 0
	
	jmp	enemy_v_3
enemy_v_l:	;na lewo
	
	push	bx
	mov	ax, word ptr ds:[bx]
	mov	bx, word ptr ds:[bx + 2]
	dec	ax
	push	ax
	push	bx
	mov	cl, 2
	shl	bx, cl	;bx = 4*y
	pop	ax
	add	bx, ax	;bx = 5*y
	mov	cl, 6
	shl	bx, cl	;bx = 320*y
	pop	ax
	add	bx, ax	;bx = 320*y + x
	mov	ax, offset video_buf
	add	bx, ax
	mov	al, byte ptr ds:[bx]	;dodaje 10 wartosci po lewej
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	dec	al
	pop	bx
	cmp	al, 0ffh
	jz	enemy_v_3
	
	mov	word ptr ds:[bx + 8], 0
	
enemy_v_3:
	
	mov	ax, word ptr ds:[bx + 10]	;sprawdzenie czy nie ma scniany w pionie
	cmp	ax, 1
	jz	enemy_v_down
	cmp	ax, 0ffffh
	jz	enemy_v_up
	jmp	enemy_v_end1
enemy_v_down:
	
	push	bx
	mov	ax, word ptr ds:[bx]
	mov	bx, word ptr ds:[bx + 2]
	add	bx, 10
	push	ax
	push	bx
	mov	cl, 2
	shl	bx, cl	;bx = 4*y
	pop	ax
	add	bx, ax	;bx = 5*y
	mov	cl, 6
	shl	bx, cl	;bx = 320*y
	pop	ax
	add	bx, ax	;bx = 320*y + x
	mov	ax, offset video_buf
	add	bx, ax
	mov	al, byte ptr ds:[bx]	;dodaje 10 wartosci po lewej
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	dec	al
	pop	bx
	cmp	al, 0ffh
	jz	enemy_v_end1
	
	mov	word ptr ds:[bx + 10], 0
	
	jmp	enemy_v_end1
enemy_v_up:
	
	push	bx
	mov	ax, word ptr ds:[bx]
	mov	bx, word ptr ds:[bx + 2]
	dec	bx
	push	ax
	push	bx
	mov	cl, 2
	shl	bx, cl	;bx = 4*y
	pop	ax
	add	bx, ax	;bx = 5*y
	mov	cl, 6
	shl	bx, cl	;bx = 320*y
	pop	ax
	add	bx, ax	;bx = 320*y + x
	mov	ax, offset video_buf
	add	bx, ax
	mov	al, byte ptr ds:[bx]	;dodaje 10 wartosci po lewej
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	dec	al
	pop	bx
	cmp	al, 0ffh
	jz	enemy_v_end1
	
	mov	word ptr ds:[bx + 10], 0
	
enemy_v_end1:
	
	cmp	byte ptr ds:[bx + 14], 1	;jesli mozna wykonac strzal
	jnz	enemy_without_shot
	
		add	byte ptr ds:[bx + 14], 15
		call	new_shot
	
	enemy_without_shot:
	
	pop	cx
	pop	ax
	
	ret
enemy_x	dw	0,0	;znak + wartosc
enemy_y	dw	0,0	;znak + wartosc
;--------------------------------------------------------------
if_wall:	;###sprawdza czy miedzy punktami jest sciana #ds-data seg, bx-offset strukt, cs-code seg###
	
	xor	ax, ax
	mov	word ptr cs:[wall_sum], ax
	mov	word ptr cs:[wall_dx], ax
	mov	word ptr cs:[wall_dy], ax
	mov	word ptr cs:[wall_r], ax
	
	mov	ax, word ptr ds:[tank_0]	;pod zmienna a podstaw moj czolg
	add	ax, 4
	mov	word ptr cs:[wall_a], ax
	mov	ax, word ptr ds:[tank_0 + 2]
	add	ax, 4
	mov	word ptr cs:[wall_a + 2], ax
	
	mov	ax, word ptr ds:[bx]	;pod zmienna b podstaw czolg wroga
	add	ax, 4
	mov	word ptr cs:[wall_b], ax
	mov	ax, word ptr ds:[bx + 2]
	add	ax, 4
	mov	word ptr cs:[wall_b + 2], ax
	
	mov	ax, word ptr cs:[wall_a + 2]	;delta y
	sub	ax, word ptr cs:[wall_b + 2]
	jns	wall_0
		neg	ax
		inc	word ptr cs:[wall_dy]
	wall_0:
	mov	word ptr cs:[wall_dy + 2], ax
	
	mov	ax, word ptr cs:[wall_a]	;delta x
	sub	ax, word ptr cs:[wall_b]
	jns	wall_1
		neg	ax
		inc	word ptr cs:[wall_dx]
	wall_1:
	mov	word ptr cs:[wall_dx + 2], ax
	
	mov	ax, word ptr cs:[wall_a]	;roznica
	mov	bx, word ptr cs:[wall_b + 2]
	mul	bx
	push	ax
	mov	ax, word ptr cs:[wall_b]
	mov	bx, word ptr cs:[wall_a + 2]
	mul	bx
	mov	bx, ax
	pop	ax
	sub	ax, bx
	jns	wall_2
		neg	ax
		inc	word ptr cs:[wall_r]
	wall_2:
	mov	word ptr cs:[wall_r + 2], ax
	
	
	mov	ax, word ptr cs:[wall_dx + 2]
	dec	ax
	cmp	ax, 0ffffh
	jnz	wall_3
	
		mov	ax, word ptr cs:[wall_a + 2]
		cmp	word ptr cs:[wall_b + 2], ax
		js	wall_5
		
			mov	dx, word ptr cs:[wall_b + 2]
			inc	dx
			mov	ax, word ptr cs:[wall_a]
			mov	bx, word ptr cs:[wall_a + 2]
			mov	cl, 50
			mov	ch, 1
			wall_6:
				
				push	ax
				push	bx

				push	ax
				push	bx
				mov	cl, 2
				shl	bx, cl	;bx = 4*y
				pop	ax
				add	bx, ax	;bx = 5*y
					
				mov	cl, 6
				shl	bx, cl	;bx = 320*y
	
				pop	ax
				add	bx, ax	;bx = 320*y + x
				
				mov	al, byte ptr ds:[bx]
				xor	ah, ah
				add	word ptr cs:[wall_sum], ax
				
				pop	bx
				pop	ax

			inc	bx
			cmp	bx, dx
			jnz	wall_6
		
		jmp	wall_4
		wall_5:
		
			mov	dx, word ptr cs:[wall_a + 2]
			inc	dx
			mov	ax, word ptr cs:[wall_a]
			mov	bx, word ptr cs:[wall_b + 2]
			wall_7:
				
				push	ax
				push	bx

				push	ax
				push	bx
				mov	cl, 2
				shl	bx, cl	;bx = 4*y
				pop	ax
				add	bx, ax	;bx = 5*y
					
				mov	cl, 6
				shl	bx, cl	;bx = 320*y
	
				pop	ax
				add	bx, ax	;bx = 320*y + x
				
				mov	al, byte ptr ds:[bx]
				xor	ah, ah
				add	word ptr cs:[wall_sum], ax
				
				pop	bx
				pop	ax
				
			inc	bx
			cmp	bx, dx
			jnz	wall_7
	
	jmp	wall_4
	wall_3:
		
		mov	ax, word ptr cs:[wall_dx + 2]
		cmp	ax, word ptr cs:[wall_dy + 2]
		jns	wall_23
		jmp	wall_8
		wall_23:
		
			cmp	word ptr cs:[wall_dx], 1	;bx<ax
			jz	wall_9
			
				xor	dx, dx
				mov	ax, word ptr cs:[wall_r + 2]
				div	word ptr cs:[wall_dx + 2]
				cmp	word ptr cs:[wall_r], 1
				jnz	wall_12
				
					neg	ax
				
				wall_12:
				mov	word ptr cs:[wall_r + 2], ax
				
				mov	cx, word ptr cs:[wall_a]
				inc	cx
				mov	ax, word ptr cs:[wall_b]
				wall_10:
				
					push	cx
					push	ax
					mul	word ptr cs:[wall_dy + 2]
					xor	dx, dx
					div	word ptr cs:[wall_dx + 2]
					cmp	word ptr cs:[wall_dy], 1
					jnz	wall_11
					
						neg	ax
					
					wall_11:
					mov	bx, ax
					add	bx, word ptr cs:[wall_r + 2]
					pop	ax
					
					push	ax
					push	bx
					push	ax
					push	bx
					mov	cl, 2
					shl	bx, cl	;bx = 4*y
					pop	ax
					add	bx, ax	;bx = 5*y
					mov	cl, 6
					shl	bx, cl	;bx = 320*y
					pop	ax
					add	bx, ax	;bx = 320*y + x
					mov	al, byte ptr ds:[bx]
					xor	ah, ah
					add	word ptr cs:[wall_sum], ax
					
					pop	bx
					pop	ax
		
					pop	cx
				
				inc	ax
				cmp	ax, cx
				jnz	wall_10
			
			jmp	wall_4
			wall_9:
			
				xor	dx, dx
				mov	ax, word ptr cs:[wall_r + 2]
				div	word ptr cs:[wall_dx + 2]
				cmp	word ptr cs:[wall_r], 1
				jz	wall_15
				
					neg	ax
				
				wall_15:
				mov	word ptr cs:[wall_r + 2], ax
				
				mov	cx, word ptr cs:[wall_b]
				inc	cx
				mov	ax, word ptr cs:[wall_a]
				wall_13:
				
					push	cx
					push	ax
					mul	word ptr cs:[wall_dy + 2]
					xor	dx, dx
					div	word ptr cs:[wall_dx + 2]
					cmp	word ptr cs:[wall_dy], 1
					jz	wall_14
					
						neg	ax
					
					wall_14:
					mov	bx, ax
					add	bx, word ptr cs:[wall_r + 2]
					pop	ax
					
					push	ax
					push	bx
					push	ax
						push	bx
					mov	cl, 2
					shl	bx, cl	;bx = 4*y
					pop	ax
					add	bx, ax	;bx = 5*y
					mov	cl, 6
					shl	bx, cl	;bx = 320*y
					pop	ax
					add	bx, ax	;bx = 320*y + x
					mov	al, byte ptr ds:[bx]
					xor	ah, ah
					add	word ptr cs:[wall_sum], ax
					
					pop	bx
					pop	ax
	
					pop	cx
				
				inc	ax
				cmp	ax, cx
				jnz	wall_13
		
		jmp	wall_4
		wall_8:
		
			cmp	word ptr cs:[wall_dy], 1	;by<ay
			jz	wall_16
			
				xor	dx, dx
				mov	ax, word ptr cs:[wall_r + 2]
				div	word ptr cs:[wall_dy + 2]
				cmp	word ptr cs:[wall_r], 1
				jz	wall_19
				
					neg	ax
				
				wall_19:
				mov	word ptr cs:[wall_r + 2], ax
				
				mov	cx, word ptr cs:[wall_a + 2]
				inc	cx
				mov	ax, word ptr cs:[wall_b + 2]
				wall_17:
				
					push	cx
					push	ax
					mul	word ptr cs:[wall_dx + 2]
					xor	dx, dx
					div	word ptr cs:[wall_dy + 2]
					cmp	word ptr cs:[wall_dx], 1
					jnz	wall_18
					
						neg	ax
					
					wall_18:
					mov	bx, ax
					add	bx, word ptr cs:[wall_r + 2]
					pop	ax
					
					push	ax
					xchg	ax, bx
					push	ax
					push	bx
					mov	cl, 2
					shl	bx, cl	;bx = 4*y
					pop	ax
					add	bx, ax	;bx = 5*y
					mov	cl, 6
					shl	bx, cl	;bx = 320*y
					pop	ax
					add	bx, ax	;bx = 320*y + x
					mov	al, byte ptr ds:[bx]
					xor	ah, ah
					add	word ptr cs:[wall_sum], ax
					
					pop	ax
		
					pop	cx
				
				inc	ax
				cmp	ax, cx
				jnz	wall_17
			
			jmp	wall_4
			wall_16:
			
				xor	dx, dx
				mov	ax, word ptr cs:[wall_r + 2]
				div	word ptr cs:[wall_dy + 2]
				cmp	word ptr cs:[wall_r], 1
				jnz	wall_22
				
					neg	ax
				
				wall_22:
				mov	word ptr cs:[wall_r + 2], ax
				
				mov	cx, word ptr cs:[wall_b + 2]
				inc	cx
				mov	ax, word ptr cs:[wall_a + 2]
				wall_20:
				
					push	cx
					push	ax
					mul	word ptr cs:[wall_dx + 2]
					xor	dx, dx
					div	word ptr cs:[wall_dy + 2]
					cmp	word ptr cs:[wall_dx], 1
					jz	wall_21
					
						neg	ax
					
					wall_21:
					mov	bx, ax
					add	bx, word ptr cs:[wall_r + 2]
					pop	ax
					
					push	ax
					xchg	ax, bx
					push	ax
					push	bx
					mov	cl, 2
					shl	bx, cl	;bx = 4*y
					pop	ax
					add	bx, ax	;bx = 5*y
					mov	cl, 6
					shl	bx, cl	;bx = 320*y
					pop	ax
					add	bx, ax	;bx = 320*y + x
					mov	al, byte ptr ds:[bx]
					xor	ah, ah
					add	word ptr cs:[wall_sum], ax
					
					pop	ax
		
					pop	cx
				
				inc	ax
				cmp	ax, cx
				jnz	wall_20
		
	wall_4:
	
;	if (dx=0)
;	{
;		rysuj pionowa linie;
;	}
;	else
;	{
;		if (dx>dy)
;		{
;			if (dx_z=0)	;x1>x2
;			{
;				b=b/dx;
;				for (int i=x2; i<=x1;i++)
;				{
;					w=dy*i;
;					w=w/dx;
;					w=w+b;
;				}
;			}
;			else
;			{
;				b=b/dx;
;				for (int i=x1; i<=x2;i++)
;				{
;					w=dy*i;
;					w=w/dx;
;					w=w+b;
;				}
;			}
;		}
;		else	//(dx-dy<0)
;		{
;			if (dy_z=0)	;y1>y2
;			{
;				b=b/dx;
;				for (int i=y2; i<=y1;i++)
;				{
;					w=i*dx;
;					w=w/dy;
;					w=w-b;
;				}
;			}
;			else
;			{
;				b=b/dx;
;				for (int i=y1; i<=y2;i++)
;				{
;					w=i*dx;
;					w=w/dy;
;					w=w-b;
;				}
;			}
;		}
;	}
	
	xor	cl, cl
	mov	ax, word ptr cs:[wall_sum]
	dec	ax
	cmp	ax, 0ffffh
	jz	wall_e
		inc	cl
	wall_e:
	
	ret
wall_a	dw	10,10
wall_b	dw	100,10
wall_sum	dw	0	;suma bitow
wall_dy	dw	0,0	;y1-y2 znak+wartosc
wall_dx	dw	0,0	;x1-x2
wall_r	dw	0,0	;y2x1-y1x2
;--------------------------------------------------------------
print_map:	;###rysuje mape #ds-data seg###
	;ax=x, bx=y, cl-kolor, ch-ilosc pixeli
	
	push	ax
	push	bx
	push	cx
	
	mov	cl, 28	;do konca funkcji to bedzie ten wlasnie kolor
	
	mov	ax, 0
	mov	bx, 180
	mov	ch, 200
	call	set_pixel
	
	mov	ax, 200
	mov	ch, 120
	call	set_pixel
	
	mov	ax, 0
	mov	bx, 40
	mov	ch, 20
	call	set_pixel
	
	mov	ax, 20
	mov	bx, 60
	mov	ch, 40
	call	set_pixel
	
	mov	bx, 100
	mov	ch, 160
	call	set_pixel
	
	mov	ax, 40
	mov	bx, 80
	mov	ch, 140
	call	set_pixel
	
	mov	bx, 160
	mov	ch, 40
	call	set_pixel
	
	mov	ax, 60
	mov	bx, 20
	mov	ch, 80
	call	set_pixel
	
	mov	ax, 80
	mov	bx, 40
	mov	ch, 40
	call	set_pixel
	
	mov	bx, 120
	call	set_pixel
	
	mov	ax, 140
	mov	bx, 120
	mov	ch, 100
	call	set_pixel
	
	mov	ax, 180
	mov	bx, 20
	mov	ch, 100
	call	set_pixel
	
	mov	bx, 40
	mov	ch, 60
	call	set_pixel
	
	mov	bx, 60
	mov	ch, 80
	call	set_pixel
	
	mov	ax, 200
	mov	bx, 80
	mov	ch, 60
	call	set_pixel
	
	mov	bx, 100
	mov	ch, 100
	call	set_pixel
	
	mov	ax, 280
	mov	bx, 120
	mov	ch, 40
	call	set_pixel
	
	mov	ax, 300
	mov	bx, 20
	mov	ch, 20
	call	set_pixel
	
	mov	bx, 80
	call	set_pixel
	
	;pionowe-----------------
	
	mov	ax, 20
	mov	bx, 60
	mov	ch, 100
	call	set_pixel_y
	
	mov	ax, 40
	mov	bx, 0
	mov	ch, 40
	call	set_pixel_y
	
	mov	ax, 60
	mov	bx, 20
	mov	ch, 20
	call	set_pixel_y
	
	mov	ax, 80
	mov	bx, 40
	mov	ch, 40
	call	set_pixel_y
	
	mov	bx, 120
	mov	ch, 60
	call	set_pixel_y
	
	mov	ax, 120
	mov	bx, 120
	mov	ch, 40
	call	set_pixel_y
	
	mov	ax, 140
	mov	bx, 20
	mov	ch, 80
	call	set_pixel_y
	
	mov	bx, 100
	mov	ch, 80
	call	set_pixel_y
	
	mov	ax, 180
	mov	bx, 40
	mov	ch, 20
	call	set_pixel_y
	
	mov	ax, 200
	mov	bx, 80
	call	set_pixel_y
	
	mov	ax, 240
	mov	bx, 120
	call	set_pixel_y
	
	mov	ax, 280
	mov	bx, 20
	mov	ch, 60
	call	set_pixel_y
	
	mov	bx, 160
	mov	ch, 20
	call	set_pixel_y
	
	mov	ax, 300
	mov	bx, 20
	call	set_pixel_y
	
	mov	bx, 60
	call	set_pixel_y
	
	pop	cx
	pop	bx
	pop	ax
	
	ret
;--------------------------------------------------------------
set_pixel_y:	;###ustawia pionowa linie pixeli #ds- data seg, ax-x, bx-y, cl-kolor, ch-il###
	
	push	cx
	push	bx
	
pixel_y_l0:
	push	cx
	
		xor	ch, ch
		inc	ch
		call	set_pixel
	
	pop	cx
	inc	bx
	dec	ch
	cmp	ch, 1
	jns	pixel_y_l0
	
	pop	bx
	pop	cx
	
	ret
;--------------------------------------------------------------
set_my_vector:	;###ustawia wektor przesuniecia mojego czolgu #ds-data seg, cs-code seg###

	push	ax
	push	bx
	push	cx

	; pionowo
	mov	ah, byte ptr cs:[wsad]	;ah-przod
	mov	al, byte ptr cs:[wsad + 1]	;al=tyl
	
	xor	bh, bh
	mov	bl, ah	;sumuje bh=ah+al
	add	bl, al

	cmp	bl, 1
	js	my_vector_X	;jesli ah + al =0 to brak przemieszczenia

	cmp	ah, al
	js	my_vector_1	;jesli tyl jest wiekszy

	xor	bx, bx
	xor	ax, ax
	inc	ax
	cmp	word ptr ds:[tank_0 + 2], ax	;sprawdzenie czy mozna w gore
	js	my_vector_x
	dec	bx
	jmp	my_vector_x
	
my_vector_1:
	xor	bx, bx	;y=1 czyli w dol
	mov	ax, 190
	cmp	word ptr ds:[tank_0 + 2], ax	;sprawdzenie czy mozna zejsc w dol
	jns	my_vector_x
	inc	bx

my_vector_X:
	mov	word ptr ds:[vector_0 + 2], bx

	
	;poziomo
	mov	ah, byte ptr cs:[wsad + 2]	;lewo
	mov	al, byte ptr cs:[wsad + 3]	;prawo

	xor	bh, bh
	mov	bl, ah	;bx=ah + al
	add	bl, al
	
	cmp	bl, 1
	js	my_vector_e	;jesli suma rowna 0

	cmp	ah, al
	js	my_vector_2	;jesli w prawo to skok
	
	xor	bx, bx
	xor	ax, ax
	inc	ax
	cmp	word ptr ds:[tank_0], ax	;sprawdzenie czy mozna w lewo 
	js	my_vector_e
	dec	bx
	jmp	my_vector_e

my_vector_2:
	xor	bx, bx
	mov	ax, 310
	cmp	word ptr ds:[tank_0], ax	;sprawdzenie czy mozna w prawo
	jns	my_vector_e
	inc	bx
	
my_vector_e:
	mov	word ptr ds:[vector_0], bx
	
		
	mov	ax, word ptr ds:[vector_0]	;sprawdzenie czy nie ma sciany w poziomie
	cmp	ax, 1
	jz	my_vector_r
	cmp	ax, 0ffffh
	jz	my_vector_l
	jmp	my_vector_3
my_vector_r:	;na prawo
	
	mov	ax, word ptr ds:[tank_0]
	mov	bx, word ptr ds:[tank_0 + 2]
	add	ax, 10
	push	ax
	push	bx
	mov	cl, 2
	shl	bx, cl	;bx = 4*y
	pop	ax
	add	bx, ax	;bx = 5*y
	mov	cl, 6
	shl	bx, cl	;bx = 320*y
	pop	ax
	add	bx, ax	;bx = 320*y + x
	mov	ax, offset video_buf
	add	bx, ax
	mov	al, byte ptr ds:[bx]	;dodaje 10 wartosci po prawej
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	dec	al
	cmp	al, 0ffh
	jz	my_vector_3
	
	mov	word ptr ds:[vector_0], 0
	
	jmp	my_vector_3
my_vector_l:	;na lewo
	
	mov	ax, word ptr ds:[tank_0]
	mov	bx, word ptr ds:[tank_0 + 2]
	dec	ax
	push	ax
	push	bx
	mov	cl, 2
	shl	bx, cl	;bx = 4*y
	pop	ax
	add	bx, ax	;bx = 5*y
	mov	cl, 6
	shl	bx, cl	;bx = 320*y
	pop	ax
	add	bx, ax	;bx = 320*y + x
	mov	ax, offset video_buf
	add	bx, ax
	mov	al, byte ptr ds:[bx]	;dodaje 10 wartosci po lewej
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	add	bx, 320
	add	al, byte ptr ds:[bx]
	dec	al
	cmp	al, 0ffh
	jz	my_vector_3
	
	mov	word ptr ds:[vector_0], 0
	
my_vector_3:
	
	mov	ax, word ptr ds:[vector_0 + 2]	;sprawdzenie czy nie ma scniany w pionie
	cmp	ax, 1
	jz	my_vector_down
	cmp	ax, 0ffffh
	jz	my_vector_up
	jmp	my_vector_end
my_vector_down:
	
	mov	ax, word ptr ds:[tank_0]
	mov	bx, word ptr ds:[tank_0 + 2]
	add	bx, 10
	push	ax
	push	bx
	mov	cl, 2
	shl	bx, cl	;bx = 4*y
	pop	ax
	add	bx, ax	;bx = 5*y
	mov	cl, 6
	shl	bx, cl	;bx = 320*y
	pop	ax
	add	bx, ax	;bx = 320*y + x
	mov	ax, offset video_buf
	add	bx, ax
	mov	al, byte ptr ds:[bx]	;dodaje 10 wartosci po lewej
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	dec	al
	cmp	al, 0ffh
	jz	my_vector_end
	
	mov	word ptr ds:[vector_0 + 2], 0
	
	jmp	my_vector_end
my_vector_up:
	
	mov	ax, word ptr ds:[tank_0]
	mov	bx, word ptr ds:[tank_0 + 2]
	dec	bx
	push	ax
	push	bx
	mov	cl, 2
	shl	bx, cl	;bx = 4*y
	pop	ax
	add	bx, ax	;bx = 5*y
	mov	cl, 6
	shl	bx, cl	;bx = 320*y
	pop	ax
	add	bx, ax	;bx = 320*y + x
	mov	ax, offset video_buf
	add	bx, ax
	mov	al, byte ptr ds:[bx]	;dodaje 10 wartosci po lewej
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	inc	bx
	add	al, byte ptr ds:[bx]
	dec	al
	cmp	al, 0ffh
	jz	my_vector_end
	
	mov	word ptr ds:[vector_0 + 2], 0
	
my_vector_end:
	
	pop	cx
	pop	bx
	pop	ax

	ret
;--------------------------------------------------------------
set_my_cannon:	;###ustawia armate #dx-data seg, cs-code seg###
	
	push	ax
	push	bx
	
	xor	bx, bx
	mov	al, cs:[ptlp]
	add	al, cs:[ptlp + 1]
	cmp	al, 1
	js	my_cannon_x
	mov	al, cs:[ptlp + 1]
	cmp	al, cs:[ptlp]
	js	my_cannon_up	;skok jesli przod ma wiekszy priorytet niz tyl
	
	inc	bx	;ustawienie wektora w dol	

	jmp	my_cannon_x

my_cannon_up:
	dec	bx	;ustawienie wektora na gore
	
	;os x
my_cannon_x:

	mov	word ptr ds:[tank_0 + 6], bx	;uzupelnienie poprzedniego

	xor	bx, bx
	mov	al, cs:[ptlp + 2]
	add	al, cs:[ptlp + 3]
	cmp	al, 1
	js	my_cannon_next

	mov	al, cs:[ptlp + 3]
	cmp	al, cs:[ptlp + 2]
	js	my_cannon_left

	inc	bx
	jmp	my_cannon_next

my_cannon_left:

	dec	bx

my_cannon_next:

	mov	word ptr ds:[tank_0 + 4], bx

	mov	ax, word ptr ds:[tank_0 + 4]
	cmp	ax, 1
	jz	my_cannon_end	;sprawdza czy wspolrzedne wektroa x =0
	cmp	ax, 0ffffh
	jz	my_cannon_end

	mov	ax, word ptr ds:[tank_0 + 6]
	cmp	ax, 1
	jns	my_cannon_end	;sprawdza czy wspolrzedne wektroa y =0
	cmp	ax, 0ffffh
	jz	my_cannon_end
	
	xor	bx, bx
	dec	bx
	mov	word ptr ds:[tank_0 + 6], bx
	
my_cannon_end:

	pop	bx
	pop	ax
	
	ret
;--------------------------------------------------------------
set_pixel:	;###ustawia kolor pixela w buforze #ds-segment buf, ax=x, bx=y, cl-kolor, ch-ilosc pixeli###
	
	push	bx
	push	ax
	push	cx

	;x=<0;319>, y=<0;199>
	;bx=y*(4 + 1)*64 + x

	push	ax
	push	bx
	mov	cl, 2
	shl	bx, cl	;bx = 4*y
	pop	ax
	add	bx, ax	;bx = 5*y
	
	mov	cl, 6
	shl	bx, cl	;bx = 320*y

	pop	ax
	add	bx, ax	;bx = 320*y + x
	
	pop	cx
	
	xor	al, al
pixel_l0:
	mov	ds:[bx], cl
	inc	bx
	inc	al
	cmp	al, ch
	jnz	pixel_l0
	
	pop	ax
	pop	bx

	ret
;--------------------------------------------------------------
print_tank:	;###rysuje czolg w buforze #bx-offset do struktury, cl-kolor, ds-data segemnt###
	
	push	ax
	push	bx
	push	cx
	
	;na poczatek dodajemy wektory przesuniecia
	mov	ax, word ptr ds:[bx]	;poz x mojego czolgu
	add	ax, word ptr ds:[bx + 8]	;wektor przesuniecia x
	mov	word ptr ds:[bx], ax	;nowa pozycja x
	mov	ax, word ptr ds:[bx + 2]	;poz y mojego czolgu
	add	ax, word ptr ds:[bx + 10]	;wektor przesuniecia y
	mov	word ptr ds:[bx + 2], ax	;nowa pozycja y

	push	dx
	
	mov	ch, cl
	mov	cl, 2
	mov	ax, word ptr ds:[bx + 4]	;wyrzuca wspolrzedna x*4 wektora
	shl	ax, cl
	push	ax
	mov	ax, word ptr ds:[bx + 6]	;wyrzuca wspolrzedna y*4 wektora
	shl	ax, cl
	push	ax
	mov	cl, ch	;przywrocenie koloru do cl

	mov	ax, word ptr ds:[bx]	;wspolrzedna x prawego gornego rogu czolgu do ax
	mov	bx, word ptr ds:[bx + 2]	;wspolrzedna y do bx
	
	push	cx	;kolorowanie pola wokol czolgu
	push	ax
	push	bx
	mov	cl, 20	;kolor tla
	mov	ch, 10
	call	set_pixel
	call	set_pixel_y
	inc	ax
	call	set_pixel_y
	dec	ax
	inc	bx
	call	set_pixel	;wymalowana gora i dol
	add	bx, 7
	call	set_pixel
	inc	bx
	call	set_pixel	;wymalowany dol
	pop	bx
	add	ax, 8
	call	set_pixel_y
	inc	ax
	call	set_pixel_y	;wymalowana prawa strona
	pop	ax
	pop	cx
	
	inc	ax	;czolg zaczyna sie 2 pixele dalej bo wokol czolgu jest rezerwa na armate
	inc	ax
	inc	bx
	inc	bx

	mov	ch, 6
	call	set_pixel	;rysowanie czolgu
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	inc	bx
	call	set_pixel
	
	inc	ax	;ustawienie srodka czolgu
	inc	ax
	dec	bx
	dec	bx

	mov	dl, cl
	pop	cx
	add	bx, cx	;ustawienie prawego dolnego rogu kwadratu czolgu
	pop	cx
	add	ax, cx
	mov	cl, dl

	mov	ch, 2	;rysowanie armaty
	call	set_pixel
	dec	bx
	call	set_pixel
	
	pop	dx	;przywrocenie dx
	
	pop	cx
	pop	bx
	pop	ax

	ret
;--------------------------------------------------------------
print_buf:	;###kopiuje bufor do segmentu video #es-pamiec video, ds-pamiec buf#si,di##
	
	push	cx

	xor	si, si
	xor	di, di
	mov	cx, 32000	;ilosc wyrazow do skopiowania (320*200/2=32000)
	cld	;upewnienie sie ze dirction flag jest wyczyszczona
	rep	movsw	;cx wyrazow jest przemieszonych z ds:[si] do es:[di]

	pop	cx

	ret
;--------------------------------------------------------------
clear_buf:	;###wypelnia bufor zerami #ds-pamiec buf###
	
	push	ax
	push	bx

	xor	bx, bx
	xor	al, al
clear_l0:
	mov	ds:[bx], al
	
	inc	bx
	cmp	bh, 0fah	;petla wykonuje sie 250*256 razy (fa * ff)(hex)
	jnz	clear_l0

	pop	bx
	pop	ax
	
	ret
;--------------------------------------------------------------
wyp_ax:	;###wypisuje rejestr ax #cs-code segment z ta proc###

	push	ax

	;###uzupelnienie zmiennej
	push	cx
	push	ax	;kopia zmiennej
	mov	cl, 4	;o ile bitow przesunac
	shr	ah, cl	;1 znak
	cmp	ah, 10	;zamiana na liczbe lub znak
	js	dod1	;jesli wynik ah-10 jest dodatni
	add	ah, 7
dod1:
	add	ah, 30h
	mov	byte ptr cs:[ax_txt], ah
	shr	al, cl	;3 znak
	cmp	al, 10
	js	dod2	;jesli wynik al-10 jest dodatni
	add	al, 7
dod2:
	add	al, 30h
	mov	byte ptr cs:[ax_txt + 2], al
	pop	ax	;przywrocenie kopii
	shl	ah, cl	;2 znak
	shr	ah, cl
	cmp	ah, 10
	js	dod3	;jesli wynik ah-10 jest dodatni
	add	ah, 7
dod3:
	add	ah, 30h
	mov	byte ptr cs:[ax_txt + 1], ah
	shl	al, cl	;4 znak
	shr	al, cl
	cmp	al, 10
	js	dod4	;jesli wynik al-10 jest dodatni
	add	al, 7
dod4:
	add	al, 30h
	mov	byte ptr cs:[ax_txt + 3], al
	pop	cx

	;###wypisanie 
	push	ds
	push	dx
	mov	dx, offset ax_txt
	mov	ax, cs
	mov	ds, ax
	mov	ah, 9
	int	21h
	pop	dx
	pop	ds

	pop	ax

	ret	;powrot

ax_txt	db "abcdH",10,13,'$'	;zmienna potrzebna do wypisania ax
;--------------------------------------------------------------
zamien:	;####zamiana wsad na wartosc do odczytu #cs-cs z ta proc##ax-lepsze wyswietlenie#
	push	bx
	push	cx
	
	mov	ah, cs:[ptlp]
	mov	cl, 4
	shl	ah, cl
	add	ah, cs:[ptlp + 1]
	
	mov	al, cs:[ptlp + 2]
	shl	al, cl
	add	al, cs:[ptlp + 3]
	
	pop	cx
	pop	bx
	ret
;--------------------------------------------------------------
count_ah:	;###ustawia preferencje w ah i cs:bx #bx-offset 2 zmiennej,ah={0,1}#cl##
	
	cmp	ah, 1
	jnz	count_ah_0	;jesli ah=0 skok do ah_0

	mov	cl, ah		; ah cs wynik(ah)	;oto co robi z wartosciami w ah,cs
	add	cl, cs:[bx]	; 0  0  0
	inc	ah		; 0  1  0
	inc	ah		; 1  0  1
	and	ah, cl		; 1  1  2
	jmp	count_ah_end
	
count_ah_0:	;uzupelnia wartosc cs:[bx]
	xor	ah, ah
	mov	cl, cs:[bx]
	cmp	cl, 2
	jnz	count_ah_end
	dec	cl
	mov	cs:[bx], cl
count_ah_end:
	
	ret
;--------------------------------------------------------------
call_keyboard:	;###wlasne zdarzenie obslugi klawiatury #cs-code segemnt tej proc###
	sti	;ustwienie flagi (?)
	
	push	ax
	push	cx
	push	bx
	in	al, 60h	;odczytaj znak ostatniego klawisza
	
	xor	ah, ah
	inc	ah	;jest 1 czyli wcisniety klawisz
	cmp	al, 80h
	js	key_press	;jesli wcisniety to ah=1 i w al key_code
	dec	ah	;jesli nie wcisniety ah=0 i al=al-128
	mov	cl, 1
	shl	al, cl
	shr	al, cl
key_press:
	
	cmp	ax, word ptr cs:[last_code]	;sprawdz czy kod jest taki sam jak ostatnio
	jz	key_done_alias		;zeby nie wykonywac znow tych porownan
	
	;-------------------
	cmp	al, 17	;czy w?
	jnz	not_w

	mov	bx, offset wsad
	inc	bx
	call	count_ah	;wylicza wartosc ah i ewentualnie zmienia cs:[bx]

	mov	cs:[wsad], ah
	jmp	key_done_alias
not_w:

	cmp	al, 31	;czy s?
	jnz	not_s

	mov	bx, offset wsad
	call	count_ah

	mov	cs:[wsad + 1], ah
	jmp	key_done
not_s:

	cmp	al, 30	;czy a?
	jnz	not_a
	
	mov	bx, offset wsad
	add	bx, 3
	call	count_ah

	mov	cs:[wsad + 2], ah
	jmp	key_done
not_a:

	cmp	al, 32	;czy d?
	jnz	not_d

	mov	bx, offset wsad
	inc	bx
	inc	bx
	call	count_ah

	mov	cs:[wsad + 3], ah
	jmp	key_done
key_done_alias:
	jmp	key_done
not_d:

	cmp	al, 1	;czy esc?
	jnz	not_esc
	mov	cs:[esc_b], ah
	jmp	key_done
not_esc:
	
	cmp	al, 75	;czy strzalka w lewo?
	jnz	not_left

	mov	bx, offset ptlp
	add	bx, 3
	call	count_ah

	mov	cs:[ptlp + 2], ah
	jmp	key_done
not_left:

	cmp	al, 77	;czy strzalka w prawo?
	jnz	not_right

	mov	bx, offset ptlp
	inc	bx
	inc	bx
	call	count_ah

	mov	cs:[ptlp + 3], ah
	jmp	key_done
not_right:

	cmp	al, 72	;czy strzalka w gore?
	jnz	not_up

	mov	bx, offset ptlp
	inc	bx
	call	count_ah

	mov	cs:[ptlp], ah
	jmp	key_done
not_up:

	cmp	al, 80	;czy strzalka w dol?
	jnz	not_down

	mov	bx, offset ptlp
	call	count_ah

	mov	cs:[ptlp + 1], ah
	jmp	key_done
not_down:

	cmp	al, 57	;czy spacja?
	jnz	not_space
	mov	cs:[space_b], ah
	jmp	key_done
not_space:
	;-------------------

key_done:

	mov	word ptr cs:[last_code], ax
	
	mov	al, 20h
	out	20h, al
	
	pop	bx
	pop	cx
	pop	ax

	cli
	iret	;powrot
wsad	db	0,0,0,0	;poruszanie sie: przod, tyl, lewo, prawo
ptlp	db	0,0,0,0	;armata: przod, tyl, lewo, prawo
space_b	db	0	;przycisk spacja (strzal)
esc_b	db	0	;przycisk esc
last_code	dw	0	;ostatni kod znaku
;--------------------------------------------------------------
set_keyboard:	;###ustawia obsluge klawiatury #cs-segment kodu z ta proc###
	
	push	es
	push	dx
	push	bx
	push	ax
	
	mov	ax, 3509h	;pobieram adres przerwania 09h do es:bx
	int	21h
	mov	cs:[old_keyboard_dx], bx	;zapis starej lokalizacji do zmiennych
	mov	ax, es
	mov	cs:[old_keyboard_ds], ax
	push	ds	;ustaw pod przerwanie 09h wartosc z ds:dx bez zmiany ds
	mov	ax, cs
	mov	ds, ax
	mov	dx, offset call_keyboard
	mov	ax, 2509h
	int	21h
	pop	ds
	
	pop	ax
	pop	bx
	pop	dx
	pop	es
	
	ret	;powrot
old_keyboard_dx	dw	0	;zmienna ze starym offsetem na przerwanie sprz.
old_keyboard_ds	dw	0	;ds potrzebne do przywrocenia wartosci
;--------------------------------------------------------------
restore_keyboard:	;przywraca dawna obsluge klawiatury #cs-segment kodu###
	
	push	ds
	push	ax
	push	dx
	
	mov	ax, cs:[old_keyboard_ds]	;uzupelnianie ds:dx
	mov	ds, ax
	mov	dx, cs:[old_keyboard_dx]
	mov	ax, 2509h
	int	21h
	
	pop	dx
	pop	ax
	pop	ds
	ret	;powrot
;--------------------------------------------------------------
set_video:	;###ustawia tryb graficzny ###es-offset pixeli#

	push	ax

	mov	al,13h	;tryb graficzny 320 x 200 (256 kolorow)
	mov	ah,0	;polecenie zmiany trybu
	int	10h
	
	mov	ax, 0a000h	;adres segmentu pamieci w trybie graficznym
	mov	es, ax

	pop	ax
	
	ret
;--------------------------------------------------------------
restore_video:	;###przywraca tryb tekstowy ####

	push	ax

	mov	al,3	;tryb tekstowy
	mov	ah,0	;polecenie zmiany trybu (przywrocenie trybu tekstowego
	int	10h

	pop	ax

	ret
;--------------------------------------------------------------
show_info:	;###pokazuje informacje na ekranie o stanie zakonczenia gry #al=0 gra nie rozstrzygnieta, al=1 koniec gry[ah=1 wygrana, ah=2 przegrana]###
	
	cmp	al, 1
	jz	show_info_0
	
		ret
	
	show_info_0:
	
	push	ax
	mov	ax, 0b800h	;adres segmentu pamieci w trybie tekstowym
	mov	es, ax
	pop	ax
	
	mov	bx, 3652	;ustawienie na prawy dolny rog (66, 21)
	mov	byte ptr es:[bx], 'A'	;wypisanie imienia i nazwiska
	mov	byte ptr es:[bx + 2], 'r'
	mov	byte ptr es:[bx + 4], 't'
	mov	byte ptr es:[bx + 6], 'u'
	mov	byte ptr es:[bx + 8], 'r'
	mov	byte ptr es:[bx + 12], 'B'
	mov	byte ptr es:[bx + 14], 'o'
	mov	byte ptr es:[bx + 16], 'n'
	mov	byte ptr es:[bx + 18], 'd'
	mov	byte ptr es:[bx + 20], 'e'
	mov	byte ptr es:[bx + 22], 'k'
	
	mov	bx, 1992	;ustawienie na srodek konsoli
	cmp	ah, 1
	jz	show_info_victory
	
		mov	byte ptr es:[bx], 'D'	;wypisuje "Defeat"
		mov	byte ptr es:[bx + 2], 'e'
		mov	byte ptr es:[bx + 4], 'f'
		mov	byte ptr es:[bx + 6], 'e'
		mov	byte ptr es:[bx + 8], 'a'
		mov	byte ptr es:[bx + 10], 't'
	
	jmp	show_info_end
	show_info_victory:
	
		mov	byte ptr es:[bx], 'V'	;wypisuje "Victory"
		mov	byte ptr es:[bx + 2], 'i'
		mov	byte ptr es:[bx + 4], 'c'
		mov	byte ptr es:[bx + 6], 't'
		mov	byte ptr es:[bx + 8], 'o'
		mov	byte ptr es:[bx + 10], 'r'
		mov	byte ptr es:[bx + 12], 'y'
	
	show_info_end:
	
	xor	ax, ax
	mov	bx, offset tank_1	;sumuje w ax punkty
	call	points
	add	ax, bx
	mov	bx, offset tank_2
	call	points
	add	ax, bx
	mov	bx, offset tank_3
	call	points
	add	ax, bx
	mov	bx, offset tank_4
	call	points
	add	ax, bx
	mov	bx, offset tank_5
	call	points
	add	ax, bx
	mov	bx, offset tank_6
	call	points
	add	ax, bx
	mov	bx, offset tank_7
	call	points
	add	ax, bx
	mov	bx, offset tank_8
	call	points
	add	ax, bx
	mov	bx, offset tank_9
	call	points
	add	ax, bx
	mov	bx, offset tank_10
	call	points
	add	ax, bx
	
	mov	bx, ax
	mov	ax, 100		;dodaje pkt za moje zycia
	mul	byte ptr ds:[tank_0 + 12]	;il moich zyc
	add	ax, bx
	
	mov	bx, 2472	;offset gdzie wypisac "Points"	(37, 15)
	mov	byte ptr es:[bx], 'P'
	mov	byte ptr es:[bx + 2], 'o'
	mov	byte ptr es:[bx + 4], 'i'
	mov	byte ptr es:[bx + 6], 'n'
	mov	byte ptr es:[bx + 8], 't'
	mov	byte ptr es:[bx + 10], 's'
	
	mov	bx, 2638	;offset gdzie wypisac wynik
	
	mov	cx, ax
	dec	cx
	cmp	cx, 0ffffh
	jz	show_info_3	;jesli wynik to 0 to wypisz 0 i tyle
	
	inc	bx
	inc	bx
	
	show_info_2:
	mov	cx, ax
	dec	cx
	cmp	cx, 0ffffh
	jz	show_info_1	;wypisywanie wyniku dopoki ax!=0
	
		mov	dl, 10
		div	dl
		add	ah, '0'	;zamiana na cyfre
		mov	byte ptr es:[bx], ah
		dec	bx
		dec	bx
		xor	ah, ah
	
	jmp	show_info_2
	
	show_info_3:
	mov	al, '0'
	mov	byte ptr es:[bx], al
	
	show_info_1:
	
	mov	bl, 10	;wypisanie pkt
	div	bl
	
	xor	ah, ah	;czekaj na dowolny znak
	int	16h
	
	ret
;--------------------------------------------------------------
points:	;###zwraca ilosc pkt za danego wroga #bx-offset do struk##bx-wynik w pkt#
	
	cmp	byte ptr ds:[bx + 12], 2
	jz	points_2
	
	cmp	byte ptr ds:[bx + 12], 1
	jz	points_1
	
	mov	bx, 150	;jesli pokonany
	ret
	
	points_1:
	mov	bx, 50	;jesli polowe zycia
	ret
	
	points_2:
	xor	bx, bx	;jesli nie ruszony
	
	ret
;---KONIEC-----------------------------------------------------

code1	ends



stos1	segment stack
	dw 200 dup(?)
wstosu	dw ?
stos1	ends


end	start1