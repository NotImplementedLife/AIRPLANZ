INCLUDE "inc/hardware.inc"
INCLUDE "inc/constants.asm"

INCLUDE "inc/header.asm"


SECTION "Work Ram", WRAM0[$C000]

; tells the cpu when to scroll map from "YOU" to "OP" and vice-versa
; scrollFlag > $80 ==> scroll from (112,112) to (0,0)
; scrollFlag < $80 ==> scroll from (0,0) to (112,112)
scrollFlag::
	DS 1

SECTION "Main", ROM0

INCLUDE "inc/memory.asm"
INCLUDE "inc/vblank.asm"

INCLUDE "source/title.asm"
INCLUDE "source/tilemap.asm"

Start:

	; init scroll flag
	ld a, SCROLL_FLAG_0 ;- 112
	ld [scrollFlag], a
    ; Turn off the LCD
	call waitForVBlank
	
    xor a
    ld [rLCDC],a 

    ; copy the font to VRAM	
    ld hl, CHARS_PTR
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles
	call loadMemory
	
	; copy tiles to VRAM
	ld hl, TILES_PTR
    ld de, Tileset
    ld bc, TilesetEnd - Tileset
	call loadMemory	
		    
	;call drawTitleBackground
	ld hl, SCREEN_PTR
	ld de, Tilemap
	ld bc, TilemapEnd - Tilemap
	call loadMemory	
	
	xor a ; ld a, 0		
    ld [rSCX], a	
    ld [rSCY], a
	
	; Init display registers
    ld a, %00110110
    ld [rBGP], a    
.loop		    
	call updateMapScroll
;	ld a, [scrollFlag]
;	cp a, SCROLL_FLAG_0
;	jr nz, .draw
;	ld b, 100
;.wait
;	call waitForVBlank
;	dec b
;	ld a, b
;	cp a, 0	
;	jr nz, .wait
;	ld a, [rSCX]
;	cp a, 0
;	;jr z, .set112
;.set0
	;ld a, SCROLL_FLAG_0 + 112
	;ld [scrollFlag], a
	;jr .draw
;.set112
	;ld a, SCROLL_FLAG_0 - 112
	;ld [scrollFlag], a
	;jr .draw
.draw
    ; Turn screen on, display background
    ld a, %10000001
    ld [rLCDC], a	
	
	call waitForVBlank
    
    jr .loop

SECTION "FONT", ROM0

FontTiles:
INCBIN "res/font.chr"
FontTilesEnd:

SECTION "Tileset", ROM0

Tileset:
INCLUDE "res/tileset.asm"
TilesetEnd:

Tilemap:
INCLUDE "res/tilemap.asm"
TilemapEnd:

SECTION "Strings", ROM0

Str_PLAY:
    db $50, $4C, $41, $59, $00
Str_CRB:
	db $01, $01, $01, $01, $01, $43, $72, $65, $61, $74, $65, $64, $01, $62, $79, $01
	db $01, $01, $01, $01 ,$38, $35, $33, $31, $39, $39, $30, $33, $34, $33, $35, $38 
	db $01, $4E, $6F, $74, $49, $6D, $70, $6C, $65, $6D, $65, $6E, $74, $65, $64, $4C
	db $69, $66, $65, $01, $31, $38, $31, $32, $31, $32, $32, $30, $31, $30, $30, $35
	db $00
	