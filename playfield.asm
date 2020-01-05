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
    ; Next 21 scanlines are the "ground" of the playfield
    ldy #%11111111
    sty PF0
    sty PF1
    sty PF2

    repeat 21
      sta WSYNC
    repend

    rts
