;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name     : mmbckhd.asm
; Purpose       : Handles the following application specific functions:
;                   - application initialization
;                   - resource refresh
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;DO NOT MODIFY THE FOLLOWING SUBROUTINE DEFINITION;;;;;;;;;;;;;;;;;

                IF @DEF('SUBROUTINE')
                    UNDEF SUBROUTINE
                ENDIF
                DEFINE  SUBROUTINE      "'mmbckhd'"
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

                GLOBAL  mmBackgroundHandler

mmBackgroundHandler:
                ld      IY, [COREInitializationASDAddress]

                ; Load the event to be process to AReg.
                ld      A, [COREBackgroundEvent]

                ; Check if INIT event.
                cp      A, #COREEVENT_INIT
                jr      NZ, mmBackgroundProcessExit

mmBackgroundInitEvent:
                ;TODO: Initialize your variables here

                ld     A, #MMCHOICESINIT
                ld     [IY + MMCHOICESOFFSET], A
                ;
                ld     A, #MMROUNDINIT
                ld     [IY + MMROUNDOFFSET], A

                ; extras
                ld     A, #1
                ld     [IY + MMGAMENUMBER], A

                ld     A, #0
                ld     [IY + MMWGAMENUMBER], A

mmBackgroundProcessExit:
                ret

