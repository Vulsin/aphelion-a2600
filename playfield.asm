;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; playfield.asm
; Handles drawing of the playfield for the Aphelion game for Atari 2600
;
; Written by Craig Mackles
; https://github.com/vulsin/aphelion-a2600
;
; Distributed under the MIT license
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawPlayfield subroutine
  ldx #$00                    ; Black color
  stx COLUBK                  ; Store background color
  ldx #$2E                    ; Brown color
  stx COLUPF                  ; Store playfield color

  ldx #%00000001
  stx CTRLPF                  ; Set playfield to mirror

  ; First 164 scanlines are empty
  repeat 164
    sta WSYNC
  repend

  ; Last 14 scanlines contain our "ground"
  ldx #%11111111
  stx PF0
  stx PF1
  stx PF2

  repeat 14
    sta WSYNC
  repend

  rts                         ; Return from subroutine
