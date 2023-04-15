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

TileMapLayer0 = $010000
* = TileMapLayer0
		.dsection tilelayer0

TileMapLayer1 = $011200
* = TileMapLayer1
		.dsection tilelayer1

TileMapLayer2 = $012400
* = TileMapLayer2
		.dsection tilelayer2

TileSet0Data = $013600
* = TileSet0Data
		.dsection tilesetdata
TileSet1Data = TileSet0Data + $10000
TileSet2Data = TileSet1Data + $10000

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
