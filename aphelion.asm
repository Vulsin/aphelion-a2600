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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Game initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  lda #BackgroundColor
  sta COLUBK                    ; Store the background color
  lda #PlayfieldColor
  sta COLUPF                    ; Store the playfield color
  lda #$88
  sta COLUP0
  lda #45
  sta PlayerYPos                ; Start the player off at Y position 45
  lda #80
  sta PlayerXPos                ; Start the player off at X position 80
  lda #3
  sta Lives                     ; Start the player off with 3 lives
  lda #0
  sta Score                     ; Start the score at 0

  ; Initialize player sprites
  lda #<Spaceship
  sta PlayerSpritePtr
  lda #>Spaceship
  sta PlayerSpritePtr+1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Game loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameLoop:
  ; Display VSYNC
  lda #2
  sta VBLANK
  sta VSYNC
  repeat 3
    sta WSYNC
  repend
  lda #0
  sta VSYNC

  ; Move sprites where they need to go
  lda PlayerXPos
  ldy #0
  jsr SetXPosition
  lda MissileXPos
  ldy #1
  jsr SetXPosition

  sta WSYNC
  sta HMOVE                         ; Apply horizontal offsets

  ; Display VBLANK
  repeat 36
    sta WSYNC
  repend
  lda #0
  sta VBLANK

  ; Render the scoreboard
  ;jsr DrawScoreboard
  ldx ScoreHeight
ScoreboardLoop:
  ; Player score
  ldy TensOffset
  lda Numbers,Y
  and #$F0                          ; Hide the graphics for the ones digit
  sta ScoreSprite

  ldy OnesOffset
  lda Numbers,Y
  and #$0F                          ; Hide the graphics for the tens digit
  ora ScoreSprite
  sta ScoreSprite
  sta WSYNC
  sta PF1

  ; Player lives remaining
  ;ldy TensOffset+1
  ;lda Numbers,Y
  ;and #$F0
  ;sta LivesSprite
  ;ldy OnesOffset+1
  ;lda Numbers,Y
  ;and #$0F
  ;ora LivesSprite
  ;sta LivesSprite
  ;sta PF1

  ;ldy ScoreSprite
  sta WSYNC

  ;sty PF1
  ;inc TensOffset
  ;inc TensOffset+1
  ;inc OnesOffset
  ;inc OnesOffset+1

  dex
  ;sta PF1

  bne ScoreboardLoop



  sta WSYNC

  lda #0
  sta PF1
  sta WSYNC

  ; Render the other visible scanlines
  ldx #195
.SceneScanline:
  ; See if we need to render the player's missile
  lda #0
  cpx MissileXPos
  bne .NoPewPew
  inc MissileXPos
  lda #%00000010                      ; FIRE ZE MISSILES!!
.NoPewPew
  sta ENAM0                           ; Set the TIA missile register value



.RenderPlayerSprite:                  ; Should we render the player sprite?
  txa
  sec
  sbc PlayerYPos
  cmp #PlayerHeight
  bcc .RenderPlayer
  lda #0
.RenderPlayer:
  clc
  adc PlayerAnimOffset
  tay
  lda (PlayerSpritePtr),Y
  sta WSYNC
  sta GRP0

  dex
  bne .SceneScanline

  lda #0
  sta PlayerAnimOffset                ; Reset the player anim offset to 0

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
  ; We don't want to allow movement past the middle of the screen
  sec
  ldy PlayerYPos
  iny
  cpy #96
  bcs CheckP0Down
.MovinOnUp
  inc PlayerYPos              ; Otherwise, increment player Y Position
CheckP0Down:
  lda #%00100000              ; Player 0 joystick down
  bit SWCHA
  bne CheckP0Left             ; If the bit doesn't match, skip
  ; Don't allow movement past the bottom of the screen
  sec
  ldy PlayerYPos
  dey
  cpy #1
  bcc CheckP0Left
.GoingDown
  dec PlayerYPos              ; Otherwise, decrement player Y position
CheckP0Left:
  lda #%01000000              ; Player 0 joystick left
  bit SWCHA
  bne CheckP0Right            ; If the bit doesn't match, skip
  ; Don't allow movement past the left boundary of the screen
  sec
  ldy PlayerXPos
  dey
  cpy #1
  bcc CheckP0Right
.SlideToTheLeft
  dec PlayerXPos              ; Otherwise, decrement player X position
CheckP0Right:
  lda #%10000000              ; Player 0 joystick right
  bit SWCHA
  bne CheckP0ButtonPress      ; If the bit doesn't match, check button press
  ; Don't allow movement past the right boundary of the screen
  sec
  ldy PlayerXPos
  iny
  cpy #140
  bcs CheckP0ButtonPress
.SlideToTheRight
  inc PlayerXPos              ; Otherwise, increment player X position
  lda PlayerHeight
  lda #16
CheckP0ButtonPress:
  lda #%10000000              ; Player 0 joystick button press
  bit INPT4
  bne EndInputChecks          ; If the bit doesn't match, stop checking inputs
  lda PlayerXPos
  adc #4
  sta MissileXPos
  lda PlayerYPos
  adc #1
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
; Main game sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ORG $FF9A

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Spaceship Sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Spaceship
  .byte #%00000000  ;
  .byte #%00010000  ;        ###
  .byte #%01111100  ;  ###############
  .byte #%01111100  ;  ###############
  .byte #%01111100  ;  ###############
  .byte #%01101100  ;  ######   ######
  .byte #%00101000  ;     ###   ###
  .byte #%00101000  ;     ###   ###
  .byte #%00111000  ;     #########
  .byte #%00010000  ;        ###
  .byte #%00010000  ;        ###
  .byte #%00010000  ;        ###
  .byte #%00010000  ;        ###
  .byte #%00010000  ;        ###
  .byte #%00000000  ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Thruster Sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gonna add this one later

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Number sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ORG $FFCA

Numbers
  .byte %01110111          ; ### ###
  .byte %01010101          ; # # # #
  .byte %01010101          ; # # # #
  .byte %01010101          ; # # # #
  .byte %01110111          ; ### ###

  .byte %00010001          ;   #   #
  .byte %00010001          ;   #   #
  .byte %00010001          ;   #   #
  .byte %00010001          ;   #   #
  .byte %00010001          ;   #   #

  .byte %01110111          ; ### ###
  .byte %00010001          ;   #   #
  .byte %01110111          ; ### ###
  .byte %01000100          ; #   #
  .byte %01110111          ; ### ###

  .byte %01110111          ; ### ###
  .byte %00010001          ;   #   #
  .byte %00110011          ;  ##  ##
  .byte %00010001          ;   #   #
  .byte %01110111          ; ### ###

  .byte %01010101          ; # # # #
  .byte %01010101          ; # # # #
  .byte %01110111          ; ### ###
  .byte %00010001          ;   #   #
  .byte %00010001          ;   #   #

  .byte %01110111          ; ### ###
  .byte %01000100          ; #   #
  .byte %01110111          ; ### ###
  .byte %00010001          ;   #   #
  .byte %01110111          ; ### ###

  .byte %01110111          ; ### ###
  .byte %01000100          ; #   #
  .byte %01110111          ; ### ###
  .byte %01010101          ; # # # #
  .byte %01110111          ; ### ###

  .byte %01110111          ; ### ###
  .byte %00010001          ;   #   #
  .byte %00010001          ;   #   #
  .byte %00010001          ;   #   #
  .byte %00010001          ;   #   #

  .byte %01110111          ; ### ###
  .byte %01010101          ; # # # #
  .byte %01110111          ; ### ###
  .byte %01010101          ; # # # #
  .byte %01110111          ; ### ###

  .byte %01110111          ; ### ###
  .byte %01010101          ; # # # #
  .byte %01110111          ; ### ###
  .byte %00010001          ;   #   #
  .byte %01110111          ; ### ###



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Pad ROM to 4 KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ORG $FFFC
  .word GameInit
  .word GameInit
