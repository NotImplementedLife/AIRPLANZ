INCLUDE "src/include/constants.inc"
INCLUDE "src/include/hardware.inc"

SECTION "Tile map logic", ROM0

updateMapScroll::	
	ld a, [scrollFlag]
	cp a, SCROLL_FLAG_0
	jr z, .checkBoardState	
	jr c, .scrollFlag_lt_0x80	
.scrollFlag_gt_0x80
	dec a
	ld [scrollFlag], a 
	ld a, [rSCX]
	dec a
	ld [rSCX], a
	ld a, [rSCY]
	dec a
	ld [rSCY], a	
	ret
.scrollFlag_lt_0x80
	inc a
	ld [scrollFlag], a 
	ld a, [rSCX]
	inc a
	ld [rSCX], a
	ld a, [rSCY]
	inc a
	ld [rSCY], a
	ret
.checkBoardState
	ld a, [scrollInvalidate]
	cp a, 0	
	ret z
	ld a, 0
	ld [scrollInvalidate], a
	call showBoard		
	call waitForVBlank
	call waitForVBlank
	call waitForVBlank
	ret
	

	
atkUpdateMapScroll::
	ld a, [scrollFlag]
	cp a, SCROLL_FLAG_0
	jr z, .checkBoardState	
	jr c, .scrollFlag_lt_0x80	
.scrollFlag_gt_0x80
	dec a
	ld [scrollFlag], a 
	ld a, [rSCX]
	dec a
	ld [rSCX], a
	ld a, [rSCY]
	dec a
	ld [rSCY], a	
	ret
.scrollFlag_lt_0x80
	inc a
	ld [scrollFlag], a 
	ld a, [rSCX]
	inc a
	ld [rSCX], a
	ld a, [rSCY]
	inc a
	ld [rSCY], a
	ret
.checkBoardState
	ld a, [scrollInvalidate]
	cp a, 0	
	ret z
	ld a, 0
	ld [scrollInvalidate], a
	
	call atkRefresh
	
	ret
	
atkRefresh::	
	call hideBoard
	; show only destroyed planes
	call atkGetCrtState
	ld a, [atkCrtStatePtr]
	ld h, a 
	ld a, [atkCrtStatePtr + 1]
	ld l, a 
	
	ld a, h
	ld [backup16], a
	ld a, l
	ld [backup16+1], a
	
	ld a, [hli]
	cp 0	
	;ld b, b
	jr z, .skipShow0	
	ld a, 0
	ld [crtPlane], a
	call crtSetAddress
	call crtShowDots		
	ld a, [backup16]
	ld h, a
	ld a, [backup16 + 1]
	ld l, a
	inc l
.skipShow0	
	ld a, [hli]
	cp 0
	jr z, .skipShow1
	ld a, 1
	ld [crtPlane], a
	call crtSetAddress
	call crtShowDots	
	ld a, [backup16]
	ld h, a
	ld a, [backup16 + 1]
	ld l, a
	inc l
	inc l
.skipShow1
	ld a, [hli]
	cp 0
	jr z, .skipShow2
	ld a, 2
	ld [crtPlane], a
	call crtSetAddress
	call crtShowDots
.skipShow2
	ret
	