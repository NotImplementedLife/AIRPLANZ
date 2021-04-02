INCLUDE "inc/hardware.inc"
INCLUDE "inc/constants.asm"

INCLUDE "inc/header.asm"

INCLUDE "inc/input.asm"

INCLUDE "inc/wram_vars.asm"

	
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
	
	;ld hl, planesOamData
	;ld de, planesTemplate
	;ld bc, 160
	;call loadMemory		
	
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
		and a, PADF_A		
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
	
	call clearOAM
	call initPlanes		
	
	
	ld a, 0
	ld [crtTurn], a	
			
	call hideBoard
	call showBoard			
	
	;call crtMoveRight
	; Turn on sprites 
    ld a, %10000011
    ld [rLCDC], a		
	
	xor a	
	;ld a, 112
    ld [rSCX], a	
    ld [rSCY], a			

	ld  a, HIGH(planesOamData)
	call hOAMDMA	

	
	ld a, 0	
.planePlacementLoop		    		
	call updateJoypadState
	call updateMapScroll
	
	ld a, [scrollFlag]
	cp SCROLL_FLAG_0
	jr nz, .PPL_draw
	
	ld   a, [wJoypadPressed]
	and a, PADF_UP
	call nz, crtMoveUp
	
	
	ld   a, [wJoypadPressed]
	and a, PADF_RIGHT			
	call nz, crtMoveRight
	
	ld   a, [wJoypadPressed]
	and a, PADF_LEFT		
	call nz, crtMoveLeft
	
	ld   a, [wJoypadPressed]
	and a, PADF_DOWN			
	call nz, crtMoveDown
	
	ld   a, [wJoypadPressed]
	and a, PADF_SELECT			
	call nz, crtRotate
	
	ld   a, [wJoypadPressed]
	and a, PADF_A			
	call nz, crtNext
	
	ld   a, [wJoypadPressed]
	and a, PADF_B		
	call nz, crtUndo
	
	ld   a, [wJoypadPressed]
	and a, PADF_START			
	jr nz, .ENTRYPOINT_Pass
	;call nz, nextBoard	
	
	call crtBlink
.PPL_draw					  
	call waitForVBlank	
	ld  a, HIGH(planesOamData)
	call hOAMDMA	    	
	jr .planePlacementLoop

.ENTRYPOINT_Pass:
	
	call hideBoard	
	ld  a, HIGH(planesOamData)
	call hOAMDMA	  
	
	call waitForVBlank	
	; Turn off the LCD	
    xor a
    ld [rLCDC], a     
		
	; copy tiles to VRAM
	ld hl, SCREEN_PTR
	ld de, PassScreen
	ld bc, PassScreenEnd - PassScreen
	call loadMemory
	
	; Turn on the LCD
	ld a, %10000011
    ld [rLCDC], a		
		
.passLoop
	call updateJoypadState
	ld   a, [wJoypadPressed]
	and a, PADF_START			
	jr nz, .returnToBoard
	call waitForVBlank
	jr .passLoop

.returnToBoard
	; reinit the screen
	call waitForVBlank	
	; Turn off the LCD	
    xor a
    ld [rLCDC], a     
		
	; copy tiles to VRAM
	ld hl, SCREEN_PTR
	ld de, Tilemap
	ld bc, TilemapEnd - Tilemap
	call loadMemory
	
	; Turn on the LCD
	ld a, %10000011
    ld [rLCDC], a	
	
	call hideBoard
	call showBoard
	call hideBoard
	
	ld  a, HIGH(planesOamData)
	call hOAMDMA	
	call nextBoard
	jp .planePlacementLoop
	
	


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

PassScreen:
INCLUDE "res/passmsg.asm"
PassScreenEnd:

SECTION "Strings", ROM0

Str_PLAY:
    db "    > 1 Gameboy     ____________      2 Gameboys", $00
Str_CRB:
	db $01, $01, $01, $01, $01, $43, $72, $65, $61, $74, $65, $64, $01, $62, $79, $01
	db $01, $01, $01, $01 ,$38, $35, $33, $31, $39, $39, $30, $33, $34, $33, $35, $38 
	db $01, $4E, $6F, $74, $49, $6D, $70, $6C, $65, $6D, $65, $6E, $74, $65, $64, $4C
	db $69, $66, $65, $01, $31, $38, $31, $32, $31, $32, $32, $30, $31, $30, $30, $35
	db $00
Str_PASS1:
	db "  Pass the GAMEBOY  ____________ to the next PLAYER ____________",$00
Str_PASS2:	
	db " Then Press START ", $00
	