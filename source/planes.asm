; goToPlaneOamData
; based on register a value, points hl to the beginning 
; of plane #{a} OAM data in WRAM
goToPlaneOamData:
	ld h, HIGH(planesOamData)
	cp a, 3
	jr z, .goToPlane_3
	cp a, 2
	jr z, .goToPlane_2
	cp a, 1
	jr z, .goToPlane_1
	cp a, 0
	jr z, .goToPlane_0
.goToPlane_3:
	ld l, 3 * 40	
	ret
.goToPlane_2:
	ld l, 2 * 40	
	ret
.goToPlane_1:
	ld l, 1 * 40	
	ret
.goToPlane_0:
	ld l, 0 * 40
	ret ;goToPlaneOamData
;--------------------------------------------------------------------
	
; chPlaneVisibility
; toggle plane visibility
; Argument: a = target plane [0..2]
chPlaneVisibility:	
	call goToPlaneOamData
	ld a, l
	add 3    ; access byte 3 of sprite
	ld l, a
	ld a, 10
.chPlaneV_SetFlags:
	; backup8 stores the loop counter
	ld [backup1],a
	
	; hl ^= $80 ; toggle show/hide
	ld a, [hl]
	xor a, $80	
	ld [hl], a
	
	; hl+=4
	ld a, l
	add a, 4
	ld l, a
	; >>> hl = XX00 .. XXA0, there is 
	; >>> no need to check the carry 
	;jr nc, .chPlaneV_restoreA 
	;inc h
	
.chPlaneV_restoreA:
	ld a, [backup1]
	dec a	
	cp 0
	jr nz, .chPlaneV_SetFlags
	ret ; chPlaneVisibility
;--------------------------------------------------------------------

	
; placePlane
; a = target plane [0..2]
; b = Y
; c = X
; d = Orientation
placePlane:	
	call goToPlaneOamData
	ld a, d	
	ld de, planesTemplate			
	cp a, PLANE_LEFT
	jr z, .setOrientationLeft
	cp a, PLANE_DOWN
	jr z, .setOrientationDown
	cp a, PLANE_RIGHT
	jr z, .setOrientationRight		
	cp a, PLANE_UP
	jr .setOrientationUp
	jr .setOrientationEnd
.setOrientationLeft:
	ld a, 3*20
	ld [backup1], a
	ld a, e
	add 40*3	
	jr .setOrientationEnd
.setOrientationDown:	
	ld a, 2*20
	ld [backup1], a
	ld a, e
	add 40*2
	jr .setOrientationEnd
.setOrientationRight:
	ld a, 1*20
	ld [backup1], a
	ld a, e
	add 40*1
	jr .setOrientationEnd
.setOrientationUp:
	ld a, 0*20
	ld [backup1], a
	ld a, e
	add 40*0
	jr .setOrientationEnd
.setOrientationEnd:
	ld e, a
	ld a, b
	ld [backup2], a
	ld a, c
	ld [backup3], a
	; now we have de to the wanted plane template
	ld bc, 40 ; size of a plane OAM	
	call loadMemory	
	; repoint hl to the beginning of plane OAM 
	ld a, l
	sub 40 ; advance to byte 1 [Y coord]
	ld l, a	
	
	ld a, [backup2]
	ld b, a
	ld a, [backup3]
	ld c, a
	
	ld d, HIGH(PPRC_UP)
	ld a, [backup1]
	ld e, a		
	;halt
	ld a, 10
.placePlane_SetCoords:
	; backup8 stores the loop counter
	ld [backup1],a
	
	; set Y coord
	ld a, [hl]
	ld a, [de]
	add a, b
	ld [hli], a
	inc e
	; set X coord
	ld a, [hl]
	ld a, [de]
	add a, c
	ld [hli], a
	inc e
	
	; hl+=2
	ld a, l
	add a, 2
	ld l, a
	
.chPlaneV_restoreA:
	ld a, [backup1]
	dec a	
	cp 0
	jr nz, .placePlane_SetCoords
	
	
	ret ; placePlane
;--------------------------------------------------------------------
	
