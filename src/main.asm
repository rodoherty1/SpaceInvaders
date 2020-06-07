
; Useful links
; ------------
;
; Compare and Branch reference - http://6502.org/tutorials/compare_instructions.html
;
; Screen memory map - http://cbm.ko2000.nu/manuals/anthology/p069.jpg
;
; C64 Screen Codes - https://sta.c64.org/cbm64scr.html

.DATA
; Labels

; Kernal routines
CHROUT = $FFD2        ; Character out  
SCNKEY = $FF9F        ; Scan keyboard for keypress    
GETIN = $FFE4         ; Get Input from the buffer and store it in A
PLOT = $FFF0          ; Set/Read cursor location - how it function depends on the carry flag 
SPRITE_ENABLE_REGISTER  = $D015
SPRITE0_COLOUR_REGISTER = $D027

SHIP_Y_SCREEN_ADDR = $0798     ; Second-last row, First column of the screen 


SHIP_CHARACTER = $01            ; The letter 'A'?

LATEST_KEY_PRESS = $C5          ; Address of the latest key press from the user

v = $D000
JOY = $DC00

htlo = $14
hthi = $15

sprite1  = $3200                ; Sprite1 pointer



; Variables
gameOverFlag:       .byte $0
hiscore:            .byte 0,0
shipXCoord:         .byte 16
previousShipXCoord: .byte 16
v30:                .byte 0

sprite0x:           .byte 160,0
sprite0y:           .byte 220

weight:             .byte 1
jumpStrength:       .byte 0
floor:              .byte 220


titleScreenText:
  .byte "p r o j e c t   w e l l y b o o t"
  brk

spaceToPlayText:
  .byte "1 - play the game"
  brk

qToQuitText:
  .byte "q - quit"
  brk

.CODE

.macro printString text, xcoor, ycoor
  lda #<text
  ldy #>text

  sta htlo
  sty hthi

  clc
  ldx #xcoor
  ldy #ycoor
  jsr PLOT
  jsr printText
.endmacro

jmp titleScreen

printText:
  lda (htlo),y
  cmp #0
  beq printDone
  jsr CHROUT

  clc
  inc htlo
  bne printText
  inc hthi
  jmp printText

printDone:
  rts

clearScreen:
  lda #$93
  jsr CHROUT
  rts

titleScreen:
  jsr clearScreen

  lda #$0           ; Black
  sta $D020         ; Border colour
  sta $D021         ; screen colour

setupSprites:
  lda #01                     ; Turn on Sprite0
  sta SPRITE_ENABLE_REGISTER
  sta SPRITE0_COLOUR_REGISTER

  lda #200                    ; set Sprite1 point to #200 * 64bytes = #12800 or $3200 which is defined above
  sta $07F8                   ; Store sprite pointer in Sprite base register

  jsr initSprite1Shape

printMenu:
  lda #0
  sta LATEST_KEY_PRESS
  printString titleScreenText, 2, 0
  printString spaceToPlayText, 4, 0
  printString qToQuitText, 6, 0

@printingLoop:
  lda #0
  jsr SCNKEY
  jsr GETIN
  cmp #49           ; Compare to '1'
  beq startGame
  cmp #$51          ; Compare to 'Q'
  beq quit
  jmp @printingLoop

startGame:
  jsr clearScreen
  jmp gameInit
          
quit:
  lda #$0E          ; Light Blue
  sta $D020         ; Border Colour
  lda #$06          ; Blue
  sta $D021         ; Background Colour
  rts               ; Quit to Basic

gameInit: 
  lda #$0
  sta gameOverFlag      ; Clear the GameOver FLag

gameLoop:
  jsr vbwait
  jsr readKeys
  jsr checkCollision
  jsr updateEnemy
  jsr updateShip
  jsr drawBullet

  lda gameOverFlag
  cmp #$01
  bne gameLoop
  jmp printMenu


doNotMove:
  rts

raiseGameOverFlag:
  lda #$1
  sta gameOverFlag
  rts

adjustSpriteHeightIfJumping:

  ; if jump strength >= 0 then sprite is falling
    ; 
  ; else sprite is rising
  jsr wasteTime

  lda sprite0y
  sbc jumpStrength
  sta sprite0y

  cmp floor
  bcs spriteHasLanded   ; if sprite >= floor then spriteHasLanded
                        ; else update jumpStrength
  sec
  lda jumpStrength
  sbc weight
  sta jumpStrength
  rts

spriteHasLanded:
  lda #0
  sta jumpStrength

  lda floor
  sta sprite0y
  rts

readKeys:
  jsr adjustSpriteHeightIfJumping

leftKey:
  lda LATEST_KEY_PRESS
  cmp #$0A              ; Was 'A' pressed according to contents of LATEST_KEY_PRESS 
  bne rightKey
  lda sprite0x
  sbc #05
  sta sprite0x
  rts

rightKey:
  lda LATEST_KEY_PRESS
  cmp #$12
  bne jumpKey
  lda sprite0x
  adc #05
  sta sprite0x
  rts

jumpKey:
  lda LATEST_KEY_PRESS
  cmp #$3C              ; Was 'SPACE' pressed?
  bne exitKey

  clc
  lda sprite0y
  cmp floor
  beq makeSpriteJump    ; If sprite >= floor then mak sprite jump
  rts
  
makeSpriteJump:
  lda #15
  sta jumpStrength
  rts

exitKey:
  lda LATEST_KEY_PRESS
  cmp #$17              ; Was 'X' pressed according to contents of LATEST_KEY_PRESS 
  beq raiseGameOverFlag
  rts

checkCollision:
  rts

updateEnemy:
  rts

updateShip:
  lda sprite0x
  sta v
  lda sprite0y
  sta v+1
  rts

drawBullet:
  rts

vbwait:
  lda $d012
  cmp #251
  bne vbwait
  lda v+30    ; get col reg
  sta v30     ; save to v30
  rts

initSprite1Shape:
  ldx #62
  lda #$FF
@loop:
  sta sprite1,x
  dex
  bpl @loop
  rts

wasteTime:
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop

  rts


