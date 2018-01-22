;
; interrupt-bargraph.asm
;
; Created: 2018-01-19 8:50:13 AM
; Author : Tim
;

.def output = r16

vectTable:
	.org 0x0000
	rjmp reset

	.org INT0addr
	rjmp shiftLeft

	.org INT1addr
	rjmp shiftRight

shiftLeft:
	sbrs output, 7
	lsl output

	reti

shiftRight:
	sbrs output, 0
	lsr output

	reti

reset:
	; enable output for 4 LSB of PORTB and PORTC
	ldi r16, 0xF
	out DDRB, r16
	out DDRC, r16

	; enable pullup resistors of INT0 and INT1
	ldi r16, 1 << PORTD2 | 1 << PORTD3
	out PORTD, r16

	; enable sleep and set sleep mode to power-down
	ldi r16, 1 << SE | 1 << SM1
	out SMCR, r16

	; trigger INT0 & INT1 on falling edge
	ldi r16, 1 << ISC01 | 1 << ISC11
	sts EICRA, r16
	
	; enable INT0 and INT1
	ldi r16, 1 << INT0 | 1 << INT1
	out EIMSK, r16

	; set initial state for bargraph
	ldi output, 1

	sei

write:
	out PORTB, output

	swap output
	out PORTC, output
	swap output

	sleep
	rjmp write
