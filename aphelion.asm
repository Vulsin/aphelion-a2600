;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; aphelion.asm
; Main source file for the Aphelion game for Atari 2600
;
; Written by Craig Mackles
; https://github.com/Vulsin/aphelion-a2600
;
; Distributed under the MIT License
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  PROCESSOR 6502

  INCLUDE "macro.h"
  INCLUDE "xmacro.h"
  INCLUDE "vcs.h"

  ; Include the variables before the main game code
  INCLUDE "variables.asm"

  SEG Code
  ORG $F000

GameInit:
  CLEAN_START

  lda #BackgroundColor
  sta COLUBK                    ; Store the background color
  lda #PlayfieldColor
  sta COLUPF                    ; Store the playfield color
  lda #PlayerColor
  sta COLUP0                    ; Store the player color
  lda #80
  sta PlayerYPos                ; Start the player off at Y position 80
  lda #20
  sta PlayerXPos                ; Start the player off at X position 20

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Includes and game initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  INCLUDE "playfield.asm"
  INCLUDE "player.asm"

  jsr InitPlrSprite                 ; Initialize the player sprite lookup tables

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Game loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameLoop:
  ; Move the player to where they need to be
  lda PlayerXPos
  ldy #0
  jsr SetXPosition

  sta WSYNC
  sta HMOVE                         ; Apply horizontal offsets

  ; Display VSYNC and VBLANK
  lda #2
  sta VBLANK
  sta VSYNC
  repeat 3
    sta WSYNC
  repend
  lda #0
  sta VSYNC
  repeat 37
    sta WSYNC
  repend
  sta VBLANK

  ; Render the visible 192 scanlines
  ldx #192
.VisibleScanline:
  jsr DrawPlayfield                   ; Render the playfield

  ; See if we need to render the player's missile
  jsr PewPew

.RenderPlayerSprite:                  ; Should we render the player sprite?
  txa
  sec
  sbc PlayerYPos
  cmp PlayerHeight
  bcc .RenderPlayer
  lda #0
.RenderPlayer:
  jsr DrawPlayer

  dex
  bne .VisibleScanline

  ; Overscan
  lda #2
  sta VBLANK
  repeat 30
    sta WSYNC
  repend
  lda #0
  sta VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Input processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckP0Up:
  lda #%00010000              ; Player 0 joystick up
  bit SWCHA
  bne CheckP0Down             ; If the bit doesn't match, skip
  inc PlayerYPos              ; Otherwise, increment player Y Position
  lda #0
  sta PlayerAnimOffset        ; Set the animation offset
CheckP0Down:
  lda #%00100000              ; Player 0 joystick down
  bit SWCHA
  bne CheckP0Left             ; If the bit doesn't match, skip
  dec PlayerYPos              ; Otherwise, decrement player Y position
  lda #0
  sta PlayerAnimOffset        ; Set the animation offset
CheckP0Left:
  lda #%01000000              ; Player 0 joystick left
  bit SWCHA
  bne CheckP0Right            ; If the bit doesn't match, skip
  dec PlayerXPos              ; Otherwise, decrement player X position
  lda PlayerHeight
  sta PlayerAnimOffset        ; Set the animation offset
CheckP0Right:
  lda #%10000000              ; Player 0 joystick right
  bit SWCHA
  bne CheckP0ButtonPress      ; If the bit doesn't match, check button press
  inc PlayerXPos              ; Otherwise, increment player X position
  lda PlayerHeight
  sta PlayerAnimOffset
CheckP0ButtonPress:
  lda #%10000000              ; Player 0 joystick button press
  bit INPT4
  bne EndInputChecks          ; If the bit doesn't match, stop checking inputs
  lda PlayerXPos
  adc #4
  sta MissileXPos
  lda PlayerYPos
  adc #5
  sta MissileYPos

EndInputChecks:

  jmp GameLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Handle horizontal positioning
; A is the X position, in pixels
; Y is the object type
;   0 = Player
;   1 = Missile0
;   2 = Missile1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetXPosition subroutine
  sta WSYNC
  sec                         ; Set the carry flag
.DivisionLoop
  sbc #15                     ; Subtract 15 from the accumulator
  bcs .DivisionLoop
  eor #7
  asl
  asl
  asl
  asl
  sta HMP0,Y
  sta RESP0,Y
  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Game over
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameOver subroutine
  lda #$30
  sta COLUBK                    ; Set background color to red
  sta COLUPF                    ; Set playfield color to red
  lda #0
  sta Score                     ; Reset the score
  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sleep for 12 cycles (jsr and rts burn 6 cycles each)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Sleep12Cycles subroutine
  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Include the source files for sprites and stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  INCLUDE "sprites.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Pad ROM to 4 KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ORG $FFFC
  .word GameInit
  .word GameInit
