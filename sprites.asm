;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprites.asm
; Sprites used throughout the game
;
; Written by Craig Mackles
; https://github.com/Vulsin/aphelion-a2600
;
; Distributed under the MIT License
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;ORG $FF9A

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Spaceship Sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Spaceship
  .byte #%00110000  ;     XXXX
  .byte #%01111000  ;   XXXXXXXXXX
  .byte #%01111100  ;   XXXXXXXXXXXX
  .byte #%11001111  ; XXXX    XXXXXXXXXX
  .byte #%11001111  ; XXXX    XXXXXXXXXX
  .byte #%01111100  ;   XXXXXXXXXXXX
  .byte #%01111000  ;   XXXXXXXXXX
  .byte #%00110000  ;     XXXX
SpaceshipUp
  .byte #%00000000  ;
  .byte #%01111000  ;   XXXXXXXXXX
  .byte #%01111100  ;   XXXXXXXXXXXX
  .byte #%11111111  ; XXXX    XXXXXXXXXXX
  .byte #%11001111  ; XXXXXXXXXXXXXXXXXXX
  .byte #%01111100  ;   XXXXXXXXXXXX
  .byte #%01111000  ;   XXXXXXXXXX
  .byte #%00000000  ;
SpaceshipDown
  .byte #%00000000  ;
  .byte #%01111000  ;   XXXXXXXXXX
  .byte #%01111100  ;   XXXXXXXXXXXX
  .byte #%11001111  ; XXXXXXXXXXXXXXXXXXX
  .byte #%11111111  ; XXXX    XXXXXXXXXXX
  .byte #%01111100  ;   XXXXXXXXXXXX
  .byte #%01111000  ;   XXXXXXXXXX
  .byte #%00000000  ;


SpaceshipColor
  .byte #$86;
  .byte #$86;
  .byte #$86;
  .byte #$98;
  .byte #$98;
  .byte #$86;
  .byte #$86;
  .byte #$86;
SpaceshipUpColor
  .byte #$86;
  .byte #$86;
  .byte #$86;
  .byte #$86;
  .byte #$98;
  .byte #$86;
  .byte #$86;
  .byte #$86;
SpaceshipDownColor
  .byte #$86;
  .byte #$86;
  .byte #$86;
  .byte #$98;
  .byte #$86;
  .byte #$86;
  .byte #$86;
  .byte #$86;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Thruster Sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gonna add this one later
