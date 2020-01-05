;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; variables.asm
; Game variables
;
; Written by Craig Mackles
; https://github.com/Vulsin/aphelion-a2600
;
; Distributed under the MIT License
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  SEG.u Variables
  ORG $80

PlayerHeight      EQU   #7        ; Player sprite is 7 lines tall
ScoreHeight       EQU   #5        ; Score digit height
PlayerColor       EQU   #$A8      ; Blue color
PlayfieldColor    EQU   #$F6      ; Brown color
BackgroundColor   EQU   #$00      ; Black color

PlayerXPos        byte            ; Define variable for player X position
PlayerYPos        byte            ; Define variable for player Y position
PlayerSpritePtr   word            ; Pointer to the player sprite
PlayerColorPtr    word            ; Pointer to the player sprite colors
PlayerAnimOffset  byte            ; Animation offset for the player
MissileXPos       byte            ; Define variable for missile X position
MissileYPos       byte            ; Define variable for missile Y position
Score             byte            ; 2-digit score
OnesOffset        byte            ; Digit ones lookup table offset
TensOffset        byte            ; Digit tens lookup table offset
ScoreSprite       byte            ; Sprite data for the scoreboard
Lives             byte            ; Lives remaining
LivesSprite       byte            ; Sprite data for lives remaining
