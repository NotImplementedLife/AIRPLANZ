INCLUDE "src/include/constants.inc"
INCLUDE "src/include/hardware.inc"
INCLUDE "src/include/macros.inc"

SECTION "Main", ROM0

Start::	
	xor a	
	ld [wJoypadState], a
	ld [wJoypadPressed], a
	ld [scrollFlag], a
	ld [scrollInvalidate], a
	ld [backup1], a
	ld [backup2], a
	ld [backup3], a
	ld [backup4], a
	ld [backup5], a
	ld [backup6], a
	ld [backup7], a
	ld [backup8], a
	ld [backup9], a
	
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
	
	xor a ; ld a, 0		
    ld [rSCX], a	
    ld [rSCY], a		
	
;---------------------------------------------------------------
	
.ENTRYPOINT_Title:		
	call drawTitleBackground	
	
	; Init display registers
    ld a, %00110110
    ld [rBGP], a    
	ld a, %11111111
	ld [rOBP0], a
	ld a, $00
	ld [rOBP1], a	
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
	
	halt
	
;---------------------------------------------------------------
	
.ENTRYPOINT_Board:		
	; init scroll flag
	ld a, SCROLL_FLAG_0 ;- 112	
	ld [scrollFlag], a
	
	; Turn off the LCD	
    xor a
    ld [rLCDC],a 	
		
	ld hl, SCREEN_PTR
	ld de, Tilemap
	ld bc, TilemapEnd - Tilemap
	call loadMemory	
	
	ld a, HIGH(planesTemplate0)
	call hOAMDMA		
	ld a, [rLCDC]
	or LCDCF_OBJON
	ldh [rLCDC], a
	
	call clearOAM
	call initPlanes		
	
	
	ld a, 0
	ld [crtTurn], a	
			
	call hideBoard	
	call showBoard				
		
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
	jr nz, .startPressed
	;call nz, nextBoard	
	
	call crtBlink
.PPL_draw					  
	call waitForVBlank	
	ld  a, HIGH(planesOamData)
	call hOAMDMA	    	
	jr .planePlacementLoop

.startPressed:
	call checkBoardValidity		
	jr z, .ENTRYPOINT_Pass ; if board valid, go to PASS screen	
	jr .planePlacementLoop


;---------------------------------------------------------------	

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

	ld a, [crtTurn]	
	cp a, 1
	jp z, .ENTRYPOINT_Attack
	
	ld  a, HIGH(planesOamData)
	call hOAMDMA	
	call nextBoard		
	jp .planePlacementLoop
	
;---------------------------------------------------------------
	
.ENTRYPOINT_Attack:	

	; hide both boards
	ld a, [crtTurn]
	ld [backup1], a
	
	ld a, 0
	ld [crtTurn], a
	call hideBoard	
	
	ld a, 1
	ld [crtTurn], a
	call hideBoard	
	
	ld a, [backup1]
	ld [crtTurn], a
	
	ld hl, atkStateP1
	xor a
	REPT 6
		ld [hli], a	
	ENDR
	ld [PointerX], a
	ld [PointerY], a

	call waitForVBlank
	
	ld a, 0
	ld [CoveredByPointer], a
	call getBoardPosition
	ld b, 0
	ld c, 0	
	call setPointer		
.attackLoop
	call updateJoypadState
	call atkUpdateMapScroll		
	ld a, [scrollFlag]
	cp SCROLL_FLAG_0
	jr nz, .attackDraw
	
	ld   a, [wJoypadPressed]
	and a, PADF_UP
	call nz, pointerMoveUp
	
	
	ld   a, [wJoypadPressed]
	and a, PADF_RIGHT			
	call nz, pointerMoveRight
		
	ld   a, [wJoypadPressed]
	and a, PADF_LEFT		
	call nz, pointerMoveLeft
		
	ld   a, [wJoypadPressed]
	and a, PADF_DOWN			
	call nz, pointerMoveDown
	
	ld   a, [wJoypadPressed]
	and a, PADF_A		
	call nz, atkLaunch
	
	;ld   a, [wJoypadPressed]
	;and a, PADF_START					
	;call nz, atkNextTurn
.attackDraw	        
    ; Turn screen on, display background
    ld a, %10000011
    ld [rLCDC], a	
	call waitForVBlank	
	ld  a, HIGH(planesOamData)
	call hOAMDMA
	jr .attackLoop	
	
;---------------------------------------------------------------

.ENTRYPOINT_GameOver::
	call waitForVBlank
	; Turn off the LCD	
    xor a
    ld [rLCDC], a     
	
	ld hl, SCREEN_PTR
    ld de, Str_P2WIN
    call copyString
	
	ld hl, SCREEN_PTR + $20*14 + 14
    ld de, Str_P1WIN
    call copyString
	
	; Turn on the LCD
	ld a, %10000011
    ld [rLCDC], a	
.goDraw
	call updateJoypadState
	ld   a, [wJoypadPressed]
	and a, PADF_START
	jr nz, .returnToTitle
	
	call waitForVBlank
	jr .goDraw

.returnToTitle
	call waitForVBlank	
	xor a
	ld [rLCDC], a	
	ld [rSCX], a
	ld [rSCY], a
	ld hl, $9800
	ld bc, $0200
	call fillMemory0
	xor a
	ld [scrollFlag], a
	ld [scrollInvalidate], a
	ld [backup1], a
	ld [backup2], a
	ld [backup3], a
	ld [backup4], a
	ld [backup5], a
	ld [backup6], a
	ld [backup7], a
	ld [backup8], a
	ld [backup9], a
		
	jp .ENTRYPOINT_Title


SECTION "FONT", ROM0

FontTiles:
	INCBIN "res/font.chr"
FontTilesEnd:

SECTION "Tileset", ROM0


SECTION "Strings", ROM0

Str_PLAY::
    db "     >  PLAY", $00
Str_CRB::
	db $01, $01, $01, $01 ,$01, $01, $01, $01, $32, $30, $32, $31, $01, $01, $01, $01
	db $01, $01, $01, $01 ,$36, $35, $03, $39, $14, $31, $0D, $61, $47, $1D, $38, $39
	db $01, $01, $01, $01, $01, $43, $72, $65, $61, $74, $65, $64, $01, $62, $79, $01
	db $01, $01, $01, $01 ,$38, $35, $33, $31, $39, $39, $30, $33, $34, $33, $35, $38 
	db $01, $4E, $6F, $74, $49, $6D, $70, $6C, $65, $6D, $65, $6E, $74, $65, $64, $4C
	db $69, $66, $65, $01, $31, $38, $31, $32, $31, $32, $32, $30, $31, $30, $30, $35
	db $00
Str_P1WIN:
	db "      GAME  OVER                       P1  WINS", $00
Str_P2WIN:
	db "      GAME  OVER                       P2  WINS", $00

	