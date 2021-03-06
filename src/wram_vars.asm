SECTION "WRAM VARS - PLANE", WRAM0[$C000]


; tells the cpu when to scroll map from "YOU" to "OP" and vice-versa
; scrollFlag > $80 ==> scroll from (112,112) to (0,0)
; scrollFlag < $80 ==> scroll from (0,0) to (112,112)
scrollFlag::
	DS 1
scrollInvalidate::
	DS 1
; backup addresses for temporary storage
backup1::
	DS 1
backup2::
	DS 1
backup3::
	DS 1
backup4::
	DS 1
backup5::
	DS 1
backup6::
	DS 1
backup7::
	DS 1
backup8::
	DS 1
backup9::
	DS 1
; tells whose turn is ( 0 = YOU (P1), 1 = OP (P2) )
crtTurn::
	DS 1
; used in plane manipulation process
; 0-first plane, 2-last plane
crtPlane::
	DS 1
; pointer to plane data, depends on crtTurn and crtPlane
crtAddress::
	DS 2
	

atkStateP1::
	DS 3
atkStateP2::
	DS 3
atkCrtStatePtr::
	DS 2
backup16::
	DS 2

; plane data
; bytes 1-2     : coordintes Y, X
; byte   3      : orientation
; next 10 bytes : for each sprite tells if it was hit
; next 40 bytes : data to be copied to OAM

SECTION "WRAM Board 0 Plane Data", WRAM0[$C100]

P1_Plane0::
	DS 53
P1_Plane1::
	DS 53
P1_Plane2::
	DS 53
	
SECTION "WRAM Board 1 Plane Data", WRAM0[$C200]
P2_Plane0::
	DS 53
P2_Plane1::
	DS 53
P2_Plane2::
	DS 53

SECTION "WRAM VARS - Attack", WRAM0[$C400]

; to know where to place the hits
BoardPosition::
	DS 2
BoardTop::
	DS 1
BoardLeft::
	DS 1
PointerY::
	DS 1
PointerX::
	DS 1
PointerPosition::
	DS 2
CoveredByPointer:: ; tile Id
	DS 1
