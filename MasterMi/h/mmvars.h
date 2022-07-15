;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name :   mmvars.h
; Purpose   :   MasterMind Application Variable Offsets
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;==============================================================================
;
; MasterMind APPLICATION SYSTEM DATA
; ASD area
;
;==============================================================================

MMSYSTEMDATASTARTOFFSET        equ        0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Do not change this variable but change the value if necessary.
; The equate value of this, is the last number from the above variables plus 1
; When you add variables above, be sure to change the value of this too.

MMCHOICESOFFSET		       equ	0
        MMCHOICESINIT          equ      4
        MMCHOICESMIN	       equ	4
        MMCHOICESMAX	       equ	8
                               ; 0

MMROUNDOFFSET		       equ	1
        MMROUNDINIT            equ      0
        MMROUNDFIRST           equ      1
        MMROUNDMAX             equ      9
        MMROUNDYOUWON          equ      99
                               ; 1

MMCURRENTPOSITIONOFFSET	       equ	2
        MMCURRENTPOSITIONINIT  equ      1
        MMCURRENTPOSITIONMIN   equ      1
        MMCURRENTPOSITIONMAX   equ      MMROUNDMAX
                               ; 2

MMCURSORPOSITIONOFFSET         equ      3
        MMCURSORPOSITIONINIT   equ      0
        MMCURSORPOSITIONMIN    equ      0
        MMCURSORPOSITIONMAX    equ      3
                               ; 3

MMBIGTABLEOFFSET	       equ	4
			       ; + 10 * 5bytes
        MMPOSITION1            equ      0
        MMPOSITION2            equ      1
        MMPOSITION3            equ      2
        MMPOSITION4            equ      3
        MMRESULT               equ      4
                MMRESULTWON    equ      44
                               ; 54

MMTMPTABLEOFFSET               equ      55
                               ; + 4bytes
                               ; 59

MMGAMENUMBER                   equ      60
MMWGAMENUMBER                  equ      61

MMSYSTEMDATASIZE               equ      62
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;==============================================================================
;
; MasterMind COMMON VARIABLE REDEFINITIONS
;
;==============================================================================

; TODO: Put here your variables to be use on foreground operation

; The common foreground variables is referenced using the label COREForegroundCommonBuffer.
; If the application does not use the 101 byte scroll buffer, it can make use of that space
; as a common foreground buffer.
; Is this true?

MMTMP                          equ     (COREForegroundCommonBuffer + 0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; TODO: Put here your variables to be use on background operation

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

