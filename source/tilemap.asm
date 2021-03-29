updateMapScroll:
	ld a, [scrollFlag]
	cp a, SCROLL_FLAG_0
	ret z
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
