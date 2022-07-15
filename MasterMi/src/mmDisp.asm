;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name :   mmDisp.asm
; Purpose   :   MasterMind Wrist App Common Display Routines
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;DO NOT MODIFY THE FOLLOWING SUBROUTINE DEFINITION;;;;;;;;;;;;;;;;;

                IF @DEF('SUBROUTINE')
                        UNDEF SUBROUTINE
                ENDIF
                DEFINE  SUBROUTINE      "'mmdisp'"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                ;TODO: Add your own functionality display below or edit above display routines

                GLOBAL    mmBannerMsg

mmBannerMsg:
                db        LCDBANNER_COL1, DM5_ASTERISK, DM5_M, DM5_A, DM5_S, DM5_T, DM5_E, DM5_R, DM5_ASTERISK
                db        LCDBANNER_COL7, DM5_ASTERISK, DM5_M, DM5_I, DM5_N, DM5_D, DM5_ASTERISK
                db        LCD_END_BANNER

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SUBROUTINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                GLOBAL    mmCommonRoundTableOffsetCalculator

mmCommonRoundTableOffsetCalculator:
                ld        IX, IY
                add       IX, #MMBIGTABLEOFFSET

                ; BA = [IY + MMROUNDOFFSET] * 5
                ld        B, #0
                ld        A, [IY + MMROUNDOFFSET]
                sll       A
                sll       A
                add       A, [IY + MMROUNDOFFSET]

                add       IX, BA

                ret

