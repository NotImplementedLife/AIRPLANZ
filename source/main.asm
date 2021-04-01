INCLUDE "inc/hardware.inc"
INCLUDE "inc/constants.asm"

INCLUDE "inc/header.asm"

INCLUDE "inc/input.asm"

SECTION "Work Ram", WRAM0[$C000]

; tells the cpu when to scroll map from "YOU" to "OP" and vice-versa
; scrollFlag > $80 ==> scroll from (112,112) to (0,0)
; scrollFlag < $80 ==> scroll from (0,0) to (112,112)
scrollFlag:
	DS 1
backup1:
	DS 1
backup2:
	DS 1
backup3:
	DS 1
planesY:
	DS 4
planesX:
	DS 4
	
currentPlane: ; 0, 1, 2
	DS 1 

; planeXData:
;
; byte 0: visible ? 1 : 0
; byte 1: Y (0-9)
; byte 2: X (0-9)
; byte 3: Orientation (0=Up 1=Right 2=Down 3=Left)
plane1Data:
	DS 4
plane2Data:
	DS 4
plane3Data:
	DS 4
	
INCLUDE "inc/oam.asm"


SECTION "Main", ROM0

INCLUDE "inc/memory.asm"
INCLUDE "inc/vblank.asm"

INCLUDE "source/title.asm"
INCLUDE "source/tilemap.asm"
INCLUDE "source/planes.asm"
INCLUDE "source/board.asm"

Start:	
	call waitForVBlank	
	
    ; Turn off the LCD	
    xor a
    ld [rLCDC],a 
	
	; move DMA subroutine to HRAM
	call CopyDMARoutine

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
		    
	; draw main scene to screen
	;call drawTitleBackground
	;ld hl, SCREEN_PTR
	;ld de, Tilemap
	;ld bc, TilemapEnd - Tilemap
	;call loadMemory				
	
	ld hl, planesOamData
	ld de, planesTemplate
	ld bc, 160
	call loadMemory		
	
	xor a ; ld a, 0		
    ld [rSCX], a	
    ld [rSCY], a	
	
;---------------------------------------------------------------
	
.ENTRYPOINT_Title:	
	call drawTitleBackground
	
	; Init display registers
    ld a, %00110110
    ld [rBGP], a    	
	 ; Turn screen on, display background
    ld a, %10000001
    ld [rLCDC], a

	.titleLoop
		call updateJoypadState
		ld   a, [wJoypadState]
		and a, $02		
		cp a, 0		
		jr nz, .ENTRYPOINT_Board
		call waitForVBlank		
	jr .titleLoop
	
;---------------------------------------------------------------
	
.ENTRYPOINT_Board:	
	; init scroll flag
	ld a, SCROLL_FLAG_0 ;- 112	
	ld [scrollFlag], a
	
	call waitForVBlank
	
	; Turn off the LCD	
    xor a
    ld [rLCDC],a 	
		
	ld hl, SCREEN_PTR
	ld de, Tilemap
	ld bc, TilemapEnd - Tilemap
	call loadMemory	
		
	; Turn on sprites 
    ld a, %10000011
    ld [rLCDC], a

	ld a, PLANE_ID_0
	ld b, 0
	ld c, 0
	ld d, PLANE_UP
	call placePlane

	ld a, PLANE_ID_1
	ld b, 0
	ld c, 40
	ld d, PLANE_UP
	call placePlane
	
	ld a, PLANE_ID_2
	ld b, 0
	ld c, 80
	ld d, PLANE_UP
	call placePlane
	
	ld a, PLANE_ID_0
	call hidePlane
	
	ld a, PLANE_ID_1
	call hidePlane

	ld a, PLANE_ID_2
	call hidePlane	
	
	ld a, PLANE_ID_3
	call hidePlane
	
	
	;halt
	ld  a, HIGH(planesOamData)
	call hOAMDMA	

	;call nextBoard
.loop		    
	call updateJoypadState
	call updateMapScroll
	ld   a, [wJoypadState]
	and a, PADF_START		
	cp a, 0		
	call nz, nextBoard
.draw				
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
    db "    > 1 Gameboy     ____________      2 Gameboys", $00
Str_CRB:
	db $01, $01, $01, $01, $01, $43, $72, $65, $61, $74, $65, $64, $01, $62, $79, $01
	db $01, $01, $01, $01 ,$38, $35, $33, $31, $39, $39, $30, $33, $34, $33, $35, $38 
	db $01, $4E, $6F, $74, $49, $6D, $70, $6C, $65, $6D, $65, $6E, $74, $65, $64, $4C
	db $69, $66, $65, $01, $31, $38, $31, $32, $31, $32, $32, $30, $31, $30, $30, $35
	db $00
	