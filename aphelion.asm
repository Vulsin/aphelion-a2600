;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; aphelion.asm
; Main application file for the Aphelion game for Atari 2600
;
; Written by Craig Mackles
; https://github.com/vulsin/aphelion-a2600
;
; Distributed under the MIT license
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  PROCESSOR 6502
  INCLUDE "macro.h"
  INCLUDE "vcs.h"
  INCLUDE "xmacro.h"
  INCLUDE "sprites.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set up variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  SEG.u Variables
  ORG $80

XPlr            byte      ; Player X position
YPlr            byte      ; Player Y position
SpritePtr       word      ; Sprite pointer

ScoreHeight     EQU 20    ; Scoreboard height
BGCOLOR         EQU #$80  ; Background color (Blue)
PLRCOLOR        EQU #$6C  ; Player color
GNDCOLOR        EQU #$C0  ; Ground color

  SEG Code
  ORG $F000

Start:
  CLEAN_START


NextFrame:
  VERTICAL_SYNC

  ; Set up playfield
  lda #BGCOLOR
  sta COLUBK
  lda #PLRCOLOR
  sta COLUPL
  ; Blank out the playfield
  lda #0
  sta PF0
  sta PF1
  sta PF2

  ; 37 blank scanlines
  TIMER_SETUP 37


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Complete ROM size to 4 KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ORG $FFFC
  .word Start
  .word Start
