.cpu "65c02"

showcase       .namespace

TileMapXSize = 54
TileMapYSize = 22

; Located in High Memory since Vicky can Reference them directly.

.section tilelayer0
TileMapLayer0        .include "../tile_data/TopLayer.txm"
.send

.section tilelayer1
TileMapLayer1        .include "../tile_data/Paralax1.txm"
.send

.section tilelayer2
TileMapLayer2	     .include "../tile_data/Paralax2.txm"
.send

; $012000 - $38FFF (Size: 0x27000) 156K

.section tilesetdata
TileSetData          .binary "../tile_data/tileset.bin"
.send

.section tilesetpalette
TileMapPalette	     .binary "../tile_data/tileset.pal.bin"
.send

; Start of actual showcase code

.section        showcase

start
                jsr system.setIOPage0

                stz io.joy.VIA0_DRB    ; Make Sure the VIA is in Read Mode for the Joystick 
                stz io.joy.VIA0_DRA    ; Make Sure the VIA is in Read Mode for the Joystick

                ; put some values in the LUT for graphic use
                ; Go in Page 1 to Setup LUT
                jsr system.setIOPage1
        
                ldx #$00
setLUT0_4_Tiles
                lda TileMapPalette,x
                sta vky.LUT0,x
                inx 
                cpx #196
                bne setLUT0_4_Tiles
                ; Go in Page 0 to program the rest
                jsr system.SetIOPage0

                ; Set the Tile Layer Map 0 Pointer: $10000
                stz vky.tile.T0_START_ADDY_L
                stz vky.tile.T0_START_ADDY_M
                lda #$01
                sta vky.tile.T0_START_ADDY_H

                ; Set the Tile Layer Map 1 Pointer: $10A00
                stz vky.tile.T1_START_ADDY_L
                lda #$0A
                sta vky.tile.T1_START_ADDY_M
                lda #$01
                sta vky.tile.T1_START_ADDY_H

                ; Set the Tile Layer Map 2 Pointer: $11400
                stz vky.tile.T2_START_ADDY_L
                lda #$14
                sta vky.tile.T2_START_ADDY_M
                lda #$01
                sta vky.tile.T2_START_ADDY_H

                ;Now Set the Size of the MAP itself
                lda #<TileMapXSize
                sta vky.tile.T0_MAP_X_SIZE_L
                sta vky.tile.T1_MAP_X_SIZE_L
                sta vky.tile.T2_MAP_X_SIZE_L
                lda #>TileMapXSize
                sta vky.tile.T0_MAP_X_SIZE_H
                sta vky.tile.T1_MAP_X_SIZE_H
                sta vky.tile.T2_MAP_X_SIZE_H
                lda #<TileMapYSize
                sta vky.tile.T0_MAP_Y_SIZE_L
                sta vky.tile.T1_MAP_Y_SIZE_L
                sta vky.tile.T2_MAP_Y_SIZE_L
                lda #>TileMapYSize
                sta vky.tile.T0_MAP_Y_SIZE_H
                sta vky.tile.T1_MAP_Y_SIZE_H
                sta vky.tile.T2_MAP_Y_SIZE_H

                ; now Let's setup the Window Position
                lda #$00
                sta vky.tile.T0_MAP_X_POS_L
                sta vky.tile.T1_MAP_X_POS_L
                sta vky.tile.T2_MAP_X_POS_L
                lda #$00    ; The position of the Window looking in to the MAP is 1 (X)
                sta vky.tile.T0_MAP_X_POS_H
                sta vky.tile.T1_MAP_X_POS_H
                sta vky.tile.T2_MAP_X_POS_H
                lda #$00
                sta vky.tile.T0_MAP_Y_POS_L
                sta vky.tile.T1_MAP_Y_POS_L
                sta vky.tile.T2_MAP_Y_POS_L
                lda #$00
                sta vky.tile.T0_MAP_Y_POS_H
                sta vky.tile.T1_MAP_Y_POS_H
                sta vky.tile.T2_MAP_Y_POS_H

                ; Now let's setup the different Tile Set Graphics Location
                ; We are in 16x16 Mode, so 1x TileSet is 65536bytes. (64K)
                ; Tile Set 0   : $012000
                lda #$00
                sta vky.tile.GRP_ADDY0_L
                lda #$20
                sta vky.tile.GRP_ADDY0_M
                lda #$01    ; The location of the TileSet if $B80000
                sta vky.tile.GRP_ADDY0_H
                ; tile Set 1   : $022000
                lda #$00
                sta vky.tile.GRP_ADDY1_L
                lda #$20
                sta vky.tile.GRP_ADDY1_M
                lda #$02    ; The location of the TileSet if $B80000
                sta vky.tile.GRP_ADDY1_H
                ; tile Set 2   : $032000
                lda #$00
                sta vky.tile.GRP_ADDY2_L
                lda #$20
                sta vky.tile.GRP_ADDY2_M
                lda #$03    ; The location of the TileSet if $B80000
                sta vky.tile.GRP_ADDY2_H        

                ; let's setup the attributes for each graphic sets
                lda #vky.tile.DIM_256x256     ; (bit[3] set) The tile set is a 256x256 Graphic Block
                sta vky.tile.GRP_ADDY0_CFG
                sta vky.tile.GRP_ADDY1_CFG
                sta vky.tile.GRP_ADDY2_CFG

                lda #vky.tile.ENABLE     ; (bit[0] set), (bit[4] Clear = 16x16 Mode)

                sta vky.tile.T0_CONTROL_REG  ; Enable Layer0
                lda #vky.tile.Enable
                sta vky.tile.T1_CONTROL_REG  ; Enable Layer1
                lda #vky.tile.Enable
                sta vky.tile.T2_CONTROL_REG  ; Enable Layer2

                rts

InterruptHandlerJoystick:

                ; Clear Interrupt Pending Register for SOF
                lda interrupt.PENDING_REG0
                and #interrupt.JR0_INT00_SOF
                sta interrupt.PENDING_REG0

                lda io.joy.VIA0_IRB    ; Read VIA Port B to get Joystick Value
                and #$1F        ; Remove Unwanted bits
                cmp #$1F        ; Any movement at all?
                bne joystickNotDone
                lda #$00
                sta io.joy.CNT_0
                rts 

joystickNotDone
                nop 

joystickDoneNow
                lda io.joy.VIA0_IRB
                sta io.joy.VAL
                and #$08              ; Check what value is cleared
                cmp #$00
                beq forwardX

                lda io.joy.VAL
                and #$04
                cmp #$00
                beq backwardX

                lda io.joy.VAL
                and #$02
                cmp #$00
                beq forwardY

                lda io.joy.VAL
                and #$01
                cmp #$00
                bne joystickDone
                ;backwardY
                lda vky.SCROLL_Y_CNT
                cmp #$00
                beq joystickDone
                dec vky.SCROLL_Y_CNT
                lda vky.SCROLL_Y_CNT
                sta vky.tile.T0_MAP_Y_POS_L
         ;       lsr A
                sta vky.tile.T1_MAP_Y_POS_L
          ;      lsr A
                sta vky.tile.T2_MAP_Y_POS_L

joystickDone
                lda #$00
                sta io.joy.CNT_0
                rts 

forwardX      
                lda vky.SCROLL_X_CNT
                cmp #$FE
                beq joystickDone
                inc vky.SCROLL_X_CNT

                lda vky.SCROLL_X_CNT
                sta vky.tile.T0_MAP_X_POS_L
                lsr A
                sta vky.tile.T1_MAP_X_POS_L
                lsr A
                sta vky.tile.T2_MAP_X_POS_L
                bra joystickDone

backwardX     
                lda vky.SCROLL_X_CNT
                cmp #$00
                beq joystickDone
                dec vky.SCROLL_X_CNT
                lda vky.SCROLL_X_CNT
                sta vky.tile.T0_MAP_X_POS_L
                lsr A
                sta vky.tile.T1_MAP_X_POS_L
                lsr A
                sta vky.tile.T2_MAP_X_POS_L
                bra joystickDone

forwardY      
                lda vky.SCROLL_Y_CNT
                cmp #$40
                beq joystickDone     
                inc vky.SCROLL_Y_CNT
                lda vky.SCROLL_Y_CNT
                sta vky.tile.T0_MAP_Y_POS_L
                sta vky.tile.T1_MAP_Y_POS_L
        ;        lsr A
                sta vky.tile.T2_MAP_Y_POS_L
                lda #$00
                sta io.joy.CNT_0        
                rts 
.send        ; end section showcase
.endn        ; end namespace showcase