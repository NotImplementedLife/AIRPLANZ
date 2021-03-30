; setPlane
; Arguments:
; b = 
setPlane:
	xor a
	;ld [plane1], a
	;ld [plane1+1], a
	ld a, $E0
	;ld [plane1+2], a
	ld a, %10000000
	;ld [plane1+3], a	
	ret
	
;drawPlane:
	
;	ret
