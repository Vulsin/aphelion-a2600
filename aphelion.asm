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
  INCLUDE "vcs.h"

  SEG Code
  ORG $F000

GameInit:
  CLEAN_START

  lda #$00                      ; Black background
  sta COLUBK                    ; Store the background color
  lda #$F6                      ; Brown playfield
  sta COLUPF                    ; Store the playfield color

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Frame rendering
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:
  lda #2
  sta VBLANK
  sta VSYNC

  ; 3 blank scanlines
  repeat 3
    sta WSYNC
  repend

  lda #0
  sta VBLANK

  ; 37 blank scanlines
  repeat 37
    sta WSYNC
  repend

  lda #0
  sta VBLANK

  ; Render the playfield
  INCLUDE "playfield.asm"
  jsr DrawPlayfield

  ; 30 lines of overscan
  lda #2
  sta VBLANK

  repeat 30
    sta WSYNC
  repend

  lda #0
  sta VBLANK

  jmp StartFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Pad ROM to 4 KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ORG $FFFC
  .word GameInit
  .word GameInit
