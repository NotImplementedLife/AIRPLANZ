; BoardPosition = SCREEN_PTR + 20 * P<crtTurn>_BoardY + P<crtTurn>_BoardX 
getBoardPosition:
	ld a, [crtTurn]
	cp a, 1
	jr z, .set2
	
	ld a, $28
	ld [BoardTop], a
	ld a, $38
	ld [BoardLeft], a
	
	ld b, P1_BoardY
	ld c, P1_BoardX
	jr .build16
.set2
	ld a, $38
	ld [BoardTop], a
	ld a, $28
	ld [BoardLeft], a
	
	ld b, P2_BoardY
	ld c, P2_BoardX
.build16
	ld hl, SCREEN_PTR
	ld a, l
	add c	; add X coordinate
	ld l, a	
	; add 20 * Y
	ld de, $0020	
	ld a, b
.comp20Y:
	add hl, de
	dec a	
	cp a, 0
	jr nz, .comp20Y	
	ld a, h
	ld [BoardPosition], a
	ld a, l
	ld [BoardPosition + 1], a		
	ret
;--------------------------------------------------------------------

getPointerPosition:
	; hl = BoardPosition
	ld a, [BoardPosition]
	ld h, a
	ld a, [BoardPosition + 1]
	ld l, a
	
	; hl += PointerX
	ld d, $00
	ld a, [PointerX]
	ld e, a
	add hl, de
	
	; hl += 20 * PointerY
	ld e, $20	
	ld a, [PointerY]
	cp a, 0
	jr z, .skipMul
.comp20Y:
	add hl, de
	dec a	
	cp a, 0
	jr nz, .comp20Y	
.skipMul	
	; PointerPosition = hl
	ld a, h
	ld [PointerPosition], a
	ld a, l
	ld [PointerPosition + 1], a		
	ret
;--------------------------------------------------------------------

; b = pointerY
; c = pointerX
setPointer:
	;call waitForVBlank
	; restore CoveredByPointer	
	ld a, b
	ld [backup2], a
	ld a, c
	ld [backup3], a ; place bc in temporary storage
	
	call getPointerPosition
	ld a, [PointerPosition]
	ld h, a
	ld a, [PointerPosition + 1]
	ld l, a
	ld a, [CoveredByPointer]
	cp 0 ; no tile to restore
	jr z, .skipRestore
	
	push af	
	.waitVRAM
    ldh a, [rSTAT]
    and STATF_BUSY ; %0000_0010
    jr nz, .waitVRAM	
	pop af
	
	ld [hl], a	
.skipRestore

	;reload bc
	ld a, [backup2]
	ld b, a
	ld a, [backup3]
	ld c, a	
	
	; set pointer
	ld a, b
	ld [PointerY], a
	ld a, c
	ld [PointerX], a
	call getPointerPosition
	
	ld a, [PointerPosition]
	ld h, a
	ld a, [PointerPosition + 1]
	ld l, a
		
	.waitVRAM1
    ldh a, [rSTAT]
    and STATF_BUSY ; %0000_0010
    jr nz, .waitVRAM1	
	
	ld a, [hl]	
	ld [CoveredByPointer], a
	
	; not draw the pointer tile
	ld a, $FF
	ld [hl], a		
	
	ld a, %10000011
    ld [rLCDC], a	
	call waitForVBlank ; removing this will cause the pointer to be copied twice (why?)
	ret	
;--------------------------------------------------------------------

pointerMoveUp:
	ld a, [PointerX]
	ld c, a
	ld a, [PointerY]
	cp 0
	ret z
	dec a
	ld b, a
	call setPointer	
	ret
;--------------------------------------------------------------------

pointerMoveDown:
	ld a, [PointerX]
	ld c, a
	ld a, [PointerY]
	cp 9
	ret z
	inc a
	ld b, a
	call setPointer	
	ret
;--------------------------------------------------------------------
	

pointerMoveLeft:
	ld a, [PointerY]
	ld b, a
	ld a, [PointerX]
	cp 0
	ret z
	dec a
	ld c, a
	call setPointer	
	ret
;--------------------------------------------------------------------

pointerMoveRight:
	ld a, [PointerY]
	ld b, a
	ld a, [PointerX]
	cp 9
	ret z
	inc a
	ld c, a
	call setPointer	
	ret
;--------------------------------------------------------------------

atkNextTurn:	
	call atkGetCrtState
	ld a, [atkCrtStatePtr]
	ld h, a
	ld a, [atkCrtStatePtr + 1]
	ld l, a
	
	;ld b, b
	
	ld a, [hli]
	cp 0
	jr z, .proceed
	
	ld a, [hli]
	cp 0
	jr z, .proceed
	
	ld a, [hli]
	cp 0
	jr z, .proceed
	
	jp Start.ENTRYPOINT_GameOver
	
.proceed	
	call waitForVBlank
	;xor a
    ;ld [rLCDC], a     
	call getPointerPosition
	ld a, [PointerPosition]
	ld h, a
	ld a, [PointerPosition + 1]
	ld l, a
	ld a, [CoveredByPointer]
	cp a, 0 ; no tile to restore
	jr z, .skipRestore		
	push af
	.waitVRAM	
    ldh a, [rSTAT]
    and STATF_BUSY ; %0000_0010
    jr nz, .waitVRAM
	pop af
	ld [hl], a			
.skipRestore

	ld a, 0
	ld [CoveredByPointer], a
	
	
	call nextBoard
	;call toggleOamVisibility	
	call getBoardPosition	
	ld b, 0
	ld c, 0
	call setPointer
	
	; Turn on the LCD
	ld a, %10000011
    ld [rLCDC], a	
	call waitForVBlank
	;ld  a, HIGH(planesOamData)
	;call hOAMDMA
	;ld a, 1
	;ld [atkBoardSwitchFlag], a
	ret
;--------------------------------------------------------------------

atkCheckHit:
	; b = BoardTop + 8 * PointerY
	ld a, [PointerY]
	REPT 3
		sla a	
	ENDR
	ld b, a
	ld a, [BoardTop]
	add b
	ld b, a

	; c = BoardLeft + 8 * PointerX
	ld a, [PointerX]
	REPT 3
		sla a	
	ENDR
	ld c, a
	ld a, [BoardLeft]
	add c
	ld c, a		
	
	ld a, b
	ld [backup2], a
	ld a, c
	ld [backup4], a
	
	ld a, 0
	ld [crtPlane], a
.loop
	call crtSetAddress		
	
	ld a, [backup2]
	ld b, a
	ld a, [backup4]
	ld c, a
	
	call crtCheckHit	
	
	ld e, 0
	ld a, d
	cp 1
	jr nz, .notHit
	ld a, $DE ; HIT
	jr .drawTile
.notHit
	cp 2 ; HEAD
	jr nz, .miss		
		
	ld a, b
	ld [backup1], a
	ld a, h
	ld [backup16], a	
	ld a, l
	ld [backup16 + 1], a
	
	call atkSetCrtDestroyed	
	call atkSetPhantomCells
	ld a, [backup16]
	ld h, a
	ld a, [backup16 + 1]
	ld l, a
	ld a, [backup1]
	ld b, a
	
	ld e, 13
	ld a, $DE ; HEAD
	jr .drawTile
.miss
	ld a, [crtPlane]
	cp a, 2
	jr z,.setMiss
	inc a
	ld [crtPlane], a
	jr .loop
.setMiss
	ld a, $DF ; MISS
.drawTile		
	ld l, a	
	ld [hl], b
	ld [CoveredByPointer], a	
	ld a, e	
	cp 13
	call z, atkRefresh
	
	; hide pointer
	
	ld a, [PointerY]
	ld b, a
	ld a, [PointerX]
	ld c, a
	call getPointerPosition		
	
	call waitForVBlank
	ld a, [CoveredByPointer]
	ld [hl], a
	
	ld c, 100
.wait
	call waitForVBlank ; force vblank
	ld  a, HIGH(planesOamData) ; show sprites
	call hOAMDMA
	dec c	
	jr nz, .wait
	call atkNextTurn	
	ret
	
;--------------------------------------------------------------------

atkGetCrtState:
	ld a, [crtTurn]
	cp a, 0
	jr nz, .set1
	ld bc, atkStateP1
	jr .fin
.set1
	ld bc, atkStateP2
.fin
	ld a, b
	ld [atkCrtStatePtr], a
	ld a, c
	ld [atkCrtStatePtr + 1], a	
	ret

;--------------------------------------------------------------------

atkSetCrtDestroyed:			
	;ld b, b
	call atkGetCrtState
	ld a, [atkCrtStatePtr]
	ld h, a 
	ld a, [atkCrtStatePtr + 1]
	ld l, a 
	ld a, [crtPlane]
	add l
	ld l, a
	ld [hl], 1	
	
	;ld b, b		
	ret

;--------------------------------------------------------------------
	
atkLaunch:	
	ld a, [PointerY]
	ld b, a
	ld a, [PointerX]
	ld c, a
	call getPointerPosition	
	
	ld a, [PointerPosition]
	ld h, a
	ld a, [PointerPosition + 1]
	ld l, a	

	
	; don't react on the same cell twice
	ld a, [CoveredByPointer]
	cp $DD	
	ret nz
	
	call atkCheckHit	
	
	ret
;--------------------------------------------------------------------
	
atkSetPhantomCells:		
	ld a, [crtPlane]
	call crtSetAddress
	
	ld a, [BoardTop]
	ld b, a  ; Y	
	ld a, [BoardLeft] 
	ld c, a  ; X
	
	ld a, [BoardPosition]
	ld h, a
	ld a, [BoardPosition + 1]
	ld l, a
	
	ld a, 10
	
.iterY
	ld [backup6], a	
	
	ld a, [BoardLeft] 
	ld c, a  ; X
	
	ld a, 10
.iterX
	ld [backup7], a	
	
	ld a, h
	ld [backup8], a
	ld a, l
	ld [backup9], a
	
	call crtCheckHit
	
	ld a, [backup8]
	ld h, a
	ld a, [backup9]
	ld l, a
	;ld b, b
	ld a, d
	cp 1 ; if hit, replace board tile $DD with phantom tile $FE		
	jr nz, .next		
	.waitVRAM3
    ldh a, [rSTAT]
    and STATF_BUSY ; %0000_0010
    jr nz, .waitVRAM3	
	ld a, [hl]
	cp $DD
	jr nz, .next
	ld a, $FE
	ld [hl], a
	
.next		
	inc hl
	ld a, c
	add 8
	ld c, a

	
	ld a, [backup7]
	dec a
	jr nz, .iterX
	
	ld a, b
	add 8
	ld b, a
	
	ld de, 22	
	add hl, de
	
	ld a, [backup6]
	dec a
	jr nz, .iterY
		
	call waitForVBlank
	
	ret
	
