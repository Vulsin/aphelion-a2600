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
  lda #PlayerColor
  sta COLUP0
  lda #45
  sta PlayerYPos                ; Start the player off at Y position 45
  lda #80
  sta PlayerXPos                ; Start the player off at X position 80
  lda #03
  sta Lives                     ; Start the player off with 3 lives
  lda #03
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
  ldy #2
  jsr SetXPosition

  ; Determine score and lives counter digit offsets
  jsr GetScoreOffset
  jsr GetLivesOffset

  sta WSYNC
  sta HMOVE                         ; Apply horizontal offsets

  ; Display VBLANK
  repeat 36
    sta WSYNC
  repend
  lda #0
  sta VBLANK

  ; Clear all TIA registers before the next frame
  lda #0
  sta PF0                           ; Clear Playfield0 graphics
  sta PF1                           ; Clear Playfield1 graphics
  sta PF2                           ; Clear Playfield2 graphics
  sta GRP0                          ; Clear Player0 graphics
  sta GRP1                          ; Clear Player1 graphics
  lda #00000000
  sta CTRLPF                        ; Disable playfield reflection

  ; Render the scoreboard (the actual score and how many lives we've got)
  ; We'll use the playfield registers but will make it asymmetrical. The TIA
  ; will render the playfield reflected or repeated, but we can set CTRLPF
  ; to repeat and use cycle counts per scanline to our advantage.
  ;
  ; Update PF0 from clocks 84 to 147
  ; Update PF1 from clocks 116 to 163
  ; Update PF2 from clocks 148 to 195
  ;
  ; Comments will be prefixed with how many clocks we are burning per
  ; instruction so we can keep count.

  ldx ScoreHeight
  lda #0
  sta PF2
  sta WSYNC
ScoreboardLoop:
  ; Player score - start counting clocks!
  ldy TensOffset          ; 2
  lda Numbers,Y           ; 2
  and #$F0                ; 5       Hide the graphics for the ones digit
  sta ScoreSprite         ; 3

  ldy OnesOffset          ; 2
  lda Numbers,Y           ; 2
  and #$0F                ; 5       Hide the graphics for the tens digit
  ora ScoreSprite         ; 5
  sta ScoreSprite         ; 3
  sta WSYNC               ; 3
  sta PF1                 ; 3       Store this in PF1 on the left side

  ; Lives remaining
  ldy TensOffset+1        ; 2
  lda Numbers,Y           ; 2
  and #$F0                ; 5
  sta LivesSprite         ; 3

  ldy OnesOffset+1        ; 2
  lda Numbers,Y           ; 2
  and #$0F                ; 5
  ora LivesSprite         ; 5
  sta LivesSprite         ; 3
  sta PF1                 ; 3
  ldy ScoreSprite         ; 2
  sta WSYNC               ; 3

  sty PF1                 ; 3
  inc TensOffset          ; 2
  inc TensOffset+1        ; 2
  inc OnesOffset          ; 2
  inc OnesOffset+1        ; 2

  dex                     ; 2
  sta PF1                 ; 3
  bne ScoreboardLoop

  sta WSYNC

  lda #0
  sta PF1
  sta WSYNC

  ; Render the other visible scanlines
  ldx #195
.SceneScanline:
  lda #0

  ; See if we need to render the player's missile
  cpx MissileYPos
  bne .NoPewPew
  lda MissileYPos
  adc #3
  sta MissileYPos
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
  adc #10
  sta MissileYPos

EndInputChecks:

  jmp GameLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Handle horizontal positioning
; A is the X position, in pixels
; Y is the object type
;   0 = Player 0
;   1 = Player 1
;   2 = Missile 0
;   3 = Missile 1
;   4 = Ball
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
; Score display processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Determine the offset for the lives remaining counter for the lookup tables.
GetLivesOffset subroutine
  ldx #1
.LivesLoop
  lda Lives,X
  and #$0F
  sta Tmp
  asl
  asl               ; Shift left twice (N*4)
  adc Tmp
  sta OnesOffset,X  ; Save to OnesOffset or OnesOffset+1

  lda Lives,X
  and #$F0
  lsr
  lsr               ; Shift right twice (N/4)
  sta Tmp
  lsr
  lsr               ; Shift left twice more (N/16)
  adc Tmp
  sta TensOffset,X  ; Save to TensOffset or TensOffset+1
  dex
  bpl .LivesLoop
  rts


; Determine the offset for the score for the lookup tables.
GetScoreOffset subroutine
  ldx #1
.ScoreLoop
  lda Score,X
  and #$0F
  sta Tmp
  asl
  asl               ; Shift left twice (N*4)
  adc Tmp
  sta OnesOffset,X  ; Save to OnesOffset or OnesOffset+1

  lda Score,X
  and #$F0
  lsr
  lsr               ; Shift right twice (N/4)
  sta Tmp
  lsr
  lsr               ; Shift left twice more (N/16)
  adc Tmp
  sta TensOffset,X  ; Save to TensOffset or TensOffset+1
  dex
  bpl .ScoreLoop
  rts

Sleep12Cycles subroutine
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
; Scoreboard sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LivesIcon
  .byte %0111000000   ;  ###
  .byte %1111111000   ; #######
  .byte %1110011111   ; ###  #####
  .byte %1111111000   ; #######
  .byte %0111000000   ;  ###

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
