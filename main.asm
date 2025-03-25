;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Assembly language file for Lab 3 in 55:035 (Embedded Systems)
; Spring 2025, The University of Iowa
; Created: 3/5/2025 2:05:25 PM
; Author : Thomas Tsilimigras and Joshua Abello
;
.include "m328pdef.inc"
.cseg
.org 0




;.def current_digit = R24; ; counter of index register
.def timecount = R18 ; used to track how many displays are called
.def numcorrect = R20 ; check how many correct for code
.def guesses = R19 ; keep track of number of guesses
.def bound = R21 ; make sure it stays in bound
sbi DDRB, 2      ; PB2 - SER (output)
sbi DDRB, 1      ; PB1 - SRCLK (output)
sbi DDRB, 0      ; PB0 - RCLK (output)
sbi DDRB, 5 ; LED

cbi DDRD, 5   ; PUSHBUTTON input set at high
cbi DDRC, 1  ; PC1 - RPG input A
cbi DDRC, 0 ; PC0 - RPG input B

;clock config
.def tmp1 = r23 ; Use r23 for temporary variables
.def tmp2 = r24 ; Use r24 for temporary values
ldi R28, 225
ldi tmp2,0x04
out TCCR0B,tmp2




; Values for each digit (both increment)


segments:
.db 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71


;initialize
;code = 4 D 2 2 E

.equ MIN_HOLD_TIME = 10  ; Used for the 1 second press  
.equ MAX_HOLD_TIME  = 20  ; Used for the 1-2 second press 

;rcall display

reset:
	ldi timecount, 0 
	ldi numcorrect, 0
	ldi guesses, 0
	ldi bound, 0
	ldi ZL, LOW(segments<<1)
	ldi R16, 0x40
	rcall display
	cbi PORTB, 5
loop1:
	ldi timecount, 0
	sbis PIND, 5 ;skip next if button not pressed (high)
	rjmp button_pressed


	IN R26, PINC
	cpi R26, 0x1
	breq cw
	cpi R26, 0x2
	breq cc
    rjmp loop1           ; Continue looping

button_pressed:
	.set count = 200
	ldi ZH, HIGH(count)
	ldi ZL, LOW(count)
	sbic PIND, 5 ;skip next instruction if button is released
	rjmp press_handler ; if button is pressed then go to handler
	rcall delay ; call delay to measure the hold time
	cpi timecount, 40
	brlo incR18

	rjmp button_pressed ; repeat
	
incR18:
	inc r18
	rjmp button_pressed


press_handler:
	

	cpi R18, MIN_HOLD_TIME ; compares r18 to min hold time
	brlo checkcode ; if less than one second input number to code
	cpi R18, MAX_HOLD_TIME 
	brsh reset ; resets code if held longer than 2 seconds

	rjmp loop1
	
checkcode:
	cpi guesses, 4
		breq check5
	cpi guesses, 3
		breq check4
	cpi guesses, 2
		breq check3
	cpi guesses, 1
		breq check2
	cpi guesses, 0
		breq check1
	rjmp loop1

changeup:
	
	cpi bound, 15
	breq loop1
	cpi R16, 0x40
	breq initial
	inc bound
	ldi ZL, LOW(segments<<1)
	add ZL, bound
	lpm R16, Z
	rcall display
	rjmp loop1
changedown:
	
	cpi bound, 0
	breq loop1
	dec bound
	ldi ZL, LOW(segments<<1)
	add ZL, bound
	lpm R16, Z
	rcall display
	rjmp loop1

initial:
	ldi ZL, LOW(segments<<1)
	lpm R16, Z
	rcall display
	rjmp loop1

cw:
	IN R26, PINC
	cpi R26, 0x3
	breq changeup
	rjmp cw
cc:
	IN R26, PINC
	cpi R26, 0x3
	breq changedown
	rjmp cc
	

	
check1:
	cpi R16, 0x66
	breq correct
	inc guesses
	rjmp loop1
check2:
	cpi R16, 0x5E
	breq correct
	inc guesses
	rjmp loop1
check3:
	cpi R16, 0x5B
	breq correct
	inc guesses
	rjmp loop1
check4:
	cpi R16, 0x5B
	breq correct
	inc guesses
	rjmp loop1
check5:
	cpi R16, 0x79
	inc numcorrect
	inc guesses
	rcall iscorrect
	rjmp loop1
correct:
	inc numcorrect
	inc guesses
	rjmp loop1

iscorrect:
	cp numcorrect, guesses
	breq correctfinish
	rjmp incorrectfinish
	

correctfinish:
	ldi guesses, 0
	ldi numcorrect, 0
	ldi R16, 0x80
	rcall display
	sbi PORTB, 5 
	.set count = 8000
	ldi ZH, HIGH(count)
	ldi ZL, LOW(count)
	rcall delay
	rjmp reset
incorrectfinish:
	ldi guesses, 0
	ldi numcorrect, 0
	ldi R16, 0x8
	rcall display
	.set count = 14000
	ldi ZH, HIGH(count)
	ldi ZL, LOW(count)
	rcall delay
	rjmp reset









;--------------------------------------------------------
; Display Subroutine: Shift bits into SN74HC595
;--------------------------------------------------------
display:
; backup used registers on stack
push R16
push R17
in R17, SREG
push R17
ldi R17, 8 ; loop --> test all 8 bits

loop_display:
rol R16          ; Rotate left through Carry
BRCS set_ser_in_1 ; Branch if Carry is set

; SER = 0
cbi PORTB, 2
rjmp end_display

set_ser_in_1:
; SER = 1
sbi PORTB, 2

end_display:
; Generate SRCLK pulse
sbi PORTB, 1
cbi PORTB, 1

dec R17
brne loop_display

; Generate RCLK pulse
sbi PORTB, 0
cbi PORTB, 0

; Restore registers from stack
pop R17
out SREG, R17
pop R17
pop R16

ret



delay: ; use 500 micro second counter to make a 1 second delay 
	rcall delay500us
	sbiw Z, 1
	brne delay
	ret







; Wait for TIMER0 to roll over.
delay500us:
; Stop timer 0.
in tmp1,TCCR0B ; Save configuration
ldi tmp2,0x00 ; Stop timer 0
out TCCR0B,tmp2
; Clear overflow flag.
in tmp2,TIFR0 ; tmp <-- TIFR0
sbr tmp2,1<<TOV0 ; Clear TOV0, write logic 1
out TIFR0,tmp2
; Start timer with new initial count
out TCNT0,R28 ; Load counter
out TCCR0B,tmp1 ; Restart timer
wait:
in tmp2,TIFR0 ; tmp <-- TIFR0
sbrs tmp2,TOV0 ; Check overflow flag
rjmp wait
ret
