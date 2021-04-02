SECTION "Input Memory", WRAM0
	wJoypadState:   ; Contains the current state of the joypad.
	DS 1          ; Use the PADF_* or PADB_* constants to check for specific buttons.
	wJoypadPressed: ; Contains newly pressed buttons of the joypad, for only 1 frame.
	DS 1          ; Use the PADF_* or PADB_* constants to check for specific buttons.
	
SECTION "Input Routine", ROM0

; Call this routine once per frame to update the joypad related variables.
; Routine also returns the currently pressed buttons in the a register.
updateJoypadState:
  ld   hl, rP1
  ld   [hl], P1F_GET_BTN
  ; After the initial enable we need to read twice to ensure
  ; we get the proper hardware state on real hardware
  ld   a, [hl]
  ld   a, [hl]
  ld   [hl], P1F_GET_DPAD
  cpl  ; Inputs are active low, so a bit being 0 is a button pressed. So we invert this.
  and  PADF_A | PADF_B | PADF_SELECT | PADF_START
  ld   c, a  ; Store the lower 4 button bits in c

  ; We need to read rP1 8 times to ensure the proper button state is available.
  ; This is only needed on real hardware, as it takes a while for the
  ; inputs to change state back from the first set.
  ld   b, 8
.dpadDebounceLoop:
  ld   a, [hl]
  dec  b
  jr   nz, .dpadDebounceLoop
  ld   [hl], P1F_GET_NONE ; Disable the joypad inputs again, saves a tiny bit of power and allows the lines to settle before the next read

  swap a ; We want the directional keys as upper 4 bits, so swap the nibbles.
  cpl  ; Inputs are active low, so a bit being 0 is a button pressed. So we invert this.
  and  PADF_RIGHT | PADF_LEFT | PADF_UP | PADF_DOWN
  or   c
  ld   c, a

  ; Compare the new joypad state with the previous one, and store the
  ; new bits in wJoypadPressed
  ld   hl, wJoypadState
  xor  [hl]
  and  c
  ld   [wJoypadPressed], a
  ld   a, c
  ld   [wJoypadState], a
  ret
