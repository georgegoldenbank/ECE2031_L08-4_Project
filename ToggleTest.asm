ORG 0
Main:
	LOAD	EvenToggle
	OUT		NewLEDs ; Toggles LEDS 0, 2, 4, 6, 8
	CALL	OuterLoop
	LOAD	OddToggle
	OUT		NewLEDs ; Toggles LEDS 1, 3, 5, 7, 9
	CALL	OuterLoop
	JUMP	Main

; Because of the restriction of 16 bit registers
; a single loop to decrement a value as a delay is not sufficient
; so a nested loop is used to create a larger delay on the
; order of seconds.
OuterLoop:
	LOAD	OuterCounter
	JZERO	End
	ADDI	-1
	STORE	OuterCounter
	LOADI	1000
	STORE	InnerCounter
	
InnerLoop:
	LOAD	InnerCounter
	JZERO	OuterLoop
	ADDI	-1
	STORE	InnerCounter
	JUMP	InnerLoop

End:
	LOADI	1000
	STORE	OuterCounter
	LOADI	1000
	STORE	InnerCounter
	RETURN
	
; IO address constants
EvenToggle: DW &H555
OddToggle: DW &H6AA
OuterCounter: DW	1000
InnerCounter: DW	1000
Switches:  EQU 000
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
NewLEDs:   EQU &H20
