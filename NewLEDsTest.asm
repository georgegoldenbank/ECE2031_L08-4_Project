ORG 0
Main:
	LOAD	TestVal
	OUT		NewLEDs
	CALL	OuterLoop
	JUMP	Main

OuterLoop:
	LOAD	OuterCounter
	JZERO	End
	; proceed to InnerLoop cuz we got stuff to do
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
TestVal: DW	&H402
OuterCounter: DW	1000
InnerCounter: DW	1000
Switches:  EQU 000
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
NewLEDs:   EQU &H20
