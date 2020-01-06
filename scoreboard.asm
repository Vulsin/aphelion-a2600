;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; scoreboard.asm
; Scoreboard routines
;
; Written by Craig Mackles
; https://github.com/Vulsin/aphelion-a2600
;
; Distributed under the MIT License
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DrawScoreboard subroutine
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
  ldy TensOffset+1
  lda Numbers,Y
  and #$F0
  sta LivesSprite
  ldy OnesOffset+1
  lda Numbers,Y
  and #$0F
  ora LivesSprite
  sta LivesSprite
  sta PF1

  ldy ScoreSprite
  sta WSYNC

  sty PF1
  inc TensOffset
  inc TensOffset+1
  inc OnesOffset
  inc OnesOffset+1

  dex
  sta PF1

  bne ScoreboardLoop
  rts
