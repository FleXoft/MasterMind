;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name     : mmedit.asm
; Purpose       : Handles the following application specific functions:
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;DO NOT MODIFY THE FOLLOWING SUBROUTINE DEFINITION;;;;;;;;;;;;;;;;;

                IF @DEF('SUBROUTINE')
                    UNDEF SUBROUTINE
                ENDIF
                DEFINE  SUBROUTINE      "'mmedit'"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Module Name : mmBackgroundHandler
; Description : Handles application initialization and refresh resource handlers.
; Assumptions : COREInitializationASDAddress is already set by kernel.
;               COREInitializationADDAddress is already set by kernel.
; Input(s)    : None
; Output(s)   : None
;               ( Destroyed: All registers )
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                GLOBAL  mmEditStateManager

mmEditStateManager:
                ; Set IYReg the address of the MasterMind ASD.
                ld      IY, [CORECurrentASDAddress]

                ; Load the event to be process to AReg.
                ld      A, [CORECurrentEvent]

                ; Check if state entry event.
                cp      A, #MM_STATEENTRY
                jr      Z, mmEditStateStateEntryEvent

                ; Check if mode depress event.
                cp      A, #MM_MODEDEPRESS
                jr      Z, mmEditStateModeDepressEvent

                ; Check if crown set event.
                cp      A, #MM_CROWNSET
                jr      Z, mmEditStatePulledCrownEvent

                ; Check if start/split depress event.
                cp      A, #MM_STARTSPLITDEPRESS
                jr      Z, mmEditStateStartSplitDepressEvent

                cp      A, #MM_CWPULSES
                jr      Z, mmEditStateCWPulseEvent

                cp      A, #MM_CCWPULSES
                jr      Z, mmEditStateCCWPulseEvent

                ; Check if stop/reset depress event.
                cp      A, #MM_STOPRESETDEPRESS
                jr      Z, mmEditStateStopResetDepressEvent

                ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EVENT HANDLERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mmEditStateStateEntryEvent:
                ;**************************************************************
                ;         STATE ENTRY
                ;**************************************************************

                ; reset the cursor position
                ld        A, #MMCURSORPOSITIONINIT
                ld        [IY + MMCURSORPOSITIONOFFSET], A

                ; next round
                ld        A, [IY + MMROUNDOFFSET]
                inc       A
                ld        [IY + MMROUNDOFFSET], A

                car       mmCommonRoundTableOffsetCalculator
                ; IX

                ld        A, [IY + MMROUNDOFFSET]
                cp        A, #MMROUNDFIRST
                jr        NZ, mmeditstatestateentryeventnotfirst

                ; reset the table
                ld        A, #DM5_A
                ld        [IX + MMPOSITION1], A
                ld        [IX + MMPOSITION2], A
                ld        [IX + MMPOSITION3], A
                ld        [IX + MMPOSITION4], A
;                ld        [IX + 4], A               ; #Result

                 jr        mmeditstatestateentryeventcontinue

mmeditstatestateentryeventnotfirst:
                ld        A, [IX - 5]
                ld        [IX + MMPOSITION1], A
                ld        A, [IX - 4]
                ld        [IX + MMPOSITION2], A
                ld        A, [IX - 3]
                ld        [IX + MMPOSITION3], A
                ld        A, [IX - 2]
                ld        [IX + MMPOSITION4], A

mmeditstatestateentryeventcontinue:
		car       mmEditStateRedisplay

                ; Enable pulse mode to change values.
                CORE_ENABLE_PULSE_MODE

                ret

mmEditStateModeDepressEvent:
                ;**************************************************************
                ;         MODE DEPRESS
                ;**************************************************************

                ; check the result before you leave
                car     mmEditStateCheckResult

                CORE_REQ_MODE_CHANGE_NEXT

                ret

mmEditStatePulledCrownEvent:
                ;**************************************************************
                ;         CROWN SET
                ;**************************************************************

                ; check the result before you leave
                car     mmEditStateCheckResult

                ld      B, #MMSETBANNERSTATE
                CORE_REQ_STATE_CHANGE

                ret

mmEditStateStartSplitDepressEvent:
                ;**************************************************************
                ;         START/SPLIT DEPRESS
                ;**************************************************************

                ld        A, [IY + MMCURSORPOSITIONOFFSET]
                cp        A, #MMCURSORPOSITIONMAX
                jr        Z, mmeditstatestartsplitdepressmaxcursorposition

                inc       A

                jr        mmeditstatestartsplitdepresssetcursorposition

mmeditstatestartsplitdepressmaxcursorposition:
                ld        A, #MMCURSORPOSITIONMIN

mmeditstatestartsplitdepresssetcursorposition:
                ld        [IY + MMCURSORPOSITIONOFFSET], A

		car       mmEditStateRedisplay

                ret

mmEditStateCWPulseEvent:
                ;**************************************************************
                ;         CLOCKWISE CROWN ROTATION
                ;**************************************************************

                car       mmCommonRoundTableOffsetCalculator
                ; IX
                ld        A, [IY + MMCURSORPOSITIONOFFSET]
                ld        B, #0
                add       IX, BA

                ld        A, [IY + MMCHOICESOFFSET]
                add       A, #DM5_A - 1
                ld        B, A

                ld        A, [IX]

                cp        A, B
                jr        Z, mmeditstatecwpulsemax

                inc       A
                ;
                ld        [IX], A

		car       mmEditStateRedisplay

mmeditstatecwpulsemax:
                ret

mmEditStateCCWPulseEvent:
                ;**************************************************************
                ;         COUNTER CLOCKWISE CROWN ROTATION
                ;**************************************************************

                car       mmCommonRoundTableOffsetCalculator
                ; IX
                ld        A, [IY + MMCURSORPOSITIONOFFSET]
                ld        B, #0
                add       IX, BA

                ld        A, [IX]

                ld        B, #DM5_A

                cp        A, B
                jr        Z, mmeditstateccwpulsemin

                dec       A
                ld        [IX], A

		car       mmEditStateRedisplay

mmeditstateccwpulsemin:
                ret

mmEditStateStopResetDepressEvent:
                ;**************************************************************
                ;         STOP/RESET DEPRESS
                ;**************************************************************

                ; jump to the current row to show
                ld        A, [IY + MMROUNDOFFSET]
                ld        [IY + MMCURRENTPOSITIONOFFSET], A

                ; check the result
                car       mmEditStateCheckResult

                ; and go back
                ld      B, #MMDEFAULTSTATE
                CORE_REQ_STATE_CHANGE

                ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SUBROUTINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mmEditStateRedisplay:
; debug
;                push iy
;                add       IY, #MMBIGTABLEOFFSET
;                ld        A, [IY+0]
;                ld        [mmdeb+0], A
;                ld        A, [IY+1]
;                ld        [mmdeb+1], A
;                ld        A, [IY+2]
;                ld        [mmdeb+2], A
;                ld        A, [IY+3]
;                ld        [mmdeb+3], A
;                pop iy

                car       mmCommonRoundTableOffsetCalculator
                ; IX

                ; round
                ld        A, [IY + MMROUNDOFFSET]
                add       A, #SEG_0
                ld        [mmeditstateredisplayroundseg], A

                ;
                ld        A, [IX + MMPOSITION1]
                ld        [mmeditstateredisplayposotions + MMPOSITION1], A
                ld        A, [IX + MMPOSITION2]
                ld        [mmeditstateredisplayposotions + MMPOSITION2], A
                ld        A, [IX + MMPOSITION3]
                ld        [mmeditstateredisplayposotions + MMPOSITION3], A
                ld        A, [IX + MMPOSITION4]
                ld        [mmeditstateredisplayposotions + MMPOSITION4], A

                LCD_CLR_DISPLAY
                ;
                ld 	  IY, #mmeditstateredisplayseg
		LCD_DISP_SEG_LINE_MSG
                ;
                ld        IY, #mmeditstateredisplayline1
                LCD_DISP_FORMATTED_SMALL_FIXED_WIDTH_DM_MSG
                ;
                ld        IY, #mmeditstateredisplayline2
                LCD_DISP_FORMATTED_SMALL_FIXED_WIDTH_DM_MSG

                LCD_WRITE_4HZ_GEN_BLINK_DISP_ROUTINE_ADDR   mmEditStateBlinkDisplay
                LCD_WRITE_4HZ_GEN_BLINK_CLR_ROUTINE_ADDR    mmEditStateBlinkClear
                ;
                CORE_REQ_BLINK_4HZ

                ret

mmeditstateredisplayseg:
		db 	SEG_T, SEG_R, SEG_Y, SEG_COLON, SEG_SPACE
mmeditstateredisplayroundseg:
                db      SEG_0

mmeditstateredisplayline1:
                dw        LCDMAINDMLINE1COL13
                db        4
mmdeb:
                db        DM5_ASTERISK, DM5_ASTERISK, DM5_ASTERISK, DM5_ASTERISK

mmeditstateredisplayline2:
                dw        LCDMAINDMLINE2COL1
                db        7
                db        DM5_SPACE, DM5_RIGHTARROW
mmeditstateredisplayposotions:
                db        DM5_A, DM5_B, DM5_C, DM5_D, DM5_LEFTARROW

mmEditStateBlinkDisplay:
                ld       IY, [CORECurrentASDAddress]

                car      mmCommonRoundTableOffsetCalculator
                ; IX
                ld        A, [IY + MMCURSORPOSITIONOFFSET]
                ld        B, #0
                add       IX, BA

                ld        L, [IX]

                jr        mmEditStateBlinkCommon

mmEditStateBlinkClear:
                ld       IY, [CORECurrentASDAddress]

                ld        A, [IY + MMCURSORPOSITIONOFFSET]

                ld        L, #DM5_SPACE

mmEditStateBlinkCommon:
                ld        B, A
                sll       A
                sll       A
                add       A, B
                add       A, B
                ld        B, #0

                ld        IX, #LCDMAINDMLINE2COL13
                add       IX, BA
                LCD_DISP_SMALL_FIXED_WIDTH_DM_CHAR

                ret

mmEditStateCheckResult:
                ; check the result and set the result field

                ; move the hidden (#0) line to tmp buffer
                ld        HL, #MMEDITTMPBUFFER
                ld        [HL], [IY + MMBIGTABLEOFFSET + MMPOSITION1]
                ;
                inc       HL
                ld        [HL], [IY + MMBIGTABLEOFFSET + MMPOSITION2]
                ;
                inc       HL
                ld        [HL], [IY + MMBIGTABLEOFFSET + MMPOSITION3]
                ;
                inc       HL
                ld        [HL], [IY + MMBIGTABLEOFFSET + MMPOSITION4]

                ld        HL, #MMEDITTMPBUFFER
                ;
                car       mmCommonRoundTableOffsetCalculator
                ; IX
                ;
                ld        B, #0

                ; check the place
                push      HL
                push      IX

                ld        A, #3

mmeditstatecheckresultplaceloop:
                cp        [HL], [IX]
                jr        NZ, mmeditstatecheckresultnotinplace

                inc       B

mmeditstatecheckresultnotinplace:
                dec      A
                cp       A, #0
                jr       LT, mmeditstatecheckresultplaceexit

                inc      HL
                inc      IX
                jr       mmeditstatecheckresultplaceloop

mmeditstatecheckresultplaceexit:
                pop       IX
                pop       HL

                cp        B, #4
                jr        NZ, mmeditstatecheckresultnotyetwon
                
                ; increase the won game counter
                ld     A, [IY + MMWGAMENUMBER]
                inc    A
                ld     [IY + MMWGAMENUMBER], A

mmeditstatecheckresultnotyetwon:
                ; Prepare the result itself
                ; B = B * 10
                sll       B
                ld        A, B
                sll       B
                sll       B
                add       A, B
                ld        B, A

                ; check the "color"

                ; save HL for backup
                ld        IY, HL

                car       mmEditStateColorChecker
                ;
                inc       IX
                car       mmEditStateColorChecker
                ;
                inc       IX
                car       mmEditStateColorChecker
                ;
                inc       IX
                car       mmEditStateColorChecker

                ; store result
                inc       IX
                ld        [IX], B

                ret

MMEDITTMPBUFFER:
                db        0, 0, 0, 0

mmEditStateColorChecker:
                ; restore HL first
                ld        HL, IY
                ld        A, #3

mmeditstatecolorloop:
                cp        [HL], [IX]
                jr        NZ, mmeditstatecolornotthesame

                inc       B

                ld        [HL], #DM5_SPACE              ; erase pattern in the tmpbuffer
                ret                                     ; and 'ret' right now >>>>>>>>>>>>>

mmeditstatecolornotthesame:
                dec      A
                cp       A, #0
                jr       LT, mmeditstatecolorexit

                inc      HL
                jr       mmeditstatecolorloop

mmeditstatecolorexit:
                ret

