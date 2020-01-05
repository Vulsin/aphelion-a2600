;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; playfield.asm
; Code to generate the playfield.
;
; Written by Craig Mackles
; https://github.com/Vulsin/aphelion-a2600
;
; Distributed under the MIT License
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawPlayfield subroutine
    ; First 164 scanlines are blank
    repeat 164
      sta WSYNC
    repend

    ; Next 21 scanlines are the "ground" of the playfield
    ldx #%11111111
    stx PF0
    stx PF1
    stx PF2

    repeat 21
      sta WSYNC
    repend

    rts
