.cpu "w65c02"

; *******************************************************************************************
; Memory layout
; *******************************************************************************************

* = $02			; reserved
DP		.dsection dp
		.cerror * > $00fb, "Out of DP space"

* = $100		; Stack
Stack		.dsection stack
		.fill $100

* = $1000
Music	.dsection music

* = $E000
Boot 	.dsection boot
		.dsection init
		.dsection system
		.dsection display
		.dsection audio

* = $E800
		.dsection data

* = $EE00
		.dsection tilesetpalette

* = $F000	
		.dsection showcase

* = $FE00
IRQ		.dsection irq

* = $FF00
NMI		.dsection nmi

* = $FFFA
		.dsection ivec

* = $010000
		.dsection tilelayer0

* = $010A00
		.dsection tilelayer2

* = $011400
		.dsection tilelayer1

* = $012000
		.dsection tilesetdata

.section	music
	.binary "../music/odeto64.bin"
.send

.section	irq
                pha
                phx
                phy
                php

                jsr showcase.InterruptHandlerJoystick

                plp 
                ply
                plx
                pla
EXIT_IRQ_HANDLE
		rti 
.send

.section	nmi
rti
.send

;
; Interrupt Vectors
;
.section	ivec
RVECTOR_NMI     .addr NMI    ; FFFA
RVECTOR_RST 	.addr Boot   ; FFFC
RVECTOR_IRQ     .addr IRQ    ; FFFE
.send
