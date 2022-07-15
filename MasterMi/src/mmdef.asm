;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name    : mmdef.asm
; Purpose      : MasterMind Application Default State Manager
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;DO NOT MODIFY THE FOLLOWING SUBROUTINE DEFINITION;;;;;;;;;;;;;;;;;

                IF @DEF('SUBROUTINE')
                    UNDEF SUBROUTINE
                ENDIF
                DEFINE  SUBROUTINE      "'mmdef'"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Module Name : mmDefaultStateManager
; Description : MasterMind Application Default State Manager.
; Assumptions : Display is cleared on first time entry into the state.
; Input(s)    : CORECurrentEvent  - system event to be processed
;               COREEventArgument - event extra information
; Output(s)   : None
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                GLOBAL  mmDefaultStateManager

mmDefaultStateManager:
                ; Set IYReg the address of the MasterMind ASD.
                ld      IY, [CORECurrentASDAddress]

                ; Load the event to be process to AReg.
                ld      A, [CORECurrentEvent]

                ; Check if state entry event.
                cp      A, #MM_STATEENTRY
                jr      Z, mmDefaultStateStateEntryEvent

                ; Check if mode depress event.
                cp      A, #MM_MODEDEPRESS
                jr      Z, mmDefaultStateModeDepressEvent

                ; Check if crown set event.
                cp      A, #MM_CROWNSET
                jr      Z, mmDefaultStatePulledCrownEvent

                ; Check if start/split depress event.
                cp      A, #MM_STARTSPLITDEPRESS
                jr      Z, mmDefaultStateStartSplitDepressEvent

                cp      A, #MM_CWPULSES
                jr      Z, mmDefaultStateCWPulseEvent

                cp      A, #MM_CCWPULSES
                jr      Z, mmDefaultStateCCWPulseEvent

                ; Check if stop/reset depress event.
                cp      A, #MM_STOPRESETDEPRESS
                jr      Z, mmDefaultStateStopResetDepressEvent

                ; Check if stop/reset release event.
                cp      A, #MM_STOPRESETRELEASE
                jr      Z, mmDefaultStateStopResetReleaseEvent

                ; Check if timeout hi-res done event.
                cp      A, #MM_TIMEOUTDONEHIGHRES
                jr      Z, mmDefaultStateTimeoutHiResDoneEvent

                ;TODO: Add more events detection here
                ;There are more events, add your own as needed

                ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EVENT HANDLERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mmDefaultStateStateEntryEvent:
                ;**************************************************************
                ;         STATE ENTRY
                ;**************************************************************

                ; Help message how to start the game and reset the game
                ld        A, [IY + MMROUNDOFFSET]
                cp        A, #MMROUNDINIT
                jr        NZ, mmdefaultstatestateentryeventnostartmsg

                ; Reset the game
                car       mmDefaultStateResetGame

                ret

mmdefaultstatestateentryeventnostartmsg:
                ; Enable pulse mode to change values.
                CORE_ENABLE_PULSE_MODE

                ; did you win the game?
                car       mmCommonRoundTableOffsetCalculator
                ; IX

                ld        A, [IX + MMRESULT]
                cp        A, #MMRESULTWON
                jr        NZ, mmdefaultstatestateentryeventnotyetevenwon

                ; print you won the game
                ld        IY, #mmDefaultStateStateWonTheGameBannerMsg
                LCD_DISP_BANNER_MSG

                ; disbale start/split switch
                CORE_MASK_KEYS  (MMSWITCHMASK_STARTSPLIT)

                ret

mmdefaultstatestateentryeventnotyetevenwon:
                ; lost the game?
                ld      A, [IY + MMROUNDOFFSET]
                cp      A, #MMROUNDMAX
                jr      NZ, mmdefaultstatestateentryeventnotyetlost

                ; lost, so show it
                ld        A, [IY + MMBIGTABLEOFFSET + MMPOSITION1]
                ld        [mmdefaultstateredisplayshow + MMPOSITION1], A
                ld        A, [IY + MMBIGTABLEOFFSET + MMPOSITION2]
                ld        [mmdefaultstateredisplayshow + MMPOSITION2], A
                ld        A, [IY + MMBIGTABLEOFFSET + MMPOSITION3]
                ld        [mmdefaultstateredisplayshow + MMPOSITION3], A
                ld        A, [IY + MMBIGTABLEOFFSET + MMPOSITION4]
                ld        [mmdefaultstateredisplayshow + MMPOSITION4], A

                ; print you lost the game
                ld        IY, #mmDefaultStateStateLostGameBannerMsg
                LCD_DISP_BANNER_MSG

                ; disbale start/split switch
                CORE_MASK_KEYS  (MMSWITCHMASK_STARTSPLIT)

                ret

mmdefaultstatestateentryeventnotyetlost:
		car       mmDefaultStateRedisplay

                ret

mmDefaultStateStateWonTheGameBannerMsg:
                db        LCDBANNER_COL3, DM5_Y, DM5_O, DM5_U, DM5_SPACE, DM5_W, DM5_O, DM5_N
                db        LCDBANNER_COL4, DM5_T, DM5_H, DM5_E, DM5_SPACE, DM5_G, DM5_A, DM5_M, DM5_E
                db        LCD_END_BANNER

mmDefaultStateStateLostGameBannerMsg:
                db        LCDBANNER_COL3, DM5_Y, DM5_O, DM5_U, DM5_SPACE, DM5_L, DM5_O, DM5_S, DM5_T
                db        LCDBANNER_COL4, DM5_T, DM5_H, DM5_E, DM5_SPACE, DM5_G, DM5_A, DM5_M, DM5_E
                db        LCD_END_BANNER

mmDefaultStateModeDepressEvent:
                ;**************************************************************
                ;         MODE DEPRESS
                ;**************************************************************

                CORE_REQ_MODE_CHANGE_NEXT

                ret

mmDefaultStatePulledCrownEvent:
                ;**************************************************************
                ;         CROWN SET
                ;**************************************************************

                ld      B, #MMSETBANNERSTATE
                CORE_REQ_STATE_CHANGE

                ret

mmDefaultStateStartSplitDepressEvent:
                ;**************************************************************
                ;         START/SPLIT DEPRESS
                ;**************************************************************

                ld      B, #MMEDITSTATE
                CORE_REQ_STATE_CHANGE

                ret

mmDefaultStateCWPulseEvent:
                ;**************************************************************
                ;         CLOCKWISE CROWN ROTATION
                ;**************************************************************

                ld        A, [IY + MMCURRENTPOSITIONOFFSET]
                ld        B, [IY + MMROUNDOFFSET]
                cp        A, B
                jr        Z, mmdefaultstatecwpulsemaxposition

                inc       A

                jr        mmdefaultstatecwpulsesetcursorposition

mmdefaultstatecwpulsemaxposition:
                ld        A, #MMCURRENTPOSITIONMIN

mmdefaultstatecwpulsesetcursorposition:
                ld        [IY + MMCURRENTPOSITIONOFFSET], A

		car       mmDefaultStateRedisplay

                ret

mmDefaultStateCCWPulseEvent:
                ;**************************************************************
                ;         COUNTER CLOCKWISE CROWN ROTATION
                ;**************************************************************

                ld        A, [IY + MMCURRENTPOSITIONOFFSET]
                cp        A, #MMCURRENTPOSITIONMIN
                jr        Z, mmdefaultstateccwpulseminposition

                dec       A

                jr        mmdefaultstateccwpulsesetcursorposition

mmdefaultstateccwpulseminposition:
                ld        A, [IY + MMROUNDOFFSET]

mmdefaultstateccwpulsesetcursorposition:
                ld        [IY + MMCURRENTPOSITIONOFFSET], A

		car       mmDefaultStateRedisplay

                ret

mmDefaultStateStopResetDepressEvent:
                ;**************************************************************
                ;         STOP/RESET DEPRESS
                ;**************************************************************

                ; Enable switch release
                CORE_ENABLE_SWITCH_RELEASE

                ; Request 2sec timeout.
                CORE_REQ_TIMEOUT_HIRES MMHIRESTO_2SECONDS

                LCD_CLR_DISPLAY
                LCD_DISP_SMALL_DM_MSG_HOLD_TO_RESET

                ret

mmDefaultStateStopResetReleaseEvent:
                ;**************************************************************
                ;         STOP/RESET RELEASE
                ;**************************************************************

		car       mmDefaultStateRedisplay

                ret

mmDefaultStateTimeoutHiResDoneEvent:
                ;**************************************************************
                ;          TIMEOUT DONE HI-RES
                ;**************************************************************

                AUDSTART_SYSTEM_MELODY AUDSWBEEPMELODY, AUDNOMELODYDONEEVENT

                ; new game
                ; increase the game counter
                ld     A, [IY + MMGAMENUMBER]
                inc    A
                ld     [IY + MMGAMENUMBER], A

                ; Reset the game
                car       mmDefaultStateResetGame

                ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SUBROUTINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mmDefaultStateResetGame:
                ld     A, #MMROUNDINIT
                ld     [IY + MMROUNDOFFSET], A
                ;
                ld     A, #MMCURRENTPOSITIONINIT
                ld     [IY + MMCURRENTPOSITIONOFFSET], A
                ;
                ld     A, #MMCURSORPOSITIONINIT
                ld     [IY + MMCURSORPOSITIONOFFSET], A

                ; RND generation
                car       mmDefaultStateRandomGenerator
                ld        [IY + MMBIGTABLEOFFSET + MMPOSITION1], A
                ;
                car       mmDefaultStateRandomGenerator
                ld        [IY + MMBIGTABLEOFFSET + MMPOSITION2], A
                ;
                car       mmDefaultStateRandomGenerator
                ld        [IY + MMBIGTABLEOFFSET + MMPOSITION3], A
                ;
                car       mmDefaultStateRandomGenerator
                ld        [IY + MMBIGTABLEOFFSET + MMPOSITION4], A

                LCD_CLR_DISPLAY
                ;
		ld 	  IY, #mmdefaultstatesegmsg
		LCD_DISP_SEG_LINE_MSG
                ;
                ld        IY, #mmdefaultstatebannermsg
                LCD_DISP_BANNER_MSG

                CORE_ALLOW_ALL_KEYMASK
                ;
                CORE_MASK_KEYS  (MMSWITCHMASK_STOPRESET | MMSWITCHMASK_CW | MMSWITCHMASK_CCW)
                CORE_DISABLE_PULSE_MODE

                ret

mmdefaultstatesegmsg:
		db 	  SEG_P, SEG_R, SEG_E, SEG_S, SEG_S, SEG_SPACE

mmdefaultstatebannermsg:
                db        LCDBANNER_COL11, DM5_S, DM5_T, DM5_A, DM5_R, DM5_T
                db        LCDBANNER_COL19, DM5_DOWNARROW
                db        LCD_END_BANNER

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mmDefaultStateRandomGenerator:
		CORE_GENERATE_RANDOM_NUMBER
                ld	  H, #0
		ld	  L, A
		ld	  A, [IY + MMCHOICESOFFSET]
		div
                ld	  A, H
;		inc	  A
		add       A, #DM5_A

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mmDefaultStateRedisplay:
                ld        A, [IY + MMROUNDOFFSET]
                add       A, #SEG_0
                ld        [mmdefaultstateredisplayroundseg], A

                ld        A, [IY + MMCURRENTPOSITIONOFFSET]
                add       A, #DM5_0
                ld        [mmdefaultstateredisplayposition], A

                ld        IX, IY
                add       IX, #MMBIGTABLEOFFSET

                ; BA = [IY + MMCURRENTPOSITIONOFFSET] * 5
                ld        B, #0
                ld        A, [IY + MMCURRENTPOSITIONOFFSET]
                sll       A
                sll       A
                add       A, [IY + MMCURRENTPOSITIONOFFSET]

                add       IX, BA
                ; IX

                ld        A, [IX + MMPOSITION1]
                ld        [mmdefaultstateredisplaypositions + MMPOSITION1], A
                ld        A, [IX + MMPOSITION2]
                ld        [mmdefaultstateredisplaypositions + MMPOSITION2], A
                ld        A, [IX + MMPOSITION3]
                ld        [mmdefaultstateredisplaypositions + MMPOSITION3], A
                ld        A, [IX + MMPOSITION4]
                ld        [mmdefaultstateredisplaypositions + MMPOSITION4], A

                LCD_CLR_DISPLAY
                ;
                ld	  L, [IX + MMRESULT]
		UTL_CONVERT_HEX_TO_2DIGIT_BCD
		ld	  IX, #LCDUPPERDMCOL1
		LCD_DISP_SMALL_FIXED_WIDTH_2DIG_DM_DATA_NO_ZERO_SUP
                ;
                ld        A, [IY + MMROUNDOFFSET]
                ld        IY, #mmdefaultstateredisplayline1
                cp        A, #MMROUNDMAX
                jr        NZ, mmdefaultstateredisplayhideit

                ld        IY, #mmdefaultstateredisplayline1b

mmdefaultstateredisplayhideit:
                LCD_DISP_FORMATTED_SMALL_FIXED_WIDTH_DM_MSG
                ;
                ld 	  IY, #mmdefaultstateredisplayseg
		LCD_DISP_SEG_LINE_MSG
                ;
                ld        IY, #mmdefaultstateredisplayline2
                LCD_DISP_FORMATTED_SMALL_FIXED_WIDTH_DM_MSG

                ret

mmdefaultstateredisplayseg:
		db 	SEG_T, SEG_R, SEG_Y, SEG_COLON, SEG_SPACE
mmdefaultstateredisplayroundseg:
                db      SEG_0

mmdefaultstateredisplayline1:
                dw        LCDMAINDMLINE1COL13
                db        4
mmdefaultstateredisplayasterisk:
                db        DM5_ASTERISK, DM5_ASTERISK, DM5_ASTERISK, DM5_ASTERISK

mmdefaultstateredisplayline1b:
                dw        LCDMAINDMLINE1COL13
                db        4
mmdefaultstateredisplayshow:
                db        DM5_0, DM5_1, DM5_2, DM5_3

mmdefaultstateredisplayline2:
                dw        LCDMAINDMLINE2COL1
                db        7
mmdefaultstateredisplayposition:
                db        DM5_0, DM5_RIGHTARROW
mmdefaultstateredisplaypositions:
                db        DM5_A, DM5_B, DM5_C, DM5_D, DM5_LEFTARROW

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
