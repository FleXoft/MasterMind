;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name    : mmsetbn.asm
; Purpose      : MasterMind Application Set Banner State Manager
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;DO NOT MODIFY THE FOLLOWING SUBROUTINE DEFINITION;;;;;;;;;;;;;;;;;

                IF @DEF('SUBROUTINE')
                    UNDEF SUBROUTINE
                ENDIF
                DEFINE  SUBROUTINE      "'mmsetbn'"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Module Name : mmSetBannerStateManager
; Description : MasterMind ASet Banner State Manager.
; Assumptions : Display is cleared on first time entry into the state.
; Input(s)    : CORECurrentEvent  - system event to be processed
; Output(s)   : None
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                GLOBAL  mmSetBannerStateManager

mmSetBannerStateManager:
                ; Get the event to be processed.
                ld      A, [CORECurrentEvent]

                ; Check if State Entry Event.
                cp      A, #MM_STATEENTRY
                jr      NZ, utlSetBannerStateManager

                ;**************************************************************
                ;
                ;                       STATE ENTRY
                ;
                ;**************************************************************

                ld        IY, #mmSetBannerMsg
                LCD_DISP_BANNER_MSG

                jr        utlSetBannerStateManager

;==============================================================================
;
;                THIS IS YOUR COSTUMIZED SET BANNER CREATED FROM WRISTAPP WIZARD
;
;==============================================================================

mmSetBannerMsg:
                db        LCDBANNER_COL16, DM5_M, DM5_M
                db        LCDBANNER_COL5, DM5_S, DM5_E, DM5_T, DM5_T, DM5_I, DM5_N, DM5_G
                db        LCD_END_BANNER

