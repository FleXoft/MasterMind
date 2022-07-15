;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name    : mmset.asm
; Purpose      : MasterMind Application Set State Manager
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;DO NOT MODIFY THE FOLLOWING SUBROUTINE DEFINITION;;;;;;;;;;;;;;;;;

                IF @DEF('SUBROUTINE')
                    UNDEF SUBROUTINE
                ENDIF
                DEFINE  SUBROUTINE      "'mmset'"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Module Name : mmSetStateManager
; Description : MasterMind Application Set State Manager.
; Assumptions : Display is cleared on first time entry into the state.
; Input(s)    : CORECurrentEvent  - system event to be processed
;               COREEventArgument - event extra information
; Output(s)   : None
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                GLOBAL  mmSetStateManager

mmSetStateManager:
                ; Set IYReg the address of the MasterMind ASD.
                ld      IY, [CORECurrentASDAddress]

                ; Load the event to be process to AReg.
                ld      A, [CORECurrentEvent]

                ; Check if state entry event.
                cp      A, #MM_STATEENTRY
                jr      Z, mmSetStateEntryEvent

                cp      A, #MM_CROWNHOME
                jr      Z, mmSetStatePushedCrownEvent

                ; Check if mode depress event.
                cp      A, #MM_MODEDEPRESS
                jr      Z, mmSetStateModeDepressEvent

                cp      A, #MM_CWPULSES
                jr      Z, mmSetStateCWPulseEvent

                cp      A, #MM_CCWPULSES
                jr      Z, mmSetStateCCWPulseEvent

                ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mmSetSaveStatus:
                db        0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EVENT HANDLERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mmSetStateEntryEvent:
                ;**************************************************************
                ;                       STATE ENTRY
                ;**************************************************************

                ; save the current value
                ld         A, [IY + MMCHOICESOFFSET]
                ld         [mmSetSaveStatus], A

                ; Enable pulse mode to change values.
                CORE_ENABLE_PULSE_MODE
                CORE_MASK_KEYS  (MMSWITCHMASK_STARTSPLIT | MMSWITCHMASK_STOPRESET | MMSWITCHMASK_EL)

                car       mmSetRedisplay
                ;
                ld        IY, #mmsetbannermsg
                LCD_DISP_BANNER_MSG

                ret

mmsetbannermsg:
                db        LCDBANNER_COL16, DM5_M, DM5_M
                db        LCDBANNER_COL5, DM5_S, DM5_E, DM5_T, DM5_T, DM5_I, DM5_N, DM5_G
                db        LCD_END_BANNER

mmSetStatePushedCrownEvent:
                ;**************************************************************
                ;                       CROWN HOME
                ;**************************************************************

                ; 'send' the default state to reset the game if necessary
                ld         A, [IY + MMCHOICESOFFSET]
                ld         B, [mmSetSaveStatus]
                cp         A, B
                jr         Z, mmsetstatepushedcrowneventnottoreset

                ld        A, #MMROUNDINIT
                ld        [IY + MMROUNDOFFSET], A

mmsetstatepushedcrowneventnottoreset:
                ld      B, #MMDEFAULTSTATE
                CORE_REQ_STATE_CHANGE

                ret

mmSetStateModeDepressEvent:
                ;**************************************************************
                ;         MODE DEPRESS
                ;**************************************************************

                LCD_CLR_DISPLAY
                ;
                ld        L, #DM5_P
                ld        IX, #LCDMAINDMLINE1COL1
                LCD_DISP_SMALL_FIXED_WIDTH_DM_CHAR
                ;
                ld	  L, [IY + MMGAMENUMBER]
		UTL_CONVERT_HEX_TO_2DIGIT_BCD
		ld	  IX, #LCDMAINDMLINE1COL10
		LCD_DISP_SMALL_FIXED_WIDTH_2DIG_DM_DATA_NO_ZERO_SUP
                ;
                ld        L, #DM5_W
                ld        IX, #LCDMAINDMLINE2COL1
                LCD_DISP_SMALL_FIXED_WIDTH_DM_CHAR
                ;
                ld	  L, [IY + MMWGAMENUMBER]
		UTL_CONVERT_HEX_TO_2DIGIT_BCD
		ld	  IX, #LCDMAINDMLINE2COL10
		LCD_DISP_SMALL_FIXED_WIDTH_2DIG_DM_DATA_NO_ZERO_SUP
                ;
		ld 	  IY, #mmsetstatseg
		LCD_DISP_SEG_LINE_MSG

                ret

mmsetstatseg:
		db 	SEG_V, SEG_COLON, SEG_SPACE, SEG_1, SEG_0, SEG_0

mmSetStateCWPulseEvent:
                ;**************************************************************
                ;                       CLOCKWISE CROWN ROTATION
                ;**************************************************************

                ld         A, [IY + MMCHOICESOFFSET]
                cp         A, #MMCHOICESMAX
                jr         Z, mmsetstatecwpulseeventexit

                inc        A
                ld         [IY + MMCHOICESOFFSET], A

                car       mmSetRedisplay

mmsetstatecwpulseeventexit:
                ret

mmSetStateCCWPulseEvent:
                ;**************************************************************
                ;                       COUNTER CLOCKWISE CROWN ROTATION
                ;**************************************************************

                ld         A, [IY + MMCHOICESOFFSET]
                cp         A, #MMCHOICESMIN
                jr         Z, mmsetstateccwpulseeventexit

                dec        A
                ld         [IY + MMCHOICESOFFSET], A

                car       mmSetRedisplay

mmsetstateccwpulseeventexit:
                ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SUBROUTINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mmSetRedisplay:
                ld        A, [IY + MMCHOICESOFFSET]
                add       A, #SEG_A - 1
                ld        [mmsetlastseg], A

		ld 	  IY, #mmsetsegmsg
		LCD_DISP_SEG_LINE_MSG

                ret

mmsetsegmsg:
		db 	  SEG_A, SEG_MINUS, SEG_MINUS, SEG_MINUS
mmsetlastseg:
		db	  SEG_A, SEG_SPACE

