;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name :   mm.h
; Purpose   :   MasterMind mode application header
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;==============================================================================
;
; STATE REDEFINITIONS
;
;==============================================================================
MMBANNERSTATE              equ     COREBANNERSTATE
MMDEFAULTSTATE             equ     COREDEFAULTSTATE
MMSETBANNERSTATE           equ     CORESETBANNERSTATE
MMYOUROCKSETSTATE          equ     CORESETBANNERSTATE
MMSETSTATE                 equ     CORESETSTATE
MMPOPUPSTATE               equ     COREPOPUPSTATE
MMEDITSTATE                equ     COREPOPUPSTATE
MMPASSWORDDEFAULTSTATE     equ     COREPASSWORDDEFAULTSTATE
MMPASSWORDSETBANNERSTATE   equ     COREPASSWORDSETBANNERSTATE
MMPASSWORDSETSTATE         equ     COREPASSWORDSETSTATE

; TODO: Add your own state redefinition here

;==============================================================================
;
; EVENT REDEFINITIONS
;
;==============================================================================
MM_STATEENTRY              equ     COREEVENT_STATEENTRY
MM_CROWNHOME               equ     COREEVENT_CROWN_HOME
MM_CROWNSET                equ     COREEVENT_CROWN_SET1
MM_CWPULSES                equ     COREEVENT_CW_PULSES
MM_CCWPULSES               equ     COREEVENT_CCW_PULSES
MM_MODEDEPRESS             equ     COREEVENT_SWITCH1DEPRESS
MM_STOPRESETDEPRESS        equ     COREEVENT_SWITCH2DEPRESS
MM_STOPRESETRELEASE        equ     COREEVENT_SWITCH2RELEASE
MM_STARTSPLITDEPRESS       equ     COREEVENT_SWITCH3DEPRESS


MM_TIMEOUTDONELOWRES       equ     COREEVENT_TIMEOUTDONE_LOWRES
MM_TIMEOUTDONEHIGHRES      equ     COREEVENT_TIMEOUTDONE_HIGHRES
MM_TIMEOUTDONESTICKY       equ     COREEVENT_STICKY_TIMEOUTDONE

;==============================================================================
;
; SWITCH MASK REDEFINITIONS
;
;==============================================================================
MMSWITCHMASK_MODE          equ     bCORESwitch1
MMSWITCHMASK_STOPRESET     equ     bCORESwitch2
MMSWITCHMASK_STARTSPLIT    equ     bCORESwitch3
MMSWITCHMASK_CW            equ     bCORECWSwitch
MMSWITCHMASK_CCW           equ     bCORECCWSwitch
MMSWITCHMASK_EL            equ     bCOREELSwitch

;==============================================================================
;
; HIGH RESOLUTION TIMEOUT DEFINITIONS (Based on 8Hz)
;
;==============================================================================

MMHIRESTO_1P5SECONDS       equ     TIMEOUTHIRES_1P5SEC
MMHIRESTO_2SECONDS         equ     TIMEOUTHIRES_2SEC

; TODO: Add your own state redefinition here

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

