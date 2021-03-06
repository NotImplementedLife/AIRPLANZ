INCLUDE "src/include/constants.inc"
INCLUDE "src/include/hardware.inc"

SECTION "next board", ROM0
nextBoard::
	ld a, 0
	ld [crtPlane], a		
	call hideBoard    	
	ld a, [scrollFlag]
	cp a, SCROLL_FLAG_0
	ret nz
	ld a, [rSCX]
	cp a, 0
	jr z, .set112
.set0	
	call hideBoard
	ld a, 0
	ld [crtTurn], a
	ld a, 1
	ld [scrollInvalidate], a
	ld a, SCROLL_FLAG_0 + 112
	ld [scrollFlag], a		
	
	ret
.set112
	call hideBoard	
	ld a, 1
	ld [crtTurn], a
	ld a, 1
	ld [scrollInvalidate], a
	ld a, SCROLL_FLAG_0 - 112
	ld [scrollFlag], a	
	ret

	