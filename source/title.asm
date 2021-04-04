drawTitleBackground:
	ld b, $90
	ld c, $00
	ld hl, SCREEN_PTR+2
	ld a, $80	
.drawTitleTile
	ld [hli], a
	inc a
	cp a, b
	jr nz, .drawTitleTile		
	ld d, $00
	ld e, $10
	add hl, de
	ld d, a
	ld a, b
	add a, $10
	ld b, a
	inc c	
	ld a, c
	cp a, 5
	ld a, d	
	jr nz, .drawTitleTile	
	ld hl, SCREEN_PTR+10*$20
    ld de, Str_PLAY
    call copyString
	ld hl, SCREEN_PTR+15*$20
    ld de, Str_CRB
    call copyString
	ret
	