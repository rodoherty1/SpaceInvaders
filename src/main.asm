
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
SHIP_X_SCREEN_POS: .byte $00   ; Initial location of the ship.
                                     ; Second last line, in the middle of the screen

SHIP_CHARACTER = $01  ; The letter 'A'?

LATEST_KEY_PRESS = $C5 ; AddrC5ess of the latest key press from the user

V = $D000
JOY = $DC00

htlo = $14
hthi = $15


; Variables
gameOverFlag:     .byte $0
hiscore:          .byte 0,0

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
  jsr clearScreen
  ldx #20               
  stx SHIP_X_SCREEN_POS ; Set the Ships X position to the middle of the screen
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
  jmp gameLoop

readKeys:

  lda LATEST_KEY_PRESS
  cmp #$0A              ; Was 'A' pressed according to contents of LATEST_KEY_PRESS 
  beq leftKey
  rts

leftKey:

  ; Store ' ' in SHIP_CURRENT_POS
  ; Store 'A' in SHIP_CURRENT_POS - 1
  ldx SHIP_X_SCREEN_POS  ; 
  clc                    ; Clear the carry in prep for the next instruction
  cpx #0                 ; Is the ship at the far-left of the screen?
  beq leftKeyDone        ; If not, then move left.
  bcs moveLeft

leftKeyDone:
  rts

moveLeft:

  ldx SHIP_X_SCREEN_POS
  dex

  stx SHIP_X_SCREEN_POS
  ; lda #SHIP_CHARACTER
  ; dex
  ; ldx #$01

  ; sta SHIP_Y_SCREEN_ADDR,X
  rts

checkCollision:
  rts

updateEnemy:
  rts

updateShip:
  lda #SHIP_CHARACTER
  ldy SHIP_X_SCREEN_POS
  sta SHIP_Y_SCREEN_ADDR, Y
  rts

drawBullet:
  rts

gameover:
  lda #$0
  sta gameOverFlag
  jmp titleScreen


