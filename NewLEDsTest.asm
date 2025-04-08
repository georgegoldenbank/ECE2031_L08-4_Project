ORG 0
Main:
	IN		Switches
	OUT		NewLEDs
	JUMP	Main
	
; IO address constants
Switches:  EQU 000
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
NewLEDs:   EQU &H20
