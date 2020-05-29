
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

SHIP_Y_SCREEN_ADDR = $0798     ; Second-last row, First column of the screen 

SHIP_CHARACTER = $01            ; The letter 'A'?

LATEST_KEY_PRESS = $C5          ; Address of the latest key press from the user

V = $D000
JOY = $DC00

htlo = $14
hthi = $15


; Variables
gameOverFlag:       .byte $0
hiscore:            .byte 0,0
shipXCoord:         .byte 16
previousShipXCoord: .byte 16

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

jmp init


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

init:
  jsr clearScreen

  lda #$0           ; Black
  sta $D020         ; Border colour

  lda #$0           ; Black
  sta $D021         ; screen colour

titleScreen:
  printString titleScreenText, 2, 0
  printString spaceToPlayText, 4, 0
  printString qToQuitText, 6, 0

@loop:
  lda #0
  jsr SCNKEY
  jsr GETIN
  cmp #49           ; Compare to '1'
  beq startGame
  cmp #$51          ; Compare to 'Q'
  beq quit
  jmp @loop

startGame:
  lda #$0
  sta gameOverFlag
  jsr clearScreen
  lda #20
  sta shipXCoord ; Set the Ships X position to the middle of the screen
  lda #19
  sta previousShipXCoord ; Set the Ships X position to the middle of the screen
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
  sta LATEST_KEY_PRESS  ; Clear the value of the player's latest keystroke
  jmp gameLoop

gameLoop:
  jsr readKeys
  jsr checkCollision
  jsr updateEnemy
  jsr updateShip
  jsr drawBullet
  lda gameOverFlag
  cmp #$00
  beq gameLoop
  jmp init

readKeys:
  lda LATEST_KEY_PRESS

  cmp #$3E              ; Was 'Q' pressed according to contents of LATEST_KEY_PRESS 
  beq gameOver

  cmp #$0A              ; Was 'A' pressed according to contents of LATEST_KEY_PRESS 
  beq leftKey

  cmp #$12
  beq rightKey
  rts

doNotMove:
  rts

gameOver:
  lda #$1
  sta gameOverFlag
  jmp init

leftKey:
  lda shipXCoord
  clc                     ; Clear the carry in prep for the next instruction
  cmp #0                  ; Is the ship at the far-left of the screen?
  beq doNotMove 

  jsr saveShipsPreviousPosition
  dec shipXCoord
  rts

rightKey:
  lda shipXCoord
  clc                     ; Clear the carry in prep for the next instruction
  cmp #39                 ; Is the ship at the far-right of the screen?
  beq doNotMove 

  jsr saveShipsPreviousPosition
  inc shipXCoord
  rts

saveShipsPreviousPosition:
  lda shipXCoord
  sta previousShipXCoord
  rts

checkCollision:
  rts

updateEnemy:
  rts

updateShip:

  ldy shipXCoord
  cpy previousShipXCoord
  beq doneUpdatingShip

  lda #SHIP_CHARACTER
  sta SHIP_Y_SCREEN_ADDR, y

  ldy previousShipXCoord

  lda #$20            ; Ascii for Space character
  sta SHIP_Y_SCREEN_ADDR, y

 doneUpdatingShip: 
  rts

drawBullet:
  rts



