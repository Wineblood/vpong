EnginePlaying:
    LDA #SCOREXPOS_1P
    STA arg_1
    JSR RT_EraseScore

    LDA #SCOREXPOS_2P
    STA arg_1
    JSR RT_EraseScore

@FixedMath_BallspeedX:
    LDA ballspeedx_fixedacc
    CLC
    ADC ballspeedx_fixed
    STA ballspeedx_fixedacc    ; add the speed to the accumulator
    LDA ballspeedx_fixedacc
    LSR A
    LSR A
    LSR A
    LSR A
    STA ballspeedx             ; add the whole part to the speed used this frame
    LDA ballspeedx_fixedacc
    CLC
    AND #%00001111
    STA ballspeedx_fixedacc    ; then flush the whole part

@FixedMath_BallSpeedY:  
    LDA ballspeedy_fixedacc
    CLC
    ADC ballspeedy_fixed
    STA ballspeedy_fixedacc    ; add the speed to the accumulator
    LDA ballspeedy_fixedacc
    LSR A
    LSR A
    LSR A
    LSR A
    STA ballspeedy             ; add the whole part to the speed used this frame
    LDA ballspeedy_fixedacc
    CLC
    AND #%00001111
    STA ballspeedy_fixedacc    ; then flush the whole part
    
@MoveBallRight:
    LDA ballright
    BEQ @MoveBallLeft   ;;if ballright=0, skip this section

    LDA ballx
    CLC
    ADC ballspeedx        ;;ballx position = ballx + ballspeedx
    CMP ballx
    BEQ @MoveBallRight_SaveX
    BCC @MoveBallRight_P1Scored
    JMP @MoveBallRight_SaveX      ;;if ballx + ballwidth < right wall, still on screen, skip next section
@MoveBallRight_P1Scored:
    LDA #$01
    STA p1lastscored           ;; p1 scored
    LDX score1
    INX
    STX score1                 ;; increment p1 score
    LDA #STATENEWBALL
    STA gamestate              ;; new round
    JMP GameEngineDone
@MoveBallRight_SaveX:
    STA ballx
    
@MoveBallLeft:
    LDA ballleft
    BEQ @MoveBallUp   ;;if ballleft=0, skip this section
    LDA ballx
    SEC
    SBC ballspeedx        ;;ballx position = ballx - ballspeedx
    CMP ballx
    BEQ @MoveBallLeft_SaveX
    BCS @MoveBallLeft_P2Scored
    JMP @MoveBallLeft_SaveX      ;;if ball x > left wall, still on screen, skip next section
@MoveBallLeft_P2Scored:
    LDA #$00
    STA p1lastscored           ;; p2 scored
    LDX score2
    INX
    STX score2                 ;; increment p2 score
    LDA #STATENEWBALL
    STA gamestate              ;; new round
    JMP GameEngineDone
@MoveBallLeft_SaveX:
    STA ballx

@MoveBallUp:
    LDA ballup
    BEQ @MoveBallDown   ;;if ballup=0, skip this section
    LDA bally
    SEC
    SBC ballspeedy        ;;bally position = bally - ballspeedy
    CMP bally
    STA bally
    BCS @MoveBallUp_Bounce    ;; if ball y wrapped around, bounce
    CMP #$08
    BCS @MoveBallDown    ;;if ball y > top wall, still on screen, no bounce
@MoveBallUp_Bounce:
    LDA #$01
    STA balldown
    LDA #$00
    STA ballup         ;;bounce, ball now moving down
    LDA #$08
    STA bally          ;; clip bally to topwall
    JSR RT_PlayBallBounceSound

@MoveBallDown:
    LDA balldown
    BEQ @MoveBallDownDone   ;;if ballup=0, skip this section
    LDA bally
    CLC
    ADC ballspeedy        ;;bally position = bally + ballspeedy
    CMP bally
    STA bally
    BCC @MoveBallDown_Bounce
    CMP #$F0 - $08 - BALLSIZE
    BCC @MoveBallDownDone      ;;if bally - ballsize < bottom wall, still on screen, skip next section
@MoveBallDown_Bounce:
    LDA #$00
    STA balldown
    LDA #$01
    STA ballup         ;;bounce, ball now moving down
    LDA #$F0 - $08 - BALLSIZE
    STA bally
    JSR RT_PlayBallBounceSound
@MoveBallDownDone:
    JSR RT_UpdatePaddles

@CheckPaddleCollision:
    LDA #$00
    STA var_5 ; var_5 = bounce dir (0 = bottom, 1 = top)
@CheckPaddleCollisionX:
    LDA ballleft
    CMP #$01
    BNE @CheckPaddleCollisionRight
  
@CheckPaddleCollisionLeft:
    LDA ballx
    CMP #PADDLE1X + PADDLEWIDTH
    BCC @CheckPaddleCollisionLeft_1
    JMP @CheckPaddleCollisionDone            ; if x > paddle1x + paddle width then reject collision (at left of paddle)
@CheckPaddleCollisionLeft_1:
    CMP #PADDLE1X - BALLSIZE
    BCS @CheckPaddleCollisionLeft_2  
    JMP @CheckPaddleCollisionDone            ; if x + ball size < paddle1x width then reject collision (past the paddle)
@CheckPaddleCollisionLeft_2:
    LDA paddle1ytop
    STA var_1                 ; var_1 = paddle1 y top
    LDA #PADDLE1X + PADDLEWIDTH
    SEC
    SBC ballx
    STA var_2                 ; var_2 = X penetration
    JMP @CheckPaddleCollisionY
  
@CheckPaddleCollisionRight:
    LDA ballx
    CMP #PADDLE2X + PADDLEWIDTH
    BCS @CheckPaddleCollisionDone
    CMP #PADDLE2X - BALLSIZE
    BCC @CheckPaddleCollisionDone
    LDA paddle2ytop
    STA var_1                 ; var_1 = paddle2 y top
    LDA ballx
    SEC
    SBC #PADDLE2X - BALLSIZE
    STA var_2                 ; var_2 = X penetration

@CheckPaddleCollisionY:
    LDA var_1
    CLC
    ADC #PADDLEHEIGHT
    STA var_3                ; var_3 = paddle y bottom
    LDA ballup
    CMP #01
    BNE @CheckPaddleCollisionDown
  
@CheckPaddleCollisionUp:
    LDA bally
    CMP var_3
    BCS @CheckPaddleCollisionDone ; if bally > paddle y bottom then reject collision
    CLC
    ADC #BALLSIZE
    CMP var_1
    BCC @CheckPaddleCollisionDone ; if bally bottom < paddle y top then reject collision
    JMP @CheckPaddleCollision_CalcYPen
  
@CheckPaddleCollisionDown:
    LDA bally
    CLC
    ADC #BALLSIZE
    CMP var_1
    BCC @CheckPaddleCollisionDone
    LDA bally
    CMP var_3
    BCS @CheckPaddleCollisionDone
    JMP @CheckPaddleCollision_CalcYPen

@CheckPaddleCollisionDone:
    JMP @CheckPaddleCollisionDone_LongJMP
  
@CheckPaddleCollision_CalcYPen:
    LDA var_3
    SEC
    SBC bally
    STA var_4                    ; var_4 = Y bottom penetration

    LDA bally
    CLC
    ADC #BALLSIZE
    SEC
    SBC var_1
    CMP var_4                    ; use smallest penetration, then save it
    BCC @CheckPaddleCollision_YPenTop
    JMP @CheckPaddleCollision_Reb
    
@CheckPaddleCollision_YPenTop:
    STA var_4                    ; var_4 = Y top penetration
    LDA #$01
    STA var_5                    ; var_5 = bounce up
  
@CheckPaddleCollision_Reb:
    LDA var_2
    CMP var_4
    BCS @CheckPaddleCollision_Reb_V

    LDA ballleft
    EOR #$01
    STA ballleft
    LDA ballright
    EOR #$01
    STA ballright
    JMP @CheckPaddleCollision_SetX
  
@CheckPaddleCollision_Reb_V:
    LDA var_5
    CMP ballup
    BNE @CheckPaddleCollision_Reb_V1
    JMP @CheckPaddleCollisionDone_LongJMP
  
@CheckPaddleCollision_Reb_V1:
    STA ballup
    EOR #$01
    STA balldown
    JSR RT_PlayBallBounceSound
    JMP @CheckPaddleCollisionDone_LongJMP

@CheckPaddleCollision_SetX:
    LDA ballleft
    CMP #$01
    BEQ @CheckPaddleCollision_SetXRightPaddle
    LDA #PADDLE1X + PADDLEWIDTH
    STA ballx                                  ; Set ball x on the left paddle
    JMP @CheckPaddleCollision_CalcSpeed

@CheckPaddleCollision_SetXRightPaddle:
    LDA #PADDLE2X - BALLSIZE
    STA ballx                                  ; Set ball x on the right paddle

@CheckPaddleCollision_CalcSpeed:
    LDX #$00
    LDY #$01
    STY ballup                                  ; Let's assume first that the ball will bounce up
    STX balldown

    LDA bally
    SEC
    SBC var_1                                   ; Setup value to start computing quadrants (bally - paddletop)
    LDX #$01
    CMP #$FC
    BCS @CheckPaddleCollision_CalcSpeedTable   ; if bally < 0
    LDX #$00
    CMP #$E0
    BCS @CheckPaddleCollision_CalcSpeedTable   ; if bally < -4 (or more, we're generous here)
    LDX #$02
    CMP #$04
    BCC @CheckPaddleCollision_CalcSpeedTable   ; if bally < 4
    LDX #$03
    CMP #$08
    BCC @CheckPaddleCollision_CalcSpeedTable   ; if bally < 8
    LDX #$04
    CMP #$0C
    BCC @CheckPaddleCollision_CalcSpeedTable   ; if bally < 12

    LDY #$00
    STY ballup 
    LDY #$01  
    STY balldown                        ; if all those conditions failed then the ball goes down

    LDX #$04
    CMP #$10
    BCC @CheckPaddleCollision_CalcSpeedTable   ; if bally < 16
    LDX #$03
    CMP #$14
    BCC @CheckPaddleCollision_CalcSpeedTable   ; if bally < 20
    LDX #$02
    CMP #$18
    BCC @CheckPaddleCollision_CalcSpeedTable   ; if bally < 24
    LDX #$01
    CMP #$1C
    BCC @CheckPaddleCollision_CalcSpeedTable   ; if bally < 28
    LDX #$00
    JMP @CheckPaddleCollision_CalcSpeedTable   ; if bally > 28

@CheckPaddleCollision_CalcSpeedTable:
    LDA #$00
    LDY #$00
    
@CheckPaddleCollision_CSTLoop:               ; ballspeedoffset = baseoffset + entrysize * ballspeedlevel
    CPY ballspeedlevel
    BEQ @CheckPaddleCollision_SetSpeed    
    INY
    CLC
    ADC #$0A                                  ; jump over a full entry of ball speed
    JMP @CheckPaddleCollision_CSTLoop
    
@CheckPaddleCollision_SetSpeed:
    STX var_1
    CLC
    ADC var_1
    TAX
    LDA paddlehitspeeds, x
    STA ballspeedx_fixed
    LDA paddlehitspeeds + 1, x
    STA ballspeedy_fixed
    JSR RT_PlayPaddleHitSound
    ; give progress to the ball speed
    LDY ballspeedlevel
    LDA ballspeedprogress
    CLC
    ADC #$01                           ; progress + 1
    CMP ballleveluptable,y
    BNE @CheckPaddleCollision_NoLevelUp ; level up speed if progress is greater than the levelup table value
    INY
    CPY NUMBEROFBALLLEVELS
    BEQ @CheckPaddleCollisionDone_LongJMP ; if we're at max level, no level up
    STY ballspeedlevel
    LDX #$00
    STX ballspeedprogress
    JMP @CheckPaddleCollisionDone_LongJMP
    
@CheckPaddleCollision_NoLevelUp:
    STA ballspeedprogress

@CheckPaddleCollisionDone_LongJMP:
    JMP GameEngineDone

EngineNewBall:
    ; reset speed level
    LDA #$00
    STA ballspeedlevel
    LDA #$00
    STA ballspeedprogress
    ; reset speed
    LDA paddlehitspeeds + 6
    STA ballspeedx_fixed
    LDA paddlehitspeeds + 7
    STA ballspeedy_fixed

    LDA score1
    STA arg_1
    LDA #SCOREXPOS_1P
    STA arg_2
    JSR RT_DrawScore ; draw 1p score

    LDA score2
    STA arg_1
    LDA #SCOREXPOS_2P
    STA arg_2
    JSR RT_DrawScore ; draw 1p score

    JSR RT_UpdatePaddles
  
@EngineNewBall_WaitForInput:
    LDA p1lastscored
    CMP #$01
    BEQ @EngineNewBall_WaitForP2Input

@EngineNewBall_WaitForP1Input:
    LDA #PADDLE1X + PADDLEWIDTH
    STA ballx                  ;; set service to p1 - ballx
    LDA paddle1ytop
    CLC
    ADC #((PADDLEHEIGHT / 2) - (BALLSIZE / 2))
    STA bally                  ;; set service to p1 - bally

    LDA buttons1
    AND #%11000000
    BEQ @EngineNewBallEnd
    LDA #$01
    STA ballup
    STA ballright
    LDA #$00
    STA ballleft
    STA balldown
    JSR RT_PlayPaddleHitSound
    LDA #STATEPLAYING
    STA gamestate
    JMP @EngineNewBallEnd

@EngineNewBall_WaitForP2Input:
    LDA #PADDLE2X - BALLSIZE
    STA ballx                  ;; set service to p2 - ballx
    LDA paddle2ytop
    CLC
    ADC #((PADDLEHEIGHT / 2) - (BALLSIZE / 2))
    STA bally                  ;; set service to p2 - bally

    LDA buttons2
    AND #%11000000
    BEQ @EngineNewBallEnd
    LDA #$01
    STA ballup
    STA ballleft
    LDA #$00
    STA ballright
    STA balldown
    JSR RT_PlayPaddleHitSound
    LDA #STATEPLAYING
    STA gamestate

@EngineNewBallEnd:
    JMP GameEngineDone
  
RT_UpdatePaddles: ;;#ROUTINE_START
    LDA #paddle1ytop
    STA arg_1
    LDA #buttons1
    STA arg_2
    JSR @RT_PaddleMovement ; Update psddle 1

    LDA #paddle2ytop
    STA arg_1
    LDA #buttons2
    STA arg_2
    JSR @RT_PaddleMovement ; Update psddle 2
    RTS
  
; arg_1 (INOUT) = ZP pointer to paddleytop
; arg_2 (IN)    = ZP pointer to buttons
@RT_PaddleMovement: ;;#ROUTINE_START
    LDX arg_1
    LDA $00,x
    STA var_1           ; var_1 = paddleytop
    LDX arg_2
    LDA $00,x
    STA var_2           ; var_2 = buttons
    
@MovePaddleUp:
    LDA var_2
    AND #%00001000
    BEQ @MovePaddleDown ; if up button pressed...

    LDA var_1
    SEC
    SBC #PADDLESPEED      ; ...paddley = paddley + speed
    STA var_1

    CMP #TOPWALL          ; if paddley > top wall
    BCS @MovePaddleDown ; else clip value
    LDA #TOPWALL
    STA var_1       ; clip paddley = top wall
    
@MovePaddleDown:
    LDA var_2
    AND #%00000100
    BEQ @MovePaddleDownDone ; if up button pressed...

    LDA var_1
    CLC
    ADC #PADDLESPEED        ; ...paddley = paddley + speed
    STA var_1

    CLC
    ADC #PADDLEHEIGHT
    CMP #BOTTOMWALL          ; if paddley + paddleheight > bottomwall, clip value
    BCC @MovePaddleDownDone 
    LDA #BOTTOMWALL
    SEC
    SBC #PADDLEHEIGHT
    STA var_1          ; clip paddley to bottomwall - paddleheight

@MovePaddleDownDone:
    LDX arg_1
    LDA var_1
    STA $00,x     ; *arg_1 = updated paddleytop
    RTS 

RT_PlayPaddleHitSound: ;;#ROUTINE_START
    LDA #%00011111
    STA $4008
    LDA #$08
    STA $4009
    LDA #$6A
    STA $400A
    LDA #$00
    STA $400B
    RTS

RT_PlayBallBounceSound: ;;#ROUTINE_START
    LDA #%00011111
    STA $4008
    LDA #$08
    STA $4009
    LDA #$AB
    STA $400A
    LDA #$01
    STA $400B
    RTS
  
RT_UpdateSprites: ;;#ROUTINE_START
    LDA bally  ;;update all ball sprite info
    STA $0200

    LDA #$01
    STA $0201

    LDA #$00
    STA $0202

    LDA ballx
    STA $0203

    ;;update paddle sprites

    ;;;;;;;; paddle 1 sprites
    ; sprite 1 begin
    LDX #$00  ; sprite 1 mem offset
    LDA paddle1ytop ; sprite 1 y 
    STA $204,x  
    LDA #$10  ; sprite 1 tile
    STA $205,x
    LDA #$01  ; sprite 1 attr
    STA $206,x
    LDA #PADDLE1X
    STA $207,x
    ; sprite 2 begin
    LDX #$04  ; sprite 2 mem offset
    LDA paddle1ytop 
    CLC
    ADC #$08  ; sprite 2 y = y + 8
    STA $204,x
    LDA #$20  ; sprite 2 tile
    STA $205,x
    LDA #$01  ; sprite 2 attr
    STA $206,x
    LDA #PADDLE1X
    STA $207,x
    ; sprite 3 begin
    LDX #$08  ; sprite 3 mem offset
    LDA paddle1ytop 
    CLC
    ADC #$10  ; sprite 2 y = y + 16
    STA $204,x
    LDA #$30  ; sprite 3 tile
    STA $205,x
    LDA #$01  ; sprite 3 attr
    STA $206,x
    LDA #PADDLE1X
    STA $207,x
    ; sprite 4 begin
    LDX #$0C  ; sprite 4 mem offset
    LDA paddle1ytop 
    CLC
    ADC #$18  ; sprite 2 y = y + 24
    STA $204,x
    LDA #$40  ; sprite 4 tile
    STA $205,x
    LDA #$01  ; sprite 4 attr
    STA $206,x
    LDA #PADDLE1X
    STA $207,x

    ;;;;;;;; paddle 2 sprites
    ; sprite 1 begin
    LDX #$10  ; sprite 1 mem offset
    LDA paddle2ytop ; sprite 1 y 
    STA $204,x  
    LDA #$10  ; sprite 1 tile
    STA $205,x
    LDA #%01000010 ; sprite 1 attr
    STA $206,x
    LDA #PADDLE2X
    STA $207,x
    ; sprite 2 begin
    LDX #$14  ; sprite 2 mem offset
    LDA paddle2ytop 
    CLC
    ADC #$08  ; sprite 2 y = y + 8
    STA $204,x
    LDA #$20  ; sprite 2 tile
    STA $205,x
    LDA #%01000010 ; sprite 2 attr
    STA $206,x
    LDA #PADDLE2X
    STA $207,x
    ; sprite 3 begin
    LDX #$18  ; sprite 3 mem offset
    LDA paddle2ytop 
    CLC
    ADC #$10  ; sprite 2 y = y + 16
    STA $204,x
    LDA #$30  ; sprite 3 tile
    STA $205,x
    LDA #%01000010 ; sprite 3 attr
    STA $206,x
    LDA #PADDLE2X
    STA $207,x
    ; sprite 4 begin
    LDX #$1C  ; sprite 4 mem offset
    LDA paddle2ytop 
    CLC
    ADC #$18  ; sprite 2 y = y + 24
    STA $204,x
    LDA #$40  ; sprite 4 tile
    STA $205,x
    LDA #%01000010  ; sprite 4 attr
    STA $206,x
    LDA #PADDLE2X
    STA $207,x

    RTS

; arg_1 (IN) score to display
; arg_2 (IN) x position to display
RT_DrawScore: ;;#ROUTINE_START  ;; TODO - Refactor and properly finish this function! (Do a DrawMetaTile function)

    JSR RT_BinTo2Dec ; TODO - DEBUG THIS FUNC! IT MAKES THE GAME CRASH!
    ; var_1 = score tens
    ; var_2 = score ones
    ;LDA #$01
    ;STA var_1 

    LDA #$00
    LDX #$00  
@DrawScore_CalcTensCharOffset:
    CPX var_2
    BEQ @DrawScore_DrawTens
    CLC
    ADC #$0C   ; Jump to next letter (size 12)
    INX
    JMP @DrawScore_CalcTensCharOffset

@DrawScore_DrawTens:
    TAX        ; x = char offset
    LDY #$00   ; y = curr line drawing
    LDA #<(SCOREYPOS)
    CLC
    ADC arg_2  ; low-byte = low-byte + x position
    STA var_3  ; var_3 = low-byte PPU address
    LDA #>(SCOREYPOS)
    STA var_4  ; var_4 = high-byte PPU address
@DrawScore_DrawTensLine:
    LDA $2002             ; read PPU status to reset the high/low latch
    LDA var_4
    STA $2006            
    LDA var_3
    STA $2006

    LDA numberdata_0,x
    STA $2007
    INX
    LDA numberdata_0,x
    STA $2007
    INX
    LDA numberdata_0,x
    STA $2007
    INX

    LDA var_3
    CLC
    ADC #$20 
    STA var_3 ; Add a line to the PPU offset (low byte)
    LDA var_4
    ADC #$00
    STA var_4 ; Add the carry to the high byte if there is one

    INY
    CPY #$04
    BNE @DrawScore_DrawTensLine ; stop on 4th line

    LDA #$00
    STA $2005
    STA $2005

    RTS
  
  
; arg_1 (IN) x position to display
RT_EraseScore: ;;#ROUTINE_START  ;; TODO - Refactor and properly finish this function! (Do a EraseTiles function)
    LDY #$00   ; y = curr line drawing
    LDA #<(SCOREYPOS)
    CLC
    ADC arg_1  ; low-byte = low-byte + x position
    STA var_3  ; var_3 = low-byte PPU address
    LDA #>(SCOREYPOS)
    STA var_4  ; var_4 = high-byte PPU address
    
@EraseScore_Loop:
    LDA $2002             ; read PPU status to reset the high/low latch
    LDA var_4
    STA $2006            
    LDA var_3
    STA $2006

    LDA #$00
    STA $2007
    STA $2007
    STA $2007

    LDA var_3
    CLC
    ADC #$20 
    STA var_3 ; Add a line to the PPU offset (low byte)
    LDA var_4
    ADC #$00
    STA var_4 ; Add the carry to the high byte if there is one

    INY
    CPY #$04
    BNE @EraseScore_Loop ; stop on 4th line

    LDA #$00
    STA $2005
    STA $2005

    RTS
 
RT_ReadController1: ;;#ROUTINE_START
    LDA #$01
    STA $4016
    LDA #$00
    STA $4016
    LDX #$08
@ReadController1Loop:
    LDA $4016
    LSR A            ; bit0 -> Carry
    ROL buttons1     ; bit0 <- Carry
    DEX
    BNE @ReadController1Loop
    RTS
  
RT_ReadController2: ;;#ROUTINE_START
    LDA #$01
    STA $4016
    LDA #$00
    STA $4016
    LDX #$08
@ReadController2Loop:
    LDA $4017
    LSR A            ; bit0 -> Carry
    ROL buttons2     ; bit0 <- Carry
    DEX
    BNE @ReadController2Loop
    RTS  
  
; arg_1 (IN)  = The hex number to convert
; var_1 (OUT) = The tens digit
; var_2 (OUT) = The ones digit
RT_BinTo2Dec ;;#ROUTINE_START
    LDX #$00   ; X = tens
    LDA arg_1
    CMP #$0A
    BCC @CountOnes
    
@CountTens:
    INX
    SEC
    SBC #$0A
    CMP #$0A
    BCC @CountOnes
    JMP @CountTens
    
@CountOnes:
    STX var_1
    STA var_2
    
    RTS
    
RT_InitPlaySpaceBG: ;;#ROUTINE_START
    LDA $2002   ; read PPU status to reset the high/low latch
    
    LDA #$20
    STA var_2   ; var_2 = high byte of PPU address
    LDA #$0F
    STA var_1   ; var_1 = low byte of PPU address

    LDX #$00
    
@InitPlaySpaceBG_TileLoop:
    LDA var_2
    STA $2006            ; set high byte write address 
    LDA var_1
    STA $2006            ; set low byte write address
    
    CLC
    ADC #$01
    STA var_1             ; increment low byte
    LDA var_2
    ADC #$00              ; push carry to high byte
    STA var_2
    
    LDA #$08
    STA $2007
  
    LDA var_2
    STA $2006            ; set high byte write address 
    LDA var_1
    STA $2006            ; set low byte write address
    
    CLC
    ADC #$1F
    STA var_1             ; increment low byte
    LDA var_2
    ADC #$00              ; push carry to high byte
    STA var_2
    
    LDA #$09
    STA $2007 
    
    INX
    CPX #30
    BEQ @InitPlaySpaceBG_TileDone
    JMP @InitPlaySpaceBG_TileLoop
    
@InitPlaySpaceBG_TileDone:    ; Copy palette
    LDA #$23
    STA var_2   ; var_2 = high byte of PPU address
    LDA #$C3
    STA var_1   ; var_1 = low byte of PPU address

    LDX #$00
    
@InitPlaySpaceBG_AttrLoop:
    LDA var_2
    STA $2006            ; set high byte write address 
    LDA var_1
    STA $2006            ; set low byte write address
    
    CLC
    ADC #$01
    STA var_1             ; increment low byte
    LDA var_2
    ADC #$00              ; push carry to high byte
    STA var_2
    
    LDA #%01010101
    STA $2007
    
    LDA var_2
    STA $2006            ; set high byte write address 
    LDA var_1
    STA $2006            ; set low byte write address
    
    CLC
    ADC #$07
    STA var_1             ; increment low byte
    LDA var_2
    ADC #$00              ; push carry to high byte
    STA var_2
    
    LDA #%01010101
    STA $2007
    
    INX
    CPX #$08
    BNE @InitPlaySpaceBG_AttrLoop
    
    RTS