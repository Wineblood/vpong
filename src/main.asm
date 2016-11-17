;----------------------------------------------------------------
; constants
;----------------------------------------------------------------

PRG_COUNT = 1 ;1 = 16KB, 2 = 32KB
MIRRORING = %0001 ;%0000 = horizontal, %0001 = vertical, %1000 = four-screen

STATETITLE     = $00  ; displaying title screen
STATEPLAYING   = $01  ; move paddles/ball, check for collisions
STATEGAMEOVER  = $02  ; displaying game over screen
STATENEWBALL   = $03  ; wait for player to press button to release 

TOPWALL        = $08
BOTTOMWALL     = $E6

PADDLE1X       = $08  ; horizontal position for paddles, doesnt move
PADDLE2X       = $F0

PADDLESPEED    = $03
PADDLEHEIGHT   = $20
PADDLEWIDTH    = $08

BALLSIZE     = $08
NUMBEROFBALLLEVELS = $08

SCOREXPOS_1P = $09
SCOREXPOS_2P = $14   
SCOREYPOS    = $2080   ; in ppu address (y = 4 in tiles)

;----------------------------------------------------------------
; iNES header
;----------------------------------------------------------------

    .db "NES", $1a ;identification of the iNES header
    .db PRG_COUNT ;number of 16KB PRG-ROM pages
    .db $01 ;number of 8KB CHR-ROM pages
    .db $00|MIRRORING ;mapper 0 and mirroring
    .dsb 9, $00 ;clear the remaining bytes

;----------------------------------------------------------------
; variables
;----------------------------------------------------------------

    .enum $0000
    
    gamestate            .dsb 1  ; .rs 1 means reserve one byte of space
    ballx                .dsb 1  ; ball horizontal position
    bally                .dsb 1  ; ball vertical position
    ballup               .dsb 1  ; 1 = ball moving up
    balldown             .dsb 1  ; 1 = ball moving down
    ballleft             .dsb 1  ; 1 = ball moving left
    ballright            .dsb 1  ; 1 = ball moving right
    ballspeedx           .dsb 1  ; ball horizontal speed per frame (integer updated every frame)
    ballspeedy           .dsb 1  ; ball vertical speed per frame (integer updated every frame)
    ballspeedx_fixed     .dsb 1 ; ball horizontal speed per frame (fixed 4.4 - added to accumulator every frame)
    ballspeedy_fixed     .dsb 1 ; ball vertical speed per frame (fixed 4.4 - added to accumulator every frame)
    ballspeedx_fixedacc  .dsb 1 ; fixed point accumulator for x speed of ball (fixed 4.4 - used to conserve fraction values between frames)
    ballspeedy_fixedacc  .dsb 1  ; fixed point accumulator for x speed of ball (fixed 4.4 - used to conserve fraction values between frames)
    paddle1ytop          .dsb 1  ; player 1 paddle top vertical position
    paddle2ytop          .dsb 1  ; player 1 paddle top vertical position
    buttons1             .dsb 1  ; player 1 gamepad buttons, one bit per button
    buttons2             .dsb 1  ; player 2 gamepad buttons, one bit per button
    score1               .dsb 1  ; player 1 score, 0-15
    score2               .dsb 1  ; player 2 score, 0-15
    p1lastscored         .dsb 1
    ballspeedlevel       .dsb 1
    ballspeedprogress    .dsb 1
    arg_1                .dsb 1
    arg_2                .dsb 1
    arg_3                .dsb 1
    arg_4                .dsb 1
    arg_5                .dsb 1
    var_1                .dsb 1
    var_2                .dsb 1
    var_3                .dsb 1
    var_4                .dsb 1
    var_5                .dsb 1
    
    .ende

;----------------------------------------------------------------
; program bank(s)
;----------------------------------------------------------------

    .base $10000-(PRG_COUNT*$4000)
    
RESET:
    SEI          ; disable IRQs
    CLD          ; disable decimal mode
    LDX #$40
    STX $4017    ; disable APU frame IRQ
    LDX #$FF
    TXS          ; Set up stack
    INX          ; now X = 0
    STX $2000    ; disable NMI
    STX $2001    ; disable rendering
    STX $4010    ; disable DMC IRQs

vblankwait1:       ; First wait for vblank to make sure PPU is ready
    BIT $2002
    BPL vblankwait1

clrmem:
    LDA #$00
    STA $0000, x
    STA $0100, x
    STA $0300, x
    STA $0400, x
    STA $0500, x
    STA $0600, x
    STA $0700, x
    LDA #$FE
    STA $0200, x
    INX
    BNE clrmem

vblankwait2:      ; Second wait for vblank, PPU is ready after this
    BIT $2002
    BPL vblankwait2

LoadPalettes:
    LDA $2002             ; read PPU status to reset the high/low latch
    LDA #$3F
    STA $2006             ; write the high byte of $3F00 address
    LDA #$00
    STA $2006             ; write the low byte of $3F00 address
    LDX #$00              ; start out at 0
    
LoadPalettesLoop:
    LDA palette, x        ; load data from address (palette + the value in x)
                          ; 1st time through loop it will load palette+0
                          ; 2nd time through loop it will load palette+1
                          ; 3rd time through loop it will load palette+2
                          ; etc
    STA $2007             ; write to PPU
    INX                   ; X = X + 1
    CPX #$20              ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
    BNE LoadPalettesLoop  ; Branch to LoadPalettesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down


ClearBackground:
    LDA #$20
    STA var_2   ; var_2 = high byte of PPU address
    LDA #$00
    STX var_1   ; var_1 = low byte of PPU address
    LDA $2002             ; read PPU status to reset the high/low latch

    LDY #$00
ClearBackground_OuterLoop:
    LDX #$00

ClearBackground_InnerLoop
    LDA var_2
    STA $2006            ; set high byte write address 
    LDA var_1
    STA $2006            ; set low byte write address 
    LDA #$00
    STA $2007            ; clear tile

    LDA var_1
    CLC
    ADC #$01
    STA var_1             ; increment low byte
    LDA var_2
    ADC #$00              ; push carry to high byte
    STA var_2

    INX

    CPX #32
    BNE ClearBackground_InnerLoop

    INY
    CPY #30
    BNE ClearBackground_OuterLoop
    
ClearAttributes:
    LDA #$23
    STA var_2   ; var_2 = high byte of PPU address
    LDA #$C0
    STX var_1   ; var_1 = low byte of PPU address
    LDA $2002             ; read PPU status to reset the high/low latch
    LDX #$00
    
ClearAttributes_Loop:
    LDA var_2
    STA $2006             ; set high byte write address 
    LDA var_1
    STA $2006             ; set low byte write address 
    LDA #$00
    STA $2007             ; clear attribute
    LDA var_1
    CLC
    ADC #$01
    STA var_1             ; increment low byte
    LDA var_2
    ADC #$00              ; push carry to high byte
    STA var_2

    INX
    CPX #$F0
    BNE ClearAttributes_Loop

    JSR RT_InitPlaySpaceBG
  
InitSound:
    LDA #$0F
    STA $4015
    LDA #$00

    ;;;Set initial ball state
    LDA #$00
    STA balldown
    STA ballright
    LDA #$00
    STA ballup
    STA ballleft

    LDA #$50
    STA bally

    LDA #$80
    STA ballx

    LDA #$00
    STA ballspeedx_fixedacc
    STA ballspeedy_fixedacc

    LDA #%00100000
    STA ballspeedx_fixed
    LDA #%00100000        
    STA ballspeedy_fixed

    ;;Set initial paddle state
    LDA #$68
    STA paddle1ytop
    STA paddle2ytop

    ;;:Set starting game state
    LDA #STATENEWBALL
    STA gamestate

    LDA #$00
    STA p1lastscored
              
    LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
    STA $2000

    LDA #%00011110   ; enable sprites, enable background, no clipping on left side
    STA $2001

Forever:
    JMP Forever     ;jump back to Forever, infinite loop, waiting for NMI

NMI:
    LDA #$00
    STA $2003       ; set the low byte (00) of the RAM address
    LDA #$02
    STA $4014       ; set the high byte (02) of the RAM address, start the transfer

    ;;This is the PPU clean up section, so rendering the next frame starts properly.
    LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
    STA $2000
    LDA #%00011110   ; enable sprites, enable background, no clipping on left side
    STA $2001
    LDA #$00        ;;tell the ppu there is no background scrolling
    STA $2005
    STA $2005

    ;;;all graphics updates done by here, run game engine

    JSR RT_ReadController1  ;;get the current button data for player 1
    JSR RT_ReadController2  ;;get the current button data for player 2
  
GameEngine:  
    LDA gamestate
    CMP #STATETITLE
    BNE GameEngine_CheckStateGameOver 
    BEQ EngineTitle    ;;game is displaying title screen

GameEngine_CheckStateGameOver:  
    LDA gamestate
    CMP #STATEGAMEOVER
    BNE GameEngine_CheckStatePlaying 
    JMP EngineGameOver  ;;game is displaying ending screen

GameEngine_CheckStatePlaying:
    LDA gamestate
    CMP #STATEPLAYING
    BNE GameEngine_CheckStateNewBall   
    JMP EnginePlaying                    ;;game is playing

GameEngine_CheckStateNewBall:
    LDA gamestate
    CMP #STATENEWBALL
    BNE GameEngineDone
    JMP EngineNewBall   ;; game is waiting for player input on new ball

GameEngineDone:  
    JSR RT_UpdateSprites  ;;set ball/paddle sprites from positions
    RTI             ; return from interrupt

;;;;;;;;
 
EngineTitle:
    JMP GameEngineDone

;;;;;;;;; 
 
EngineGameOver:
    JMP GameEngineDone
    
  INCLUDE src\game.asm
  
;----------------------------------------------------------------
; game data
;----------------------------------------------------------------

  .org $E000
  INCLUDE src\data.asm
  
;----------------------------------------------------------------
; interrupt vectors
;----------------------------------------------------------------

  .org $FFFA     ;first of the three vectors starts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                   ;processor will jump to the label NMI:
  .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
  .dw 0          ;external interrupt IRQ is not used in this tutorial

;----------------------------------------------------------------
; CHR-ROM bank
;----------------------------------------------------------------

  .incbin "data\custom.chr"   ;includes 8KB graphics file from SMB1