; ROUTINE :: crtSetAddress
; 	based on crtTurn and crtPlane, point crtAddress to 
; 	P<crtTurn>_Plane<crtPlane>
crtSetAddress:
	ld a, [crtTurn]	
	cp a, 0
	jr nz, .setBoard1
.setBoard0
	ld hl, P1_Plane0	
	jr .choosePlane
.setBoard1
	ld hl, P2_Plane0	
.choosePlane
	ld a, [crtPlane]
	cp a, 0
	jr z, .fin	
	ld bc, 53
	add hl, bc
	cp a, 1
	jr z, .fin	
	add hl, bc
.fin
	ld a, h
	ld [crtAddress], a
	ld a, l
	ld [crtAddress+1], a
	ret ; crtSetAddress
;--------------------------------------------------------------------

crtLoadAddressToHL:
	ld a, [crtAddress]
	ld h, a
	ld a, [crtAddress + 1]
	ld l, a
	ret
;--------------------------------------------------------------------

; ROUTINE :: crtSetPosition
; b = Y
; c = X
; d = O
; e = $00/$10 [sprite]
crtSetPosition:		
	call crtLoadAddressToHL
	ld a, b
	ld [hli], a ; Y
	ld a, c
	ld [hli], a ; X
	ld a, d
	ld [hli], a ; O	
	ld a, e
	ld [hl], a  ; S  
	ret
;--------------------------------------------------------------------

; de = source
crtWriteToOamData:
	ld bc, 40 ; size of a plane OAM	
	ld hl, planesOamData	
	ld a, [crtPlane]
	
	cp a, 0
	jr z, .fin	
	ld bc, 40
	add hl, bc
	cp a, 1
	jr z, .fin	
	add hl, bc
.fin		
	call loadMemory	
	ret
;--------------------------------------------------------------------	


; ROUTINE :: crtCreateOAM
; render OAM data
crtCreateOAM:
	call crtLoadAddressToHL
	inc l ; skip X
	inc l ; skip Y
	; get Orientation
	ld a, [hli] 
	ld e, a
	ld d, HIGH(planesTemplate0)
	ld a, [crtTurn]
	cp a, 0
	jr z, .keepTemplate0
	ld d, HIGH(planesTemplate1)
.keepTemplate0:
	; get hit texture
	ld a, [hl]
	ld [backup5], a ; hit texture
	
	ld a, l	
	add 10 ; planification mistake should have been "add 1"
	ld l, a
	ld bc, PLANE_OAM_SIZE
	call loadMemory

	; update coordinates
	ld a, l
	sub 53
	ld l, a
	ld a, [hli]
	ld b, a ; Y
	ld a, [hli]
	ld c, a ; X
	ld a, l
	add 11
	ld l, a	
	
	ld a, 10
.setCoords:
	; backup1 stores the loop counter
	ld [backup1],a	
	
	; set Y coord
	ld a, [hl]	
	add a, b
	ld [hli], a	
	; set X coord
	ld a, [hl]	
	add a, c
	ld [hli], a	

	; set sprite
	ld a, [backup5]
	cp 0
	jr z, .endSetSprite
	cp $10	
	jr nz, .hideSprite
	add [hl]
	ld [hl], a
	jr .endSetSprite
.hideSprite
	ld a, $EE ; a blank sprite
	ld [hl], a
.endSetSprite
	
	inc l
	inc l
		
	ld a, [backup1]
	dec a	
	cp 0
	jr nz, .setCoords	
	
	;prepare to Write OAM
	ld a, l
	sub 40
	ld l, a	
	; perform de = hl :
	ld a, h
	ld d, a
	ld a, l
	ld e, a		
	
	call crtWriteToOamData
	ret
;--------------------------------------------------------------------	


crtHide:	
	call crtLoadAddressToHL			
	inc l ; skip Y
	inc l ; skip X
	inc l ; skip O
	ld a, 1
	ld [hl], a
	call crtCreateOAM
	ret
;--------------------------------------------------------------------	
crtShow:	
	call crtLoadAddressToHL			
	inc l ; skip Y
	inc l ; skip X
	inc l ; skip O
	ld a, 0
	ld [hl], a
	call crtCreateOAM
	ret	
;--------------------------------------------------------------------

; show the current plane using $FX sprites
crtShowDots:	
	call crtLoadAddressToHL		
	ld a, l
	add 3
	ld l, a 	
	ld a, $10
	ld [hl], a ; 
	call crtCreateOAM	
	ret
;--------------------------------------------------------------------	

initPlanes:
	ld a, 0
	ld [crtTurn], a
	
.init
	ld a, 0
	ld [crtPlane], a
	call crtSetAddress	
	ld bc, $0000
	ld d, $00
	ld e, $00
	call crtSetPosition
	call crtCreateOAM	
	
	ld a, 1
	ld [crtPlane], a
	call crtSetAddress	
	ld bc, $0000
	ld d, $00
	ld e, $00
	call crtSetPosition
	call crtCreateOAM
	
	ld a, 2
	ld [crtPlane], a
	call crtSetAddress
	ld bc, $0000
	ld d, $00
	ld e, $00
	call crtSetPosition
	call crtCreateOAM	
	
	ld a, [crtTurn]
	cp a, 0	
	ld a, 1
	ld [crtTurn], a
	jr z, .init	

	ld a, 0
	ld [crtPlane], a	
	ret
;--------------------------------------------------------------------	

hideBoard:
	ld a, [crtPlane]
	ld [backup2], a
	
	ld a, 0
	ld [crtPlane], a
	call crtSetAddress		
	call crtHide	
	
	ld a, 1
	ld [crtPlane], a
	call crtSetAddress	
	call crtHide	
	
	ld a, 2
	ld [crtPlane], a
	call crtSetAddress
	call crtHide		
		
	ld a, [backup2]
	ld [crtPlane], a
	call crtSetAddress
	ret
;--------------------------------------------------------------------	

showBoard:
	ld a, [crtPlane]
	ld [backup2], a
	
	ld a, 0
	ld [crtPlane], a
	call crtSetAddress	
	call crtShow
	
	ld a, 1
	ld [crtPlane], a
	call crtSetAddress
	call crtShow
	
	ld a, 2
	ld [crtPlane], a
	call crtSetAddress
	call crtShow
	
	ld a, [backup2]	
	ld [crtPlane], a
	call crtSetAddress
	ret
;--------------------------------------------------------------------	

; b = dY
; c = dX
crtMove:
	call crtLoadAddressToHL			
	inc l
	inc l
	ld a, [hl]
	ld d, a ; d = orientation
	dec l
	dec l   
	
	ld a, d
	and $08 ; catch Orientation LEFT (0x28) and RIGHT (0x78)
	jr nz, .setDimForLeftRight
	ld d, 8*7 ; Y
	ld e, 8*6 ; X
	jr .loadAndCompare
.setDimForLeftRight
	ld d, 8*6 ; Y
	ld e, 8*7 ; X 
.loadAndCompare
	ld a, [hl]
	add b		
	cp -8
	ret z	
	cp d
	ret z
	ld [hli], a
	ld a, [hl]
	add c
	cp -8	
	ret z
	cp e
	ret z
	ld [hli], a	
	call crtCreateOAM	
	ret
;--------------------------------------------------------------------	

crtMoveUp:	
	ld b, -8
	ld c, 0
	call crtMove
	ret
;--------------------------------------------------------------------	
	
crtMoveRight:	
	ld b, 0
	ld c, 8	
	call crtMove
	ret
;--------------------------------------------------------------------	
	
crtMoveLeft:	
	ld b, 0
	ld c, -8
	call crtMove
	ret
;--------------------------------------------------------------------	
	
crtMoveDown:	
	ld b, 8
	ld c, 0
	call crtMove
	ret
;--------------------------------------------------------------------	
	
crtRotate:
	call crtLoadAddressToHL
	inc l
	inc l
	ld a, [hl]
	add 40
	cp 160
	jr nz, .fin
	ld a, 0
.fin:
	ld [hl], a
	ld d, a
	; check if bottom and right sides exceeded
	dec l	
	ld a, [hl]
	ld c, a
	dec l
	ld a, [hl]
	ld b, a
	
	ld a, d
	and $08 ; catch Orientation LEFT (0x28) and RIGHT (0x78)
	jr nz, .checkLeftRight	
	ld a, c
	cp 8*6
	jr nz, .keep
	ld c, 8*5
.checkLeftRight
	ld a, b
	cp 8*6
	jr nz, .keep
	ld b, 8*5
.keep
	ld a, b
	ld [hli], a
	ld a, c
	ld [hli], a
	
	call crtCreateOAM
	ret
;--------------------------------------------------------------------	

crtNext:
	ld a, [crtPlane]
	cp 2
	ret z
	inc a
	ld [crtPlane], a
	call crtSetAddress
	call crtCreateOAM
	call showBoard
	ret
;--------------------------------------------------------------------	
	
crtUndo:
	ld a, [crtPlane]
	cp 0
	ret z	
	ld a, [crtPlane]
	dec a	
	ld [crtPlane], a
	call crtSetAddress	
	call crtCreateOAM
	call showBoard
	ret
;--------------------------------------------------------------------	
	
crtBlink:
	ld a, [scrollFlag]
	cp SCROLL_FLAG_0
	ret nz
	call crtLoadAddressToHL
	ld a, l
	add 13
	ld l, a
	
	ld a, 10
.setCoords:
	; backup1 stores the loop counter
	ld [backup1],a	
	
	inc l ; skip Y
	inc l ; skip X
	inc l ; skip T	
	ld a, [hl]
	xor $80
	ld [hli], a ; change Priority	
		
	ld a, [backup1]
	dec a	
	cp 0
	jr nz, .setCoords	
	
	;prepare to Write OAM
	ld a, l
	sub 40
	ld l, a	
	; perform de = hl :
	ld a, h
	ld d, a
	ld a, l
	ld e, a		
	call crtWriteToOamData	
	ret
;--------------------------------------------------------------------	

; checkOverlapping
; de = plane address 1
; hl = plane address 2
; sets FLAG Z if the two planes are OVERLAPPPING
checkOverlapping:
	ld a, 10
.outerLoop
	; backup1 stores the loop counter
	ld [backup2], a
	
	ld a, [de]
	ld b, a ; load Y
	inc e
	ld a, [de]
	ld c, a ; load X
	
	ld a, 10
.innerLoop:
	; backup1 stores the loop counter
	ld [backup1],a	
	
	ld a, [hli]	
	cp b               ; compare Y coords 
	jr nz, .continue
	; if cursor reaches this, the Y1==Y2 so we compare X1, X2	
	ld a, [hl]	
	cp c               ; compare Y coords 	
	ret z              ; X1==X2 && Y1==Y2 => set Z = 1		
	
.continue
	REPT 3
		inc l			
	ENDR
	ld a, [backup1]
	dec a	
	cp 0
	jr nz, .innerLoop	
		
	REPT 3
		inc e				
	ENDR
	
	ld a, l
	sub 40 ; reset hl
	ld l, a	
	
	ld a, [backup2]
	dec a	
	cp 0
	jr nz, .outerLoop	
	
	
	ld a, 1
	cp 0		
	ret                ; everything ok, set Z = 0
	
;--------------------------------------------------------------------	
	
; checkBoardValidity
checkBoardValidity:
	ld de, planesOamData
	ld hl, planesOamData + 40	
	call checkOverlapping		
	jr z, .false 
	
	ld de, planesOamData
	ld hl, planesOamData + 80	
	call checkOverlapping		
	jr z, .false 
	
	ld de, planesOamData + 40
	ld hl, planesOamData + 80	
	call checkOverlapping		
	jr z, .false 	
	
.true:
	ld a, 0
	cp 0
	ret       ; Z = 1
.false:
	ld a, 1
	cp 0	
	ret       ; Z = 0
	
;--------------------------------------------------------------------	

crtSetHit:
	call crtLoadAddressToHL
	ret
	
;--------------------------------------------------------------------	

; crtCheckHit
; check if current plane contains coordinates Y,X
; b = test Y
; c = test X
; Output:
; d = 0 => miss
; d = 1 => hit
; d = 2 => head

crtCheckHit:
	ld a, b
	ld [backup2], a
	ld a, c
	ld [backup3], a
	call crtLoadAddressToHL
	ld a, [backup2]
	ld b, a
	ld a, [backup3]
	ld c, a
	
	ld a, l
	add 13
	ld l, a
	
	;check for head
	ld a, [hli]
	cp b
	jr nz, .skipHeadX	
	
	ld a, [hl]
	cp c
	jr nz, .skipHeadX
	
	; if still here, then it's a HEAD
	ld d, 2
	ret	
	
.skipHeadX
	inc l
	inc l
	inc l
	
	; test the other sprites
	ld a, 9
.chkLoop
	; store counter
	ld [backup1], a 
	ld a, [hli]
	cp b
	jr nz, .skipX
	ld a, [hl]
	cp c
	jr nz, .skipX
	
	; here is a HIT
	ld d, 1
	ret
	
.skipX
	inc l
	inc l
	inc l
	ld a, [backup1]
	dec a
	cp a, 0	
	jr nz, .chkLoop
	
	; here is a MISS
	ld d, 0
	ret ; crtCheckHit
;--------------------------------------------------------------------	

	
	
	