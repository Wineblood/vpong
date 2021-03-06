palette:
    .incbin "data\custom.chr.dat"

ballleveluptable:
    .db 2,3,3,3,4,5,7,8
    
paddlehitspeeds:
    .db $1c,$30   ; 3.5 * cos(60.0), 3.5 * sin(60.0) in fixed 4.4
    .db $28,$28   ; 3.5 * cos(45.0), 3.5 * sin(45.0) in fixed 4.4
    .db $30,$1c   ; 3.5 * cos(30.0), 3.5 * sin(30.0) in fixed 4.4
    .db $35,$13   ; 3.5 * cos(20.0), 3.5 * sin(20.0) in fixed 4.4
    .db $37,$0a   ; 3.5 * cos(10.0), 3.5 * sin(10.0) in fixed 4.4
    .db $1e,$35   ; 3.8 * cos(60.0), 3.8 * sin(60.0) in fixed 4.4
    .db $2b,$2b   ; 3.8 * cos(45.0), 3.8 * sin(45.0) in fixed 4.4
    .db $35,$1e   ; 3.8 * cos(30.0), 3.8 * sin(30.0) in fixed 4.4
    .db $39,$15   ; 3.8 * cos(20.0), 3.8 * sin(20.0) in fixed 4.4
    .db $3c,$0b   ; 3.8 * cos(10.0), 3.8 * sin(10.0) in fixed 4.4
    .db $21,$39   ; 4.1 * cos(60.0), 4.1 * sin(60.0) in fixed 4.4
    .db $2e,$2e   ; 4.1 * cos(45.0), 4.1 * sin(45.0) in fixed 4.4
    .db $39,$21   ; 4.1 * cos(30.0), 4.1 * sin(30.0) in fixed 4.4
    .db $3e,$16   ; 4.1 * cos(20.0), 4.1 * sin(20.0) in fixed 4.4
    .db $41,$0b   ; 4.1 * cos(10.0), 4.1 * sin(10.0) in fixed 4.4
    .db $23,$3d   ; 4.4 * cos(60.0), 4.4 * sin(60.0) in fixed 4.4
    .db $32,$32   ; 4.4 * cos(45.0), 4.4 * sin(45.0) in fixed 4.4
    .db $3d,$23   ; 4.4 * cos(30.0), 4.4 * sin(30.0) in fixed 4.4
    .db $42,$18   ; 4.4 * cos(20.0), 4.4 * sin(20.0) in fixed 4.4
    .db $45,$0c   ; 4.4 * cos(10.0), 4.4 * sin(10.0) in fixed 4.4
    .db $26,$41   ; 4.7 * cos(60.0), 4.7 * sin(60.0) in fixed 4.4
    .db $35,$35   ; 4.7 * cos(45.0), 4.7 * sin(45.0) in fixed 4.4
    .db $41,$26   ; 4.7 * cos(30.0), 4.7 * sin(30.0) in fixed 4.4
    .db $47,$1a   ; 4.7 * cos(20.0), 4.7 * sin(20.0) in fixed 4.4
    .db $4a,$0d   ; 4.7 * cos(10.0), 4.7 * sin(10.0) in fixed 4.4
    .db $28,$45   ; 5.0 * cos(60.0), 5.0 * sin(60.0) in fixed 4.4
    .db $39,$39   ; 5.0 * cos(45.0), 5.0 * sin(45.0) in fixed 4.4
    .db $45,$28   ; 5.0 * cos(30.0), 5.0 * sin(30.0) in fixed 4.4
    .db $4b,$1b   ; 5.0 * cos(20.0), 5.0 * sin(20.0) in fixed 4.4
    .db $4f,$0e   ; 5.0 * cos(10.0), 5.0 * sin(10.0) in fixed 4.4
    .db $2a,$49   ; 5.3 * cos(60.0), 5.3 * sin(60.0) in fixed 4.4
    .db $3c,$3c   ; 5.3 * cos(45.0), 5.3 * sin(45.0) in fixed 4.4
    .db $49,$2a   ; 5.3 * cos(30.0), 5.3 * sin(30.0) in fixed 4.4
    .db $50,$1d   ; 5.3 * cos(20.0), 5.3 * sin(20.0) in fixed 4.4
    .db $54,$0f   ; 5.3 * cos(10.0), 5.3 * sin(10.0) in fixed 4.4
    .db $2d,$4e   ; 5.6 * cos(60.0), 5.6 * sin(60.0) in fixed 4.4
    .db $3f,$3f   ; 5.6 * cos(45.0), 5.6 * sin(45.0) in fixed 4.4
    .db $4e,$2d   ; 5.6 * cos(30.0), 5.6 * sin(30.0) in fixed 4.4
    .db $54,$1f   ; 5.6 * cos(20.0), 5.6 * sin(20.0) in fixed 4.4
    .db $58,$10   ; 5.6 * cos(10.0), 5.6 * sin(10.0) in fixed 4.4
    .db $2f,$52   ; 5.9 * cos(60.0), 5.9 * sin(60.0) in fixed 4.4
    .db $43,$43   ; 5.9 * cos(45.0), 5.9 * sin(45.0) in fixed 4.4
    .db $52,$2f   ; 5.9 * cos(30.0), 5.9 * sin(30.0) in fixed 4.4
    .db $59,$20   ; 5.9 * cos(20.0), 5.9 * sin(20.0) in fixed 4.4
    .db $5d,$10   ; 5.9 * cos(10.0), 5.9 * sin(10.0) in fixed 4.4
    .db $32,$56   ; 6.2 * cos(60.0), 6.2 * sin(60.0) in fixed 4.4
    .db $46,$46   ; 6.2 * cos(45.0), 6.2 * sin(45.0) in fixed 4.4
    .db $56,$32   ; 6.2 * cos(30.0), 6.2 * sin(30.0) in fixed 4.4
    .db $5d,$22   ; 6.2 * cos(20.0), 6.2 * sin(20.0) in fixed 4.4
    .db $62,$11   ; 6.2 * cos(10.0), 6.2 * sin(10.0) in fixed 4.4

numberdata_0:
    .db $03,$02,$04
    .db $01,$00,$01
    .db $01,$00,$01
    .db $05,$02,$06
numberdata_1:
    .db $03,$01,$00
    .db $07,$01,$00
    .db $00,$01,$00
    .db $02,$02,$02
numberdata_2:
    .db $03,$02,$04
    .db $07,$00,$01
    .db $03,$02,$06
    .db $02,$02,$02
numberdata_3:
    .db $02,$02,$04
    .db $00,$02,$01
    .db $00,$00,$01
    .db $02,$02,$06
numberdata_4:
    .db $01,$00,$01
    .db $02,$02,$01
    .db $00,$00,$01
    .db $00,$00,$02
numberdata_5:
    .db $01,$02,$02
    .db $02,$02,$04
    .db $00,$00,$01
    .db $02,$02,$06
numberdata_6:
    .db $03,$02,$04
    .db $01,$00,$07
    .db $01,$02,$04
    .db $05,$02,$06
numberdata_7:
    .db $03,$02,$01
    .db $00,$00,$01
    .db $00,$00,$01
    .db $00,$00,$02
numberdata_8:
    .db $03,$02,$04
    .db $01,$02,$01
    .db $01,$00,$01
    .db $05,$02,$06
numberdata_9:
    .db $03,$02,$04
    .db $01,$07,$01
    .db $05,$02,$01
    .db $02,$02,$06