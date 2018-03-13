
; Quark Forth
; started at Jul 2006
; current version 1.0

BUILD_VERSION = 31

MAJOR_VERSION = 1
MINOR_VERSION = 0
SUBVERSION = 10

FORMAT equ 'dll'
;FORMAT equ 'exe'

if FORMAT = 'dll'
  format PE GUI 4.0 DLL
  entry DllEntryPoint
end if;

if FORMAT = 'exe'
  format PE GUI 4.0
  entry start
end if;

; build 31 (06.08.12)
; ====================================
; sprite support
; SPRITE24 SPRITE24R SPRITE24T SPRITE24RT
;
; [I]@ [I]! [I]F@ [I]F!


; build 30 (28.09.11)
; ====================================
; CREATE-WORD LINE.F"
; two delimiters - 0x20, 0x09

; build 29 (01.01.11)
; ====================================
; Windows 7 compatibility

; build 28: (31.08.10)
; ====================================
; CMOVE< MOVE< S= >= <= <> TYPE CCOMPARE COMPARE ." TRUE FALSE

; build 27: (26.08.10)
; ====================================
; CTRL & ALT modifiers for keyboard accelerators

; build 26:
; ====================================
; K_BACKSPACE K_ENTER DEBUGIP

; build 25:
; ====================================
; WINMSG PROCESSED WMSG WPARAM LPARAM SMARTSTRING
; smart strings

; 19-Mar-2010
; SGN corrected

; build 24: 14-Feb-2010
; ====================================
; New: FILESIZE FLG SGN D:X*X ALIGN16 K_CHAR kb Mb RND RANDOMIZE RANDOM SQR SQRT CELL+ CELL- FCELL+ FCELL- << >> K_DEL K_INSERT MOUSE_LBUTTONDBLCLK
;
; Corrected: FLN FLOG2 FLG - argument 1.0 no longer cause additional number drop



include 'C:\Fasm\include\win32a.inc'

include 'opengl.inc'

IDM_EXIT	   = 101
ID_MESSAGE	   = 102
ID_ICONERROR	   = 201
ID_ICONINFORMATION = 202
ID_ICONQUESTION    = 203
ID_ICONWARNING	   = 204
ID_TOPMOST	   = 301

section '.data' data readable writeable

  _title	    db 'Quark Forth',0
  _class	    db 'FASMOPENGL32',0
  _about_title	    db 'About Forth',0
  _about_text	    db 'This is Win32 Quark Forth',0

  hinstance	    dd ?
  hwnd		    dd ?
  hdc		    dd ?
  hrc		    dd ?

  wherex	    dd 0
  wherey	    dd 0

  bgcolor	    dd 0x00000000
  fgcolor	    dd 0x0000FF00

  msg		    MSG
  wc		    WNDCLASS
  rc		    RECT
  ps		    PAINTSTRUCT
  pfd		    PIXELFORMATDESCRIPTOR

  active	    dd ?

  padptr	    dd	  ?

  x		    dd	100
  y		    dd	100
  maxx		    dd	1023
  opaque	    dd	0

  xsize 	    dd	1024
  ysize 	    dd	768

  ViewPort	    dd	0, 2047, 0, 2047
  x0y0		    dd	0, 0

  CodeStart	    dd	  0
  DataStart	    dd	  0

  mousex	    dd	  0
  mousey	    dd	  0
  mousez	    dd	  0

  span		    dd	  0
  TibPtr	    dd	  0
  Depth 	    dd	  0
  lastkey	    dd	  0
  lastimm	    dd	  0
  lastvoc	    dd	  0
  lastsmudge	    dd	  0
  lastnumerical     dd	  0
  lastvar	    dd	  0
  lastflags	    dd	  0
  lastnumber	    dd	  0
  lastfloat	    dd	  0
  ErrSym	    dd	  0

  limit 	    dd	   268435456
  climit	    dd	   1048576

  ddp		    dd	  0
  cdp		    dd	  0
  state 	    dd	  0
  base		    dd	 10
  delimiter	    db	 32
  delimiter2	    db	  9
  ConsoleX	    dd	  0
  ConsoleY	    dd	  0
  ConsoleL	    dd	128
  draw2d	    dd	  1

  ForthLatest	    dd	  0    ; entry point to FORTH vocabulary: address of latest LFA
  CurrentWord	    dd	  0    ; address of LFA currently checked for FIND
  Context	    dd	  0
  Current	    dd	  0
  FoundLFA	    dd	  0    ; LFA of latest found word

  Number	    dd	  0
  NumberSign	    dd	  0
  FNumberMant	    dq	  0
  FNumberExp	    dd	  0
  FNumberExpSign    dd	  0
  FNumberPoint	    dd	  0
  FDigitsPassed     dd	  0
  NumError	    dd	  0
  NumberBuf	    dd	  0
  CanDispatch	    dd	  0
  EmTrailingSpace   dd	  1
  IsDebug	    dd	  0
  DebugIP	    dd	  0
  smartString	    dd	  1
  MsgProcessed	    dd	  0
  WMsg		    dd	  0
  WParam	    dd	  0
  LParam	    dd	  0

  Zpixel	    dd	  0
  IDpixel	    dd	  0
  object_z	    dd	  0
  object_id	    dd	  0


  timer_interval    dd	  1000
  old_ticks	    dd	  0
  fps		    dd	  0
  old_fps	    dd	  0
  loady 	    dd	  0
  rnd		    dd	  0

  errormsgpos	    dd	  0
  errormsgx	    dd	  0
  errormsgy	    dd	 16

  MAXTOOLBUTTONS    equ   10

  ToolButtons	    dd	  0
  ToolButtonsFixed  dd	  0
  ToolButtonsLimited  dd  0
  ToolButtonsSize   dd	  75
  ToolButtonsLimit  dd	  100

  NumberOfBytesRead dd	  0   ; for ReadFile
  LineLength	    dd	  0
  IOLastError	    dd	  0
  hSource	    dd	  0
  LineNumber	    dd	  0   ; number of line to load

  MAXLOADING	    equ  64
  sDepth	    dd	  0	; source context stack depth
  cfDepth	    dd	  0	; control flow stack depth
  lDepth	    dd	  0	; loop stack depth
  caseDepth	    dd	  0	; case selector stack depth
  localDepth	    dd	  0	; local stack depth
  frameDepth	    dd	  0	; stack frames depth
  addrDepth	    dd	  0	; addresses stack depth

  MAXCF 	    equ  1024
  MAXLOOP	    equ   256
  MAXSELECTORS	    equ   256
  MAXLOCALS	    equ  1024
  MAXFRAMES	    equ   256
  MAXADDR	    equ   256


nameTimer	    db '<TIMER>', 0

MsgOK		    db 'Ok ', 0
MsgNotFound	    db 'Not found (Не найдено)', 0
MsgOpenError	    db 'File opening error (Ошибка открытия файла)', 0
MsgReadError	    db 'File reading error (Ошибка чтения файла)', 0
MsgWriteError	    db 'File writing error (Ошибка записи файла)', 0
MsgCompileOnly	    db 'For compile mode only (Только для режима компиляции)', 0
MsgTHEN 	    db 'THEN without IF (THEN без IF)', 0
MsgELSE 	    db 'ELSE without IF (ELSE без IF)', 0
MsgLOOP 	    db 'LOOP without DO (LOOP без DO)', 0
MsgPlusLOOP	    db '+LOOP without DO (+LOOP без DO)', 0
MsgI		    db 'Not enough loop levels for access to I (Нет цикла, чтобы взять счетчик I)', 0
MsgJ		    db 'Not enough loop levels for access to J (Недостаточно вложенности циклов, чтобы взять счетчик J)', 0
MsgK		    db 'Not enough loop levels for access to K (Недостаточно вложенности циклов, чтобы взять счетчик K)', 0
MsgAGAIN	    db 'AGAIN without BEGIN (AGAIN без BEGIN)', 0
MsgUNTIL	    db 'UNTIL without BEGIN (UNTIL без BEGIN)', 0
MsgWHILE	    db 'WHILE without BEGIN (WHILE без BEGIN)', 0
MsgREPEAT	    db 'REPEAT without WHILE (REPEAT без WHILE)', 0
MsgREPEAT2	    db 'REPEAT without BEGIN (REPEAT без BEGIN)', 0
MsgOF		    db 'OF without CASE (OF без CASE)', 0
MsgENDOF	    db 'ENDOF without OF (ENDOF без OF)', 0
MsgBREAK	    db 'BREAK without OF (BREAK без OF)', 0
MsgENDCASE	    db 'ENDCASE without CASE (ENDCASE без CASE)', 0
MsgSSEUnaligned     db 'Unaligned address for SSE command (Команда из набора SSE вызвана с невыровненными адресами)', 0

symbols db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,126,129,165,129,129,189,153,129,129,126,0,0,0,0		     ; 0
db 0,0,126,255,219,255,255,195,231,255,255,126,0,0,0,0,0,0,0,0,108,254,254,254,254,124,56,16,0,0,0,0
db 0,0,0,0,16,56,124,254,124,56,16,0,0,0,0,0,0,0,0,24,60,60,231,231,231,24,24,60,0,0,0,0
db 0,0,0,24,60,126,255,255,126,24,24,60,0,0,0,0,0,0,0,0,0,0,24,60,60,24,0,0,0,0,0,0
db 255,255,255,255,255,255,231,195,195,231,255,255,255,255,255,255,0,0,0,0,0,60,102,66,66,102,60,0,0,0,0,0
db 255,255,255,255,255,195,153,189,189,153,195,255,255,255,255,255,0,0,30,14,26,50,120,204,204,204,204,120,0,0,0,0
db 0,0,60,102,102,102,102,60,24,126,24,24,0,0,0,0,0,0,63,51,63,48,48,48,48,112,240,224,0,0,0,0
db 0,0,127,99,127,99,99,99,99,103,231,230,192,0,0,0,0,0,0,24,24,219,60,231,60,219,24,24,0,0,0,0

db 0,128,192,224,240,248,252,248,240,224,192,128,0,0,0,0,0,2,6,14,30,62,126,62,30,14,6,2,0,0,0,0	     ; 1
db 0,0,24,60,126,24,24,24,126,60,24,0,0,0,0,0,0,0,102,102,102,102,102,102,102,0,102,102,0,0,0,0
db 0,0,127,219,219,219,123,27,27,27,27,27,0,0,0,0,0,124,198,96,56,108,198,198,108,56,12,198,124,0,0,0
db 0,0,0,0,0,0,0,0,254,254,254,254,0,0,0,0,0,0,24,60,126,24,24,24,126,60,24,126,0,0,0,0
db 0,0,24,60,126,24,24,24,24,24,24,24,0,0,0,0,0,0,24,24,24,24,24,24,24,126,60,24,0,0,0,0
db 0,0,0,0,0,24,12,254,12,24,0,0,0,0,0,0,0,0,0,0,0,48,96,254,96,48,0,0,0,0,0,0
db 0,0,0,0,0,0,192,192,192,254,0,0,0,0,0,0,0,0,0,0,0,40,108,254,108,40,0,0,0,0,0,0
db 0,0,0,0,16,56,56,124,124,254,254,0,0,0,0,0,0,0,0,0,254,254,124,124,56,56,16,0,0,0,0,0

db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,24,60,60,60,24,24,24,0,24,24,0,0,0,0				      ; 2
db 0,102,102,102,36,0,0,0,0,0,0,0,0,0,0,0,0,0,0,108,108,254,108,108,108,254,108,108,0,0,0,0
db 24,24,124,198,194,192,124,6,6,134,198,124,24,24,0,0,0,0,0,0,194,198,12,24,48,96,198,134,0,0,0,0
db 0,0,56,108,108,56,118,220,204,204,204,118,0,0,0,0,0,48,48,48,96,0,0,0,0,0,0,0,0,0,0,0
db 0,0,12,24,48,48,48,48,48,48,24,12,0,0,0,0,0,0,48,24,12,12,12,12,12,12,24,48,0,0,0,0
db 0,0,0,0,0,102,60,255,60,102,0,0,0,0,0,0,0,0,0,0,0,24,24,126,24,24,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,24,24,24,48,0,0,0,0,0,0,0,0,0,0,254,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,24,24,0,0,0,0,0,0,0,0,2,6,12,24,48,96,192,128,0,0,0,0

db 0,0,56,108,198,198,214,214,198,198,108,56,0,0,0,0,0,0,24,56,120,24,24,24,24,24,24,126,0,0,0,0	      ; 3
db 0,0,124,198,6,12,24,48,96,192,198,254,0,0,0,0,0,0,124,198,6,6,60,6,6,6,198,124,0,0,0,0
db 0,0,12,28,60,108,204,254,12,12,12,30,0,0,0,0,0,0,254,192,192,192,252,6,6,6,198,124,0,0,0,0
db 0,0,56,96,192,192,252,198,198,198,198,124,0,0,0,0,0,0,254,198,6,6,12,24,48,48,48,48,0,0,0,0
db 0,0,124,198,198,198,124,198,198,198,198,124,0,0,0,0,0,0,124,198,198,198,126,6,6,6,12,120,0,0,0,0
db 0,0,0,0,24,24,0,0,0,24,24,0,0,0,0,0,0,0,0,0,24,24,0,0,0,24,24,48,0,0,0,0
db 0,0,0,6,12,24,48,96,48,24,12,6,0,0,0,0,0,0,0,0,0,126,0,0,126,0,0,0,0,0,0,0
db 0,0,0,96,48,24,12,6,12,24,48,96,0,0,0,0,0,0,124,198,198,12,24,24,24,0,24,24,0,0,0,0

db 0,0,0,124,198,198,222,222,222,220,192,124,0,0,0,0,0,0,16,56,108,198,198,254,198,198,198,198,0,0,0,0	       ; 4
db 0,0,252,102,102,102,124,102,102,102,102,252,0,0,0,0,0,0,60,102,194,192,192,192,192,194,102,60,0,0,0,0
db 0,0,248,108,102,102,102,102,102,102,108,248,0,0,0,0,0,0,254,102,98,104,120,104,96,98,102,254,0,0,0,0
db 0,0,254,102,98,104,120,104,96,96,96,240,0,0,0,0,0,0,60,102,194,192,192,222,198,198,102,58,0,0,0,0
db 0,0,198,198,198,198,254,198,198,198,198,198,0,0,0,0,0,0,60,24,24,24,24,24,24,24,24,60,0,0,0,0
db 0,0,30,12,12,12,12,12,204,204,204,120,0,0,0,0,0,0,230,102,102,108,120,120,108,102,102,230,0,0,0,0
db 0,0,240,96,96,96,96,96,96,98,102,254,0,0,0,0,0,0,198,238,254,254,214,198,198,198,198,198,0,0,0,0
db 0,0,198,230,246,254,222,206,198,198,198,198,0,0,0,0,0,0,124,198,198,198,198,198,198,198,198,124,0,0,0,0

db 0,0,252,102,102,102,124,96,96,96,96,240,0,0,0,0,0,0,124,198,198,198,198,198,198,214,222,124,12,14,0,0	; 5
db 0,0,252,102,102,102,124,108,102,102,102,230,0,0,0,0,0,0,124,198,198,96,56,12,6,198,198,124,0,0,0,0
db 0,0,126,126,90,24,24,24,24,24,24,60,0,0,0,0,0,0,198,198,198,198,198,198,198,198,198,124,0,0,0,0
db 0,0,198,198,198,198,198,198,198,108,56,16,0,0,0,0,0,0,198,198,198,198,214,214,214,254,238,108,0,0,0,0
db 0,0,198,198,108,124,56,56,124,108,198,198,0,0,0,0,0,0,102,102,102,102,60,24,24,24,24,60,0,0,0,0
db 0,0,254,198,134,12,24,48,96,194,198,254,0,0,0,0,0,0,60,48,48,48,48,48,48,48,48,60,0,0,0,0
db 0,0,0,128,192,224,112,56,28,14,6,2,0,0,0,0,0,0,60,12,12,12,12,12,12,12,12,60,0,0,0,0
db 16,56,108,198,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255,0,0

db 48,48,24,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,120,12,124,204,204,204,118,0,0,0,0			       ; 6
db 0,0,224,96,96,120,108,102,102,102,102,124,0,0,0,0,0,0,0,0,0,124,198,192,192,192,198,124,0,0,0,0
db 0,0,28,12,12,60,108,204,204,204,204,118,0,0,0,0,0,0,0,0,0,124,198,254,192,192,198,124,0,0,0,0
db 0,0,56,108,100,96,240,96,96,96,96,240,0,0,0,0,0,0,0,0,0,118,204,204,204,204,124,12,12,204,120,0
db 0,0,224,96,96,108,118,102,102,102,102,230,0,0,0,0,0,0,24,24,0,56,24,24,24,24,24,60,0,0,0,0
db 0,0,6,6,0,14,6,6,6,6,6,6,102,102,60,0,0,0,224,96,96,102,108,120,120,108,102,230,0,0,0,0
db 0,0,56,24,24,24,24,24,24,24,24,60,0,0,0,0,0,0,0,0,0,236,254,214,214,214,214,198,0,0,0,0
db 0,0,0,0,0,220,102,102,102,102,102,102,0,0,0,0,0,0,0,0,0,124,198,198,198,198,198,124,0,0,0,0

db 0,0,0,0,0,220,102,102,102,102,102,124,96,96,240,0,0,0,0,0,0,118,204,204,204,204,204,124,12,12,30,0	      ; 7
db 0,0,0,0,0,220,118,102,96,96,96,240,0,0,0,0,0,0,0,0,0,124,198,96,56,12,198,124,0,0,0,0
db 0,0,16,48,48,252,48,48,48,48,54,28,0,0,0,0,0,0,0,0,0,204,204,204,204,204,204,118,0,0,0,0
db 0,0,0,0,0,102,102,102,102,102,60,24,0,0,0,0,0,0,0,0,0,198,198,214,214,214,254,108,0,0,0,0
db 0,0,0,0,0,198,108,56,56,56,108,198,0,0,0,0,0,0,0,0,0,198,198,198,198,198,126,6,6,198,124,0
db 0,0,0,0,0,254,204,24,48,96,198,254,0,0,0,0,0,0,14,24,24,24,112,24,24,24,24,14,0,0,0,0
db 0,0,24,24,24,24,0,24,24,24,24,24,0,0,0,0,0,0,112,24,24,24,14,24,24,24,24,112,0,0,0,0
db 0,0,118,220,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,56,108,198,198,198,254,0,0,0,0,0

db 198,198,0,254,102,98,104,120,104,98,102,254,0,0,0,0,0,0,198,198,0,124,198,254,192,192,198,124,0,0,0,0
db 0,0,0,48,24,12,6,12,24,48,0,126,0,0,0,0,0,0,0,12,24,48,96,48,24,12,0,126,0,0,0,0
db 0,0,14,27,27,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,216,216,216,112,0,0,0,0
db 0,0,0,0,24,24,0,126,0,24,24,0,0,0,0,0,0,0,0,0,0,118,220,0,118,220,0,0,0,0,0,0
db 0,56,108,108,56,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,24,24,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,24,0,0,0,0,0,0,0,0,0,0,1,3,2,6,4,204,104,56,16,0,0,0,0
db 0,0,0,60,66,153,165,161,165,153,66,60,0,0,0,0,0,112,216,48,96,200,248,0,0,0,0,0,0,0,0,0
db 0,0,0,0,124,124,124,124,124,124,124,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

db 24,24,24,24,24,24,24,31,0,0,0,0,0,0,0,0,24,24,24,24,24,24,24,255,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,255,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,31,24,24,24,24,24,24,24,24
db 0,0,0,0,0,0,0,255,0,0,0,0,0,0,0,0,24,24,24,24,24,24,24,255,24,24,24,24,24,24,24,24
db 24,24,24,24,24,31,24,31,24,24,24,24,24,24,24,24,54,54,54,54,54,54,54,55,54,54,54,54,54,54,54,54
db 54,54,54,54,54,55,48,63,0,0,0,0,0,0,0,0,0,0,0,0,0,63,48,55,54,54,54,54,54,54,54,54
db 54,54,54,54,54,247,0,255,0,0,0,0,0,0,0,0,0,0,0,0,0,255,0,247,54,54,54,54,54,54,54,54
db 54,54,54,54,54,55,48,55,54,54,54,54,54,54,54,54,0,0,0,0,0,255,0,255,0,0,0,0,0,0,0,0
db 54,54,54,54,54,247,0,247,54,54,54,54,54,54,54,54,24,24,24,24,24,255,0,255,0,0,0,0,0,0,0,0

db 54,54,54,54,54,54,54,255,0,0,0,0,0,0,0,0,0,0,0,0,0,255,0,255,24,24,24,24,24,24,24,24
db 0,0,0,0,0,0,0,255,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,63,0,0,0,0,0,0,0,0
db 24,24,24,24,24,31,24,31,0,0,0,0,0,0,0,0,0,0,0,0,0,31,24,31,24,24,24,24,24,24,24,24
db 0,0,0,0,0,0,0,63,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,255,54,54,54,54,54,54,54,54
db 24,24,24,24,24,255,24,255,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,248,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,31,24,24,24,24,24,24,24,24,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
db 0,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240
db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,255,255,255,255,255,255,255,0,0,0,0,0,0,0,0,0

db 198,198,0,254,102,98,104,120,104,98,102,254,0,0,0,0,0,0,198,198,0,124,198,254,192,192,198,124,0,0,0,0
db 0,0,0,48,24,12,6,12,24,48,0,126,0,0,0,0,0,0,0,12,24,48,96,48,24,12,0,126,0,0,0,0
db 0,0,14,27,27,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,216,216,216,112,0,0,0,0
db 0,0,0,0,24,24,0,126,0,24,24,0,0,0,0,0,0,0,0,0,0,118,220,0,118,220,0,0,0,0,0,0
db 0,56,108,108,56,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,24,24,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,24,0,0,0,0,0,0,0,0,0,0,1,3,2,6,4,204,104,56,16,0,0,0,0
db 0,0,0,60,66,153,165,161,165,153,66,60,0,0,0,0,0,112,216,48,96,200,248,0,0,0,0,0,0,0,0,0
db 0,0,0,0,124,124,124,124,124,124,124,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

db 0,0,30,54,102,198,198,254,198,198,198,198,0,0,0,0,0,0,254,98,98,96,124,102,102,102,102,252,0,0,0,0
db 0,0,252,102,102,102,124,102,102,102,102,252,0,0,0,0,0,0,254,98,98,96,96,96,96,96,96,240,0,0,0,0
db 0,0,30,54,102,102,102,102,102,102,102,255,195,129,0,0,0,0,254,102,98,104,120,104,96,98,102,254,0,0,0,0
db 0,0,214,214,84,84,124,124,84,214,214,214,0,0,0,0,0,0,124,198,6,6,60,6,6,6,198,124,0,0,0,0
db 0,0,198,198,206,206,214,230,230,198,198,198,0,0,0,0,56,56,198,198,206,206,214,230,230,198,198,198,0,0,0,0
db 0,0,230,102,108,108,120,120,108,108,102,230,0,0,0,0,0,0,30,54,102,198,198,198,198,198,198,198,0,0,0,0
db 0,0,198,238,254,254,214,198,198,198,198,198,0,0,0,0,0,0,198,198,198,198,254,198,198,198,198,198,0,0,0,0
db 0,0,124,198,198,198,198,198,198,198,198,124,0,0,0,0,0,0,254,198,198,198,198,198,198,198,198,198,0,0,0,0

db 0,0,252,102,102,102,124,96,96,96,96,240,0,0,0,0,0,0,60,102,194,192,192,192,192,194,102,60,0,0,0,0	       ; 8
db 0,0,126,90,24,24,24,24,24,24,24,60,0,0,0,0,0,0,198,198,198,198,198,126,6,6,198,124,0,0,0,0
db 0,60,24,126,219,219,219,219,219,126,24,60,0,0,0,0,0,0,198,198,108,124,56,56,124,108,198,198,0,0,0,0
db 0,0,204,204,204,204,204,204,204,204,204,254,6,6,0,0,0,0,198,198,198,198,198,126,6,6,6,6,0,0,0,0
db 0,0,219,219,219,219,219,219,219,219,219,255,0,0,0,0,0,0,219,219,219,219,219,219,219,219,219,255,3,3,0,0
db 0,0,248,176,48,48,60,54,54,54,54,124,0,0,0,0,0,0,195,195,195,195,243,219,219,219,219,243,0,0,0,0
db 0,0,240,96,96,96,124,102,102,102,102,252,0,0,0,0,0,0,124,198,6,38,62,38,6,6,198,124,0,0,0,0
db 0,0,206,219,219,219,251,219,219,219,219,206,0,0,0,0,0,0,63,102,102,102,62,62,102,102,102,231,0,0,0,0

db 0,0,0,0,0,120,12,124,204,204,204,118,0,0,0,0,0,2,6,60,96,96,124,102,102,102,102,60,0,0,0,0
db 0,0,0,0,0,252,102,102,124,102,102,252,0,0,0,0,0,0,0,0,0,126,50,50,48,48,48,120,0,0,0,0
db 0,0,0,0,0,30,54,54,102,102,102,255,195,195,0,0,0,0,0,0,0,124,198,254,192,192,198,124,0,0,0,0
db 0,0,0,0,0,214,214,84,124,84,214,214,0,0,0,0,0,0,0,0,0,60,102,6,12,6,102,60,0,0,0,0
db 0,0,0,0,0,198,198,206,214,230,198,198,0,0,0,0,0,0,0,56,56,198,198,206,214,230,198,198,0,0,0,0
db 0,0,0,0,0,230,108,120,120,108,102,230,0,0,0,0,0,0,0,0,0,30,54,102,102,102,102,102,0,0,0,0
db 0,0,0,0,0,198,238,254,254,214,214,198,0,0,0,0,0,0,0,0,0,198,198,198,254,198,198,198,0,0,0,0
db 0,0,0,0,0,124,198,198,198,198,198,124,0,0,0,0,0,0,0,0,0,254,198,198,198,198,198,198,0,0,0,0

db 0,0,0,0,0,220,102,102,102,102,102,124,96,96,240,0,0,0,0,0,0,124,198,192,192,192,198,124,0,0,0,0
db 0,0,0,0,0,126,90,24,24,24,24,60,0,0,0,0,0,0,0,0,0,198,198,198,198,198,126,6,6,198,124,0
db 0,0,0,0,60,24,126,219,219,219,219,126,24,24,60,0,0,0,0,0,0,198,108,56,56,56,108,198,0,0,0,0
db 0,0,0,0,0,204,204,204,204,204,204,254,6,6,0,0,0,0,0,0,0,198,198,198,198,126,6,6,0,0,0,0
db 0,0,0,0,0,214,214,214,214,214,214,254,0,0,0,0,0,0,0,0,0,214,214,214,214,214,214,254,3,3,0,0
db 0,0,0,0,0,248,176,48,62,51,51,126,0,0,0,0,0,0,0,0,0,198,198,198,246,222,222,246,0,0,0,0
db 0,0,0,0,0,240,96,96,124,102,102,252,0,0,0,0,0,0,0,0,0,60,102,6,30,6,102,60,0,0,0,0
db 0,0,0,0,0,206,219,219,251,219,219,206,0,0,0,0,0,0,0,0,0,126,204,204,252,108,204,206,0,0,0,0


  digits	    db '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ', 0
  downcase	    db 'abcdefghijklmnopqrstuvwxyzабвгдеёжзийклмнопрстуфхцчшщьъыэюя', 0
  upcase	    db 'ABCDEFGHIJKLMNOPQRSTUVWXYZАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЪЫЭЮЯ', 0
  Zeroes16	    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

  ten		    dt 10.0f
  minus_one	    dt -1.0f

  float1	    dt 1.0f
  float2	    dt 2.0f
  float3	    dt 3.0f
  float4	    dt 4.0f
  float5	    dt 5.0f
  float6	    dt 6.0f
  float7	    dt 7.0f
  float8	    dt 8.0f
  float9	    dt 9.0f

  RotateAngle	    GLfloat    0.0
  glX		    GLfloat    0.0
  glY		    GLfloat    0.0
  glZ		    GLfloat    0.0
  glW		    GLfloat    0.0
  glParams	    GLdouble	-1.0
  glParams1	    GLdouble	1.0
  glParams2	    GLdouble   -1.0
  glParams3	    GLdouble   1.0
  glParams4	    GLdouble   3.0
  glParams5	    GLdouble   10.0
  glParams6	    GLdouble   0.0
  glParams7	    GLdouble   0.0


  hSources	    rd	 MAXLOADING
  hTibPtrs	    rd	 MAXLOADING
  hSpan 	    rd	 MAXLOADING
  hLineLength	    rd	 MAXLOADING
  hLineNumber	    rd	 MAXLOADING
  hTibs 	    rb	 256*MAXLOADING

  CFstackAddr	    rd	 MAXCF
  CFstackID	    rd	 MAXCF
  LStackI	    rd	 MAXLOOP
  LStackImax	    rd	 MAXLOOP
  LStackAddr	    rd	 MAXLOOP

  SelectorStack     rd	 MAXSELECTORS

  Tib		    rb	256
  Dstack	    rd 2048    ; 1024 + 1024 reserved
  token 	    rb	256
  parsed_token	    rb	256
  _pad		    rb	256
  Lstack	    rb	8 * MAXLOCALS
  FrameStack	    rd	MAXFRAMES
  Astack	    rd	256

  ToolButtonCaption rb	256 * MAXTOOLBUTTONS
  ToolButtonGlyph   rb	256 * MAXTOOLBUTTONS
  ToolButtonScript  rb	256 * MAXTOOLBUTTONS

  Systime	    rw	  8
  OldSystime	    rw	  8
  overlapped	    rd	  5    ; OVERLAPPED structure for ReadFile

  BtnNumber	    rd	  1

  inputbuf	    rb	  258
  ParamStr	    rd	  256



  screen rb 16777216	      ; GDI
	 rb 16777216	      ; OpenGL
	 rb 4096


section '.code' code readable writeable executable

proc DllEntryPoint hinstDLL,fdwReason,lpvReserved
	mov	eax, TRUE
	ret
endp


  start:

	invoke	GetModuleHandle, 0
	mov	[hinstance], eax
;        invoke  LoadIcon,0,IDI_APPLICATION
	invoke	LoadIcon, eax, 17

	mov	[wc.hIcon], eax
	invoke	LoadCursor, 0, IDC_ARROW
	mov	[wc.hCursor], eax
	mov	[wc.style], 0
	mov	[wc.lpfnWndProc], WindowProc
	mov	[wc.cbClsExtra], 0
	mov	[wc.cbWndExtra], 0
	mov	eax, [hinstance]
	mov	[wc.hInstance], eax
	mov	[wc.hbrBackground], 0
	mov	[wc.lpszMenuName], 0
	mov	[wc.lpszClassName], _class
	invoke	RegisterClass, wc
	invoke	LoadMenu, [hinstance], 37
	invoke	CreateWindowEx, 0, _class,_title, WS_VISIBLE+WS_OVERLAPPEDWINDOW, 16, 16, 1032, 768, NULL, eax, [hinstance], NULL  ; +WS_CLIPCHILDREN+WS_CLIPSIBLINGS
	mov	[hwnd], eax
	mov	ebx, Dstack

  msg_loop:
	call	ProcessTimer
	invoke	InvalidateRect, [hwnd], NULL, FALSE
	invoke	GetMessage, msg, NULL, 0, 0
	or	eax, eax
	jz	end_loop
	invoke	TranslateMessage, msg
	invoke	DispatchMessage, msg
	jmp	msg_loop

  end_loop:
	invoke	ExitProcess, [msg.wParam]

proc DialogProc hwnddlg, msg, wparam, lparam
	push	ebx esi edi
	cmp	[msg], WM_INITDIALOG
	je	wminitdialog
	cmp	[msg], WM_COMMAND
	je	wmcommanddlg
	cmp	[msg], WM_CLOSE
	je	wmclosedlg
	xor	eax, eax
	jmp	finishdlg
  wminitdialog:
	jmp	processed
  wmcommanddlg:
	cmp	[wparam], BN_CLICKED shl 16 + IDCANCEL
	jne	dlgnext
	xor	eax, eax
	mov	[BtnNumber], eax
	jmp	wmclosedlg
  dlgnext:
	cmp	[wparam], BN_CLICKED shl 16 + IDOK
	jne	processed
	mov	eax, 1
	mov	[BtnNumber], eax
;        invoke  GetDlgItemText,[hwnddlg],ID_MESSAGE,inputbuf,100h
	jmp	wmclosedlg
	jmp	processed
  wmclosedlg:
	invoke	GetDlgItemText, [hwnddlg], ID_MESSAGE, inputbuf, 100h
	invoke	EndDialog, [hwnddlg], 0
  processed:
	mov	eax, 1		    ; required for normal operation
  finishdlg:
	pop	edi esi ebx
	ret
endp


proc WindowProc, hwnd,wmsg,wparam,lparam
;        enter
	push	ebx esi edi

	xor	eax, eax		    ; build 25
	mov	[MsgProcessed], eax
	mov	eax, [wmsg]
	mov	[WMsg], eax
	mov	eax, [wparam]
	mov	[WParam], eax
	mov	eax, [lparam]
	mov	[LParam], eax
	call	WinMsg
	mov	eax, [MsgProcessed]
	cmp	eax, 0			    ; build 25
	jne	finish

	mov	[lastkey], 0
	cmp	[wmsg], WM_CREATE
	je	wmcreate
	cmp	[wmsg], WM_SIZE
	je	wmsize
	cmp	[wmsg], WM_ACTIVATEAPP
	je	wmactivateapp
	cmp	[wmsg], WM_PAINT
	je	wmpaint
	cmp	[wmsg], WM_KEYDOWN
	je	wmkeydown
	cmp	[wmsg], WM_KEYUP
	je	wmkeyup
	cmp	[wmsg], WM_LBUTTONDOWN
	je	wmlmbdown
	cmp	[wmsg], WM_RBUTTONDOWN
	je	wmrmbdown
	cmp	[wmsg], WM_LBUTTONUP
	je	wmlmbup
	cmp	[wmsg], WM_RBUTTONUP
	je	wmrmbup
	cmp	[wmsg], WM_LBUTTONDBLCLK
	je	wmlmbdbl
	cmp	[wmsg], WM_RBUTTONDBLCLK
	je	wmrmbdbl
	cmp	[wmsg], WM_MOUSEWHEEL
	je	wmmousewheel
	cmp	[wmsg], WM_MOUSEMOVE
	je	wmmousemove
	cmp	[wmsg], WM_CHAR
	je	wmchar
	cmp	[wmsg], WM_DESTROY
	je	wmdestroy
	mov	eax, [wparam]
	and	eax, 0xFFFF
	cmp	eax, IDM_EXIT
	je	wmdestroy
	mov	eax, [wparam]
	and	eax, 0xFFFF
notest:
	jmp	defwndproc
  defwndproc:
	invoke	DefWindowProc, [hwnd], [wmsg], [wparam], [lparam]
	jmp	finish
  wmcreate:
	invoke	GetDC, [hwnd]
	mov	[hdc], eax
	mov	edi, pfd
	mov	ecx, sizeof.PIXELFORMATDESCRIPTOR shr 2
	xor	eax, eax
	rep	stosd
	mov	[pfd.nSize], sizeof.PIXELFORMATDESCRIPTOR
	mov	[pfd.nVersion], 1
	mov	[pfd.dwFlags], PFD_SUPPORT_OPENGL + PFD_DOUBLEBUFFER + PFD_DRAW_TO_WINDOW
	mov	[pfd.dwLayerMask], PFD_MAIN_PLANE
	mov	[pfd.iPixelType], PFD_TYPE_RGBA
	mov	[pfd.cColorBits], 32
	mov	[pfd.cDepthBits], 32
	mov	[pfd.cAccumBits], 0
	mov	[pfd.cStencilBits], 0
	invoke	ChoosePixelFormat, [hdc], pfd
	invoke	SetPixelFormat,[hdc], eax, pfd
	invoke	wglCreateContext, [hdc]
	mov	[hrc], eax
	invoke	wglMakeCurrent, [hdc], [hrc]
	invoke	GetClientRect, [hwnd], rc
	invoke	glViewport, 0, 0, [rc.right], [rc.bottom]

	call	Init
	call	StartUp

	xor	eax,eax
	jmp	finish
  wmsize:
	invoke	GetClientRect,[hwnd],rc
	invoke	glViewport,0,0,[rc.right],[rc.bottom]
	invoke	InvalidateRect,[hwnd],NULL,FALSE
	mov	eax, [rc.right]
	mov	[xsize], eax
	mov	eax, [rc.bottom]
	mov	[ysize], eax
	call	VectWinResize
	xor	eax,eax
	jmp	finish
  wmactivateapp:
	push	[wmsg]
	pop	[active]
	xor	eax,eax
	jmp	finish
  wmpaint:

	mov	eax, [rc.right]
	call	PushingEax
	mov	eax, [rc.bottom]
	call	PushingEax
	call	GLRedraw
;        invoke  glClear, GL_COLOR_BUFFER_BIT

;        mov     eax, screen
;        add     eax, 16777216
;        invoke  glDrawPixels, [rc.right], [rc.bottom], GL_RGBA, GL_UNSIGNED_BYTE, eax

;        call    GL3D

;        invoke  SwapBuffers,[hdc]
	xor	eax,eax
	jmp	finish

  wmchar:
	xor	eax, eax
	mov	ax, word [wparam]
	mov	[lastkey], eax
	call	VectKChar
	mov	eax, [lastkey]
	call	ProcessKey

	jmp	defwndproc

  wmkeydown:
	xor	eax, eax
	mov	ax, word [wparam]
	mov	[lastkey], eax

	cmp	[wparam],VK_UP
	je	process_up

	cmp	[wparam],VK_DOWN
	je	process_down

	cmp	[wparam],VK_LEFT
	je	process_left

	cmp	[wparam],VK_RIGHT
	je	process_right

	cmp	[wparam],VK_HOME
	je	process_home

	cmp	[wparam],VK_END
	je	process_end

	cmp	[wparam],VK_PGUP
	je	process_pgup

	cmp	[wparam],VK_PGDN
	je	process_pgdn

	cmp	[wparam],VK_DELETE
	je	process_del

	cmp	[wparam],VK_INSERT
	je	process_ins

	cmp	[wparam],VK_ESCAPE
	je	process_esc

	cmp	[wparam],VK_F1
	je	process_f1

	cmp	[wparam],VK_F2
	je	process_f2

	cmp	[wparam],VK_F3
	je	process_f3

	cmp	[wparam],VK_F4
	je	process_f4

	cmp	[wparam],VK_F5
	je	process_f5

	cmp	[wparam],VK_F6
	je	process_f6

	cmp	[wparam],VK_F7
	je	process_f7

	cmp	[wparam],VK_F8
	je	process_f8

	cmp	[wparam],VK_F9
	je	process_f9

	cmp	[wparam],VK_F10
	je	process_f10

	cmp	[wparam],VK_F11
	je	process_f11

	cmp	[wparam],VK_F12
	je	process_f12

	cmp	[wparam], 48
	je	process_Char0

	cmp	[wparam], 49
	je	process_Char1

	cmp	[wparam], 50
	je	process_Char2

	cmp	[wparam], 51
	je	process_Char3

	cmp	[wparam], 52
	je	process_Char4

	cmp	[wparam], 53
	je	process_Char5

	cmp	[wparam], 54
	je	process_Char6

	cmp	[wparam], 55
	je	process_Char7

	cmp	[wparam], 56
	je	process_Char8

	cmp	[wparam], 57
	je	process_Char9

	cmp	[wparam], 65
	je	process_CharA

	cmp	[wparam], 66
	je	process_CharB

	cmp	[wparam], 67
	je	process_CharC

	cmp	[wparam], 68
	je	process_CharD

	cmp	[wparam], 69
	je	process_CharE

	cmp	[wparam], 70
	je	process_CharF

	cmp	[wparam], 71
	je	process_CharG

	cmp	[wparam], 72
	je	process_CharH

	cmp	[wparam], 73
	je	process_CharI

	cmp	[wparam], 74
	je	process_CharJ

	cmp	[wparam], 75
	je	process_CharK

	cmp	[wparam], 76
	je	process_CharL

	cmp	[wparam], 77
	je	process_CharM

	cmp	[wparam], 78
	je	process_CharN

	cmp	[wparam], 79
	je	process_CharO

	cmp	[wparam], 80
	je	process_CharP

	cmp	[wparam], 81
	je	process_CharQ

	cmp	[wparam], 82
	je	process_CharR

	cmp	[wparam], 83
	je	process_CharS

	cmp	[wparam], 84
	je	process_CharT

	cmp	[wparam], 85
	je	process_CharU

	cmp	[wparam], 86
	je	process_CharV

	cmp	[wparam], 87
	je	process_CharW

	cmp	[wparam], 88
	je	process_CharX

	cmp	[wparam], 89
	je	process_CharY

	cmp	[wparam], 90
	je	process_CharZ

	xor	eax, eax
	mov	ax, word [wparam]
	mov	[lastkey], eax
	call	ProcessKeyDown

	jmp	defwndproc

  process_up:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_up
	call	VectKUp
	jmp	defwndproc
  process_shift_up:
	call	VectKShiftUp
	jmp	defwndproc

  process_down:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_down
	call	VectKDown
	jmp	defwndproc
  process_shift_down:
	call	VectKShiftDown
	jmp	defwndproc

  process_left:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_left
	call	VectKLeft
	jmp	defwndproc
  process_shift_left:
	call	VectKShiftLeft
	jmp	defwndproc

  process_right:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_right
	call	VectKRight
	jmp	defwndproc
  process_shift_right:
	call	VectKShiftRight
	jmp	defwndproc

  process_home:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_home
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_home
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_home
	call	VectKHome
	jmp	defwndproc
  process_shift_home:
	call	VectKShiftHome
	jmp	defwndproc
  process_alt_home:
	call	VectKAltHome
	jmp	defwndproc
  process_ctrl_home:
	call	VectKCtrlHome
	jmp	defwndproc

  process_end:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_end
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_end
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_end
	call	VectKEnd
	jmp	defwndproc
  process_shift_end:
	call	VectKShiftEnd
	jmp	defwndproc
  process_alt_end:
	call	VectKAltEnd
	jmp	defwndproc
  process_ctrl_end:
	call	VectKCtrlEnd
	jmp	defwndproc

  process_pgup:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_pgup
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_pgup
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_pgup
	call	VectKPgUp
	jmp	defwndproc
  process_shift_pgup:
	call	VectKShiftPgUp
	jmp	defwndproc
  process_alt_pgup:
	call	VectKAltPgUp
	jmp	defwndproc
  process_ctrl_pgup:
	call	VectKCtrlPgUp
	jmp	defwndproc

  process_pgdn:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_pgdn
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_pgdn
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_pgup
	call	VectKPgDn
	jmp	defwndproc
  process_shift_pgdn:
	call	VectKShiftPgDn
	jmp	defwndproc
  process_alt_pgdn:
	call	VectKAltPgDn
	jmp	defwndproc
  process_ctrl_pgdn:
	call	VectKCtrlPgDn
	jmp	defwndproc

  process_del:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_del
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_del
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_del
	call	VectKDel
	jmp	defwndproc
  process_shift_del:
	call	VectKShiftDel
	jmp	defwndproc
  process_alt_del:
	call	VectKAltDel
	jmp	defwndproc
  process_ctrl_del:
	call	VectKCtrlDel
	jmp	defwndproc

  process_ins:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_ins
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_ins
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_ins
	call	VectKIns
	jmp	defwndproc
  process_shift_ins:
	call	VectKShiftIns
	jmp	defwndproc
  process_alt_ins:
	call	VectKAltIns
	jmp	defwndproc
  process_ctrl_ins:
	call	VectKCtrlIns
	jmp	defwndproc

  process_esc:
	call	VectKESC
	jmp	defwndproc

  process_f1:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_f1
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_f1
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_f1
	call	VectKF1
	jmp	defwndproc
  process_shift_f1:
	call	VectKShiftF1
	jmp	defwndproc
  process_alt_f1:
	call	VectKAltF1
	jmp	defwndproc
  process_ctrl_f1:
	call	VectKCtrlF1
	jmp	defwndproc

  process_f2:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_f2
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_f2
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_f2
	call	VectKF2
	jmp	defwndproc
  process_shift_f2:
	call	VectKShiftF2
	jmp	defwndproc
  process_alt_f2:
	call	VectKAltF2
	jmp	defwndproc
  process_ctrl_f2:
	call	VectKCtrlF2
	jmp	defwndproc


  process_f3:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_f3
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_f3
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_f3
	call	VectKF3
	jmp	defwndproc
  process_shift_f3:
	call	VectKShiftF3
	jmp	defwndproc
  process_alt_f3:
	call	VectKAltF3
	jmp	defwndproc
  process_ctrl_f3:
	call	VectKCtrlF3
	jmp	defwndproc

  process_f4:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_f4
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_f4
	call	VectKF4
	jmp	defwndproc
  process_shift_f4:
	call	VectKShiftF4
	jmp	defwndproc
  process_ctrl_f4:
	call	VectKCtrlF4
	jmp	defwndproc

  process_f5:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_f5
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_f5
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_f5
	call	VectKF5
	jmp	defwndproc
  process_shift_f5:
	call	VectKShiftF5
	jmp	defwndproc
  process_alt_f5:
	call	VectKAltF5
	jmp	defwndproc
  process_ctrl_f5:
	call	VectKCtrlF5
	jmp	defwndproc

  process_f6:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_f6
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_f6
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_f6
	call	VectKF6
	jmp	defwndproc
  process_shift_f6:
	call	VectKShiftF6
	jmp	defwndproc
  process_alt_f6:
	call	VectKAltF6
	jmp	defwndproc
  process_ctrl_f6:
	call	VectKCtrlF6
	jmp	defwndproc

  process_f7:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_f7
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_f7
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_f7
	call	VectKF7
	jmp	defwndproc
  process_shift_f7:
	call	VectKShiftF7
	jmp	defwndproc
  process_alt_f7:
	call	VectKAltF7
	jmp	defwndproc
  process_ctrl_f7:
	call	VectKCtrlF7
	jmp	defwndproc

  process_f8:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_f8
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_f8
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_f8
	call	VectKF8
	jmp	defwndproc
  process_shift_f8:
	call	VectKShiftF8
	jmp	defwndproc
  process_alt_f8:
	call	VectKAltF8
	jmp	defwndproc
  process_ctrl_f8:
	call	VectKCtrlF8
	jmp	defwndproc

  process_f9:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_f9
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_f9
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_f9
	call	VectKF9
	jmp	defwndproc
  process_shift_f9:
	call	VectKShiftF9
	jmp	defwndproc
  process_alt_f9:
	call	VectKAltF9
	jmp	defwndproc
  process_ctrl_f9:
	call	VectKCtrlF9
	jmp	defwndproc

  process_f10:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_f10
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_f10
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_f10
	call	VectKF10
	jmp	defwndproc
  process_shift_f10:
	call	VectKShiftF10
	jmp	defwndproc
  process_alt_f10:
	call	VectKAltF10
	jmp	defwndproc
  process_ctrl_f10:
	call	VectKCtrlF10
	jmp	defwndproc

  process_f11:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_f11
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_f11
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_f11
	call	VectKF11
	jmp	defwndproc
  process_shift_f11:
	call	VectKShiftF11
	jmp	defwndproc
  process_alt_f11:
	call	VectKAltF11
	jmp	defwndproc
  process_ctrl_f11:
	call	VectKCtrlF11
	jmp	defwndproc

  process_f12:
	invoke	GetKeyState, VK_SHIFT
	and	eax, 0x8000
	jnz	process_shift_f12
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_f12
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_f12
	call	VectKF12
	jmp	defwndproc
  process_shift_f12:
	call	VectKShiftF12
	jmp	defwndproc
  process_alt_f12:
	call	VectKAltF12
	jmp	defwndproc
  process_ctrl_f12:
	call	VectKCtrlF12
	jmp	defwndproc

  process_Char0:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_0
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_0
  process_alt_0:
	call	VectKAlt0
	jmp	defwndproc
  process_ctrl_0:
	call	VectKCtrl0
	jmp	defwndproc

  process_Char1:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_1
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_1
  process_alt_1:
	call	VectKAlt1
	jmp	defwndproc
  process_ctrl_1:
	call	VectKCtrl1
	jmp	defwndproc

  process_Char2:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_2
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_2
  process_alt_2:
	call	VectKAlt2
	jmp	defwndproc
  process_ctrl_2:
	call	VectKCtrl2
	jmp	defwndproc

  process_Char3:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_3
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_3
  process_alt_3:
	call	VectKAlt3
	jmp	defwndproc
  process_ctrl_3:
	call	VectKCtrl3
	jmp	defwndproc

  process_Char4:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_4
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_4
  process_alt_4:
	call	VectKAlt4
	jmp	defwndproc
  process_ctrl_4:
	call	VectKCtrl4
	jmp	defwndproc

  process_Char5:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_5
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_5
  process_alt_5:
	call	VectKAlt5
	jmp	defwndproc
  process_ctrl_5:
	call	VectKCtrl5
	jmp	defwndproc

  process_Char6:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_6
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_6
  process_alt_6:
	call	VectKAlt6
	jmp	defwndproc
  process_ctrl_6:
	call	VectKCtrl6
	jmp	defwndproc

  process_Char7:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_7
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_7
  process_alt_7:
	call	VectKAlt7
	jmp	defwndproc
  process_ctrl_7:
	call	VectKCtrl7
	jmp	defwndproc

  process_Char8:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_8
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_8
  process_alt_8:
	call	VectKAlt8
	jmp	defwndproc
  process_ctrl_8:
	call	VectKCtrl8
	jmp	defwndproc

  process_Char9:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_9
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_9
  process_alt_9:
	call	VectKAlt9
	jmp	defwndproc
  process_ctrl_9:
	call	VectKCtrl9
	jmp	defwndproc


  process_CharA:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_A
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_A
  process_alt_A:
	call	VectKAltA
	jmp	defwndproc
  process_ctrl_A:
	call	VectKCtrlA
	jmp	defwndproc

  process_CharB:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_B
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_B
  process_alt_B:
	call	VectKAltB
	jmp	defwndproc
  process_ctrl_B:
	call	VectKCtrlB
	jmp	defwndproc

  process_CharC:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_C
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_C
  process_alt_C:
	call	VectKAltC
	jmp	defwndproc
  process_ctrl_C:
	call	VectKCtrlC
	jmp	defwndproc

  process_CharD:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_D
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_D
  process_alt_D:
	call	VectKAltD
	jmp	defwndproc
  process_ctrl_D:
	call	VectKCtrlD
	jmp	defwndproc

  process_CharE:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_E
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_E
  process_alt_E:
	call	VectKAltE
	jmp	defwndproc
  process_ctrl_E:
	call	VectKCtrlE
	jmp	defwndproc

  process_CharF:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_F
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_F
  process_alt_F:
	call	VectKAltF
	jmp	defwndproc
  process_ctrl_F:
	call	VectKCtrlF
	jmp	defwndproc

  process_CharG:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_G
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_G
  process_alt_G:
	call	VectKAltG
	jmp	defwndproc
  process_ctrl_G:
	call	VectKCtrlG
	jmp	defwndproc

  process_CharH:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_H
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_H
  process_alt_H:
	call	VectKAltH
	jmp	defwndproc
  process_ctrl_H:
	call	VectKCtrlH
	jmp	defwndproc

  process_CharI:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_I
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_I
  process_alt_I:
	call	VectKAltI
	jmp	defwndproc
  process_ctrl_I:
	call	VectKCtrlI
	jmp	defwndproc

  process_CharJ:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_J
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_J
  process_alt_J:
	call	VectKAltJ
	jmp	defwndproc
  process_ctrl_J:
	call	VectKCtrlJ
	jmp	defwndproc

  process_CharK:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_K
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_K
  process_alt_K:
	call	VectKAltK
	jmp	defwndproc
  process_ctrl_K:
	call	VectKCtrlK
	jmp	defwndproc

  process_CharL:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_L
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_L
  process_alt_L:
	call	VectKAltL
	jmp	defwndproc
  process_ctrl_L:
	call	VectKCtrlL
	jmp	defwndproc

  process_CharM:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_M
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_M
  process_alt_M:
	call	VectKAltM
	jmp	defwndproc
  process_ctrl_M:
	call	VectKCtrlM
	jmp	defwndproc

  process_CharN:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_N
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_N
  process_alt_N:
	call	VectKAltN
	jmp	defwndproc
  process_ctrl_N:
	call	VectKCtrlN
	jmp	defwndproc

  process_CharO:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_O
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_O
  process_alt_O:
	call	VectKAltO
	jmp	defwndproc
  process_ctrl_O:
	call	VectKCtrlO
	jmp	defwndproc

  process_CharP:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_P
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_P
  process_alt_P:
	call	VectKAltP
	jmp	defwndproc
  process_ctrl_P:
	call	VectKCtrlP
	jmp	defwndproc

  process_CharQ:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_Q
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_Q
  process_alt_Q:
	call	VectKAltQ
	jmp	defwndproc
  process_ctrl_Q:
	call	VectKCtrlQ
	jmp	defwndproc

  process_CharR:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_R
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_R
  process_alt_R:
	call	VectKAltR
	jmp	defwndproc
  process_ctrl_R:
	call	VectKCtrlR
	jmp	defwndproc

  process_CharS:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_S
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_S
  process_alt_S:
	call	VectKAltS
	jmp	defwndproc
  process_ctrl_S:
	call	VectKCtrlS
	jmp	defwndproc

  process_CharT:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_T
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_T
  process_alt_T:
	call	VectKAltT
	jmp	defwndproc
  process_ctrl_T:
	call	VectKCtrlT
	jmp	defwndproc

  process_CharU:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_U
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_U
  process_alt_U:
	call	VectKAltU
	jmp	defwndproc
  process_ctrl_U:
	call	VectKCtrlU
	jmp	defwndproc

  process_CharV:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_V
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_V
  process_alt_V:
	call	VectKAltV
	jmp	defwndproc
  process_ctrl_V:
	call	VectKCtrlV
	jmp	defwndproc

  process_CharW:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_W
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_W
  process_alt_W:
	call	VectKAltW
	jmp	defwndproc
  process_ctrl_W:
	call	VectKCtrlW
	jmp	defwndproc

  process_CharX:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_X
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_X
  process_alt_X:
	call	VectKAltX
	jmp	defwndproc
  process_ctrl_X:
	call	VectKCtrlX
	jmp	defwndproc

  process_CharY:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_Y
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_Y
  process_alt_Y:
	call	VectKAltY
	jmp	defwndproc
  process_ctrl_Y:
	call	VectKCtrlY
	jmp	defwndproc

  process_CharZ:
	invoke	GetKeyState, VK_MENU
	and	eax, 0x8000
	jnz	process_alt_Z
	invoke	GetKeyState, VK_CONTROL
	and	eax, 0x8000
	jnz	process_ctrl_Z
  process_alt_Z:
	call	VectKAltZ
	jmp	defwndproc
  process_ctrl_Z:
	call	VectKCtrlZ
	jmp	defwndproc



  wmkeyup:
	xor	eax, eax
	mov	ax, word [wparam]
	mov	[lastkey], eax
	call	ProcessKeyUp

	jmp	defwndproc

  wmlmbdown:
	mov	eax, [lparam]
	and	eax, 0xFFFF
	mov	[mousex], eax
	mov	eax, [lparam]
	shr	eax, 16
	and	eax, 0xFFFF
	mov	[mousey], eax
	call	VectMouseLeft
	jmp	defwndproc

  wmrmbdown:
	mov	eax, [lparam]
	and	eax, 0xFFFF
	mov	[mousex], eax
	mov	eax, [lparam]
	shr	eax, 16
	and	eax, 0xFFFF
	mov	[mousey], eax
	call	VectMouseRight
	jmp	defwndproc

  wmlmbdbl:
	mov	eax, [lparam]
	and	eax, 0xFFFF
	mov	[mousex], eax
	mov	eax, [lparam]
	shr	eax, 16
	and	eax, 0xFFFF
	mov	[mousey], eax
	call	VectMouseDblLeft
	jmp	defwndproc

  wmrmbdbl:
	mov	eax, [lparam]
	and	eax, 0xFFFF
	mov	[mousex], eax
	mov	eax, [lparam]
	shr	eax, 16
	and	eax, 0xFFFF
	mov	[mousey], eax
	call	VectMouseDblRight
	jmp	defwndproc


  wmlmbup:
	mov	eax, [lparam]
	and	eax, 0xFFFF
	mov	[mousex], eax
	mov	eax, [lparam]
	shr	eax, 16
	and	eax, 0xFFFF
	mov	[mousey], eax
	call	VectMouseLeftUp
	jmp	defwndproc

  wmrmbup:
	mov	eax, [lparam]
	and	eax, 0xFFFF
	mov	[mousex], eax
	mov	eax, [lparam]
	shr	eax, 16
	and	eax, 0xFFFF
	mov	[mousey], eax
	call	VectMouseRightUp
	jmp	defwndproc

  wmmousewheel:
	mov	eax, [wparam]
	shr	eax, 16
	and	eax, 0xFFFF
	mov	[mousez], eax
	call	VectMouseWheel
	jmp	defwndproc

  wmmousemove:
	mov	eax, [lparam]
	and	eax, 0xFFFF
	mov	[mousex], eax
	mov	eax, [lparam]
	shr	eax, 16
	and	eax, 0xFFFF
	mov	[mousey], eax
	call	VectMouseMove
	jmp	defwndproc

  wmdestroy:
	invoke	wglMakeCurrent,0,0
	invoke	wglDeleteContext,[hrc]
	invoke	ReleaseDC,[hwnd],[hdc]
	invoke	GlobalFree, [CodeStart]
	invoke	GlobalFree, [DataStart]

	mov	eax, ForthNoop
	mov	ecx, VectTimer
	inc	ecx
	mov	[ecx], eax

	invoke	PostQuitMessage,0
	xor	eax,eax
  finish:
	pop	edi esi ebx
	ret
endp

; ********************************************************************

proc	ProcessTimer
	push	esi edi ebx
	xor	eax, eax
	cmp	eax, [timer_interval]
	je	TimerNo
	invoke	GetTickCount
	mov	edx, eax
	sub	eax, dword [old_ticks]
	cmp	eax, dword [timer_interval]
	jng	TimerNo
	mov	[old_ticks], edx
	call	VectTimer
TimerNo:
	pop	esi edi ebx
	ret
endp


proc	Stack2eax
;        enter
	mov	eax,[Depth]
	mov	eax,[Dstack+eax*4-4]
	dec	dword [Depth]
	ret
endp

proc Print
;       mov eax, [ebp + 4]
;       add ebp, 4
;        enter
       push	eax
       push	ecx
       push	edx
       mov	ecx, eax
       shr	eax, 28
       and	eax, 15
       add	eax, 48
       cmp	eax, 58
       jc	p1
       add	eax, 7
p1:    mov	[_pad], al
       mov	eax, ecx
       shr	eax, 24
       and	eax, 15
       add	eax, 48
       cmp	eax, 58
       jc	p2
       add	eax, 7
p2:    mov	[_pad +1], al
       mov	eax, ecx
       shr	eax, 20
       and	eax, 15
       add	eax, 48
       cmp	eax, 58
       jc	p3
       add	eax, 7
p3:    mov	[_pad +2], al
       mov	eax, ecx
       shr	eax, 16
       and	eax, 15
       add	eax, 48
       cmp	eax, 58
       jc	p4
       add	eax, 7
p4:    mov	[_pad +3], al
       mov	eax, ecx
       shr	eax, 12
       and	eax, 15
       add	eax, 48
       cmp	eax, 58
       jc	p5
       add	eax, 7
p5:    mov	[_pad +4], al
       mov	eax, ecx
       shr	eax, 8
       and	eax, 15
       add	eax, 48
       cmp	eax, 58
       jc	p6
       add	eax, 7
p6:    mov	[_pad +5], al
       mov	eax, ecx
       shr	eax, 4
       and	eax, 15
       add	eax, 48
       cmp	eax, 58
       jc	p7
       add	eax, 7
p7:    mov	[_pad +6], al
       mov	eax, ecx
       and	eax, 15
       add	eax, 48
       cmp	eax, 58
       jc	p8
       add	eax, 7
p8:    mov	[_pad +7], al
       mov	al, 0
       mov	byte [_pad +8], al
       pop	edx
       pop	ecx
       pop	eax
       ret
endp

; ********************************************************************

proc	emit1	 ; eax = symbol

	and	eax, 0xFF
	push	ebx
	push	edi
	push	edx
	push	ecx

	shl	eax, 4
	mov	ebx, symbols
	add	ebx, eax

	mov	edi, screen
	mov	eax, [wherey]
	shl	eax, 11
	add	eax, [wherex]
	shl	eax, 2
	add	eax, edi
	mov	edi, eax   ; edi = screen

	mov	ecx, 16
  emit1loop:
	push	ecx
	mov	ecx, 8
	mov	al, [ebx]
  emit2loop:
	test	al, 0x80
	jz	emit_bg
	mov	edx, [fgcolor]
	jmp	emit_wrmem
  emit_bg:
	cmp	[opaque], 0
	jne	emit_opaque
	mov	edx, [bgcolor]
  emit_wrmem:
	mov	[edi], edx
  emit_opaque:
	add	edi, 4
	shl	eax, 1
	dec	ecx
	cmp	ecx, 0
	jnz	emit2loop
	inc	ebx
	add	edi, 8160

	pop	ecx
	dec	ecx
	cmp	ecx, 0
	jnz	emit1loop

	mov	eax, [wherex]
	add	eax, 8
	cmp	eax, [maxx]
	jc	noincy
	mov	eax, [wherey]
	add	eax, 16
	mov	[wherey], eax
	xor	eax, eax
  noincy:
	mov	[wherex], eax

	pop	ecx
	pop	edx
	pop	edi
	pop	ebx
	ret
endp

proc	TypePad
	mov	al, [_pad]
	call	emit1
	mov	al, [_pad+1]
	call	emit1
	mov	al, [_pad+2]
	call	emit1
	mov	al, [_pad+3]
	call	emit1
	mov	al, [_pad+4]
	call	emit1
	mov	al, [_pad+5]
	call	emit1
	mov	al, [_pad+6]
	call	emit1
	mov	al, [_pad+7]
	call	emit1
	mov	al, byte [_pad+8]
	call	emit1
	ret
endp

proc	TypeMessage	; eax = lpstr
	mov	ecx, eax

TypeMessageStart:

	mov	al, [ecx]
	cmp	al, 0
	je	TypeMessageEnd
	call	emit1
	inc	ecx
	jmp	TypeMessageStart

TypeMessageEnd:

	ret
endp

proc proctest
	mov	eax, [ysize]
	call	Print
	call	TypePad
	ret
endp

proc	ViewMem
	mov	ecx, 8
	mov	edx, eax
	call	Print
	call	TypePad
ViewMem1:
	mov	eax, [edx]
	call	Print
	call	TypePad
	add	edx, 4
	dec	ecx
	cmp	ecx, 0
	jne	ViewMem1
	add	[wherey], 16
	mov	[wherex], 0
	ret
endp

proc	ViewStack
	mov	ecx,[Depth]
	cmp	ecx, 0
	jng	 vstack1
	mov	[wherex], 0
	mov	[wherey], 0
vstack0:
	dec	ecx
	mov	eax,[Dstack+ecx*4]
	push	ecx
	call	Print
	call	TypePad
	pop	ecx
	add	[wherey], 16
	mov	[wherex], 0
	cmp	ecx, 0
	jne	vstack0
vstack1:
	ret
endp

proc	SetToken   ; eax = null-terminated string address
	mov	ecx, token
SetTokenLoop:
	mov	dl, [eax]
	mov	[ecx], dl
	cmp	dl, 0
	je	SetTokenEnd
	inc	ecx
	inc	eax
	jmp	SetTokenLoop
SetTokenEnd:
	ret
endp

proc	LoadFlags2ecx
	; eax - LFA on enter
	; ecx - flags on exit
	add	eax, 4	  ; goto NFA
LoadFlagsLoop:
	mov	cl, [eax]
	inc	eax
	cmp	cl, 0
	jne	LoadFlagsLoop
	mov	ecx, [eax]
	ret
endp

proc	CompareWord  ; returns eax = 1 if token==CurrentWord
	push	ebx esi edi
	mov	esi, token
	mov	edi, [CurrentWord]
	mov	ah, [edi]
	cmp	ah, 0
	je	CompareFound
CompareLoop:
	mov	al, [esi]
	mov	ah, [edi]
	cmp	al, ah
	jne	CompareNotThis
	cmp	ah, 0
	je	CompareFound
	inc	esi
	inc	edi
	jmp	CompareLoop
;       This is right word!
CompareFound:
	mov	eax, 1
	jmp	CompareEnd
CompareNotThis:
	mov	eax, 0
CompareEnd:
	pop	ebx esi edi
	ret
endp

proc	FindWord     ; shows for 'token' in the vocabulary, starting from [ForthLatest]
		     ; returns CFA of word in eax

	mov	al, [token]
	cmp	al, 0
	jnz	FindWord1
	mov	eax, ForthNoop
	ret

FindWord1:

	push	ebx esi edi

	mov	eax, [Context]
	mov	eax, [eax]
	; was -        mov  eax, [ForthLatest]
FindWordLoop:
	add	eax, 4		     ; LFA->NFA
	mov	[CurrentWord], eax   ; and set NFA to CurrentWord
	sub	eax, 4		     ; back to LFA
	push	eax
	call	CompareWord
	cmp	eax, 0
	je	FindWordNotThis
	; else found!
	pop	eax
	mov	[FoundLFA], eax
	add	eax, 4		     ; LFA->NFA
FindWordSkipNFA:
	mov	cl, [eax]
	cmp	cl, 0
	je	FindWordSkipped
	inc	eax
	jmp	FindWordSkipNFA
FindWordSkipped:
	add	eax, 2		     ; also skip FLAGS
	mov	ecx, [eax - 1]	     ; load FLAGS to ecx
	jmp	FindWordEnd
FindWordNotThis:
	pop	eax
	push	eax
	call	LoadFlags2ecx
	pop	eax
	mov	eax,[eax]
	and	ecx, 2		     ; may be vocabulary
	jz	FindWordNoVoc
	mov	eax, [eax]
FindWordNoVoc:
	or	eax, eax
	jnz	FindWordLoop
	add	eax, 6

FindWordEnd:
	mov	ecx, [eax-1]	     ; load flags
	mov	[lastflags], ecx
	and	ecx, 1
	mov	[lastimm], ecx
	mov	[lastflags], ecx
	and	ecx, 2
	mov	[lastvoc], ecx
	mov	[lastflags], ecx
	and	ecx, 4
	mov	[lastsmudge], ecx
	mov	[lastflags], ecx
	and	ecx, 8
	mov	[lastnumerical], ecx
	mov	[lastflags], ecx
	and	ecx, 16
	mov	[lastvar], ecx
	pop	ebx esi edi
	ret
endp

proc	ParseClear
	mov	ecx, 255
	mov	edx, token
	mov	al, 0

ParseClearLoop:
	mov	[edx], al
	dec	ecx
	inc	edx
	cmp	ecx, 0
	jne	ParseClearLoop
	ret
endp

proc	TibClear
ForthTibClear:
	xor	eax, eax	 ; 1/03/09
	mov	[span], eax

	mov	ecx, 255
	mov	edx, Tib
	mov	al, 0

TibClearLoop:
	mov	[edx], al
	dec	ecx
	inc	edx
	cmp	ecx, 0
	jne	TibClearLoop
	ret
endp

proc	PadClear
	mov	ecx, 256
	mov	edx, _pad
	mov	al, 0

PadClearLoop:
	mov	[edx], al
	dec	ecx
	inc	edx
	cmp	ecx, 0
	jne	PadClearLoop
	ret
endp

proc	InputClear
	mov	ecx, 256
	mov	edx, inputbuf
	mov	al, 0

InputClearLoop:
	mov	[edx], al
	dec	ecx
	inc	edx
	cmp	ecx, 0
	jne	InputClearLoop
	ret
endp

proc	Parse
ForthParse:
	call	ParseClear
	mov	edx, [TibPtr]
ParseSkipBL:
	mov	al, [Tib+edx]
	cmp	al, 0
	je	ParseEnd
	cmp	al, 13
	je	ParseEnd
	cmp	al, 10
	je	ParseEnd
	cmp	al, 32
	je	ParseIsBL
	cmp	al, 9
	je	ParseIsBL
	jmp	ParseGetWord

ParseIsBL:
	inc	edx
	jmp	ParseSkipBL

ParseGetWord:
	mov	ecx, 0

ParseGetWordLoop:
	mov	al, [Tib+edx]
	cmp	al, 0
	je	ParseEnd
	cmp	al, 13
	je	ParseEnd
	cmp	al, 10
	je	ParseEnd
;        cmp     al, 9
;        je      ParseEnd
	cmp	al, [delimiter]
	je	ParseEnd
	cmp	al, [delimiter2]
	je	ParseEnd
	mov	[token+ecx], al
	inc	ecx
	inc	edx
	jmp	ParseGetWordLoop

ParseEnd:
	inc	edx
	mov	[TibPtr], edx

	mov	ax, word [token]
	cmp	ax, 32
	je	ParseNoToken
	cmp	ax, 9
	je	ParseNoToken
	jmp	ParseFinish

ParseNoToken:
	mov	al, 0
	mov	[token], al

ParseFinish:

	ret
endp

proc	ViewTib
	mov	eax, [ConsoleX]
	mov	[wherex], eax
	mov	eax, [ConsoleY]
	mov	[wherey], eax
	mov	ecx, [ConsoleL]

ViewTibClear:
	mov	eax, 0
	call	emit1
	dec	ecx
	inc	edx
	cmp	ecx, 0
	jne	ViewTibClear

	mov	eax, [ConsoleX]
	mov	[wherex], eax
	mov	eax, [ConsoleY]
	mov	[wherey], eax
	mov	edx, Tib
	mov	ecx, [span]
ViewTibLoop:
	cmp	ecx, 0
	je	ViewTibEnd
	mov	al, [edx]
	call	emit1
	inc	edx
	dec	ecx
	jmp	ViewTibLoop

ViewTibEnd:
	ret
endp

proc	ViewToken
	mov	ecx, 128
	mov	edx, token
	mov	[wherex], 0
	mov	[wherey], 16
	mov	eax, [errormsgpos]
	cmp	eax, 0
	je	ViewTokenLoop
	mov	eax, [errormsgx]
	mov	[wherex], eax
	mov	eax, [errormsgy]
	mov	[wherey], eax

ViewTokenLoop:
	cmp	ecx, 0
	je	ViewTokenEnd
	mov	al, [edx]
	cmp	al, 0
	je	ViewTokenEnd
	call	emit1
	inc	edx
	dec	ecx
	jmp	ViewTokenLoop

ViewTokenEnd:
	mov	eax, 32
	call	emit1
	ret
endp

proc	CompileToken
	mov	edx, token
CompileTokenLoop:
	mov	al, [edx]
	cmp	al, 0
	je	CompileTokenEnd
	mov	ecx, [cdp]
	mov	[ecx], al
	add	dword [cdp], 1
	inc	edx
	jmp	CompileTokenLoop
CompileTokenEnd:
	mov	al, 0
	mov	ecx, [cdp]
	mov	[ecx], al
	add	dword [cdp], 1

	ret
endp

proc	Digit		   ; al - symbol
			   ; returns eax - index
	push	ecx
	push	edx

	mov	ecx, digits

DigitLoop:

	mov	dl, [ecx]
	cmp	al, dl
	je	DigitEnd
	cmp	ecx, digits+36
	je	DigitEnd
	inc	ecx
	jmp	DigitLoop

DigitEnd:

	mov	eax, ecx
	sub	eax, digits
	pop	edx
	pop	ecx

	ret
endp

proc	IntegerNumber

NumberEntry:

	xor    eax, eax
	mov    [Number], eax
	mov    [NumberSign], eax
	mov    [NumError], eax
	mov    [lastnumber], eax
	mov    [lastfloat], eax
	mov    ecx, 0
	mov    edx, [base]

	mov    ax, word [token]
	cmp    al, 0
	je     IntegerNumberErr

	cmp    al, '-'
	jne    NumberTryPlus
	mov    eax, 1
	mov    [NumberSign], eax
	inc    ecx
	jmp    NumberTry0x

NumberTryPlus:

	cmp    al, '+'
	jne    NumberTry0x
	inc    ecx
;        jmp    IntegerNumberLoop

NumberTry0x:

	mov    ax, word [token+ecx]
	cmp    ax, '0x'
	jne    NumberTry0b
	mov    edx, 16
	add    ecx, 2
	jmp    IntegerNumberLoop

NumberTry0b:

	cmp    ax, '0b'
	jne    NumberTry0d
	mov    edx, 2
	add    ecx, 2
	jmp    IntegerNumberLoop

NumberTry0d:

	cmp    ax, '0d'
	jne    IntegerNumberLoop
	mov    edx, 10
	add    ecx, 2
	jmp    IntegerNumberLoop

IntegerNumberLoop:

	mov    al, byte [token+ecx]
	cmp    al, 0
	je     IntegerNumberSign
	call   Digit
	cmp    eax, edx
	jg     IntegerNumberErr
	xchg   eax, [Number]
	imul   eax, edx
	add    [Number], eax
	inc    ecx
	jmp    IntegerNumberLoop

IntegerNumberSign:

	mov    eax, [NumberSign]
	cmp    eax, 0
	je     IntegerNumberEnd
	mov    eax, [Number]
	xor    eax, 0xffffffff
	inc    eax
	mov    [Number], eax
	jmp    IntegerNumberEnd

IntegerNumberErr:

	inc    ecx
	mov    [NumError], ecx

IntegerNumberEnd:

	mov    [lastnumber], 1

	ret
endp

proc	FNumber

FNumberEntry:
	xor    eax,eax
	mov    dword [FNumberMant],   eax
	mov    dword [FNumberExp],    eax
	mov    dword [FNumberExpSign],eax
	mov    dword [FNumberPoint],  eax
	mov    dword [NumberSign],    eax
	mov    dword [FDigitsPassed], eax
	mov    [lastnumber], eax
	mov    [lastfloat], eax

	mov    ecx, token
	mov    al, [token]
	cmp    al, 0
	je     FNumberErr

FNumberCheckDotOrE:

	mov    al, [ecx]
	cmp    al, '.'
	je     FNumberFloatOK
	cmp    al, ','
	je     FNumberFloatOK
;        cmp  al, 'E'
;        je   FNumberFloatOK
;        cmp  al, 'e'
;        je   FNumberFloatOK
	cmp    al, 0
	je     IntegerNumber
	inc    ecx
	jmp    FNumberCheckDotOrE

FNumberFloatOK:

	fldz
	mov    ecx, token

FNumberMainLoop:

	mov    al, [ecx]
	cmp    al, 0
	je     FNumberAllOK
	cmp    ecx, token
	jne    FNumberSignNotAllowed
	cmp    al, '+'
	jne    FNumber1
	mov    edx, 0
	mov    dword [NumberSign], edx
	inc    ecx
	jmp    FNumberMainLoop

FNumber1:
	cmp    al, '-'
	jne    FNumberSignNotAllowed
	mov    edx, 1
	mov    dword [NumberSign], edx
	inc    ecx
	jmp    FNumberMainLoop

FNumberSignNotAllowed:

	cmp    al, '.'
	je     FNumberItsDot
	cmp    al, ','
	je     FNumberItsDot
	jmp    FNumber3

FNumberItsDot:
	mov    edx, [FDigitsPassed]
	mov    dword [FNumberPoint], edx
	inc    ecx
	jmp    FNumberMainLoop

FNumber3:

	cmp    al, 'E'
	je     FNumberExponent1
	cmp    al, 'e'
	je     FNumberExponent1

FNumber4:

	cmp    al, 48
	jl     FNumberErr
	cmp    al, 57
	jg     FNumberErr

	sub    al, 48

	fld    tbyte [ten]
	fmulp  st1, st0
	and    eax, 0xff
	mov    dword [NumberBuf], eax
	fild   dword [NumberBuf]
	faddp  st1, st0
	inc    dword [FDigitsPassed]
	inc    ecx

	jmp    FNumberMainLoop

FNumberExponent1:

	inc    ecx

FNumberExponent:

	mov    al, [ecx]
	cmp    al, 0
	je     FNumberAllOK
	cmp    al, '-'
	je     FNumberSetNegativeExponent
	cmp    al, 48
	jl     FNumberErr
	cmp    al, 57
	jg     FNumberErr

	sub    al, 48

	mov    edx, 0
	mov    dl, al
	push   edx
	mov    eax, [FNumberExp]
	mov    edx, 10
	mul    edx
	pop    edx
	add    eax, edx
	mov    [FNumberExp], eax
	inc    ecx
	jmp    FNumberExponent

FNumberSetNegativeExponent:

	mov    eax, 1
	mov    [FNumberExpSign], eax
	inc    ecx

	jmp    FNumberExponent

FNumberErr:
	inc    ecx
	mov    [NumError], ecx
	jmp    FNumberEnd

FNumberAllOK:

	mov    eax, [NumberSign]
	cmp    eax, 1
	jne    FNumberFinalize
	fld    tbyte [minus_one]
	fmulp  st1, st0

FNumberFinalize:

	mov    ecx, [FNumberExp]
	mov    eax, [FNumberExpSign]
	cmp    eax, 1
	jne    FNumberNotNegativeExp
	neg    ecx

FNumberNotNegativeExp:

	sub    ecx, [FDigitsPassed]
	add    ecx, [FNumberPoint]

FNumberFinalizeLoop:

	cmp    ecx, 0
	je     FNumberFinalizeAll
	test   ecx, 0x80000000
	jz     FExpCorrectionUp

	fld    tbyte [ten]
	fdivp  st1, st0
	inc    ecx
	jmp    FNumberFinalizeLoop

FExpCorrectionUp:

	fld    tbyte [ten]
	fmulp  st1, st0
	dec    ecx

	jmp    FNumberFinalizeLoop


FNumberFinalizeAll:

	mov    ecx, 0
	mov    [NumError], ecx
	mov    eax, 1
	mov    [lastnumber], eax
	mov    [lastfloat], eax

	mov    eax, [CanDispatch]
	cmp    eax, 0
	je     FNumberNoDispatch

	call   ForthDispatchFNumber

FNumberNoDispatch:


FNumberEnd:

	ret
endp

proc	ProcEvaluateStdCall lpstr
	mov    eax, [lpstr]
	call	ForthEv
	ret
endp

proc	ProcessKey
	push   ebx esi edi
	mov    eax, [lastkey]
	cmp    eax, 0
	je     ExeProcessKeyNothing
	mov    eax, [lastkey]
	cmp    eax, 8	 ; is it BACKSPACE?
	jne    ExeProcessKey1
	call   VectKBackspace
	mov    ecx, [span]
	cmp    ecx, 0
	je     ExeProcessKeyEnd
	mov    [Tib-1+ecx], 0
	dec    dword [span]
	jmp    ExeProcessKeyEnd

ExeProcessKey1:

	cmp    eax, 13	  ; is it ENTER
	jne    ExeProcessKey2
	call   VectEnter
	mov    dword [wherex], 0
	mov    dword [wherey], 16

ExeProcessEvaluate:

	cmp    [span], 0
	je     ExeProcessKeyEnd

	xor    eax, eax
	mov    [lastnumber], eax
	call   Parse
	cmp    byte [token], 0
	je     ExeProcessKeyEnd
	call   FindWord
	cmp    eax, NotFound
	je     ExeProcessRun
	mov    ecx, [lastimm]
	cmp    ecx, 0
	jne    ExeProcessRun
	mov    ecx, [state]
	cmp    ecx, 0
	je     ExeProcessRun

ExeProcessCompile:
	mov    ecx, [Depth]
	mov    [Dstack+ecx*4], eax
	inc    dword [Depth]
	call   ForthCall
	jmp    ExeProcessCleanUp

ExeProcessRun:
	call   eax

ExeProcessCleanUp:

	mov    eax, [TibPtr]
	cmp    eax, [span]
	jl     ExeProcessEvaluate

	mov    eax, 0
	mov    [span], eax
	mov    [TibPtr], eax
	call   ParseClear
	call   TibClear

	jmp    ExeProcessKeyEnd

ExeProcessKey2:

	cmp    al, 32
	jb     ExeProcessKeyNothing  ; 31.08.10 was: jl, and russian symbols becomes LESSER because they have 1 in MSB

	mov    ecx, [span]
	mov    [Tib+ecx], al
	inc    dword [span]

ExeProcessKeyEnd:

	call   VectOk

	call   ViewTib

ExeProcessKeyNothing:

	pop    ebx esi edi

	ret
endp

proc	EvaluateLoaded
	push	ebx esi edi
	jmp	EvaluateString
	ret
endp

proc	EvaluateTib
	push	ebx esi edi
	jmp	EvaluateString
	ret
endp


proc	ProcessEvaluate

ForthEv:
	push	ebx esi edi

	mov	edx, eax
	mov	ecx, Tib
	xor	eax, eax
	mov	ebx, 0
	mov	[ErrSym], eax

MoveString:
	inc	ebx
	cmp	ebx, 255
	je	MoveComplete
	mov	al, [edx]
	mov	[ecx], al
	cmp	byte [edx], 0
	je	MoveComplete
	inc	edx
	inc	ecx
	jmp	MoveString
MoveComplete:

	mov	eax, 0
	mov	[span], eax
	mov	[TibPtr], eax
	mov	eax, Tib
CalcLength:
	cmp	byte [eax], 0
	je	CalcComplete
	inc	eax
	inc	dword [span]
	jmp	CalcLength

CalcComplete:

EvaluateString:

	cmp	byte [Tib], 0	; 1/03/09 - added 'byte'
	je	ProcessKeyEnd

ProcessNextWord:
	xor	eax, eax
	mov	[lastnumber], eax
	call	Parse
	call	FindWord
	cmp	eax, NotFound
	je	ProcessRun
	mov	ecx, [lastimm]
	cmp	ecx, 0
	jne	ProcessRun
	mov	ecx, [state]
	cmp	ecx, 0
	je	ProcessRun
ProcessCompile:
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	call	ForthCall

;       in debug mode, compile <debug> also

	mov	eax, [IsDebug]
	cmp	eax, 0
	je	ProcessCleanUp

	mov	eax, 0xB8	       ; code for MOV EAX, NNNN
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, [cdp]		 ; compile CDP as literal
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	mov	eax, 0xE8	       ; code for CALL
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, StoringEaxIP      ; compile CALL to 'EAX to IP var' code
	sub	eax, [cdp]
	sub	eax, 4
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	mov	eax, CallDebug
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	call	ForthCall


	jmp	ProcessCleanUp

ProcessRun:
	call	eax

ProcessCleanUp:

	mov	eax, [TibPtr]
	cmp	eax, [span]
	jl	ProcessNextWord

	mov	eax, 0
	mov	[span], eax
	mov	[TibPtr], eax
	call	ParseClear
	call	TibClear

ProcessKeyEnd:

;        mov  ecx, [Depth]
;        mov  eax, dword [Dstack+ecx*4-4]

	call	VectOk

	pop	edi esi ebx
	mov	eax, [ErrSym]

	ret
endp


proc	PushingEax
	mov  ecx, [Depth]
	mov  [Dstack+ecx*4], eax
	inc  dword [Depth]
	ret
endp

proc	StoringEaxIP
	mov  ecx, DebugIP
	mov  [ecx], eax
	ret
endp

proc	PushingFLiteral
	fld  qword [eax]
	ret
endp

proc	CheckStack
	dec  dword [Depth]
	mov  eax, [Depth]
	cmp  dword [Dstack+eax*4], 0
	ret
endp

proc	PushSourceContext

	push   edi esi

	mov    edx, [sDepth]

	mov    eax, [TibPtr]
	mov    [hTibPtrs+edx*4], eax
	mov    eax, [span]
	mov    [hSpan+edx*4], eax
	mov    eax, [hSource]
	mov    [hSources+edx*4], eax
	mov    eax, [LineLength]
	mov    [hLineLength+edx*4], eax
	mov    eax, [LineNumber]
	mov    [hLineNumber+edx*4], eax

	mov    ecx, 256
	mov    esi, Tib
	mov    edi, hTibs
	shl    edx, 8
	add    edi, edx
	cld
	repz   movsb

	inc    dword [sDepth]

	pop    edi esi

	ret
endp

proc	PopSourceContext

	push   edi esi

	dec    dword [sDepth]
	mov    edx, [sDepth]

	mov    eax, [hTibPtrs+edx*4]
	mov    [TibPtr], eax
	mov    eax, [hSpan+edx*4]
	mov    [span], eax
	mov    eax, [hSources+edx*4]
	mov    [hSource], eax
	mov    eax, [hLineLength+edx*4]
	mov    [LineLength], eax
	mov    eax, [hLineNumber+edx*4]
	mov    [LineNumber], eax

	mov    ecx, 256
	mov    esi, hTibs
	mov    edi, Tib
	shl    edx, 8
	add    esi, edx
	cld
	repz   movsb

	pop    edi esi

	ret
endp

proc	PushControlFlow 	; eax - code for structure ID
	mov  ecx, [cfDepth]
	mov  [CFstackID+ecx*4], eax
	mov  eax, [cdp]
	mov  [CFstackAddr+ecx*4], eax
	inc  dword [cfDepth]
	ret
endp

proc	CheckCompileMode
	cmp  dword [state], 0
	jne  CompileModeOK
	mov  eax, MsgCompileOnly
	call TypeMessage
	jmp  Abort

CompileModeOK:

	ret
endp

proc	PrintSymbols
	mov  ecx, 0
	mov  [wherex], 0
	mov  [wherey], 0
PrintSymbols0:
	mov  eax, ecx
	and  eax, 0xf0
	mov  [wherey], eax
	mov  eax, ecx
	and  eax, 0x0f
	shl  eax, 3
	mov  [wherex], eax
	mov  al, cl
	call emit1
PrintSym1:
	inc  ecx
	cmp  ecx, 256
	jne  PrintSymbols0
	ret
endp

proc	Eip2ecx
	pop  ecx
	push ecx
	ret
endp

proc	CodeDo2

CodeDo2Start:

	mov  [LStackAddr+edx*4], eax

DO2SIZE 	 = $ - CodeDo2Start

endp

proc	CodeDo

CodeDoStart:

	mov  edx, [lDepth]
	mov  [LStackAddr+edx*4], eax
	mov  ecx, [Depth]
	mov  eax, [Dstack+ecx*4-4]
	mov  [LStackI+edx*4], eax
	mov  eax, [Dstack+ecx*4-8]
	mov  [LStackImax+edx*4], eax
	sub  dword [Depth], 2
	inc  dword [lDepth]

;        mov  [LStackAddr+edx*4-4], eax

DOSIZE		= $ - CodeDoStart

	ret
endp

proc	CodeFor

CodeForStart:

	mov	 edx, [lDepth]
	mov	 [LStackAddr+edx*4], eax
	mov	 ecx, [Depth]
	mov	 eax, [Dstack+ecx*4-4]
	mov	[LStackI+edx*4], 0
	mov	[LStackImax+edx*4], eax
	dec	dword [Depth]
	inc	dword [lDepth]

;        mov  [LStackAddr+edx*4-4], eax

FORSIZE 	 = $ - CodeForStart

	ret
endp

proc	CodeLoop

CodeLoopStart:

	mov	edx, [lDepth]
	inc	dword [LStackI+edx*4-4]
	mov	eax, [LStackI+edx*4-4]
	cmp	eax, [LStackImax+edx*4-4]
	mov	eax, [LStackAddr+edx*4-4]
	je	LoopForward
	jmp	eax

LoopForward:

	dec	dword [lDepth]

LOOPSIZE	= $ - CodeLoopStart

	ret
endp

proc	CodePlusLoop

CodePlusLoopStart:

	mov	eax, [Depth]
	dec	dword [Depth]
	mov	eax, [Dstack+eax*4-4]
	mov	edx, [lDepth]
	add	dword [LStackI+edx*4-4], eax
	mov	eax, [LStackI+edx*4-4]
	inc	eax
	cmp	eax, [LStackImax+edx*4-4]
	mov	eax, [LStackAddr+edx*4-4]
	jnl	PlusLoopForward
	jmp	eax

PlusLoopForward:

	dec	dword [lDepth]

PLUSLOOPSIZE	    = $ - CodePlusLoopStart

	ret
endp

proc	CodeNext

CodeNextStart:

	mov	edx, [lDepth]
	mov	eax, [LStackI+edx*4-4]
	cmp	eax, [LStackImax+edx*4-4]
	mov	eax, [LStackAddr+edx*4-4]
	je	NextForward
	inc	dword [LStackI+edx*4-4]
	jmp	eax

NextForward:

	dec	dword [lDepth]

NEXTSIZE	= $ - CodeNextStart

	ret
endp


proc	CodeTO

CodeTOStart:

	mov	ecx, [Depth]
	mov	edx, [Dstack+ecx*4-4]
	mov	[eax], edx
	dec	dword [Depth]

CODETOSIZE	    = $ - CodeTOStart

	ret
endp

proc	CodePlusTO

CodePlusTOStart:

	mov	ecx, [Depth]
	mov	edx, [Dstack+ecx*4-4]
	add	[eax], edx
	dec	dword [Depth]

CODEPLUSTOSIZE		= $ - CodePlusTOStart

	ret
endp

proc	CodeFROM

CodeFROMStart:

	mov	ecx, [Depth]
	mov	eax, [eax]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]

CODEFROMSIZE	    = $ - CodeFROMStart

	ret
endp

proc	CodeVocabulary

CodeVocabularyStart:

	; словарь получает в eax указатель на структуру
	; 4 байта - указатель на переменную, где лежит точка входа в словарь-родитель
	; 4 байта - точка входа в этот словарь

	; при исполнении словарь делается контекстным

	add	eax, 4
	mov	[Context], eax

CODEVOCABULARYSIZE   = $ - CodeVocabularyStart

	ret
endp

proc	CodeCase

CodeCaseStart:

	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	mov	ecx, [caseDepth]
	mov	[SelectorStack+ecx*4], eax
	dec	dword [Depth]
	inc	dword [caseDepth]

CODECASESIZE	     = $ - CodeCaseStart

	ret
endp

proc	CodeOf

CodeOfStart:

	mov	ecx, [Depth]
	dec	dword [Depth]
	mov	eax, [Dstack+ecx*4-4]
	mov	ecx, [caseDepth]
	cmp	eax, [SelectorStack+ecx*4-4]
	;  jnz
CODEOFSIZE	   = $ - CodeOfStart

	ret
endp

proc	CodeWithinOf

CodeWithinOfStart:

	mov	ecx, [Depth]
	sub	dword [Depth], 2
	mov	eax, [Dstack+ecx*4-8]
	mov	edx, [Dstack+ecx*4-4]
	mov	ecx, [caseDepth]
	cmp	eax, [SelectorStack+ecx*4-4]
	jg	CodeWithinOf1
	cmp	edx, [SelectorStack+ecx*4-4]
	jl	CodeWithinOf1
	xor	eax, eax
	jmp	CodeWithinOf2
CodeWithinOf1:
	mov	eax, 0xffffffff

CodeWithinOf2:
	or	eax, eax
	;  jnz
CODEWITHINOFSIZE	 = $ - CodeWithinOfStart

	ret
endp


proc	CodeEndCase

CodeEndCaseStart:

	dec	dword [caseDepth]

CODEENDCASESIZE 	= $ - CodeEndCaseStart

	ret
endp

proc	CodeEndOf

CodeEndOfStart:

CODEENDOFSIZE	      = $ - CodeEndOfStart

	ret
endp


; *********************************** START *********************************

latest	=  CodeStart

ForthStart:

macro	FWORD	name
	{
	dd	latest - 4
	latest	= $
	db	name
	db	0
	db	0
	}
macro	IMMWORD   name
	{
	dd	latest - 4
	latest	= $
	db	name
	db	0
	db	1
	}
macro	VOCAB	name
	{
	dd	latest - 4
	latest	= $
	db	name
	db	0
	db	2
	}
macro	NUMBER	 name
	{
	dd	latest - 4
	latest	= $
	db	name
	db	0
	db	4
	}
macro	INLINE	 name
	{
	dd	latest - 4
	latest	= $
	db	name
	db	0
	db	8
	}

macro	VECT	name
	{
	dd	latest - 4
	latest	= $
	db	name
	db	0
	db	0
	mov	eax, ForthNoop
	jmp	eax
	ret
	}

macro	PUSHSTACK value
	{
	mov	eax, value
	jmp	PushingEax
	}


; ////////////////////////////////////////////////////////////////////////
;               Start of vocabulary
; ////////////////////////////////////////////////////////////////////////

;       NOTFOUND
	dd	0
	latest	= $
	db	0   ; name
	db	0   ; flags

NotFound:

	mov	al, [token]
	cmp	al, 0x22
	jne	NotFoundNumber
	mov	eax, [smartString]
	cmp	eax, 0
	je	NotFoundNumber

	mov	ecx, 128
	mov	edx, token
NotFoundMoveString:
	mov	al, [edx+1]
	mov	[edx], al
	inc	edx
	dec	ecx
	jnz	NotFoundMoveString

	mov	edx, token
NotFoundToAddr:
	mov	al, [edx]
	cmp	al, 0
	je	NotFoundAddSymbol0
	inc	edx
	jmp	NotFoundToAddr

NotFoundAddSymbol0:

	mov	al, 32
	mov	[edx], al
	inc	edx

NotFoundAddSymbol:

	mov	ecx, [TibPtr]
	mov	al, byte [Tib+ecx]

	inc	dword [TibPtr]
	cmp	al, 0x22
	je	NotFoundClosedByQuote	; right quote must be replaced by 0, this is not necessary when string terminated by CR
	cmp	al, 0x0a
	je	NotFoundAllAdded
	cmp	al, 0x0d
	je	NotFoundAllAdded
	mov	[edx], al
	inc	edx
	jmp	NotFoundAddSymbol

NotFoundClosedByQuote:
	inc edx

NotFoundAllAdded:

	xor	eax, eax
	mov	[edx], al
	jmp	ForthString

NotFoundNumber:

	call	FNumber
	mov	eax, [NumError]
	cmp	eax, 0
	jne	NotFoundError

	mov	eax, [state]
	cmp	eax, 0
	jne	NotFoundFLiteral

	mov	eax,  [lastfloat]
	cmp	eax, 0
	jne	NotFoundOK
	mov	ecx, [Depth]
	mov	eax, [Number]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]

	mov	eax, [CanDispatch]
	cmp	eax, 0
	je	NotFoundNoDispatch

	call	ForthDispatchNumber

NotFoundNoDispatch:

	jmp	NotFoundOK

NotFoundFLiteral:

	mov	eax, dword [lastfloat]
	cmp	eax, 0
	je	NotFoundLiteral

	mov	eax, 0xB8	       ; code for MOV EAX, NNNN
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, [ddp]	       ; compile HERE as literal
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	mov	eax, [ddp]
	fstp	qword [eax]
	add	dword [ddp], 8

	mov	eax, 0xE8	       ; code for CALL
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, PushingFLiteral   ; compile CALL to 'Push FLiteral' code
	sub	eax, [cdp]
	sub	eax, 4
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	jmp	NotFoundOK

NotFoundLiteral:

	mov	eax, 0xB8	       ; code for MOV EAX, NNNN
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, [Number]	       ; compile Number as literal
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	mov	eax, 0xE8	       ; code for CALL
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, PushingEax        ; compile CALL to 'Push EAX' code
	sub	eax, [cdp]
	sub	eax, 4
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	jmp	NotFoundOK

NotFoundError:

	add	[wherey], 16
	mov	[wherex], 0
	mov	eax, [fgcolor]
	push	eax
	mov	eax, [bgcolor]
	push	eax
	mov	[fgcolor], 0x00FF0000
	mov	[bgcolor], 0xFF000000
	call	ViewToken
	mov	[bgcolor], 0x00000000
	mov	eax, '?'
	call	emit1
	pop	eax
	mov	[bgcolor], eax
	pop	eax
	mov	[fgcolor], eax

Abort:

	mov	eax, [TibPtr]
	mov	[ErrSym], eax
	xor	eax, eax
	mov	[Depth], eax	; reset data stack
	mov	[frameDepth], eax
	mov	[localDepth], eax
	mov	[span], eax
	mov	[TibPtr], eax
	mov	[state], eax
	mov	[hSource], eax
	mov	[sDepth], eax	; 03/03/09 !!!

	fninit

	call	ParseClear
	call	TibClear

	mov	ecx, 128
	mov	edx, token
	mov	al, 0

NFParseClear:
	mov	[edx], al
	inc	edx
	dec	ecx
	cmp	ecx, 0
	jne	NFParseClear

	mov	ecx, 128
	mov	edx, Tib
	mov	al, 0

NFTibClear:
	mov	[edx], al
	dec	ecx
	inc	edx
	cmp	ecx, 0
	jne	NFTibClear

NotFoundOK:

	ret

FWORD	'ABORT1'
Abort1:
	jmp	Abort

FWORD	'NOOP'
ForthNoop:
	ret

; FWORD   'REDRAW'
;        invoke  glClear,GL_COLOR_BUFFER_BIT
;
;        mov     eax, 2048
;        sub     eax, [ysize]
;        shl     eax, 13
;        add     eax, screen
;        invoke  glDrawPixels, 2048, [ysize], GL_RGBA, GL_UNSIGNED_BYTE, eax
;        invoke  SwapBuffers,[hdc]
;        ret

FWORD	'REDRAW' ;  --

; 30
	xor	eax, eax
	cmp	eax, [rc.bottom]
	je	Redraw0
	mov	eax, [rc.right]
	call	PushingEax
	mov	eax, [rc.bottom]
	call	PushingEax
GLRedraw:
	push	esi
	push	edi
	push	ebx

	invoke	glClear, GL_COLOR_BUFFER_BIT

	mov	ecx, [Depth]
	mov	edx, [Dstack+ecx*4-4]

	mov	eax, [draw2d]
	cmp	eax, 0
	je	RedrawNo2D

	mov	ebx, 0
Redraw1:
	; calculating 'from' address   screen + 8192*(height - edx)
	mov	ecx, [Depth]
	mov	eax, ebx
	shl	eax, 13
	add	eax, screen
	mov	esi, eax
	; calculating 'to' address     screen + 16 Mb + width*4*(edx-1)
	mov	eax, [Dstack+ecx*4-8]
	shl	eax, 2
	dec	edx
	push	edx
	mul	edx
	pop	edx
	add	eax, screen
	add	eax, 16777216
	mov	edi, eax
	mov	ecx, [Dstack+ecx*4-8]
	rep	movsd
	inc	ebx
	cmp	edx, 0
	jne	Redraw1
	sub	dword [Depth], 2

	pop	ebx
	pop	edi
	pop	esi

	mov	eax, screen
	add	eax, 16777216
	invoke	glDrawPixels, [rc.right], [rc.bottom], GL_BGRA, GL_UNSIGNED_BYTE, eax

RedrawNo2D:
	call	GL3D

	invoke	SwapBuffers,[hdc]

Redraw0:

	ret


FWORD	'$'
	mov	eax, [rc.right]
	call	PushingEax
	mov	eax, [rc.bottom]
	call	PushingEax
	call	GLRedraw
	call	ProcessTimer
	invoke	GetMessage, msg, NULL, 0, 0
	or	eax, eax
	jz	end_loop
	invoke	TranslateMessage, msg
	invoke	DispatchMessage, msg

	ret

FWORD	'GLINIT'
	push	esi
	push	edi
	invoke	GetDC, [hwnd]
	mov	[hdc], eax
	mov	edi, pfd
	mov	ecx, sizeof.PIXELFORMATDESCRIPTOR shr 2
	xor	eax, eax
	rep	stosd
	mov	[pfd.nSize], sizeof.PIXELFORMATDESCRIPTOR
	mov	[pfd.nVersion], 1
	mov	[pfd.dwFlags], PFD_SUPPORT_OPENGL+PFD_DOUBLEBUFFER+PFD_DRAW_TO_WINDOW
	mov	[pfd.dwLayerMask], PFD_MAIN_PLANE
	mov	[pfd.iPixelType], PFD_TYPE_RGBA
	mov	[pfd.cColorBits], 32
	mov	[pfd.cDepthBits], 16
	mov	[pfd.cAccumBits], 0
	mov	[pfd.cStencilBits], 0
	invoke	ChoosePixelFormat, [hdc], pfd
	invoke	SetPixelFormat, [hdc], eax, pfd
	invoke	wglCreateContext, [hdc]
	mov	[hrc], eax
	invoke	wglMakeCurrent, [hdc], [hrc]
	invoke	GetClientRect, [hwnd], rc
	invoke	glViewport, 0, 0, [rc.right], [rc.bottom]
	pop	edi
	pop	esi
	ret

FWORD	'3DINIT'
;        invoke  glLoadIdentity
	invoke	glOrtho, -1.0, 1.0, -1.0, 1.0, 3.0, 10.0
	ret


FWORD	'glFrustum'
	invoke glFrustum, -1.0, 1.0, -1.0, 1.0, 3.0, 10.0
	ret

FWORD	'3DROTATE'
	invoke	glRotatef, [RotateAngle], [glX], [glY], [glZ]
	ret

FWORD	'3DTRANSLATE'
	invoke	glTranslatef, [glX], [glY], [glZ]
	ret

FWORD	'3DSCALE'
	invoke	glScalef, [glX], [glY], [glZ]
	ret

FWORD	'INPUTDIALOG' ; -- N
ForthInputDialog:
	push	ebx
	push	esi
	push	edi
	mov	eax, 1
	mov	[BtnNumber], eax
	invoke	GetModuleHandle, 0
	invoke	DialogBoxParam, eax, 37, [hwnd], DialogProc, 0
	mov	ecx, [Depth]
	mov	eax, [BtnNumber]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	pop	edi
	pop	esi
	pop	ebx
	ret

FWORD	'INPUT' ; ( addr -- )
ForthInput:
	call	InputClear
	call	ForthInputDialog
	mov	ecx, [Depth]
	mov	ecx, [Dstack+ecx*4-4]
	dec	dword [Depth]
	cmp	ecx, 0
	je	ForthInputEnd
	mov	eax, inputbuf
	call	SetToken
	call	NumberEntry
	mov	eax, [NumError]
	cmp	eax, 0
	jne	ForthInput
	mov	eax, [Number]
	mov	ecx, [Depth]
	mov	ecx, [Dstack+ecx*4-4]
	mov	[ecx], eax
ForthInputEnd:
	dec	dword [Depth]
	ret


FWORD	'FINPUT' ; ( addr -- )
ForthFInput:
	call	InputClear
	call	ForthInputDialog
	mov	ecx, [Depth]
	mov	ecx, [Dstack+ecx*4-4]
	dec	dword [Depth]
	cmp	ecx, 0
	je	ForthFInputEnd
	mov	eax, inputbuf
	call	SetToken
	call	FNumberEntry
	mov	eax, [NumError]
	cmp	eax, 0
	jne	ForthFInput
	mov	ecx, [Depth]
	mov	ecx, [Dstack+ecx*4-4]
	fstp	qword [ecx]
ForthFInputEnd:
	dec	dword [Depth]
	ret

FWORD	'SINPUT' ; ( addr -- )
ForthSInput:
	call	InputClear
	call	ForthInputDialog
	mov	ecx, [Depth]
	mov	ecx, [Dstack+ecx*4-4]
	dec	dword [Depth]
	cmp	ecx, 0
	je	ForthSInputEnd
	mov	eax, inputbuf
	call	PushingEax
	call	ForthSwap
	call	ForthSmove

ForthSInputEnd:
	ret

FWORD	'DUP'
	mov	eax, [Depth]
	mov	ecx, [Dstack+eax*4-4]
	mov	[Dstack+eax*4], ecx
	inc	dword [Depth]
	ret

FWORD	'2DUP'
	mov	eax, [Depth]
	mov	ecx, [Dstack+eax*4-8]
	mov	[Dstack+eax*4], ecx
	mov	ecx, [Dstack+eax*4-4]
	mov	[Dstack+eax*4+4], ecx
	add	dword [Depth], 2
	ret

INLINE	'DROP'
	dec	[Depth]
	ret

INLINE	'2DROP'
	sub	[Depth], 2
	ret

INLINE	'3DROP'
	sub	[Depth], 3
	ret

INLINE	'4DROP'
	sub	[Depth], 4
	ret

INLINE	'5DROP'
	sub	[Depth], 5
	ret


FWORD	'SWAP'
ForthSwap:
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	mov	edx, [Dstack+ecx*4-8]
	mov	[Dstack+ecx*4-8], eax
	mov	[Dstack+ecx*4-4], edx
	ret

FWORD	'OVER'
	mov	eax, [Depth]
	mov	ecx, [Dstack+eax*4-8]
	mov	[Dstack+eax*4], ecx
	inc	dword [Depth]
	ret

FWORD	'2OVER'
	mov	eax, [Depth]
	mov	ecx, [Dstack+eax*4-16]
	mov	[Dstack+eax*4], ecx
	mov	ecx, [Dstack+eax*4-12]
	mov	[Dstack+eax*4+4], ecx
	add	dword [Depth], 2
	ret

FWORD	'ROT'	; a b c -- b c a
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	xchg	eax, [Dstack+ecx*4-8]
	xchg	eax, [Dstack+ecx*4-12]
	mov	[Dstack+ecx*4-4], eax
	ret

FWORD	'NIP'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	mov	[Dstack+ecx*4-8], eax
	dec	dword [Depth]
	ret

FWORD	'PICK'
	mov	ecx, [Depth]
	mov	edx, [Dstack+ecx*4-4]
	sub	ecx, edx
	mov	eax, [Dstack+ecx*4-8]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4-4], eax
	ret

FWORD	'XCHG'
	mov	ecx, [Depth]
	mov	edx, [Dstack+ecx*4-4]
	mov	eax, [Dstack+ecx*4-8]
	sub	ecx, edx
	xchg	eax, [Dstack+ecx*4-8]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4-8], eax
	dec	dword [Depth]
	ret

FWORD	'>R'
	dec	dword [Depth]
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4]
	pop	ecx
	push	eax
	push	ecx
	ret

FWORD	'R>'
	pop	ecx
	pop	eax
	push	ecx
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'R@'
	pop	ecx
	pop	eax
	push	eax
	push	ecx
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'RDROP'
	pop	ecx
	pop	eax
	push	ecx
	ret

FWORD	'EXIT'
	pop	ecx
	pop	eax
	push	ecx
	ret

FWORD	'TRUE'
	 mov	 eax,[Depth]
	 mov	 dword [Dstack+eax*4], 0xFFFFFFFF
	 inc	 dword [Depth]
	 ret

FWORD	'FALSE'
	 mov	 eax,[Depth]
	 mov	 dword [Dstack+eax*4], 0
	 inc	 dword [Depth]
	 ret

; NUMBER  '0'
; code_0: mov     eax,[Depth]
;         mov     dword [Dstack+eax*4], 0
;         inc     eax
;         mov     [Depth], eax

;         mov     eax, [CanDispatch]
;         cmp     eax, 0
;         je      code_0_no
;         mov     eax, [state]
;         cmp     eax, 0
;         jne     code_0_no

;         call    ForthDispatchNumber

; code_0_no:

;         ret

; NUMBER  '1'
; code_1:
;         mov     eax,[Depth]
;         mov     dword [Dstack+eax*4], 1
;         inc     dword [Depth]
;         mov     eax, [CanDispatch]
;         cmp     eax, 0
;         je      code_1_no
;         mov     eax, [state]
;         cmp     eax, 0
;         jne     code_1_no

;         call    ForthDispatchNumber

; code_1_no:
;         ret

; NUMBER  '2'
; code_2:
;         mov     eax,[Depth]
;         mov     dword [Dstack+eax*4], 2
;         inc     dword [Depth]
;         mov     eax, [CanDispatch]
;         cmp     eax, 0
;         je      code_2_no
;         mov     eax, [state]
;         cmp     eax, 0
;         jne     code_2_no

;         call    ForthDispatchNumber

; code_2_no:
;         ret

; NUMBER  '3'
;         mov     eax,[Depth]
;         mov     dword [Dstack+eax*4], 3
;         inc     dword [Depth]
;         mov     eax, [CanDispatch]
;         cmp     eax, 0
;         je      code_3_no
;         mov     eax, [state]
;         cmp     eax, 0
;         jne     code_3_no

;         call    ForthDispatchNumber

; code_3_no:
;         ret

; NUMBER  '4'
;         mov     eax,[Depth]
;         mov     dword [Dstack+eax*4], 4
;         inc     dword [Depth]
;         mov     eax, [CanDispatch]
;         cmp     eax, 0
;         je      code_4_no
;         mov     eax, [state]
;         cmp     eax, 0
;         jne     code_4_no

;         call    ForthDispatchNumber

; code_4_no:
;         ret

NUMBER	'RED'
	mov	eax,[Depth]
	mov	dword [Dstack+eax*4], 0x000000ff
	inc	dword [Depth]
	ret

NUMBER	'GREEN'
	mov	eax,[Depth]
	mov	dword [Dstack+eax*4], 0x0000ff00
	inc	dword [Depth]
	ret

NUMBER	'BLUE'
	mov	eax,[Depth]
	mov	dword [Dstack+eax*4], 0x00ff0000
	inc	dword [Depth]
	ret

NUMBER	'BLACK'
	mov	eax,[Depth]
	mov	dword [Dstack+eax*4], 0x00000000
	inc	dword [Depth]
	ret

NUMBER	'WHITE'
	mov	eax,[Depth]
	mov	dword [Dstack+eax*4], 0x00ffffff
	inc	dword [Depth]
	ret

NUMBER	'1.0'
	fld1
	mov	eax, [CanDispatch]
	cmp	eax, 0
	je	code_f10_no
	mov	eax, [state]
	cmp	eax, 0
	jne	code_f10_no

	call	ForthDispatchFNumber

code_f10_no:
	ret

FWORD	'RGB'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	shl	eax, 16
	mov	edx, [Dstack+ecx*4-8]
	and	edx, 0xFF
	shl	edx, 8
	or	eax, edx
	mov	edx, [Dstack+ecx*4-12]
	and	edx, 0xFF
	or	eax, edx
	sub	dword [Depth], 2
	mov	[Dstack+ecx*4-12], eax
	ret

FWORD	'BYTES'
	ret

FWORD	'WORDS'
	mov	eax, [Depth]
	shl	dword [Dstack+eax*4-4], 1
	ret

FWORD	'CELLS'
	mov	eax,[Depth]
	shl	dword [Dstack+eax*4-4], 2
	ret

FWORD	'FLOATS'
	mov	eax,[Depth]
	shl	dword [Dstack+eax*4-4], 3
	ret

FWORD	'kb'
	mov	eax,[Depth]
	shl	dword [Dstack+eax*4-4], 10
	ret

FWORD	'Mb'
	mov	eax,[Depth]
	shl	dword [Dstack+eax*4-4], 20
	ret

FWORD	'+'
code_plus:
	mov	eax, [Depth]
	dec	eax
	mov	ecx, [Dstack+eax*4]
	add	[Dstack-4+eax*4], ecx
	mov	[Depth], eax
	ret

FWORD	'D+'
code_dplus:
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	add	eax, [Dstack+ecx*4-12]
	mov	[Dstack+ecx*4-12], eax
	mov	eax, [Dstack+ecx*4-8]
	adc	eax, [Dstack+ecx*4-16]
	mov	[Dstack+ecx*4-16], eax
	sub	dword [Depth], 2
	ret

FWORD	'-'
	mov	eax, [Depth]
	dec	eax
	mov	ecx, [Dstack+eax*4]
	sub	[Dstack-4+eax*4], ecx
	mov	[Depth], eax
	ret

FWORD	'D-'
code_dminus:
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-12]
	sub	eax, [Dstack+ecx*4-4]
	mov	[Dstack+ecx*4-12], eax
	mov	eax, [Dstack+ecx*4-16]
	sbb	eax, [Dstack+ecx*4-8]
	mov	[Dstack+ecx*4-16], eax
	sub	dword [Depth], 2
	ret

FWORD	'1+'
	mov	eax, [Depth]
	inc	dword [Dstack+eax*4-4]
	ret

FWORD	'1-'
	mov	eax, [Depth]
	dec	dword [Dstack+eax*4-4]
	ret

FWORD	'CELL+'
	mov	eax, [Depth]
	add	dword [Dstack+eax*4-4], 4
	ret

FWORD	'CELL-'
	mov	eax, [Depth]
	sub	dword [Dstack+eax*4-4], 4
	ret

FWORD	'FCELL+'
	mov	eax, [Depth]
	add	dword [Dstack+eax*4-4], 8
	ret

FWORD	'FCELL-'
	mov	eax, [Depth]
	sub	dword [Dstack+eax*4-4], 8
	ret

FWORD	'*'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	mul	dword [Dstack+ecx*4-8]
	mov	[Dstack+ecx*4-8], eax
	dec	dword [Depth]
	ret

FWORD	'U*'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	imul	dword [Dstack+ecx*4-8]
	mov	[Dstack+ecx*4-8], eax
	dec	dword [Depth]
	ret

FWORD	'/'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-8]
	cdq
	idiv	dword [Dstack+ecx*4-4]
	mov	[Dstack+ecx*4-8], eax
	dec	dword [Depth]
	ret

FWORD	'U/'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-8]
	mov	edx, 0 ;  cdq
	div	dword [Dstack+ecx*4-4]
	mov	[Dstack+ecx*4-8], eax
	dec	dword [Depth]
	ret

FWORD	'2*'
	mov	eax, [Depth]
	shl	dword [Dstack+eax*4-4], 1
	ret

FWORD	'2/'
	mov	eax, [Depth]
	shr	dword [Dstack+eax*4-4], 1
	ret

FWORD	'MOD'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-8]
	cdq
	idiv	dword [Dstack+ecx*4-4]
	mov	[Dstack+ecx*4-8], edx
	dec	dword [Depth]
	ret

FWORD	'UMOD'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-8]
	mov	edx, 0
	div	dword [Dstack+ecx*4-4]
	mov	[Dstack+ecx*4-8], edx
	dec	dword [Depth]
	ret

FWORD	'/MOD'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-8]
	cdq
	idiv	dword [Dstack+ecx*4-4]
	mov	[Dstack+ecx*4-8], eax
	mov	[Dstack+ecx*4-4], edx
	ret

FWORD	'U/MOD'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-8]
	mov	edx, 0
	div	dword [Dstack+ecx*4-4]
	mov	[Dstack+ecx*4-8], eax
	mov	[Dstack+ecx*4-4], edx
	ret

FWORD	'AND'
	mov	eax, [Depth]
	dec	eax
	mov	ecx, [Dstack+eax*4]
	and	[Dstack+eax*4-4], ecx
	mov	[Depth], eax
	ret

FWORD	'OR'
	mov	eax, [Depth]
	dec	eax
	mov	ecx, [Dstack+eax*4]
	or	[Dstack+eax*4-4], ecx
	mov	[Depth], eax
	ret

FWORD	'XOR'
	mov	eax, [Depth]
	dec	eax
	mov	ecx, [Dstack+eax*4]
	xor	[Dstack+eax*4-4], ecx
	mov	[Depth], eax
	ret

FWORD	'SHL'
	mov	 ecx, [Depth]
	shl	 [Dstack+ecx*4-4], 1
	ret

FWORD	'SHLA'
	mov	 ecx, [Depth]
	sal	 [Dstack+ecx*4-4], 1
	ret

FWORD	'SHR'
	mov	 ecx, [Depth]
	shr	 [Dstack+ecx*4-4], 1
	ret

FWORD	'SHRA'
	mov	 ecx, [Depth]
	sar	 [Dstack+ecx*4-4], 1
	ret

FWORD	'LSHIFT' ; x, count -- y
	mov	 eax, [Depth]
	mov	 ecx, [Dstack+eax*4-4]
	shl	 [Dstack+eax*4-8], cl
	dec	 dword [Depth]
	ret

FWORD	'RSHIFT' ; x, count -- y
	mov	 eax, [Depth]
	mov	 ecx, [Dstack+eax*4-4]
	shr	 [Dstack+eax*4-8], cl
	dec	 dword [Depth]
	ret

FWORD	'<<' ; x, count -- y
	mov	 eax, [Depth]
	mov	 ecx, [Dstack+eax*4-4]
	shl	 [Dstack+eax*4-8], cl
	dec	 dword [Depth]
	ret

FWORD	'>>' ; x, count -- y
	mov	 eax, [Depth]
	mov	 ecx, [Dstack+eax*4-4]
	shr	 [Dstack+eax*4-8], cl
	dec	 dword [Depth]
	ret

FWORD	'NEGATE'
	mov	ecx, [Depth]
	neg	dword [Dstack+ecx*4-4]
	ret

FWORD	'ABS'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	test	eax, 0x80000000
	jz	Abs1
	neg	eax
	mov	[Dstack+ecx*4-4], eax
Abs1:
	ret

FWORD	'SGN'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	cmp	eax, 0
	jne	Forth_sgn_1
	mov	edx, 0
	jmp	Forth_sgn_end
Forth_sgn_1:
	test	eax, 0x80000000
	jnz	Forth_sgn_minus
	mov	edx, 1
	jmp	Forth_sgn_end
Forth_sgn_minus:
	mov	edx, 0xFFFFFFFF
Forth_sgn_end:
	mov	[Dstack+ecx*4-4], edx
	ret

FWORD	'NOT'
	mov	ecx, [Depth]
	mov	edx, 0xFFFFFFFF
	mov	eax, [Dstack+ecx*4-4]
	cmp	eax, 0
	je	Not1
	mov	edx, 0
Not1:
	mov	[Dstack+ecx*4-4], edx
	ret

FWORD	'WITHIN'  ; x low high -- T
	mov	ecx, [Depth]
	mov	edx, 0xFFFFFFFF
	mov	eax, [Dstack+ecx*4-12]
	cmp	eax, [Dstack+ecx*4-8]
	jge	Within1
	mov	edx, 0

Within1:
	cmp	eax, [Dstack+ecx*4-4]
	jle	Within2
	mov	edx, 0
Within2:
	mov	[Dstack+ecx*4-12], edx
	sub	dword [Depth], 2
	ret

FWORD	'RANDOMIZE'
	invoke	GetTickCount
	mov	[rnd], eax
	ret

FWORD	'RANDOM'
;        69069 * 31415 + 278720333 MOD
	mov	eax, [rnd]
	mov	ecx, 69069
	imul	ecx
	add	eax, 31415
	cdq
	mov	ecx, 278720333
	idiv	ecx
	mov	[rnd], edx
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], edx
	inc	dword [Depth]
	ret

FWORD	'='
	mov  ecx, [Depth]
	mov  eax, [Dstack+ecx*4-4]
	cmp  eax, [Dstack+ecx*4-8]
	je   ForthEqualYes
	xor  eax, eax
	jmp  ForthEqualEnd

ForthEqualYes:

	mov  eax, 0xffffffff

ForthEqualEnd:

	mov  [Dstack+ecx*4-8], eax
	dec  dword [Depth]

	ret

FWORD	'<>'
	mov  ecx, [Depth]
	mov  eax, [Dstack+ecx*4-4]
	cmp  eax, [Dstack+ecx*4-8]
	jne  ForthNEqualYes
	xor  eax, eax
	jmp  ForthNEqualEnd

ForthNEqualYes:

	mov  eax, 0xffffffff

ForthNEqualEnd:

	mov  [Dstack+ecx*4-8], eax
	dec  dword [Depth]

	ret

FWORD	'>'
	mov  ecx, [Depth]
	mov  eax, [Dstack+ecx*4-8]
	cmp  eax, [Dstack+ecx*4-4]
	jg   ForthGreaterYes
	xor  eax, eax
	jmp  ForthGreaterEnd

ForthGreaterYes:

	mov  eax, 0xffffffff

ForthGreaterEnd:

	mov  [Dstack+ecx*4-8], eax
	dec  dword [Depth]

	ret

FWORD	'<'
	mov  ecx, [Depth]
	mov  eax, [Dstack+ecx*4-8]
	cmp  eax, [Dstack+ecx*4-4]
	jl   ForthLesserYes
	xor  eax, eax
	jmp  ForthLesserEnd

ForthLesserYes:

	mov  eax, 0xffffffff

ForthLesserEnd:

	mov  [Dstack+ecx*4-8], eax
	dec  dword [Depth]

	ret

FWORD	'>='
	mov  ecx, [Depth]
	mov  eax, [Dstack+ecx*4-8]
	cmp  eax, [Dstack+ecx*4-4]
	jge  ForthGreaterEqualYes
	xor  eax, eax
	jmp  ForthGreaterEqualEnd

ForthGreaterEqualYes:

	mov  eax, 0xffffffff

ForthGreaterEqualEnd:

	mov  [Dstack+ecx*4-8], eax
	dec  dword [Depth]

	ret

FWORD	'<='
	mov  ecx, [Depth]
	mov  eax, [Dstack+ecx*4-8]
	cmp  eax, [Dstack+ecx*4-4]
	jle  ForthLesserEqualYes
	xor  eax, eax
	jmp  ForthLesserEqualEnd

ForthLesserEqualYes:

	mov  eax, 0xffffffff

ForthLesserEqualEnd:

	mov  [Dstack+ecx*4-8], eax
	dec  dword [Depth]

	ret

FWORD	'U>'
	mov  ecx, [Depth]
	mov  eax, [Dstack+ecx*4-8]
	cmp  eax, [Dstack+ecx*4-4]
	ja   ForthUGreaterYes
	xor  eax, eax
	jmp  ForthUGreaterEnd

ForthUGreaterYes:

	mov  eax, 0xffffffff

ForthUGreaterEnd:

	mov  [Dstack+ecx*4-8], eax
	dec  dword [Depth]

	ret

FWORD	'U<'
	mov  ecx, [Depth]
	mov  eax, [Dstack+ecx*4-8]
	cmp  eax, [Dstack+ecx*4-4]
	jb   ForthULesserYes
	xor  eax, eax
	jmp  ForthULesserEnd

ForthULesserYes:

	mov  eax, 0xffffffff

ForthULesserEnd:

	mov  [Dstack+ecx*4-8], eax
	dec  dword [Depth]

	ret

FWORD	'MIN'
	mov   ecx, [Depth]
	mov   eax, [Dstack+ecx*4-4]
	mov   edx, [Dstack+ecx*4-8]
	cmp   eax, edx
	cmovg eax, edx
	mov   [Dstack+ecx*4-8], eax
	dec   dword [Depth]
	ret

FWORD	'MAX'
	mov   ecx, [Depth]
	mov   eax, [Dstack+ecx*4-4]
	mov   edx, [Dstack+ecx*4-8]
	cmp   eax, edx
	cmovl eax, edx
	mov   [Dstack+ecx*4-8], eax
	dec   dword [Depth]
	ret

FWORD	'RANGE'   ; number, low, high -- ranged_number
	mov   ecx, [Depth]
	mov   eax, [Dstack+ecx*4-12]
	mov   edx, [Dstack+ecx*4-8]
	cmp   eax, edx
	cmovl eax, edx
	mov   edx, [Dstack+ecx*4-4]
	cmp   eax, edx
	cmovg eax, edx
	mov   [Dstack+ecx*4-12], eax
	sub   dword [Depth], 2
	ret

FWORD	'UMIN'
	mov   ecx, [Depth]
	mov   eax, [Dstack+ecx*4-4]
	mov   edx, [Dstack+ecx*4-8]
	cmp   eax, edx
	cmova eax, edx
	mov   [Dstack+ecx*4-8], eax
	dec   dword [Depth]
	ret

FWORD	'UMAX'
	mov   ecx, [Depth]
	mov   eax, [Dstack+ecx*4-4]
	mov   edx, [Dstack+ecx*4-8]
	cmp   eax, edx
	cmovb eax, edx
	mov   [Dstack+ecx*4-8], eax
	dec   dword [Depth]
	ret

FWORD	'URANGE'   ; number, low, high -- ranged_number
	mov   ecx, [Depth]
	mov   eax, [Dstack+ecx*4-12]
	mov   edx, [Dstack+ecx*4-8]
	cmp   eax, edx
	cmovb eax, edx
	mov   edx, [Dstack+ecx*4-4]
	cmp   eax, edx
	cmova eax, edx
	mov   [Dstack+ecx*4-12], eax
	sub   dword [Depth], 2
	ret

FWORD	'@'
	mov eax, [Depth]
	mov ecx, [Dstack+eax*4-4]
	mov ecx, [ecx]
	mov [Dstack+eax*4-4],ecx
	ret

FWORD	'!'
	mov eax, [Depth]
	mov ecx, [Dstack+eax*4-4]
	mov eax, [Dstack+eax*4-8]
	mov [ecx], eax
	sub dword [Depth], 2
	ret

FWORD	'+!'
	mov	eax, [Depth]
	mov	ecx, [Dstack+eax*4-4]
	mov	eax, [Dstack+eax*4-8]
	add	[ecx], eax
	sub	dword [Depth], 2
	ret

FWORD	'ON'
	dec	dword [Depth]
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4]
	mov	dword [eax], 0xFFFFFFFF
	ret

FWORD	'OFF'
	dec	dword [Depth]
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4]
	mov	dword [eax], 0
	ret

FWORD	','
	mov	eax, [Depth]
	dec	eax
	mov	ecx, [Dstack+eax*4]
	mov	edx, [ddp]
	mov	[edx], ecx
	mov	[Depth], eax
	add	dword [ddp], 4
	ret

FWORD	'F,'
	mov	eax, [ddp]
	fstp	qword [eax]
	add	dword [ddp], 8
	ret

FWORD	'SF,'
	mov	eax, [ddp]
	fstp	dword [eax]
	add	dword [ddp], 4
	ret



FWORD	'C@'
	mov	eax, [Depth]
	mov	ecx, [Dstack-4+eax*4]
	mov	cl, [ecx]
	and	ecx, 0xFF
	mov	[Dstack-4+eax*4],ecx
	ret

FWORD	'C!'
	mov	eax, [Depth]
	mov	ecx, [Dstack-4+eax*4]
	mov	eax, [Dstack-8+eax*4]
	mov	[ecx], al
	sub	dword [Depth], 2
	ret

FWORD	'C,'
	mov	eax, [Depth]
	dec	eax
	mov	ecx, [Dstack+eax*4]
	mov	edx, [ddp]
	mov	[edx], cl
	mov	[Depth], eax
	inc	dword [ddp]
	ret

FWORD	'[C]@'
	mov	eax, [Depth]
	mov	ecx, [Dstack-4+eax*4]
	mov	ecx, [ecx]
	mov	[Dstack-4+eax*4],ecx
	ret

FWORD	'[C]!'
	mov	eax, [Depth]
	mov	ecx, [Dstack-4+eax*4]
	mov	eax, [Dstack-8+eax*4]
	mov	[ecx], eax
	sub	dword [Depth], 2
	ret

FWORD	'[C],'
	mov	eax, [Depth]
	dec	eax
	mov	ecx, [Dstack+eax*4]
	mov	edx, [cdp]
	mov	[edx], ecx
	mov	[Depth], eax
	add	dword [cdp], 4
	ret

FWORD	'[C]C@'
	mov	eax, [Depth]
	mov	ecx, [Dstack-4+eax*4]
	mov	cl, [ecx]
	and	ecx, 0xFF
	mov	[Dstack-4+eax*4],ecx
	ret

FWORD	'[C]C!'
	mov	eax, [Depth]
	mov	ecx, [Dstack-4+eax*4]
	mov	eax, [Dstack-8+eax*4]
	mov	[ecx], al
	sub	dword [Depth], 2
	ret

FWORD	'[C]C,'
	mov	eax, [Depth]
	dec	eax
	mov	ecx, [Dstack+eax*4]
	mov	edx, [cdp]
	mov	[edx], cl
	mov	[Depth], eax
	inc	dword [cdp]
	ret

FWORD	'W@'
	mov	eax, [Depth]
	mov	ecx, [Dstack-4+eax*4]
	mov	cx, [ecx]
	and	ecx, 0xFFFF
	mov	[Dstack-4+eax*4],ecx
	ret

FWORD	'W!'
	mov	eax, [Depth]
	mov	ecx, [Dstack-4+eax*4]
	mov	eax, [Dstack-8+eax*4]
	mov	[ecx], ax
	sub	dword [Depth], 2
	ret

FWORD	'W,'
	mov	eax, [Depth]
	dec	eax
	mov	ecx, [Dstack+eax*4]
	mov	edx, [ddp]
	mov	[edx], cx
	mov	[Depth], eax
	add	dword [ddp], 2
	ret

FWORD	'W>D'
	mov	ecx, [Depth]
	dec	ecx
	mov	eax, [Dstack+ecx*4]
	cwd
	mov	[Dstack+ecx*4], eax
	ret

FWORD	'-TH'	; arr, index -- index*4 + arr
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	shl	eax, 2
	add	eax, [Dstack+ecx*4-8]
	mov	[Dstack+ecx*4-8], eax
	dec	dword [Depth]
	ret

FWORD	'-FTH'	 ; arr, index -- index*8 + arr
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	shl	eax, 3
	add	eax, [Dstack+ecx*4-8]
	mov	[Dstack+ecx*4-8], eax
	dec	dword [Depth]
	ret

FWORD	'CMOVE'  ; src dest size_bytes
	cld			       ; build 28
	push	esi
	push	edi
	mov	edx, [Depth]
	mov	ecx, [Dstack+edx*4-4]
	mov	edi, [Dstack+edx*4-8]
	mov	esi, [Dstack+edx*4-12]
	repz	movsb
	pop	edi
	pop	esi
	sub	dword [Depth], 3
	ret

FWORD	'MOVE'	; src dest size_dwords
	cld			       ; build 28
	push	esi
	push	edi
	mov	edx, [Depth]
	mov	ecx, [Dstack+edx*4-4]
	mov	edi, [Dstack+edx*4-8]
	mov	esi, [Dstack+edx*4-12]
	repz	movsd
	pop	edi
	pop	esi
	sub	dword [Depth], 3
	ret

FWORD	'CMOVE<'  ; src dest size_bytes
	std
	push	esi
	push	edi
	mov	edx, [Depth]
	mov	ecx, [Dstack+edx*4-4]
	mov	edi, [Dstack+edx*4-8]
	mov	esi, [Dstack+edx*4-12]
	add	edi, ecx
	add	esi, ecx
	dec	edi
	dec	esi
	repz	movsb
	pop	edi
	pop	esi
	sub	dword [Depth], 3
	ret

FWORD	'MOVE<'  ; src dest size_dwords
	std
	push	esi
	push	edi
	mov	edx, [Depth]
	mov	ecx, [Dstack+edx*4-4]
	mov	edi, [Dstack+edx*4-8]
	mov	esi, [Dstack+edx*4-12]
	add	edi, ecx
	add	esi, ecx
	sub	edi, 4
	sub	esi, 4
	repz	movsb
	pop	edi
	pop	esi
	sub	dword [Depth], 3
	ret

FWORD	'SMOVE'  ; src dest
ForthSmove:
	push	esi
	push	edi
	mov	eax, [Depth]
	mov	edi, [Dstack+eax*4-4]
	mov	esi, [Dstack+eax*4-8]

	cld

SmoveNext:
	mov	al, [esi]
	movsb
	cmp	al, 0
	je	SmoveEnd
	jmp	SmoveNext

SmoveEnd:
	pop	edi
	pop	esi
	sub	dword [Depth], 2
	ret

FWORD	'S='   ; s1, s2 -- F
	cld			       ; build 28
	push	esi
	push	edi
	mov	eax, [Depth]
	mov	edi, [Dstack+eax*4-4]
	mov	esi, [Dstack+eax*4-8]
	mov	ecx, 0
SFindEndStr:
	cmp	byte [esi+ecx], 0
	je	SFindEndHere
	inc	ecx
	jmp	SFindEndStr
SFindEndHere:
	repz	cmpsb
	mov	ecx, 0
	mov	ebx, 0xffffffff
	cmove	ecx, ebx
	mov	[Dstack+eax*4-8], ecx

	pop	edi
	pop	esi
	dec	dword [Depth]

	ret

FWORD	'CCOMPARE'   ; A1, A2, COUNT -- F
	cld			       ; build 28
	push	esi
	push	edi
	mov	eax, [Depth]
	mov	ecx, [Dstack+eax*4-4]
	mov	edi, [Dstack+eax*4-8]
	mov	esi, [Dstack+eax*4-12]

	repz	cmpsb
	mov	ecx, 0
	mov	ebx, 0xffffffff
	cmove	ecx, ebx
	mov	[Dstack+eax*4-12], ecx

	pop	edi
	pop	esi
	sub	dword [Depth], 2

	ret

FWORD	'COMPARE'   ; A1, A2, COUNT -- F
	cld			       ; build 28
	push	esi
	push	edi
	mov	eax, [Depth]
	mov	ecx, [Dstack+eax*4-4]
	mov	edi, [Dstack+eax*4-8]
	mov	esi, [Dstack+eax*4-12]

	repz	cmpsd
	mov	ecx, 0
	mov	ebx, 0xffffffff
	cmove	ecx, ebx
	mov	[Dstack+eax*4-12], ecx

	pop	edi
	pop	esi
	sub	dword [Depth], 2

	ret

FWORD	'FILL' ; d addr len --
	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-12]
	mov	ecx, [Dstack+edx*4-4]
	mov	edx, [Dstack+edx*4-8]
Fill1:
	cmp	ecx, 0
	je	Fill2
	mov	[edx], eax
	dec	ecx
	add	edx, 4
	jmp	Fill1

Fill2:
	sub	dword [Depth], 3
	ret

FWORD	'CFILL' ; d addr len --
	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-12]
	mov	ecx, [Dstack+edx*4-4]
	mov	edx, [Dstack+edx*4-8]
CFill1:
	cmp	ecx, 0
	je	CFill2
	mov	[edx], al
	dec	ecx
	inc	edx
	jmp	CFill1

CFill2:
	sub	dword [Depth], 3
	ret

FWORD	'DEPTH'
	mov	eax, [Depth]
	mov	[Dstack+eax*4], eax
	inc	dword [Depth]
	ret

FWORD	'LOCALDEPTH'
	mov	eax, [localDepth]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'FRAMEDEPTH'
	mov	eax, [frameDepth]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'CFDEPTH'
	mov	eax, [cfDepth]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'LDEPTH'
	mov	eax, [lDepth]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'@DEPTH'
	mov	eax, Depth
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'@LOCALDEPTH'
	mov	eax, localDepth
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'@FRAMEDEPTH'
	mov	eax, frameDepth
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'@CFDEPTH'
	mov	eax, cfDepth
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'@LDEPTH'
	mov	eax, lDepth
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'LOCALSTACK'
	mov	eax, Lstack
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'FRAMESTACK'
	mov	eax, FrameStack
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'CFSTACKADDR'
	mov	eax, CFstackAddr
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'CFSTACKID'
	mov	eax, CFstackID
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'LSTACKI'
	mov	eax, LStackI
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'LSTACKIMAX'
	mov	eax, LStackImax
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'LSTACKADDR'
	mov	eax, LStackAddr
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret


FWORD	'CLEARSTACK'
	xor	eax, eax
	mov	[Depth], eax
	mov	[localDepth], eax
	mov	[frameDepth], eax
	ret

FWORD	'FRAME{'
	mov	eax, [Depth]
	mov	ecx, [frameDepth]
	mov	[FrameStack+ecx*4], eax
	inc	dword [frameDepth]
	ret

FWORD	'}FRAME'
	dec	dword [frameDepth]
	ret

FWORD	'ARG0'	; -- adr of top element
	mov	ecx, [frameDepth]
	mov	eax, [FrameStack+ecx*4-4]
	sub	eax, 1
	shl	eax, 2
	add	eax, Dstack
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'ARG1'	; -- adr of next top element
	mov	ecx, [frameDepth]
	mov	eax, [FrameStack+ecx*4-4]
	sub	eax, 2
	shl	eax, 2
	add	eax, Dstack
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'ARG2'
	mov	ecx, [frameDepth]
	mov	eax, [FrameStack+ecx*4-4]
	sub	eax, 3
	shl	eax, 2
	add	eax, Dstack
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'ARG3'
	mov	ecx, [frameDepth]
	mov	eax, [FrameStack+ecx*4-4]
	sub	eax, 4
	shl	eax, 2
	add	eax, Dstack
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'ARG4'
	mov	ecx, [frameDepth]
	mov	eax, [FrameStack+ecx*4-4]
	sub	eax, 5
	shl	eax, 2
	add	eax, Dstack
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'ARG5'
	mov	ecx, [frameDepth]
	mov	eax, [FrameStack+ecx*4-4]
	sub	eax, 6
	shl	eax, 2
	add	eax, Dstack
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'ARG6'
	mov	ecx, [frameDepth]
	mov	eax, [FrameStack+ecx*4-4]
	sub	eax, 7
	shl	eax, 2
	add	eax, Dstack
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'ARG7'
	mov	ecx, [frameDepth]
	mov	eax, [FrameStack+ecx*4-4]
	sub	eax, 8
	shl	eax, 2
	add	eax, Dstack
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'ARG8'
	mov	ecx, [frameDepth]
	mov	eax, [FrameStack+ecx*4-4]
	sub	eax, 9
	shl	eax, 2
	add	eax, Dstack
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'ARG9'
	mov	ecx, [frameDepth]
	mov	eax, [FrameStack+ecx*4-4]
	sub	eax, 10
	shl	eax, 2
	add	eax, Dstack
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret



FWORD	'INPORT'
	mov	ecx, [Depth]
	xor	eax, eax
	mov	edx, [Dstack+ecx*4-4]
	in	al, dx
	mov	[Dstack+ecx*4-4], eax
	ret

FWORD	'INPORTW'
	mov	ecx, [Depth]
	xor	eax, eax
	mov	edx, [Dstack+ecx*4-4]
	in	ax, dx
	mov	[Dstack+ecx*4-4], eax
	ret

FWORD	'INPORTD'
	mov	ecx, [Depth]
	mov	edx, [Dstack+ecx*4-4]
	in	eax, dx
	mov	[Dstack+ecx*4-4], eax
	ret

FWORD	'OUTPORT'
	mov	ecx, [Depth]
	mov	edx, [Dstack+ecx*4-4]
	mov	eax, [Dstack+ecx*4-8]
	out	dx, al
	ret

FWORD	'OUTPORTW'
	mov	ecx, [Depth]
	mov	edx, [Dstack+ecx*4-4]
	mov	eax, [Dstack+ecx*4-8]
	out	dx, ax
	ret

FWORD	'OUTPORTD'
	mov	ecx, [Depth]
	mov	edx, [Dstack+ecx*4-4]
	mov	eax, [Dstack+ecx*4-8]
	out	dx, eax
	ret

FWORD	'CALL,'

ForthCall:

	mov	al, 0xE8		; opcode of CALL
	mov	ecx, [cdp]
	mov	[ecx], al
	inc	dword [cdp]
	mov	eax, [Depth]
	mov	eax, [Dstack-4+eax*4]
	sub	eax, dword [cdp]
	sub	eax, 4			; offset = ADDR - CDP - 4
	mov	ecx, [cdp]
	mov	[ecx], eax
	add	dword [cdp], 4
	dec	dword [Depth]
	ret

FWORD	'BRANCH,'

ForthBranch:

	mov	al, 0xE9		; opcode of JMP
	mov	ecx, [cdp]
	mov	[ecx], al
	inc	dword [cdp]
	mov	eax, [Depth]
	mov	eax, [Dstack-4+eax*4]
	sub	eax, dword [cdp]
	sub	eax, 4			; offset = ADDR - CDP - 4
	mov	ecx, [cdp]
	mov	[ecx], eax
	add	dword [cdp], 4
	dec	dword [Depth]
	ret

FWORD	'EXECUTE'
	dec	dword [Depth]
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4]
	jmp	eax
	ret

FWORD	'HERE'
	mov	eax, [ddp]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'[C]HERE'
	mov	eax, [cdp]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'DP'
	mov	eax, ddp
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'[C]DP'
	mov	eax, cdp
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'STACK'
	mov	eax, Dstack
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'LOCALSTACK'
	mov	eax, Lstack
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret



FWORD	'PARSE'
	call	ForthParse
	push	esi
	push	edi
	cld
	mov	ecx, 256
	mov	esi, token
	mov	edi, parsed_token
	repz	movsb
	pop	edi
	pop	esi
	mov	eax, parsed_token
	call	PushingEax
	ret

FWORD	'CREATE'
ForthCreate:
	; creating LFA
	mov	eax, [Current]
	mov	eax, [eax]
	; mov eax, [ForthLatest]
	mov	edx, [cdp]
	mov	[edx], eax
	mov	eax, [Current]
	mov	[eax], edx
	add	dword [cdp], 4

	; creating NAME
	call	Parse
	call	CompileToken

	; creating flags = 0
	xor	eax, eax
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	; creating basic code

	mov	eax, 0xB8	       ; code for MOV EAX, NNNN
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, [ddp]	       ; compile HERE as literal
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	mov	eax, 0xE8	       ; code for CALL
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, PushingEax        ; compile CALL to 'Push EAX' code
	sub	eax, [cdp]
	sub	eax, 4
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	mov	eax, 0xC3	       ; code for RET
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	ret

	; build 30

FWORD	'CREATE-WORD'  ; str --
ForthCreateWord:
	; creating LFA
	mov	eax, [Current]
	mov	eax, [eax]
	; mov eax, [ForthLatest]
	mov	edx, [cdp]
	mov	[edx], eax
	mov	eax, [Current]
	mov	[eax], edx
	add	dword [cdp], 4

	; creating NAME
	mov	ecx, [Depth]
	mov	esi, [Dstack+ecx*4-4]
	mov	edi, [cdp]

ForthCreateWordLoop:
	mov	al, byte [esi]
	mov	byte [edi], al
	inc	dword [cdp]
	inc	esi
	inc	edi
	cmp	al, 0
	jne	ForthCreateWordLoop
	dec	dword [Depth]

	; creating flags = 0
	xor	eax, eax
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	; creating basic code

	mov	eax, 0xB8	       ; code for MOV EAX, NNNN
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, [ddp]	       ; compile HERE as literal
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	mov	eax, 0xE8	       ; code for CALL
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, PushingEax        ; compile CALL to 'Push EAX' code
	sub	eax, [cdp]
	sub	eax, 4
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	mov	eax, 0xC3	       ; code for RET
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	ret

FWORD	'{'
ForthNoname:


	; creating LFA
	mov	eax, [Current]
	mov	eax, [eax]
	; mov eax, [ForthLatest]
	mov	edx, [cdp]
	mov	[edx], eax
	mov	eax, [Current]
	mov	[eax], edx
	add	dword [cdp], 4

	; creating NAME
	mov	al, 'L'
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1
	mov	al, 'A'
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1
	mov	al, 'S'
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1
	mov	al, 'T'
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1
	mov	al, '-'
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1
	mov	al, 'N'
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1
	mov	al, 'O'
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1
	mov	al, 'N'
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1
	mov	al, 'A'
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1
	mov	al, 'M'
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1
	mov	al, 'E'
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	; creating flags = 0
	xor	eax, eax
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	; creating basic code

	mov	eax, [cdp]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	add	dword [Depth], 1

	mov	eax, 1
	mov	[state], eax

	ret

IMMWORD '}'

	xor	eax, eax
	mov	[state], eax

	mov	eax, 0xC3	       ; code for RET
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, [Depth]
	mov	eax, [Dstack+eax*4-4]
	dec	dword [Depth]
	call	eax

	ret


FWORD	'VOCABULARY'
ForthCreateVoc:
	; creating LFA
	mov	eax, [Current]
	mov	eax, [eax]
	mov	edx, [cdp]
	mov	[edx], eax
	mov	eax, [Current]
	mov	[eax], edx
	add	dword [cdp], 4

	; creating NAME
	call	Parse
	call	CompileToken

	; creating flags = 0
	mov	eax, 0
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	; creating basic code

	mov	eax, 0xB8	       ; code for MOV EAX, NNNN
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, [ddp]	       ; compile HERE as literal
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	mov	esi, CodeVocabulary
	mov	edi, [cdp]
	mov	ecx, CODEVOCABULARYSIZE
	add	[cdp], ecx
	repz	movsb

	mov	eax, 0xC3	       ; code for RET
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

;       creating dummy word in new vocabulary

	mov	eax, [Current]
	mov	ecx, [ddp]
	mov	[ecx], eax
	mov	eax, [cdp]
	mov	[ecx+4], eax

	add	dword [ddp], 8

	mov	edx, [cdp]
	mov	eax, [Current]
	mov	[edx], eax
	add	dword [cdp], 4

	call	CompileToken

	; creating flags = 2
	mov	eax, 2
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, 0xC3	       ; code for RET
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	ret

FWORD	'DEFINITIONS'
	mov	eax, [Context]
	mov	[Current], eax

	ret

FWORD	'FORTH'
	mov	eax, ForthLatest
	mov	[Context], eax

	ret

FWORD	'IMMEDIATE'
	mov	eax, [Current]
	mov	eax, [eax]

	add	eax, 4		     ; LFA->NFA
ImmSkipNFA:
	mov	cl, [eax]
	cmp	cl, 0
	je	ImmSkipped
	inc	eax
	jmp	ImmSkipNFA
ImmSkipped:
	inc	eax		     ; go to FLAGS
	or	dword [eax], 1
	ret

FWORD	'DOES>'
	dec	dword [cdp]
	pop	eax
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	call	ForthBranch

	ret

FWORD	':'
ForthNewWord:
	; creating LFA
	mov	eax, [Current]
	mov	eax, [eax]
	mov	edx, [cdp]
	mov	[edx], eax
	mov	eax, [Current]
	mov	[eax], edx
	add	dword [cdp], 4

	; creating NAME
	call	Parse
	call	CompileToken

	; creating flags = 0
	xor	eax, eax
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, 1
	mov	[state], eax

	ret

IMMWORD ';'
ForthEndWord:
	mov	al, 0xC3		; opcode of RET
	mov	ecx, [cdp]
	mov	byte [ecx], al
	inc	dword [cdp]

	xor	eax, eax
	mov	[state], eax
	ret

IMMWORD '['
	xor	eax, eax
	mov	[state], eax
	ret

FWORD	']'
	mov	eax, 1
	mov	[state], eax
	ret

IMMWORD   'PROC'
	call	ForthNewWord
	ret

IMMWORD 'ENDPROC'
	call	ForthEndWord
	ret

FWORD	'EVALUATE'
	mov	eax, [Depth]
	mov	eax, [Dstack+eax*4-4]
	dec	dword [Depth]
	call	ForthEv
	ret

FWORD	'ALLOT'
	mov	eax, [Depth]
	mov	eax, [Dstack+eax*4-4]
	add	dword [ddp], eax
	dec	dword [Depth]
	ret

FWORD	'[C]ALLOT'
	mov	eax, [Depth]
	mov	eax, [Dstack+eax*4-4]
	add	dword [cdp], eax
	dec	dword [Depth]
	ret

FWORD	'ALIGN16'
	mov	eax, [ddp]
	and	eax, 0x0F
	jz	Forth_AlignEnd
	add	eax, 0x10
	mov	[ddp], eax
Forth_AlignEnd:
	ret

FWORD	'CONSTANT'
	; creating LFA
	mov	eax, [Current]
	mov	eax, [eax]
	; mov eax, [ForthLatest]
	mov	edx, [cdp]
	mov	[edx], eax
	mov	eax, [Current]
	mov	[eax], edx
	add	dword [cdp], 4

	; creating NAME
	call	Parse
	call	CompileToken

	; creating flags = 0
	xor	eax, eax
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	; creating basic code

	mov	eax, 0xB8	       ; code for MOV EAX, NNNN
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]  ; compile top number as literal
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	mov	eax, 0xE8	       ; code for CALL
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, PushingEax        ; compile CALL to 'Push EAX' code
	sub	eax, [cdp]
	sub	eax, 4
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	mov	eax, 0xC3	       ; code for RET
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	dec	dword [Depth]

	ret

FWORD	'VARIABLE'
	call	ForthCreate
	add	dword [ddp], 4
	ret

FWORD	'FLOAT'
	call	ForthCreate
	add	dword [ddp], 8
	ret

FWORD	'ARRAY' 		   ;  array_size --
	call	ForthCreate
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	add	dword [ddp], eax
	dec	dword [Depth]
	ret

FWORD	'SETCOLOR'
	mov	eax, [Depth]
	mov	ecx, [Dstack-4+eax*4]
	mov	[fgcolor], ecx
	dec	dword [Depth]
	ret

FWORD	'SETBGCOLOR'
	mov	eax, [Depth]
	mov	ecx, [Dstack-4+eax*4]
	mov	[bgcolor], ecx
	dec	dword [Depth]
	ret

FWORD	'GETCOLOR'
	mov	eax, [fgcolor]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'GETBGCOLOR'
	mov	eax, [bgcolor]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret


FWORD	'OPEN'	; ( filename -- hFile )
ForthOpen:
	mov	eax, [Depth]
	mov	eax, [Dstack+eax*4-4]
;        invoke  CreateFileA, eax, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, 0, 0
	invoke	CreateFileA, eax, GENERIC_READ, 0, 0, OPEN_EXISTING, 0, 0
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4-4], eax
	ret

FWORD	'OPENRW'  ; ( filename -- hFile )
ForthOpenRW:
	mov	eax, [Depth]
	mov	eax, [Dstack+eax*4-4]
	invoke	CreateFileA, eax, GENERIC_READ+GENERIC_WRITE, FILE_SHARE_READ, 0, OPEN_EXISTING, 0, 0
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4-4], eax
	invoke	SetFilePointer, eax, 0, 0, FILE_END
	ret

FWORD	'NEWFILE'  ; ( filename -- hFile )
	mov	eax, [Depth]
	mov	eax, [Dstack+eax*4-4]
	invoke	CreateFileA, eax, GENERIC_READ+GENERIC_WRITE, FILE_SHARE_READ, 0, CREATE_ALWAYS, 0, 0
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4-4], eax
	ret

FWORD	'CLOSE'  ; ( hFile -- )
	mov	eax, [Depth]
	mov	eax, [Dstack+eax*4-4]
	invoke	CloseHandle, eax
	dec	dword [Depth]
	test	eax, eax
	jnz	ForthCloseOK
	mov	[IOLastError], eax
ForthCloseOK:
	ret

FWORD	'READFILE'   ; ( hFile, buf, count -- )
ForthReadFile:
	mov	[IOLastError], 0
	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-12]
	mov	ecx, [Dstack+edx*4-8]
	mov	edx, [Dstack+edx*4-4]
	sub	dword [Depth], 3
	invoke	ReadFile, eax, ecx, edx, NumberOfBytesRead, 0
	cmp	eax, 0
	jne	ForthReadSuccess
	mov	[IOLastError], 1
ForthReadSuccess:
	ret

FWORD	'READCHAR'   ; ( hFile  -- char )
ForthReadChar:
	mov	[IOLastError], 0
	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-4]
	mov	ecx, Dstack
	shl	edx, 2
	add	ecx, edx
	sub	ecx, 4
	mov	dword [ecx], 0
	invoke	ReadFile, eax, ecx, 1, NumberOfBytesRead, 0
	cmp	[NumberOfBytesRead], 1
	je	ReadCharEnd
	mov	[IOLastError], 1

ReadCharEnd:
	ret

FWORD	'WRITEFILE'   ; ( hFile, buf, count -- )
ForthWriteFile:
	mov	[IOLastError], 0
	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-12]
	mov	ecx, [Dstack+edx*4-8]
	mov	edx, [Dstack+edx*4-4]
	sub	dword [Depth], 3
	invoke	WriteFile, eax, ecx, edx, NumberOfBytesRead, 0
	cmp	eax, 0
	jne	ForthWriteSuccess
	mov	[IOLastError], 1
ForthWriteSuccess:
	ret

FWORD	'WRITECHAR'   ; ( hFile, char  -- )
ForthWriteChar:
	mov	[IOLastError], 0
	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-8]
	mov	ecx, Dstack
	shl	edx, 2
	add	ecx, edx
	sub	ecx, 4
	invoke	WriteFile, eax, ecx, 1, NumberOfBytesRead, 0
	sub	dword [Depth], 2
	cmp	[NumberOfBytesRead], 1
	je	WriteCharEnd
	mov	[IOLastError], 1

WriteCharEnd:
	ret

FWORD	'FILESIZE'   ; ( handle -- size )
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	invoke	GetFileSize, eax, 0
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4-4], eax
	ret


FWORD	'EMITF'       ;  char --       emit to HF-OUT
ForthEmitf:
	mov	[IOLastError], 0
	call	ForthHFOUT
	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-4]
	mov	ecx, Dstack
	shl	edx, 2
	add	ecx, edx
	sub	ecx, 8
	invoke	WriteFile, eax, ecx, 1, NumberOfBytesRead, 0
	sub	dword [Depth], 2
	cmp	[NumberOfBytesRead], 1
	je	EmitfEnd
	mov	[IOLastError], 1

EmitfEnd:
	ret

FWORD	'PRINTF'
ForthPrintF:
	mov	eax, ForthEmitf
	mov	ecx, VectEmit
	inc	ecx
	mov	edx, [ecx]
	push	edx
	mov	[ecx], eax
	call	ForthPrint
	pop	edx
	mov	ecx, VectEmit
	inc	ecx
	mov	[ecx], edx
	ret

FWORD	'CRF'
	mov	eax, 0x0D
	call	PushingEax
	call	ForthEmitf
	mov	eax, 0x0A
	call	PushingEax
	call	ForthEmitf
	ret

FWORD	'.F'
	mov	eax, ForthEmitf
	mov	ecx, VectEmit
	inc	ecx
	mov	edx, [ecx]
	push	edx
	mov	[ecx], eax
	call	ForthDot
	pop	edx
	mov	ecx, VectEmit
	inc	ecx
	mov	edx, ForthEmit
	mov	[ecx], edx
	ret

FWORD	'U.F'
	mov	eax, ForthEmitf
	mov	ecx, VectEmit
	inc	ecx
	mov	edx, [ecx]
	push	edx
	mov	[ecx], eax
	call	ForthUDot
	pop	edx
	mov	ecx, VectEmit
	inc	ecx
	mov	edx, ForthEmit
	mov	[ecx], edx
	ret

FWORD	'F.F'
	mov	eax, ForthEmitf
	mov	ecx, VectEmit
	inc	ecx
	mov	edx, [ecx]
	push	edx
	mov	[ecx], eax
	call	FPrint
	pop	edx
	mov	ecx, VectEmit
	inc	ecx
	mov	[ecx], edx
	ret

FWORD	'READLINE'   ; ( handle, buf -- )
ForthReadLine:
	mov	dword [LineLength], 0
	mov	[IOLastError], 0
	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-8]
	mov	edx, [Dstack+edx*4-4]
	mov	byte [edx], 0		    ; test

ReadLineLoop:
	push	edx
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-8]
	invoke	ReadFile, eax, edx, 1, NumberOfBytesRead, 0

	cmp	eax, 0
	je	ReadLineError
	pop	edx
	cmp	eax, 0
	je	ReadLineEnd
	mov	eax, [NumberOfBytesRead]
	cmp	eax, 1
	jne	ReadLineEnd
	cmp	byte [edx], 0
	je	ReadLineEnd

	cmp	byte [edx], 0x0a
	je	ReadLineLoop	      ; ignore 0x0a
	cmp	byte [edx], 0x0d
	je	ReadLineEnd0	      ; 0x0d is before 0x0a - this is the end of line
	inc	edx
	inc	dword [LineLength]
	jmp	ReadLineLoop

ReadLineError:
	mov	[IOLastError], 1
	jmp	ReadLineEnd

ReadLineEnd0:	    ; 0a or 0d was read

	mov	byte [edx], 0

ReadLineEnd:
	sub	dword [Depth], 2

	ret

FWORD	'L'	; ( filename -- )
ForthLoadFile:

	call	PushSourceContext

	call	ForthOpen

	xor	eax, eax
	mov	[LineNumber], eax


	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-4]
	mov	[hSource], eax
	dec	dword [Depth]

LoadingLoop:
	mov	edx, [Depth]
	mov	eax, [hSource]
	mov	[Dstack+edx*4], eax
;        call    TibClear                       ; *** not tested
	mov	eax, Tib
	mov	[Dstack+edx*4+4], eax
	add	dword [Depth], 2
	call	ForthReadLine
	inc	dword [LineNumber]
	cmp	dword [NumberOfBytesRead], 0
	jne	Loading0
	cmp	dword [LineLength], 0
	jne	Loading0

	jmp	LoadingEnd

Loading0:

	mov	eax, [LineLength]
	cmp	eax, 0
	je	LoadingLoop
	mov	[span], eax
	mov	dword [TibPtr], 0

LoadingContinue:

	call	EvaluateLoaded

	mov	eax, [ErrSym]	       ; build 16
	cmp	eax, 0		       ;
	jne	LoadingEnd	       ;

	mov	eax, [NumError]        ; build 23
	cmp	eax, 0		       ;
	jne	LoadingEnd	       ;

	mov	eax, [TibPtr]
	cmp	eax, dword [LineLength]
	jl	LoadingLoop

LoadingEnd:

	mov	eax, [hSource]
	invoke	CloseHandle, eax

	call	PopSourceContext

	mov	eax, [sDepth]
	cmp	eax, 1
	jge	LoadingContinue

	call	TibClear	       ; build 25

	ret

FWORD	'PUSHEDSOURCE'
	mov	eax, [hTibPtrs+4]
	call	PushingEax
	call	ForthDot
	mov	eax, [hSpan+4]
	call	PushingEax
	call	ForthDot
	mov	eax, [hSources+4]
	call	PushingEax
	call	ForthDot
	mov	eax, [hLineLength+4]
	call	PushingEax
	call	ForthDot
	mov	eax, hTibs
	add	eax, 256
	call	PushingEax
	call	ForthPrint
	ret

FWORD	'GOTOXY' ; ( x, y -- )
	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-8]
	mov	edx, [Dstack+edx*4-4]
	shl	eax, 3
	shl	edx, 4
	mov	[wherex], eax
	mov	[wherey], edx
	sub	dword [Depth], 2
	ret

FWORD	'TEXTXY' ; ( x, y -- )
	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-8]
	mov	edx, [Dstack+edx*4-4]
	mov	[wherex], eax
	mov	[wherey], edx
	sub	dword [Depth], 2
	ret

FWORD	'EMIT1'
ForthEmit:
	dec	dword [Depth]
	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4]
	call	emit1
	ret

FWORD	'CR'
	xor	eax, eax
	mov	[wherex], eax
	add	dword [wherey], 16
	ret

FWORD	'WHEREXY'
	mov	ecx, [Depth]
	mov	eax, [wherex]
	shr	eax, 3
	mov	[Dstack+ecx*4], eax
	mov	eax, [wherey]
	shr	eax, 4
	mov	[Dstack+ecx*4+4], eax
	add	dword [Depth], 2
	ret

FWORD	'WHEREX'
	mov	ecx, [Depth]
	mov	eax, [wherex]
	shr	eax, 3
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'WHEREY'
	mov	ecx, [Depth]
	mov	eax, [wherey]
	shr	eax, 4
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'WHERETEXTXY'
	mov	ecx, [Depth]
	mov	eax, [wherex]
	mov	[Dstack+ecx*4], eax
	mov	eax, [wherey]
	mov	[Dstack+ecx*4+4], eax
	add	dword [Depth], 2
	ret

FWORD	'COUNT'      ; lpStringZ -- count
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	mov	edx, 0
ForthCountLoop:
	cmp	byte [eax], 0
	je	ForthCountEnd
	inc	edx
	inc	eax
	jmp	ForthCountLoop
ForthCountEnd:
	mov	[Dstack+ecx*4-4], edx
	ret

FWORD	'TYPE'	    ; ( lpString, count -- )
ForthType:
	mov	edx, [Depth]
	mov	ecx, [Dstack+edx*4-4]
	mov	edx, [Dstack+edx*4-8]
	sub	dword [Depth], 2
TypeLoop:
	cmp	ecx, 0
	je	TypeEnd
	mov	al, [edx]
	cmp	al, 0
	je	TypeEnd
	cmp	al, 0x0a
	je	TypeEnd
	cmp	al, 0x0d
	je	TypeEnd
	push	ecx
	push	edx
	call	PushingEax
	call	VectEmit
	pop	edx
	pop	ecx
	dec	ecx
	inc	edx
	jmp	TypeLoop
TypeEnd:

	ret


FWORD	'PRINT'      ; ( lpStringZ -- )
ForthPrint:
	mov	edx, [Depth]
	mov	edx, [Dstack+edx*4-4]
	dec	dword [Depth]
PrintLoop:
	mov	al, [edx]
	cmp	al, 0
	je	PrintEnd
	cmp	al, 0x0a
	je	PrintEnd
	cmp	al, 0x0d
	je	PrintEnd
	push	edx
	call	PushingEax
	call	VectEmit
	pop	edx
	inc	edx
	jmp	PrintLoop
PrintEnd:

	ret

FWORD	'U.'

ForthUDot:

	call	PadClear
	dec	dword [Depth]
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4]
	mov	ecx, 0

ForthUDotLoop:

	mov	edx, 0
	div	dword [base]		       ; eax = div, edx = mod
	mov	dl, [digits+edx]
	mov	[_pad+ecx], dl
	inc	ecx
	cmp	eax, 0
	jne	ForthUDotLoop

	mov	ecx, 255

ForthUDotFindStart:

	cmp	byte [_pad+ecx], 0
	jne	ForthUDotStartType
	dec	ecx
	jmp	ForthUDotFindStart

ForthUDotStartType:

	mov	al, [_pad+ecx]
	push	ecx
	call	PushingEax
	call	VectEmit
	pop	ecx
	dec	ecx
	cmp	ecx, 0xffffffff
	jne	ForthUDotStartType

	mov	eax, [EmTrailingSpace]
	cmp	eax, 0
	je	ForthUDotEnd

	mov	al, 32
	call	PushingEax
	call	VectEmit

ForthUDotEnd:

	ret

FWORD	'.'

ForthDot:

	call	PadClear
	mov	dword [NumberSign], 0

	mov	ecx, [Depth]
	dec	dword [Depth]
	mov	eax, [Dstack+ecx*4-4]
	mov	ecx, 0

	test	eax, 0x80000000
	jz	ForthDotLoop		       ; number is positive, no need to add MINUS sign
	mov	dword [NumberSign], 1
	xor	eax, 0xffffffff
	inc	eax

ForthDotLoop:

	cdq
	idiv	dword [base]		       ; eax = div, edx = mod
	mov	dl, [digits+edx]
	mov	[_pad+ecx], dl
	inc	ecx
	cmp	eax, 0
	jne	ForthDotLoop

	cmp	dword [NumberSign], 0
	je	ForthDotTyping
	mov	al, '-'
	mov	[_pad+ecx], al

ForthDotTyping:

	mov	ecx, 255

ForthDotFindStart:

	cmp	byte [_pad+ecx], 0
	jne	ForthDotStartType
	dec	ecx
	jmp	ForthDotFindStart

ForthDotStartType:

	mov	al, [_pad+ecx]
	push	ecx
	call	PushingEax
	call	VectEmit
	pop	ecx
	dec	ecx
	cmp	ecx, 0xffffffff
	jne	ForthDotStartType

	mov	eax, [EmTrailingSpace]
	cmp	eax, 0
	je	ForthDotEnd

	mov	al, 32
	call	PushingEax
	call	VectEmit

ForthDotEnd:
	ret

FWORD	'DECIMAL'
	mov	dword [base], 10
	ret

FWORD	'HEX'
	mov	dword [base], 16
	ret

FWORD	'BIN'
	mov	dword [base], 2
	ret


FWORD	'PIXEL1'
ForthPixel:
	mov	edx, [Depth]
;        mov     ecx, 2048
;       sub     ecx, [Dstack+eax*4-8]
	mov	ecx, [Dstack+edx*4-8]
	cmp	ecx, 0
	jl	ForthPixelNo
	cmp	ecx, 2047
	jg	ForthPixelNo
	mov	eax, [Dstack+edx*4-12]
	cmp	eax, 0
	jl	ForthPixelNo
	cmp	eax, 2047
	jg	ForthPixelNo
	shl	ecx, 11
	add	ecx, eax
	mov	eax, [Dstack+edx*4-4]

;        cmp     ecx, 0
;        jb      ForthPixelNo
;        cmp     ecx, 4194304
;        jae     ForthPixelNo
	mov	dword [screen+ecx*4], eax
ForthPixelNo:
	sub	dword [Depth], 3
	ret

FWORD	'PSET'
ForthPset:
	mov	edx, [Depth]
	mov	ecx, [Dstack+edx*4-4]
	cmp	ecx, 0
	jl	ForthPsetNo
	cmp	ecx, 2047
	jg	ForthPsetNo
	mov	eax, [Dstack+edx*4-8]
	cmp	eax, 0
	jl	ForthPsetNo
	cmp	eax, 2047
	jg	ForthPsetNo
	shl	ecx, 11
	add	ecx, eax
	mov	eax, [ForthColor+1]

	mov	dword [screen+ecx*4], eax
ForthPsetNo:
	sub	dword [Depth], 2
	ret

FWORD	'PRESET'
ForthPreset:
	mov	edx, [Depth]
	mov	ecx, [Dstack+edx*4-4]
	cmp	ecx, 0
	jl	ForthPresetNo
	cmp	ecx, 2047
	jg	ForthPresetNo
	mov	eax, [Dstack+edx*4-8]
	cmp	eax, 0
	jl	ForthPresetNo
	cmp	eax, 2047
	jg	ForthPresetNo
	shl	ecx, 11
	add	ecx, eax
	mov	eax, [ForthBGColor+1]

	mov	dword [screen+ecx*4], eax
ForthPresetNo:
	sub	dword [Depth], 2
	ret


FWORD	'PIXEL2'
ForthPixel2:
	mov	edx, [Depth]
;        mov     ecx, 2048
;       sub     ecx, [Dstack+eax*4-8]
	mov	ecx, [Dstack+edx*4-8]
	cmp	ecx, [ViewPort+8]
	jl	ForthPixelNo2
	cmp	ecx, [ViewPort+12]
	jg	ForthPixelNo2
	mov	eax, [Dstack+edx*4-12]
	cmp	eax, [ViewPort]
	jl	ForthPixelNo2
	cmp	eax, [ViewPort+4]
	jg	ForthPixelNo2
	shl	ecx, 11
	add	ecx, eax
	mov	eax, [Dstack+edx*4-4]

;        cmp     ecx, 0
;        jb      ForthPixelNo
;        cmp     ecx, 4194304
;        jae     ForthPixelNo
	mov	dword [screen+ecx*4], eax
ForthPixelNo2:
	sub	dword [Depth], 3
	ret

FWORD	'PIXELZ'
ForthPixelZ:
	mov	edx, [Depth]
;        mov     ecx, 2048
;       sub     ecx, [Dstack+eax*4-8]
	mov	ecx, [Dstack+edx*4-8]
	add	ecx, [x0y0+4]
	cmp	ecx, [ViewPort+8]
	jl	ForthPixelNoZ
	cmp	ecx, [ViewPort+12]
	jg	ForthPixelNoZ
	mov	eax, [Dstack+edx*4-12]
	add	eax, [x0y0]
	cmp	eax, [ViewPort]
	jl	ForthPixelNoZ
	cmp	eax, [ViewPort+4]
	jg	ForthPixelNoZ
	shl	ecx, 11
	add	ecx, eax

;       now ecx contains index of addr, checking for Z coord
	mov	eax, [Zpixel]
	mov	eax, [eax+ecx*4]	; load Z from that addr
	cmp	eax, [object_z]
	jg	ForthPixelNoZ

	mov	eax, [Dstack+edx*4-4]
	mov	dword [screen+ecx*4], eax

	mov	eax, [object_z]
	mov	edx, [Zpixel]
	mov	dword [edx+ecx*4], eax

	mov	eax, [object_id]
	mov	edx, [IDpixel]
	mov	dword [edx+ecx*4], eax

ForthPixelNoZ:
	sub	dword [Depth], 3
	ret

FWORD	'PIXELZ0'
ForthPixelZ0:
	mov	edx, [Depth]
;        mov     ecx, 2048
;       sub     ecx, [Dstack+eax*4-8]
	mov	ecx, [Dstack+edx*4-8]
	mov	eax, [Dstack+edx*4-12]
	shl	ecx, 11
	add	ecx, eax

;       now ecx contains index of addr, checking for Z coord
	mov	eax, [Zpixel]
	mov	eax, [eax+ecx*4]	; load Z from that addr
	cmp	eax, [object_z]
	jg	ForthPixelNoZ0

	mov	eax, [Dstack+edx*4-4]
	mov	dword [screen+ecx*4], eax

	mov	eax, [object_z]
	mov	edx, [Zpixel]
	mov	dword [edx+ecx*4], eax

	mov	eax, [object_id]
	mov	edx, [IDpixel]
	mov	dword [edx+ecx*4], eax

ForthPixelNoZ0:
	sub	dword [Depth], 3
	ret

FWORD	'GETPIXEL1'
ForthGetPixel:
	mov	edx, [Depth]
;        mov     ecx, 2048
;       sub     ecx, [Dstack+eax*4-8]
	mov	ecx, [Dstack+edx*4-4]
	shl	ecx, 11
	add	ecx, [Dstack+edx*4-8]
	cmp	ecx, 0
	jb	ForthGetPixelNo
	cmp	ecx, 4194304
	jae	ForthGetPixelNo
	mov	eax, dword [screen+ecx*4]
	mov	[Dstack+edx*4-8], eax
ForthGetPixelNo:
	dec	dword [Depth]
	ret

FWORD	'HLINE'  ; x, y, len, color --
	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-12]
	cmp	eax, [ViewPort+8]
	jl	ForthHlineNoDraw
	cmp	eax, [ViewPort+12]
	jg	ForthHlineNoDraw

	mov	eax, [Depth]
	mov	ecx, [Dstack+eax*4-12]
	shl	ecx, 11
	add	ecx, [Dstack+eax*4-16]
	mov	edx, [Depth]
ForthHlineOnemore:
	cmp	ecx, 0
	jb	ForthHlineNo
	cmp	ecx, 4194304
	jae	ForthHlineNo

	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-16]
	cmp	eax, [ViewPort]
	jl	ForthHlineNo
	cmp	eax, [ViewPort+4]
	jg	ForthHlineNo

	mov	eax, [Dstack+edx*4-4]
	mov	dword [screen+ecx*4], eax
ForthHlineNo:
	inc	ecx
	inc	dword [Dstack+edx*4-16]
	dec	dword [Dstack+edx*4-8]
	xor	eax, eax
	cmp	eax, [Dstack+edx*4-8]
	jne	ForthHlineOnemore
ForthHlineNoDraw:
	sub	dword [Depth], 4
	ret

FWORD	'VLINE' ; x, y, len, color --
	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-16]
	cmp	eax, [ViewPort]
	jl	ForthVlineNoDraw
	cmp	eax, [ViewPort+4]
	jg	ForthVlineNoDraw

	mov	eax, [Depth]
	mov	ecx, [Dstack+eax*4-12]
	shl	ecx, 11
	add	ecx, [Dstack+eax*4-16]
	mov	edx, [Depth]
ForthVlineOnemore:
	cmp	ecx, 0
	jb	ForthVlineNo
	cmp	ecx, 4194304
	jae	ForthVlineNo

	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-12]
	cmp	eax, [ViewPort+8]
	jl	ForthVlineNo
	cmp	eax, [ViewPort+12]
	jg	ForthVlineNo

	mov	eax, [Dstack+edx*4-4]
	mov	dword [screen+ecx*4], eax
ForthVlineNo:
	add	ecx, 2048
	inc	dword [Dstack+edx*4-12]
	dec	dword [Dstack+edx*4-8]
	xor	eax, eax
	cmp	eax, [Dstack+edx*4-8]
	jne	ForthVlineOnemore
ForthVlineNoDraw:
	sub	dword [Depth], 4
	ret

FWORD	'CLS'
	xor	eax, eax
	mov	[wherex], eax
	mov	[wherey], eax
	mov	edx, screen
	mov	ecx, 0
CLS_Loop:
	mov	[edx+ecx*4], eax
	inc	ecx
	cmp	ecx, 4194304
	jl	CLS_Loop
	ret

; ------- build 31 -----------

; sprite support
; --------------
; SPRITE<bpp>[R][T]
; bpp - 24 or 32 bits per pixel in the original image
; R - reversed image (started from the bottom line)
; T - transparent image (0 don't change screen)

FWORD	'SPRITE24'  ; x, y, w, h, addr --
	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-16]	; y
	shl	eax, 11
	add	eax, [Dstack+edx*4-20]	; x
	mov	ecx, eax
	mov	ebx, [Dstack+edx*4-4]	; addr

SpriteVert:
	mov	edx, [Depth]
	mov	edx, [Dstack+edx*4-12]	; w

SpriteHoriz:
	mov	eax, [ebx]
	mov	dword [screen+ecx*4], eax
	sub	edx, 1
	add	ebx, 3
	add	ecx, 1
	cmp	edx, 0
	jne	SpriteHoriz

	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-8]
	sub	eax, 1
	mov	[Dstack+edx*4-8], eax

	add	ecx, 2048
	sub	ecx, [Dstack+edx*4-12]

	cmp	eax, 0
	jne	SpriteVert

	sub	edx, 5
	mov	[Depth], edx

	ret

FWORD	'SPRITE24R'  ; x, y, w, h, addr --
	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-16]	; y

	; reversed sprite
	add	eax, [Dstack+edx*4-8]	; h

	shl	eax, 11
	add	eax, [Dstack+edx*4-20]	; x
	mov	ecx, eax
	mov	ebx, [Dstack+edx*4-4]	; addr

SpriteRVert:
	mov	edx, [Depth]
	mov	edx, [Dstack+edx*4-12]	; w

SpriteRHoriz:
	mov	eax, [ebx]
	mov	dword [screen+ecx*4], eax
	sub	edx, 1
	add	ebx, 3
	add	ecx, 1
	cmp	edx, 0
	jne	SpriteRHoriz

	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-8]
	sub	eax, 1
	mov	[Dstack+edx*4-8], eax

	sub	ecx, 2048
	sub	ecx, [Dstack+edx*4-12]

	cmp	eax, 0
	jne	SpriteRVert

	sub	edx, 5
	mov	[Depth], edx

	ret

FWORD	'SPRITE24T'  ; x, y, w, h, addr --
	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-16]	; y
	shl	eax, 11
	add	eax, [Dstack+edx*4-20]	; x
	mov	ecx, eax
	mov	ebx, [Dstack+edx*4-4]	; addr

SpriteTVert:
	mov	edx, [Depth]
	mov	edx, [Dstack+edx*4-12]	; w

SpriteTHoriz:
	mov	eax, [ebx]
	cmp	eax, 0
	je	SpriteTNo
	mov	dword [screen+ecx*4], eax
SpriteTNo:
	sub	edx, 1
	add	ebx, 3
	add	ecx, 1
	cmp	edx, 0
	jne	SpriteTHoriz

	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-8]
	sub	eax, 1
	mov	[Dstack+edx*4-8], eax

	add	ecx, 2048
	sub	ecx, [Dstack+edx*4-12]

	cmp	eax, 0
	jne	SpriteTVert

	sub	edx, 5
	mov	[Depth], edx

	ret

FWORD	'SPRITE24RT'  ; x, y, w, h, addr --
	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-16]	; y

	; reversed sprite
	add	eax, [Dstack+edx*4-8]	; h

	shl	eax, 11
	add	eax, [Dstack+edx*4-20]	; x
	mov	ecx, eax
	mov	ebx, [Dstack+edx*4-4]	; addr

SpriteRTVert:
	mov	edx, [Depth]
	mov	edx, [Dstack+edx*4-12]	; w

SpriteRTHoriz:
	mov	eax, [ebx]
	cmp	eax, 0
	je	SpriteRTNo
	mov	dword [screen+ecx*4], eax
SpriteRTNo:
	sub	edx, 1
	add	ebx, 3
	add	ecx, 1
	cmp	edx, 0
	jne	SpriteRTHoriz

	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-8]
	sub	eax, 1
	mov	[Dstack+edx*4-8], eax

	sub	ecx, 2048
	sub	ecx, [Dstack+edx*4-12]

	cmp	eax, 0
	jne	SpriteRTVert

	sub	edx, 5
	mov	[Depth], edx

	ret

IMMWORD   '"'
ForthQuote:
	mov	al, 0x22	 ; ASCII for "
	mov	[delimiter], al
	mov	[delimiter2], al
	call	ParseClear
	mov	edx, [TibPtr]
	call	ParseGetWord

;       token contains parsed string

ForthString:

	mov	edx, [ddp]
	push	edx		 ; here at start compilation
	mov	ecx, token
	add	edx, 4		 ; reserving space for string counter (DWORD)

ForthQuoteLoop:

	cmp	byte [ecx], 0
	je	ForthQuoteComplete
	mov	al, [ecx]
	mov	[edx], al
	inc	edx
	inc	ecx
	jmp	ForthQuoteLoop

ForthQuoteComplete:

	inc	edx
	xor	eax, eax
	mov	[edx], al	 ; placing latest CHAR 0
	mov	[ddp], edx
	pop	edx		 ; cell for placing counter
	sub	ecx, token
	mov	[edx], ecx
	add	edx, 4

	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], edx
	inc	dword [Depth]
	cmp	dword [state], 0
	je	ForthQuoteFinish

;       we are in COMPILE mode, needs to processing this lpStr

	mov	eax, 0xB8	       ; code for MOV EAX, NNNN
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-4]  ; compile lpStr as literal
	dec	dword [Depth]
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	mov	eax, 0xE8	       ; code for CALL
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, PushingEax        ; compile CALL to 'Push EAX' code
	sub	eax, [cdp]
	sub	eax, 4
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

ForthQuoteFinish:

	call	ParseClear
	mov	al, 32	       ;
	mov	[delimiter], al
	mov	al, 9
	mov	[delimiter2], al

	ret

IMMWORD '."'
	call	ForthQuote
	cmp	dword [state], 0
	je	ForthDotQuotePrint

	mov	eax, 0xE8	       ; code for CALL
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, ForthPrint        ; compile CALL to 'PRINT' code
	sub	eax, [cdp]
	sub	eax, 4
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4
	jmp	ForthDotQuoteFinish

ForthDotQuotePrint:
	call	ForthPrint

ForthDotQuoteFinish:
	ret

IMMWORD   'LINE"'
ForthLineQuote:
	mov	al, 0x0 	; to the end of line
	mov	[delimiter], al
	mov	[delimiter2], al
	call	ParseClear
	mov	edx, [TibPtr]
	call	ParseGetWord

;       token contains parsed string

	mov	edx, [ddp]
	push	edx		 ; here at start compilation
	mov	ecx, token
	add	edx, 4		 ; reserving space for string counter (DWORD)

ForthLineQuoteLoop:

	cmp	byte [ecx], 0
	je	ForthLineQuoteComplete
	mov	al, [ecx]
	mov	[edx], al
	inc	edx
	inc	ecx
	jmp	ForthLineQuoteLoop

ForthLineQuoteComplete:

	inc	edx
	xor	eax, eax
	mov	[edx], al	 ; placing latest CHAR 0
	mov	[ddp], edx
	pop	edx		 ; cell for placing counter
	sub	ecx, token
	mov	[edx], ecx
	add	edx, 4

	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], edx
	inc	dword [Depth]
	cmp	dword [state], 0
	je	ForthLineQuoteFinish

;       we are in COMPILE mode, needs to processing this lpStr

	mov	eax, 0xB8	       ; code for MOV EAX, NNNN
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-4]  ; compile lpStr as literal
	dec	dword [Depth]
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	mov	eax, 0xE8	       ; code for CALL
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, PushingEax        ; compile CALL to 'Push EAX' code
	sub	eax, [cdp]
	sub	eax, 4
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

ForthLineQuoteFinish:

	call	ParseClear
	mov	al, 32	       ;
	mov	[delimiter], al
	mov	al, 9	      ;
	mov	[delimiter2], al

	ret

IMMWORD   'LINE.F"'
ForthLineDotQuote:
	mov	al, 0x0 	; to the end of line
	mov	[delimiter], al
	mov	[delimiter2], al
	call	ParseClear
	mov	edx, [TibPtr]
	call	ParseGetWord

;       token contains parsed string

	mov	edx, [ddp]
	push	edx		 ; here at start compilation
	mov	ecx, token
	add	edx, 4		 ; reserving space for string counter (DWORD)

ForthLineDotQuoteLoop:

	cmp	byte [ecx], 0
	je	ForthLineDotQuoteComplete
	mov	al, [ecx]
	mov	[edx], al
	inc	edx
	inc	ecx
	jmp	ForthLineDotQuoteLoop

ForthLineDotQuoteComplete:

	inc	edx
	xor	eax, eax
	mov	[edx], al	 ; placing latest CHAR 0
	mov	[ddp], edx
	pop	edx		 ; cell for placing counter
	sub	ecx, token
	mov	[edx], ecx
	add	edx, 4

	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], edx
	inc	dword [Depth]
	cmp	dword [state], 0
	je	ForthLineDotQuoteFinish

;       we are in COMPILE mode, needs to processing this lpStr

	mov	eax, 0xB8	       ; code for MOV EAX, NNNN
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	edx, [Depth]
	mov	eax, [Dstack+edx*4-4]  ; compile lpStr as literal
	dec	dword [Depth]
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	mov	eax, 0xE8	       ; code for CALL
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, PushingEax        ; compile CALL to 'Push EAX' code
	sub	eax, [cdp]
	sub	eax, 4
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

ForthLineDotQuoteFinish:

	call	ParseClear
	mov	al, 32	       ;
	mov	[delimiter], al
	mov	al, 9
	mov	[delimiter2], al

	ret


IMMWORD '\'

ForthCommentLine:

	mov	al, 0
	mov	[delimiter], al
	mov	[delimiter2], al
	call	ParseClear
	call	Parse

	call	ParseClear
	mov	al, 32	       ;
	mov	[delimiter], al
	mov	al, 9
	mov	[delimiter2], al

	ret

IMMWORD '//'
	jmp	ForthCommentLine
	ret

IMMWORD 'IF'
	call	CheckCompileMode

	mov	eax, 0xE8	       ; code for CALL
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, CheckStack        ; compile CALL to 'Check stack' code
	sub	eax, [cdp]
	sub	eax, 4
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	mov	eax, 0x0F	       ; code for JZ
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1
	mov	eax, 0x84	       ; code for JZ
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, 1
	call	PushControlFlow
	add	dword [cdp], 4	       ; reserving space

	ret

IMMWORD 'THEN'
	call	CheckCompileMode

	mov	ecx, [cfDepth]
	cmp	ecx, 0
	je	ForthThenErr
	cmp	dword [CFstackID+ecx*4-4], 1
	jne	ForthThenErr

	mov	eax, [cdp]
	sub	eax, 4
	sub	eax, dword [CFstackAddr+ecx*4-4]  ; now eax contains an offset
	mov	ecx, [CFstackAddr+ecx*4-4]

	mov	[ecx], eax
	dec	[cfDepth]
	jmp	ForthThenEnd

ForthThenErr:

	mov	eax, MsgTHEN
	call	TypeMessage
	call	Abort

ForthThenEnd:
	ret

IMMWORD 'ELSE'
	call	CheckCompileMode

	mov	ecx, [cfDepth]
	cmp	ecx, 0
	je	ForthElseErr
	cmp	dword [CFstackID+ecx*4-4], 1
	jne	ForthElseErr

	mov	eax, 0xE9	       ; code for JMP
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	edx, [cdp]	       ; edx contains an address for forward reference
	add	dword [cdp], 4	       ; reserving space

	mov	eax, [cdp]
	sub	eax, 4
	sub	eax, [CFstackAddr+ecx*4-4]  ; now eax contains an offset
	mov	ecx, [CFstackAddr+ecx*4-4]

	mov	[ecx], eax

	mov	ecx, [cfDepth]
	mov	[CFstackAddr+ecx*4-4], edx	  ; replace to edx - leave on CF stack forward reference

	jmp	ForthThenEnd

ForthElseErr:

	mov	eax, MsgELSE
	call	TypeMessage
	call	Abort

ForthElseEnd:

	ret

IMMWORD 'BEGIN'

	call	CheckCompileMode

	mov	eax, 2
	call	PushControlFlow

	ret

IMMWORD 'AGAIN'

	call	CheckCompileMode

	mov	ecx, [cfDepth]
	cmp	ecx, 0
	je	ForthAgainErr
	cmp	dword [CFstackID+ecx*4-4], 2
	jne	ForthAgainErr

	mov	eax, 0xE9	       ; code for JMP
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, [CFstackAddr+ecx*4-4]
	sub	eax, [cdp]
	sub	eax, 4
	mov	ecx, [cdp]
	mov	[ecx], eax
	add	dword [cdp], 4

	dec	dword [cfDepth]
	jmp	ForthAgainEnd

ForthAgainErr:

	mov	eax, MsgAGAIN
	call	TypeMessage
	call	Abort

ForthAgainEnd:

	ret

IMMWORD 'UNTIL'
	call	CheckCompileMode

	mov	ecx, [cfDepth]
	cmp	ecx, 0
	je	ForthUntilErr
	cmp	dword [CFstackID+ecx*4-4], 2
	jne	ForthUntilErr

	mov	eax, 0xE8	       ; code for CALL
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, CheckStack        ; compile CALL to 'Check stack' code
	sub	eax, [cdp]
	sub	eax, 4
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	mov	eax, 0x0F	       ; code for JZ
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1
	mov	eax, 0x84	       ; code for JZ
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	ecx, [cfDepth]
	mov	eax, [CFstackAddr+ecx*4-4]
	sub	eax, [cdp]
	sub	eax, 4
	mov	ecx, [cdp]
	mov	[ecx], eax
	add	dword [cdp], 4

	dec	dword [cfDepth]
	jmp	ForthUntilEnd

ForthUntilErr:

	mov	eax, MsgUNTIL
	call	TypeMessage
	call	Abort

ForthUntilEnd:

	ret

 IMMWORD 'WHILE'
	call	CheckCompileMode

	mov	eax, 0xE8	       ; code for CALL
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, CheckStack        ; compile CALL to 'Check stack' code
	sub	eax, [cdp]
	sub	eax, 4
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	mov	eax, 0x0F	       ; code for JZ
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1
	mov	eax, 0x84	       ; code for JZ
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, 4
	call	PushControlFlow

	add	dword [cdp], 4

	ret

IMMWORD 'REPEAT'
	call	CheckCompileMode

	mov	ecx, [cfDepth]
	cmp	ecx, 0
	je	ForthRepeatErr
	cmp	ecx, 1
	je	ForthRepeatErr
	cmp	dword [CFstackID+ecx*4-4], 4
	jne	ForthRepeatErr
	cmp	dword [CFstackID+ecx*4-8], 2
	jne	ForthRepeatErr2

	mov	eax, 0xE9	       ; code for JMP
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, [CFstackAddr+ecx*4-8]
	sub	eax, [cdp]
	sub	eax, 4
	mov	ecx, [cdp]
	mov	[ecx], eax
	add	dword [cdp], 4

	mov	ecx, [cfDepth]
	mov	eax, [cdp]
	sub	eax, 4
	sub	eax, dword [CFstackAddr+ecx*4-4]  ; now eax contains an offset
	mov	ecx, [CFstackAddr+ecx*4-4]

	mov	[ecx], eax
	sub	dword [cfDepth], 2
	jmp	ForthRepeatEnd

ForthRepeatErr:

	mov	eax, MsgREPEAT
	call	TypeMessage
	call	Abort
	jmp	ForthRepeatEnd

ForthRepeatErr2:

	mov	eax, MsgREPEAT2
	call	TypeMessage
	call	Abort

ForthRepeatEnd:

	ret

IMMWORD 'CASE'
	call	CheckCompileMode

	mov	esi, CodeCase
	mov	edi, [cdp]
	mov	ecx, CODECASESIZE
	add	[cdp], ecx
	repz	movsb

	mov	eax, 6
	call	PushControlFlow

	ret

IMMWORD 'ENDCASE'
	call	CheckCompileMode
ForthEndcase:
	mov	ecx, [cfDepth]
	cmp	ecx, 0
	je	ForthEndCaseErr
	cmp	dword [CFstackID+ecx*4-4], 6
	je	ForthEndcaseEndof
	cmp	dword [CFstackID+ecx*4-4], 10
	je	ForthEndcaseBreak
	jmp	ForthEndCaseErr

ForthEndcaseBreak:

	mov	eax, [cdp]
	sub	eax, dword [CFstackAddr+ecx*4-4]  ; now eax contains an offset
	mov	ecx, [CFstackAddr+ecx*4-4]
	sub	ecx, 4
	mov	[ecx], eax
	dec	dword [cfDepth]
	jmp	ForthEndcase

ForthEndcaseEndof:
	mov	esi, CodeEndCase
	mov	edi, [cdp]
	mov	ecx, CODEENDCASESIZE
	add	[cdp], ecx
	repz	movsb
	dec	dword [cfDepth]
	jmp	ForthEndcaseEnd


ForthEndCaseErr:
	mov	eax, MsgENDCASE
	call	TypeMessage
	call	Abort

ForthEndcaseEnd:

	ret

IMMWORD 'OF'
	call	CheckCompileMode

	mov	esi, CodeOf
	mov	edi, [cdp]
	mov	ecx, CODEOFSIZE
	add	[cdp], ecx
	repz	movsb

	mov	al, 0x0F
	mov	edx, [cdp]
	mov	[edx], al
	inc	dword [cdp]
	mov	al, 0x85	; code for JNE
	mov	edx, [cdp]
	mov	[edx], al
	inc	dword [cdp]

	mov	eax, 7
	call	PushControlFlow
	add	dword [cdp], 4

	ret


IMMWORD 'BREAK'
	call	CheckCompileMode

	mov	ecx, [cfDepth]
	cmp	ecx, 0
	je	ForthBreakErr
	cmp	dword [CFstackID+ecx*4-4], 7
	jne	ForthBreakErr

; **************************************
	mov	eax, 0xE9	       ; code for JMP
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 5

; **************************************

	mov	eax, [cdp]
	sub	eax, 4
	sub	eax, dword [CFstackAddr+ecx*4-4]  ; now eax contains an offset
	mov	ecx, [CFstackAddr+ecx*4-4]

	mov	[ecx], eax
	dec	[cfDepth]

	mov	eax, 10
	call	PushControlFlow

	jmp	ForthBreakEnd

ForthBreakErr:
	mov	eax, MsgBREAK
	call	TypeMessage
	call	Abort


ForthBreakEnd:

	ret

IMMWORD 'ENDOF'
	call	CheckCompileMode

	mov	ecx, [cfDepth]
	cmp	ecx, 0
	je	ForthEndOfErr
	cmp	dword [CFstackID+ecx*4-4], 7
	jne	ForthEndOfErr

	mov	eax, [cdp]
	sub	eax, 4
	sub	eax, dword [CFstackAddr+ecx*4-4]  ; now eax contains an offset
	mov	ecx, [CFstackAddr+ecx*4-4]

	mov	[ecx], eax
	dec	[cfDepth]
	jmp	ForthEndOfEnd

ForthEndOfErr:
	mov	eax, MsgENDOF
	call	TypeMessage
	call	Abort

ForthEndOfEnd:

	ret

IMMWORD '<OF>'
	call	CheckCompileMode

	mov	esi, CodeWithinOf
	mov	edi, [cdp]
	mov	ecx, CODEWITHINOFSIZE
	add	[cdp], ecx
	repz	movsb

	mov	al, 0x0F
	mov	edx, [cdp]
	mov	[edx], al
	inc	dword [cdp]
	mov	al, 0x85	; code for JNE
	mov	edx, [cdp]
	mov	[edx], al
	inc	dword [cdp]

	mov	eax, 7
	call	PushControlFlow
	add	dword [cdp], 4

	ret


IMMWORD 'DO'
	call	CheckCompileMode

	mov	esi, CodeDo
	mov	edi, [cdp]
	mov	ecx, DOSIZE
	add	[cdp], ecx
	repz	movsb

	mov	eax, 0xB8	       ; code for MOV EAX, NNNN
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, [cdp]	       ; compile [C]HERE as literal
	add	eax, 4
	add	eax, DO2SIZE
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	mov	esi, CodeDo2
	mov	edi, [cdp]
	mov	ecx, DO2SIZE
	add	[cdp], ecx
	repz	movsb

	ret

IMMWORD 'FOR'
	call	CheckCompileMode
	mov	esi, CodeFor
	mov	edi, [cdp]
	mov	ecx, FORSIZE
	add	[cdp], ecx
	repz	movsb

	mov	eax, 0xB8	       ; code for MOV EAX, NNNN
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, [cdp]	       ; compile [C]HERE as literal
	add	eax, 4
	add	eax, DO2SIZE
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	mov	esi, CodeDo2
	mov	edi, [cdp]
	mov	ecx, DO2SIZE
	add	[cdp], ecx
	repz	movsb
	ret

IMMWORD 'LOOP'
	call	CheckCompileMode

	mov	esi, CodeLoop
	mov	edi, [cdp]
	mov	ecx, LOOPSIZE
	add	[cdp], ecx
	repz	movsb

	ret

IMMWORD '+LOOP'
	call	CheckCompileMode

	mov	esi, CodePlusLoop
	mov	edi, [cdp]
	mov	ecx, PLUSLOOPSIZE
	add	[cdp], ecx
	repz	movsb

	ret

IMMWORD 'NEXT'
	call	CheckCompileMode

	mov	esi, CodeNext
	mov	edi, [cdp]
	mov	ecx, NEXTSIZE
	add	[cdp], ecx
	repz	movsb
	ret

IMMWORD 'TO'

ForthTOStart:
	call	Parse
	call	FindWord
	cmp	eax, NotFound
	je	ForthToErr

	mov	ecx, [state]
	cmp	ecx, 0
	jne	ForthToCompile

	add	eax, 1
	mov	ecx, [Depth]
	mov	edx, [Dstack+ecx*4-4]
	mov	[eax], edx
	dec	dword [Depth]
	jmp	ForthToEnd

ForthToCompile:

	mov	ecx, 0xB8	       ; code for MOV EAX, NNNN
	mov	edx, [cdp]
	mov	[edx], cl
	add	dword [cdp], 1

	mov	edx, [cdp]
	inc	eax
	mov	[edx], eax
	add	dword [cdp], 4

	mov	esi, CodeTO
	mov	edi, [cdp]
	mov	ecx, CODETOSIZE
	add	[cdp], ecx
	repz	movsb

	jmp	ForthToEnd

ForthToErr:

	jmp	NotFoundError

ForthToEnd:

	ret

IMMWORD 'AS'
	jmp	ForthTOStart
	ret

IMMWORD '+TO'

	call	Parse
	call	FindWord
	cmp	eax, NotFound
	je	ForthPlusToErr

	mov	ecx, [state]
	cmp	ecx, 0
	jne	ForthPlusToCompile

	add	eax, 1
	mov	ecx, [Depth]
	mov	edx, [Dstack+ecx*4-4]
	add	[eax], edx
	dec	dword [Depth]
	jmp	ForthPlusToEnd

ForthPlusToCompile:

	mov	ecx, 0xB8	       ; code for MOV EAX, NNNN
	mov	edx, [cdp]
	mov	[edx], cl
	add	dword [cdp], 1

	mov	edx, [cdp]
	inc	eax
	mov	[edx], eax
	add	dword [cdp], 4

	mov	esi, CodePlusTO
	mov	edi, [cdp]
	mov	ecx, CODEPLUSTOSIZE
	add	[cdp], ecx
	repz	movsb

	jmp	ForthPlusToEnd

ForthPlusToErr:

	jmp	NotFoundError

ForthPlusToEnd:

	ret

IMMWORD 'FROM'

	call	Parse
	call	FindWord
	cmp	eax, NotFound
	je	ForthFromErr

	mov	ecx, [state]
	cmp	ecx, 0
	jne	ForthFromCompile

	add	eax, 1
	mov	ecx, [Depth]
	mov	eax, [eax]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	jmp	ForthFromEnd

ForthFromCompile:

	mov	ecx, 0xB8	       ; code for MOV EAX, NNNN
	mov	edx, [cdp]
	mov	[edx], cl
	add	dword [cdp], 1

	mov	edx, [cdp]
	inc	eax
	mov	[edx], eax
	add	dword [cdp], 4

	mov	esi, CodeFROM
	mov	edi, [cdp]
	mov	ecx, CODEFROMSIZE
	add	[cdp], ecx
	repz	movsb

	jmp	ForthFromEnd

ForthFromErr:

	jmp	NotFoundError

ForthFromEnd:

	ret

IMMWORD 'RECURSE'
	ret

FWORD	'LIT,'

ForthLitCompile:

	mov	eax, 0xB8	       ; code for mov eax, NNNN
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4
	dec	dword [Depth]

	mov	eax, 0xE8	       ; code for CALL
	mov	edx, [cdp]
	mov	[edx], al
	add	dword [cdp], 1

	mov	eax, PushingEax        ; compile CALL to 'Push EAX' code
	sub	eax, [cdp]
	sub	eax, 4
	mov	edx, [cdp]
	mov	[edx], eax
	add	dword [cdp], 4

	ret

IMMWORD "[']"

ForthFindWordImm:

;        call    CheckCompileMode

	mov	eax, [state]
	and	eax, eax
	je	ForthFindWord

	call	Parse
	call	FindWord
	cmp	eax, NotFound
	je	ForthImmFindErr
	cmp	eax, 0
	je	ForthImmFindErr

	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]

	call	ForthLitCompile

	jmp	ForthImmFindEnd

ForthImmFindErr:

	jmp	NotFoundError

ForthImmFindEnd:

	ret

FWORD	"'"
ForthFindWord:
	call	Parse
	call	FindWord
	cmp	eax, NotFound
	je	ForthFindErr
	cmp	eax, 0
	je	ForthFindErr

	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]

	jmp	ForthFindEnd

ForthFindErr:

	jmp	NotFoundError

ForthFindEnd:

	ret

FWORD	"LFA'"
ForthFindWordLFA:
	call	Parse
	call	FindWord
	cmp	eax, NotFound
	je	ForthFindLFAErr
	cmp	eax, 0
	je	ForthFindLFAErr

	mov	eax, [FoundLFA]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]

	jmp	ForthFindLFAEnd

ForthFindLFAErr:

	jmp	NotFoundError

ForthFindLFAEnd:

	ret

IMMWORD 'USE'
	jmp	ForthFindWordImm
	ret

IMMWORD '[COMPILE]'
	call	ForthFindWord
	call	ForthCall
	ret

FWORD	'QUAN'
	call	ForthCreate
	mov	eax, 0
	mov	ecx, [cdp]
	mov	[ecx-10], eax
	ret

FWORD	'VALUE'
	call	ForthCreate
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	dec	dword [Depth]
	mov	ecx, [cdp]
	mov	[ecx-10], eax
	ret

FWORD	'VECT'
	call	ForthCreate

	sub	dword [cdp], 11

	mov	al, 0xB8		; opcode of mov eax
	mov	ecx, [cdp]
	mov	[ecx], al
	inc	dword [cdp]

	mov	eax, ForthNoop
	mov	ecx, [cdp]
	mov	[ecx], eax
	add	dword [cdp], 4

	mov	al, 0xFF		; opcode of jmp eax
	mov	ecx, [cdp]
	mov	[ecx], al
	inc	dword [cdp]

	mov	al, 0xE0		; opcode of jmp eax
	mov	ecx, [cdp]
	mov	[ecx], al
	inc	dword [cdp]

	mov	al, 0xC3		; opcode of RET
	mov	ecx, [cdp]
	mov	[ecx], al
	inc	dword [cdp]

	ret

FWORD	'I'
	mov	ecx, [lDepth]
	mov	eax, [LStackI+ecx*4-4]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'J'
	mov	ecx, [lDepth]
	mov	eax, [LStackI+ecx*4-8]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'K'
	mov	ecx, [lDepth]
	mov	eax, [LStackI+ecx*4-12]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'IMAX'
	mov	ecx, [lDepth]
	mov	eax, [LStackImax+ecx*4-4]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'IADDR'
	mov	ecx, [lDepth]
	mov	eax, [LStackAddr+ecx*4-4]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'IJ'
	mov	ecx, [lDepth]
	mov	eax, [LStackImax+ecx*4-4]
	mov	edx, [LStackI+ecx*4-8]
	mul	edx
	add	eax, [LStackI+ecx*4-4]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

; 31 Oct 2012

FWORD	'[I]@'	; addr -- [addr + i*4]
	mov	ecx, [lDepth]
	mov	eax, [LStackI+ecx*4-4]
	mov	ecx, [Depth]
	mov	edx, [Dstack+ecx*4-4]
	mov	eax, dword [edx+eax*4]
	mov	dword [Dstack+ecx*4-4], eax
	ret

FWORD	'[I]!'	; data, addr --
	mov	ecx, [Depth]
	mov	edx, [Dstack+ecx*4-4]
	mov	eax, dword [Dstack+ecx*4-8]
	mov	ecx, [lDepth]
	mov	ecx, [LStackI+ecx*4-4]
	mov	dword [edx+ecx*4], eax
	ret

FWORD	'[I]F@'  ; addr -- f: [addr + i*8]
	mov	ecx, [lDepth]
	mov	eax, [LStackI+ecx*4-4]
	mov	ecx, [Depth]
	mov	edx, [Dstack+ecx*4-4]
	shl	eax, 3
	add	eax, edx
	fld	qword [eax]
	sub	[Depth], 1
	ret

FWORD	'[I]F!'  ; addr, f: data --
	mov	ecx, [Depth]
	mov	edx, [Dstack+ecx*4-4]
	mov	ecx, [lDepth]
	mov	eax, [LStackI+ecx*4-4]
	shl	eax, 3
	add	eax, edx
	fstp	qword [eax]
	ret


; ------------------------------------------

FWORD	'>L'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	mov	ecx, [localDepth]
	mov	dword [Lstack+ecx*8], eax
	dec	dword [Depth]
	inc	dword [localDepth]
	ret

FWORD	'L>'
	mov	ecx, [localDepth]
	mov	eax, dword [Lstack+ecx*8-8]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	dec	dword [localDepth]
	ret

FWORD	'L@'
	mov	ecx, [localDepth]
	mov	eax, dword [Lstack+ecx*8-8]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'LDROP'
	dec	dword [localDepth]
	ret

FWORD	'>FRAME'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	mov	ecx, [frameDepth]
	mov	dword [FrameStack+ecx*4], eax
	dec	dword [Depth]
	inc	dword [frameDepth]
	ret

FWORD	'FRAME>'
	mov	ecx, [frameDepth]
	mov	eax, dword [FrameStack+ecx*4-4]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	dec	dword [frameDepth]
	ret

FWORD	'L>F'
	mov	ecx, [localDepth]
	fld	qword [Lstack+ecx*8-8]
	dec	dword [localDepth]
	ret

FWORD	'F>L'
	mov	ecx, [localDepth]
	fstp	qword [Lstack+ecx*8]
	inc	dword [localDepth]
	ret

FWORD	'L>SF'
	mov	ecx, [localDepth]
	fld	dword [Lstack+ecx*8-8]
	dec	dword [localDepth]
	ret

FWORD	'SF>L'
	mov	ecx, [localDepth]
	fstp	dword [Lstack+ecx*8]
	inc	dword [localDepth]
	ret

FWORD	'S>F'
	mov	ecx, [Depth]
	fild	dword [Dstack+ecx*4-4]
	dec	dword [Depth]
	ret

FWORD	'F>S'
	mov	ecx, [Depth]
	fistp	dword [Dstack+ecx*4]
	inc	dword [Depth]
	ret

FWORD	'FDUP'
	fld	st0
	ret

FWORD	'F2DUP'
	fld	st1
	fld	st1
	ret

FWORD	'FDROP'
	fstp	st0
	ret

FWORD	'FSWAP'
	fxch	st1
	ret

FWORD	'FOVER'
	fld	st1
	ret

FWORD	'FROT'
	fxch	st1
	fxch	st2
	ret

FWORD	'F+'
	faddp	st1, st0
	ret

FWORD	'F-'
	fsubp	st1, st0
	ret

FWORD	'F*'
	fmulp	st1, st0
	ret

FWORD	'F/'
	fdivp	st1, st0
	ret

FWORD	'FSIN'
	fsin
	ret

FWORD	'FCOS'
	fcos
	ret

FWORD	'FSINCOS'
	fsincos
	ret

FWORD	'FSQRT'
	fsqrt
	ret

FWORD	'FATAN'
	fld1
	fpatan
	ret

FWORD	'FPATAN'
	fpatan
	ret

FWORD	'FABS'
	fabs
	ret

FWORD	'FNEGATE'
	fchs
	ret

FWORD	'F@'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	fld	qword [eax]
	dec	dword [Depth]
	ret

FWORD	'SF@'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	fld	dword [eax]
	dec	dword [Depth]
	ret

FWORD	'F!'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	fstp	qword [eax]
	dec	dword [Depth]
	ret

FWORD	'F+!'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	fld	qword [eax]
	faddp	st1, st0
	fstp	qword [eax]
	dec	dword [Depth]
	ret

FWORD	'SF+!'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	fld	dword [eax]
	faddp	st1, st0
	fstp	dword [eax]
	dec	dword [Depth]
	ret

FWORD	'SF!'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	fstp	dword [eax]
	dec	dword [Depth]
	ret

FWORD	'10.0'
	fld tbyte [ten]
	mov	eax, [CanDispatch]
	cmp	eax, 0
	je	code_ften_no
	mov	eax, [state]
	cmp	eax, 0
	jne	code_ften_no

	call	ForthDispatchFNumber

code_ften_no:
	ret

FWORD	'PI'
ForthPi:
	fldpi
	mov	eax, [CanDispatch]
	cmp	eax, 0
	je	code_fpi_no
	mov	eax, [state]
	cmp	eax, 0
	jne	code_fpi_no

	call	ForthDispatchFNumber

code_fpi_no:
	ret

FWORD	'FPI'
	jmp	ForthPi
	ret

FWORD	'F0>'
FZeroGreater:
	fldz
	fcompp
	fnstsw	ax
	pushf
	sahf

	mov	eax, 0
	jnc	FGreaterYes
	mov	eax, 0xffffffff
FGreaterYes:
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	popf
	ret

FWORD	'F0<'
	fldz
	fcompp
	fnstsw	ax
	pushf
	sahf

	mov	eax, 0
	jc	FLesserYes
	mov	eax, 0xffffffff
FLesserYes:
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	popf
	ret

FWORD	'F0='
FZeroEqual:
	fldz
	fcompp
	fnstsw	ax
	pushf
	sahf

	mov	eax, 0
	jnz	FZeroYes
	mov	eax, 0xffffffff
FZeroYes:
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	popf
	ret

FWORD	'FMIN'
	fcom
	fnstsw	ax
	pushf
	sahf
	jnc	FMinGr
	fxch	st1
FMinGr:
	fstp	st0

	popf
	ret

FWORD	'FMAX'
	fcom
	fnstsw	ax
	pushf
	sahf
	jc	FMaxGr
	fxch	st1
FMaxGr:
	fstp	st0

	popf
	ret


FWORD	'F>'
FGreater:
	fcompp
	fnstsw	ax
	pushf
	sahf

	mov	eax, 0
	jnc	FGrYes
	mov	eax, 0xffffffff
FGrYes:
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	popf
	ret

FWORD	'F<'
	fcompp
	fnstsw	ax
	pushf
	sahf

	mov	eax, 0
	jc	FLessYes
	mov	eax, 0xffffffff
FLessYes:
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	popf
	ret

FWORD	'F='
FEqual:
	fcompp
	fnstsw	ax
	pushf
	sahf

	mov	eax, 0
	jnz	FEqualYes
	mov	eax, 0xffffffff
FEqualYes:
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	popf
	ret

FWORD	'F2^X'
Forth_x_pow2:
	fld	st0
	fld1
	fxch	st1
	fprem
	f2xm1
	faddp	st1, st0
	fscale
	fstp	st1
	ret

FWORD	'FEXP'
	fldl2e
	fmulp	st1, st0
	jmp	Forth_x_pow2
	ret

FWORD	'FGAUSS'    ; f:delta, sigma -- f:gauss
	fdivp	st1, st0
	fld	st0
	fmulp	st1, st0
	fldl2e
	fmulp	st1, st0
	call	Forth_x_pow2
	fld1
	fxch	st1
	fdivp	st1, st0

	ret

FWORD	'FLOG2'
	fld	st0
	fld1
	fcompp
	fnstsw	ax
	pushf
	sahf
	jne	Forth_Log2Calc
	fldz
	jmp	Forth_Log2End

Forth_Log2Calc:
	fld1
	fxch	st1
	fyl2x
Forth_Log2End:
	popf
	ret

FWORD	'FLN'
	fld	st0
	fld1
	fcompp
	fnstsw	ax
	pushf
	sahf
	jne	Forth_LnCalc
	fldz
	jmp	Forth_LnEnd

Forth_LnCalc:
	fld1
	fldl2e
	fdivp	st1, st0
	fxch	st1
	fyl2x
Forth_LnEnd:
	popf
	ret

FWORD	'FLG'
	fld	st0
	fld1
	fcompp
	fnstsw	ax
	pushf
	sahf
	jne	Forth_LgCalc
	fldz
	jmp	Forth_LgEnd

Forth_LgCalc:

	fld1
	fldl2t
	fdivp	st1, st0
	fxch	st1
	fyl2x
Forth_LgEnd:
	popf
	ret

FWORD	'F.'
FPrint:
	fld	st0
	call	FZeroEqual
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	dec	dword [Depth]
	cmp	eax, 0xffffffff
	jne	FDotNot0
	mov	al, '0'
	call	PushingEax
	call	VectEmit
	mov	al, '.'
	call	PushingEax
	call	VectEmit
	mov	al, '0'
	call	PushingEax
	call	VectEmit
	mov	al, 32
	call	PushingEax
	call	VectEmit
	fstp	st0
	jmp	FDotEnd

FDotNot0:
	fld	st0
	call	FZeroGreater
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	dec	dword [Depth]
	cmp	eax, 0xffffffff
	je	FDotPlus
	mov	al, '-'
	call	PushingEax
	call	VectEmit
	fabs

FDotPlus:

	xor	eax, eax
	mov	dword [_pad], eax

FDotNormalizeTen:

	fld	st0
	fld	tbyte [ten]
	fcompp
	fnstsw	ax
	pushf
	sahf
	jnc	FDotNormalizeOne
	fld	tbyte [ten]
	fdivp	st1, st0
	inc	dword [_pad]
	popf
	jmp	FDotNormalizeTen

FDotNormalizeOne:

	popf

FDotNormalizeOneLoop:

	fld	st0
	fld1
	fcompp
	fnstsw	ax
	pushf
	sahf
	jc	FDotNormalizeEnd
	fld	tbyte [ten]
	fmulp	st1, st0
	dec	dword [_pad]
	popf
	jmp	FDotNormalizeOneLoop

FDotNormalizeEnd:

	popf

	mov	edx, 0

FDotPrintMantissa:

	push	edx

	cmp	edx, 1
	jne	FDotItsNotDot
	mov	eax, '.'
	call	PushingEax
	call	VectEmit

FDotItsNotDot:

	fld	tbyte [float9]
	fld	st1
	fcompp
	fnstsw	ax
	pushf
	sahf
	jc	FDotMant8OrLess

	mov	eax, '9'
	call	PushingEax
	call	VectEmit
	fld	tbyte [float9]
	fsubp	st1, st0
	fld	tbyte [ten]
	fmulp	st1, st0
	jmp	FDotGotoNextDigit

FDotMant8OrLess:

	popf

	fld	tbyte [float8]
	fld	st1
	fcompp
	fnstsw	ax
	pushf
	sahf
	jc	FDotMant7OrLess

	mov	eax, '8'
	call	PushingEax
	call	VectEmit
	fld	tbyte [float8]
	fsubp	st1, st0
	fld	tbyte [ten]
	fmulp	st1, st0
	jmp	FDotGotoNextDigit

FDotMant7OrLess:

	popf

	fld	tbyte [float7]
	fld	st1
	fcompp
	fnstsw	ax
	pushf
	sahf
	jc	FDotMant6OrLess

	mov	eax, '7'
	call	PushingEax
	call	VectEmit
	fld	tbyte [float7]
	fsubp	st1, st0
	fld	tbyte [ten]
	fmulp	st1, st0
	jmp	FDotGotoNextDigit

FDotMant6OrLess:

	popf

	fld	tbyte [float6]
	fld	st1
	fcompp
	fnstsw	ax
	pushf
	sahf
	jc	FDotMant5OrLess

	mov	eax, '6'
	call	PushingEax
	call	VectEmit
	fld	tbyte [float6]
	fsubp	st1, st0
	fld	tbyte [ten]
	fmulp	st1, st0
	jmp	FDotGotoNextDigit

FDotMant5OrLess:

	popf

	fld	tbyte [float5]
	fld	st1
	fcompp
	fnstsw	ax
	pushf
	sahf
	jc	FDotMant4OrLess

	mov	eax, '5'
	call	PushingEax
	call	VectEmit
	fld	tbyte [float5]
	fsubp	st1, st0
	fld	tbyte [ten]
	fmulp	st1, st0
	jmp	FDotGotoNextDigit

FDotMant4OrLess:

	popf

	fld	tbyte [float4]
	fld	st1
	fcompp
	fnstsw	ax
	pushf
	sahf
	jc	FDotMant3OrLess

	mov	eax, '4'
	call	PushingEax
	call	VectEmit
	fld	tbyte [float4]
	fsubp	st1, st0
	fld	tbyte [ten]
	fmulp	st1, st0
	jmp	FDotGotoNextDigit

FDotMant3OrLess:

	popf

	fld	tbyte [float3]
	fld	st1
	fcompp
	fnstsw	ax
	pushf
	sahf
	jc	FDotMant2OrLess

	mov	eax, '3'
	call	PushingEax
	call	VectEmit
	fld	tbyte [float3]
	fsubp	st1, st0
	fld	tbyte [ten]
	fmulp	st1, st0
	jmp	FDotGotoNextDigit

FDotMant2OrLess:

	popf

	fld	tbyte [float2]
	fld	st1
	fcompp
	fnstsw	ax
	pushf
	sahf
	jc	FDotMant1OrLess

	mov	eax, '2'
	call	PushingEax
	call	VectEmit
	fld	tbyte [float2]
	fsubp	st1, st0
	fld	tbyte [ten]
	fmulp	st1, st0
	jmp	FDotGotoNextDigit

FDotMant1OrLess:

	popf

	fld	tbyte [float1]
	fld	st1
	fcompp
	fnstsw	ax
	pushf
	sahf
	jc	FDotMant0

	mov	eax, '1'
	call	PushingEax
	call	VectEmit
	fld	tbyte [float1]
	fsubp	st1, st0
	fld	tbyte [ten]
	fmulp	st1, st0
	jmp	FDotGotoNextDigit

FDotMant0:

	mov	eax, '0'
	call	PushingEax
	call	VectEmit
	fld	tbyte [ten]
	fmulp	st1, st0

FDotGotoNextDigit:

	popf


	pop	edx
	inc	edx
	cmp	edx, 10
	jne	FDotPrintMantissa

FExponent:

	mov	eax, 'E'
	call	PushingEax
	call	VectEmit
	mov	eax, dword [_pad]
	mov	edx, [Depth]
	mov	[Dstack+edx*4], eax
	inc	dword [Depth]
	call	ForthDot

FDotEnd:

	fstp	st0

	ret

FWORD	'X*X'  ;  addrx, addrpsi, len --
	push	esi
	push	edi
	mov	eax, [Depth]
	mov	ecx, [Dstack+eax*4-4]
	mov	esi, [Dstack+eax*4-8]
	mov	edi, [Dstack+eax*4-12]
	fldz
ForthConv1:
	fld	dword [edi]
	fild	word [esi]
	fmulp	st1, st0
	faddp	st1, st0
	dec	ecx
	add	edi, 4
	add	esi, 2
	cmp	ecx, 0
	jne	ForthConv1

	pop	edi
	pop	esi
	ret

FWORD	'D*D'  ;  addrx, addrpsi, len --
	push	esi
	push	edi
	mov	eax, [Depth]
	mov	ecx, [Dstack+eax*4-4]
	mov	esi, [Dstack+eax*4-8]
	mov	edi, [Dstack+eax*4-12]
	fldz
ForthDConv1:
	fld	qword [edi]
	fld	qword [esi]
	fmulp	st1, st0
	faddp	st1, st0
	dec	ecx
	add	edi, 8
	add	esi, 8
	cmp	ecx, 0
	jne	ForthDConv1

	pop	edi
	pop	esi
	ret



FWORD	'SSE:F(T)*G(T)DT' ;  addrx, addrpsi, len --
	push	esi
	push	edi
	mov	edx, Zeroes16
	movups	xmm0, [edx]
	mov	edx, [Depth]
	mov	ecx, [Dstack+edx*4-4]
	mov	esi, [Dstack+edx*4-8]
	mov	edi, [Dstack+edx*4-12]
	sub	dword [Depth], 3
	mov	eax, esi
	and	eax, 15
	jnz	SSE_ConvolutionUnaligned
	mov	eax, edi
	and	eax, 15
	jnz	SSE_ConvolutionUnaligned

SSE_Convolution1:
	movaps	xmm1, [esi]
	movaps	xmm2, [edi]
	mulps	xmm1, xmm2
	addps	xmm0, xmm1
	add	esi,  16
	add	edi,  16
	dec	ecx
	cmp	ecx, 0
	jne	SSE_Convolution1
	jmp	SSE_ConvolutionEnd

SSE_ConvolutionUnaligned:
	movups	xmm1, [esi]
	movups	xmm2, [edi]
	mulps	xmm1, xmm2
	addps	xmm0, xmm1
	add	esi,  16
	add	edi,  16
	dec	ecx
	cmp	ecx, 0
	jne	SSE_ConvolutionUnaligned

SSE_ConvolutionEnd:
	pop	edi
	pop	esi
	ret

FWORD	'SSE!'
	mov	edx, [Depth]
	mov	edx, [Dstack+edx*4-4]
	movups	[edx], xmm0
	dec	dword [Depth]
	ret

FWORD	'SSE:[X]+=[Y]'	; arr1, arr2, quads --
; add elements of y to elements of x

	mov	edx, [Depth]
	mov	ecx, [Dstack+edx*4-4]
	mov	eax, [Dstack+edx*4-8]  ; arr2
	mov	edx, [Dstack+edx*4-12] ; arr1

SSE_Accumulate:
	cmp	ecx, 0
	je	SSE_AccumulateEnd
	movups	xmm0, [edx]
	movups	xmm1, [eax]
	addps	xmm0, xmm1
	movups	[edx], xmm0
	add	eax, 16
	add	edx, 16
	dec	ecx
	jmp	SSE_Accumulate

SSE_AccumulateEnd:
	sub	dword [Depth], 3
	ret

; -------- API interface -------

FWORD	'LOADLIBRARY'
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	invoke	LoadLibraryA, eax
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4-4], eax
	ret

FWORD	'GETPROCADDRESS'  ; hModule, lpProcname --
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	mov	ecx, [Dstack+ecx*4-8]
	invoke	GetProcAddress, ecx, eax
	dec	dword [Depth]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4-4], eax
	ret

FWORD	'API0' ; addr --
ForthAPI0:
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	call	eax
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4-4], eax
	ret

FWORD	'API1' ; param1, addr --
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-8]
	push	eax
	mov	eax, [Dstack+ecx*4-4]
	call	eax
	dec	dword [Depth]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4-4], eax
	ret

FWORD	'API2' ; param1, param2, addr --
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-8]
	push	eax
	mov	eax, [Dstack+ecx*4-12]
	push	eax
	mov	eax, [Dstack+ecx*4-4]
	call	eax
	sub	dword [Depth],2
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4-4], eax
	ret

FWORD	'API3' ; param1, param2, param3, addr --
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-8]
	push	eax
	mov	eax, [Dstack+ecx*4-12]
	push	eax
	mov	eax, [Dstack+ecx*4-16]
	push	eax
	mov	eax, [Dstack+ecx*4-4]
	call	eax
	sub	dword [Depth], 3
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4-4], eax
	ret

FWORD	'API4' ; param1, param2, param3, param4, addr --
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-8]
	push	eax
	mov	eax, [Dstack+ecx*4-12]
	push	eax
	mov	eax, [Dstack+ecx*4-16]
	push	eax
	mov	eax, [Dstack+ecx*4-20]
	push	eax
	mov	eax, [Dstack+ecx*4-4]
	sub	dword [Depth], 4
	call	eax
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4-4], eax
	ret

FWORD	'API5' ; param1, param2, param3, param4, param5, addr --
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-8]
	push	eax
	mov	eax, [Dstack+ecx*4-12]
	push	eax
	mov	eax, [Dstack+ecx*4-16]
	push	eax
	mov	eax, [Dstack+ecx*4-20]
	push	eax
	mov	eax, [Dstack+ecx*4-24]
	push	eax
	mov	eax, [Dstack+ecx*4-4]
	sub	dword [Depth], 4
	call	eax
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4-4], eax
	ret

FWORD	'API6' ; param1, param2, param3, param4, param5, param6, addr --
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-8]
	push	eax
	mov	eax, [Dstack+ecx*4-12]
	push	eax
	mov	eax, [Dstack+ecx*4-16]
	push	eax
	mov	eax, [Dstack+ecx*4-20]
	push	eax
	mov	eax, [Dstack+ecx*4-24]
	push	eax
	mov	eax, [Dstack+ecx*4-28]
	push	eax
	mov	eax, [Dstack+ecx*4-4]
	sub	dword [Depth], 4
	call	eax
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4-4], eax
	ret

FWORD	'API9' ; param1, param2, param3,... param9, addr --
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-8]
	push	eax
	mov	eax, [Dstack+ecx*4-12]
	push	eax
	mov	eax, [Dstack+ecx*4-16]
	push	eax
	mov	eax, [Dstack+ecx*4-20]
	push	eax
	mov	eax, [Dstack+ecx*4-24]
	push	eax
	mov	eax, [Dstack+ecx*4-28]
	push	eax
	mov	eax, [Dstack+ecx*4-32]
	push	eax
	mov	eax, [Dstack+ecx*4-36]
	push	eax
	mov	eax, [Dstack+ecx*4-40]
	push	eax
	mov	eax, [Dstack+ecx*4-4]
	sub	dword [Depth], 9
	call	eax
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4-4], eax
	ret


FWORD	'API'	; -- param1, .. paramn, N, addr
	mov	ecx, [Depth]		; check for 0 params
	mov	eax, [Dstack+ecx*4-8]
	cmp	eax, 0
	jne	API_Not0Params
	mov	eax, [Dstack+ecx*4-4]	; get addr
	mov	[Dstack+ecx*4-8], eax	; and replace N with addr
	dec	dword [Depth]		; correct stack depth
	jmp	ForthAPI0		; goto API0

API_Not0Params:
	mov	ecx, [Depth]
	mov	edx, [Dstack+ecx*4-8]
	shl	ecx, 2
	sub	ecx, 8
API_OneMoreParam:
	sub	ecx, 4
	mov	eax, [Dstack+ecx]
	push	eax
	dec	edx
	cmp	edx, 0
	jne	API_OneMoreParam
	mov	ecx, [Depth]
	mov	edx, [Dstack+ecx*4-8]
	inc	edx
	mov	eax, [Dstack+ecx*4-4]
	sub	[Depth], edx
	call	eax
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4-4], eax
	ret

FWORD	'hInstance'
	mov	ecx, [Depth]
	mov	eax, [hinstance]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'hwnd'
	mov	ecx, [Depth]
	mov	eax, hwnd
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'LIST'
	mov	ecx, [Depth]
	mov	ecx, [Dstack+ecx*4-4]
	dec	dword [Depth]
	mov	edx, 0

ListLoop:

	push	ecx
	push	edx
	xor	eax, eax
	mov	al, [ecx]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	add	dword [wherey], 16
	mov	dword [wherex], 0
	call	ForthDot
	pop	edx
	pop	ecx
	inc	ecx
	inc	edx
	cmp	edx, 32
	jne	ListLoop

	ret

FWORD	'GETCOMMANDLINE'
	invoke	GetCommandLine
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'GETPARAMSTR'
	mov	eax, [ParamStr]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'CLEARTIB'
	call	ForthTibClear
	xor	eax, eax
	mov	[TibPtr], eax
	mov	[span], eax
	ret

FWORD	'BYE1'
ForthBye1:
	jmp	wmdestroy
	ret

FWORD	'ToolButtons'
	mov	eax, ToolButtons
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'ToolButtonsFixed'
	mov	eax, ToolButtonsFixed
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'ToolButtonsLimited'
	mov	eax, ToolButtonsLimited
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'ToolButtonsSize'
	mov	eax, ToolButtonsSize
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'ToolButtonsLimit'
	mov	eax, ToolButtonsLimit
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'ToolButtonCaption' ; n -- lpstr_caption
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	shl	eax, 8
	add	eax, ToolButtonCaption
	mov	[Dstack+ecx*4-4], eax
	ret

FWORD	'ToolButtonGlyph' ; n -- lpstr_caption
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	shl	eax, 8
	add	eax, ToolButtonGlyph
	mov	[Dstack+ecx*4-4], eax
	ret

FWORD	'ToolButtonScript' ; n -- lpstr_caption
	mov	ecx, [Depth]
	mov	eax, [Dstack+ecx*4-4]
	shl	eax, 8
	add	eax, ToolButtonScript
	mov	[Dstack+ecx*4-4], eax
	ret


FWORD	'GL_POINTS'
	PUSHSTACK GL_POINTS

FWORD	'GL_LINES'
	PUSHSTACK GL_LINES

FWORD	'GL_LINE_STRIP'
	PUSHSTACK GL_LINE_STRIP

FWORD	'GL_TRIANGLES'
	PUSHSTACK GL_TRIANGLES

FWORD	'GL_TRIANGLE_STRIP'
	PUSHSTACK GL_TRIANGLE_STRIP

FWORD	'GL_TRIANGLE_FAN'
	PUSHSTACK GL_TRIANGLE_FAN

FWORD	'GL_QUADS'
	PUSHSTACK GL_QUADS

FWORD	'GL_QUAD_STRIP'
	PUSHSTACK GL_QUAD_STRIP

FWORD	'GL_POLYGON'
	PUSHSTACK GL_POLYGON

FWORD	'GL_CW'
	PUSHSTACK GL_CW

FWORD	'GL_CCW'
	PUSHSTACK GL_CCW

FWORD	'GL_BLEND'
	PUSHSTACK GL_BLEND

FWORD	'GL_SRC_ALPHA'
	PUSHSTACK GL_SRC_ALPHA

FWORD	'GL_ONE_MINUS_SRC_ALPHA'
	PUSHSTACK GL_ONE_MINUS_SRC_ALPHA

FWORD	'GL_CULL_FACE'
	PUSHSTACK GL_CULL_FACE

FWORD	'GL_DEPTH_TEST'
	PUSHSTACK GL_DEPTH_TEST

FWORD	'GL_DITHER'
	PUSHSTACK GL_DITHER

FWORD	'GL_FOG'
	PUSHSTACK GL_FOG

FWORD	'GL_LIGHTING'
	PUSHSTACK GL_LIGHTING

FWORD	'GL_LIGHT0'
	PUSHSTACK GL_LIGHT0

FWORD	'GL_LIGHT1'
	PUSHSTACK GL_LIGHT1

FWORD	'GL_LIGHT2'
	PUSHSTACK GL_LIGHT2

FWORD	'GL_LIGHT3'
	PUSHSTACK GL_LIGHT3

FWORD	'GL_LIGHT4'
	PUSHSTACK GL_LIGHT4

FWORD	'GL_LIGHT5'
	PUSHSTACK GL_LIGHT5

FWORD	'GL_LIGHT6'
	PUSHSTACK GL_LIGHT6

FWORD	'GL_LIGHT7'
	PUSHSTACK GL_LIGHT7

FWORD	'GL_POINT_SMOOTH'
	PUSHSTACK GL_POINT_SMOOTH

FWORD	'GL_LINE_SMOOTH'
	PUSHSTACK GL_LINE_SMOOTH

FWORD	'GL_LINE_STIPPLE'
	PUSHSTACK GL_LINE_STIPPLE

FWORD	'GL_POLYGON_SMOOTH'
	PUSHSTACK GL_POLYGON_SMOOTH

FWORD	'GL_SCISSOR_TEST'
	PUSHSTACK GL_SCISSOR_TEST

FWORD	'GL_STENCIL_TEST'
	PUSHSTACK GL_STENCIL_TEST

FWORD	'GL_TEXTURE_1D'
	PUSHSTACK GL_TEXTURE_1D

FWORD	'GL_TEXTURE_2D'
	PUSHSTACK GL_TEXTURE_2D

FWORD	'GL_TEXTURE_3D'
	PUSHSTACK GL_TEXTURE_3D

FWORD	'GL_TEXTURE_GEN_S'
	PUSHSTACK GL_TEXTURE_GEN_S

FWORD	'GL_TEXTURE_GEN_T'
	PUSHSTACK GL_TEXTURE_GEN_T

FWORD	'GL_TEXTURE_GEN_R'
	PUSHSTACK GL_TEXTURE_GEN_R

FWORD	'GL_TEXTURE_GEN_Q'
	PUSHSTACK GL_TEXTURE_GEN_Q

FWORD	'GL_PROJECTION'
	PUSHSTACK GL_PROJECTION

FWORD	'GL_MODELVIEW'
	PUSHSTACK GL_MODELVIEW

FWORD	'GL_NORMALIZE'
	PUSHSTACK GL_NORMALIZE

FWORD	'GL_COLOR_BUFFER_BIT'
	PUSHSTACK GL_COLOR_BUFFER_BIT

FWORD	'GL_DEPTH_BUFFER_BIT'
	PUSHSTACK GL_DEPTH_BUFFER_BIT

FWORD	'GL_COLOR_MATERIAL'
	PUSHSTACK GL_COLOR_MATERIAL

FWORD	'GL_FLAT'
	PUSHSTACK GL_FLAT

FWORD	'GL_SMOOTH'
	PUSHSTACK GL_SMOOTH

FWORD	'GL_AMBIENT'
	PUSHSTACK GL_AMBIENT

FWORD	'GL_DIFFUSE'
	PUSHSTACK GL_DIFFUSE

FWORD	'GL_AMBIENT_AND_DIFFUSE'
	PUSHSTACK GL_AMBIENT_AND_DIFFUSE

FWORD	'GL_SPECULAR'
	PUSHSTACK GL_SPECULAR

FWORD	'GL_EMISSION'
	PUSHSTACK GL_EMISSION

FWORD	'GL_SHININESS'
	PUSHSTACK GL_SHININESS

FWORD	'GL_POSITION'
	PUSHSTACK GL_POSITION

FWORD	'GL_FRONT'
	PUSHSTACK GL_FRONT

FWORD	'GL_BACK'
	PUSHSTACK GL_BACK

FWORD	'GL_LINE'
	PUSHSTACK GL_LINE

FWORD	'GL_FILL'
	PUSHSTACK GL_FILL

FWORD	'GL_LIGHT_MODEL_TWO_SIDE'
	PUSHSTACK GL_LIGHT_MODEL_TWO_SIDE

FWORD	'GL_TEXTURE_GEN_MODE'
	PUSHSTACK GL_TEXTURE_GEN_MODE

FWORD	'GL_FOG_START'
	PUSHSTACK GL_FOG_START

FWORD	'GL_FOG_END'
	PUSHSTACK GL_FOG_END

FWORD	'GL_FOG_MODE'
	PUSHSTACK GL_FOG_MODE

FWORD	'GL_FOG_COLOR'
	PUSHSTACK GL_FOG_COLOR

FWORD	'GL_FOG_DENSITY'
	PUSHSTACK GL_FOG_DENSITY

FWORD	'GL_LINEAR'
	PUSHSTACK GL_LINEAR

FWORD	'GL_EXP'
	PUSHSTACK GL_EXP

FWORD	'GL_EXP2'
	PUSHSTACK GL_EXP2

FWORD	'GL_ACCUM'
	PUSHSTACK GL_ACCUM

FWORD	'GL_LOAD'
	PUSHSTACK GL_LOAD

FWORD	'GL_RETURN'
	PUSHSTACK GL_RETURN

FWORD	'GL_MULT'
	PUSHSTACK GL_MULT

FWORD	'GL_ADD'
	PUSHSTACK GL_ADD


FWORD	'GL_RGB'
	PUSHSTACK GL_RGB

FWORD	'GL_RGBA'
	PUSHSTACK GL_RGBA

FWORD	'GL_BGR'
	PUSHSTACK GL_BGR

FWORD	'GL_UNSIGNED_BYTE'
	PUSHSTACK GL_UNSIGNED_BYTE

FWORD	'GL_NEAREST'
	PUSHSTACK GL_NEAREST

FWORD	'GL_DECAL'
	PUSHSTACK GL_DECAL

FWORD	'GL_OBJECT_PLANE'
	PUSHSTACK GL_OBJECT_PLANE

FWORD	'GL_TEXTURE_MAG_FILTER'
	PUSHSTACK GL_TEXTURE_MAG_FILTER

FWORD	'GL_TEXTURE_MIN_FILTER'
	PUSHSTACK GL_TEXTURE_MIN_FILTER

FWORD	'GL_TEXTURE_ENV'
	PUSHSTACK GL_TEXTURE_ENV

FWORD	'GL_TEXTURE_ENV_MODE'
	PUSHSTACK GL_TEXTURE_ENV_MODE


FWORD	'STATE'
	mov	eax, state
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'BASE'
	mov	eax, base
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'LIMIT'
	mov	eax, limit
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'[C]LIMIT'
	mov	eax, climit
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'GETSTACK'
	mov	eax, Dstack
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'GETSCREEN'
	mov	eax, screen
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'GETDATA'
	mov	eax, [DataStart]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'GETCODE'
	mov	eax, [CodeStart]
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'CONTEXT'
	mov	eax, Context
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'CURRENT'
	mov	eax, Current
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'SOURCE'
	mov	eax, hSource
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'SDEPTH'
	mov	eax, sDepth
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'MAXX'
	mov	eax, maxx
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'OPAQUE'
	mov	eax, opaque
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'MOUSE-X'
	mov	eax, mousex
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'MOUSE-Y'
	mov	eax, mousey
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'MOUSE-Z'
	mov	eax, mousez
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'?.SPACE'
	mov	eax, EmTrailingSpace
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'DRAW2D'
	mov	eax, draw2d
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'CONSOLEX'
	mov	eax, ConsoleX
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'CONSOLEY'
	mov	eax, ConsoleY
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'CONSOLEL'
	mov	eax, ConsoleL
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'SCREEN.WIDTH'
	mov	eax, rc.right
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'SCREEN.HEIGTH'
	mov	eax, rc.bottom
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'TIMER_INTERVAL'
	mov	eax, timer_interval
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'SYMBOLS'
	mov	eax, symbols
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'RND'
	mov	eax, rnd
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'TIB'
	mov	eax, Tib
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'LINENUMBER'
	mov	eax, LineNumber
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'CAN-DISPATCH'
	mov	eax, CanDispatch
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'ROTATEANGLE'
	mov	eax, RotateAngle
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'glX'
	mov	eax, glX
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'glY'
	mov	eax, glY
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'glZ'
	mov	eax, glZ
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'glParams'
	mov	eax, glParams
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'INPUTBUF'
	mov	eax, inputbuf
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'VIEWPORT'
	mov	eax, ViewPort
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'X0Y0'
	mov	eax, x0y0
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'OBJECT-Z'
	mov	eax, object_z
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'OBJECT-ID'
	mov	eax, object_id
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'OBJECT-Z[]'
	mov	eax, Zpixel
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'OBJECT-ID[]'
	mov	eax, IDpixel
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'LASTKEY'
	mov	eax, lastkey
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'DEBUG'
	mov	eax, IsDebug
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'DEBUGIP'
	mov	eax, DebugIP
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'WINDOW.X'
	mov	eax, xsize
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'WINDOW.Y'
	mov	eax, ysize
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'PROCESSED'
	mov	eax, MsgProcessed
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'WMSG'
	mov	eax, WMsg
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'WPARAM'
	mov	eax, WParam
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'LPARAM'
	mov	eax, LParam
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'SMARTSTRING'
	mov	eax, smartString
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'ERRORMSGPOS'
	mov	eax, errormsgpos
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'ERRORMSGX'
	mov	eax, errormsgx
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret

FWORD	'ERRORMSGY'
	mov	eax, errormsgy
	mov	ecx, [Depth]
	mov	[Dstack+ecx*4], eax
	inc	dword [Depth]
	ret


;   *** quans  ***

FWORD	'HF-OUT'
ForthHFOUT:
	mov	eax, 0
	call	PushingEax
	ret

FWORD	'MAJOR-VERSION'
	mov	eax, MAJOR_VERSION
	call	PushingEax
	ret

FWORD	'MINOR-VERSION'
	mov	eax, MINOR_VERSION
	call	PushingEax
	ret

FWORD	'SUBVERSION'
	mov	eax, SUBVERSION
	call	PushingEax
	ret

FWORD	'BUILD-VERSION'
	mov	eax, BUILD_VERSION
	call	PushingEax
	ret

FWORD	'COLOR'
ForthColor:
	mov	eax, 0x00FF00
	call	PushingEax
	ret

FWORD	'BGCOLOR'
ForthBGColor:
	mov	eax, 0
	call	PushingEax
	ret

;   *** vectors ***

FWORD	'WINMSG'
WinMsg:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'3D'
GL3D:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'BYE'
VectBye:
	mov	eax, ForthBye1
	call	eax
	ret

FWORD	'EMIT'
VectEmit:
	mov	eax, ForthEmit
	call	eax
	ret

FWORD	'PIXEL'
VectPixel:
	mov	eax, ForthPixel
	call	eax
	ret

FWORD	'GETPIXEL'
VectGetPixel:
	mov	eax, ForthGetPixel
	call	eax
	ret

FWORD	'NUMBER'
VectNumber:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'DISPATCH-NUMBER'
ForthDispatchNumber:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'DISPATCH-FNUMBER'
ForthDispatchFNumber:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'OK'
VectOk:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'ABORT'
VectAbort:
	mov	eax, Abort1
	jmp	eax
	ret


FWORD	'<TIMER>'
VectTimer:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'<DEBUG>'
CallDebug:
	mov	eax, ForthNoop
	call	eax
	ret


FWORD	'<MOUSE_LEFT>'
VectMouseLeft:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'<MOUSE_RIGHT>'
VectMouseRight:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'<MOUSE_DBLLEFT>'
VectMouseDblLeft:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'<MOUSE_DBLRIGHT>'
VectMouseDblRight:
	mov	eax, ForthNoop
	call	eax
	ret


FWORD	'<MOUSE_LEFT_UP>'
VectMouseLeftUp:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'<MOUSE_RIGHT_UP>'
VectMouseRightUp:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'<MOUSE_WHEEL>'
VectMouseWheel:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'<MOUSE_MOVE>'
VectMouseMove:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'<WINDOW_RESIZE>'
VectWinResize:
	mov	eax, ForthNoop
	call	eax
	ret


FWORD	'K_CHAR'
VectKChar:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_LEFT'
VectKLeft:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_RIGHT'
VectKRight:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_UP'
VectKUp:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_DOWN'
VectKDown:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_HOME'
VectKHome:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_HOME'
VectKShiftHome:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_HOME'
VectKAltHome:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_HOME'
VectKCtrlHome:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_END'
VectKEnd:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_END'
VectKShiftEnd:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_END'
VectKAltEnd:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_END'
VectKCtrlEnd:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_PGUP'
VectKPgUp:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_PGUP'
VectKShiftPgUp:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_PGUP'
VectKCtrlPgUp:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_PGUP'
VectKAltPgUp:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_PGDOWN'
VectKPgDn:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_PGDOWN'
VectKShiftPgDn:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_PGDOWN'
VectKCtrlPgDn:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_PGDOWN'
VectKAltPgDn:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_DEL'
VectKDel:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_DEL'
VectKAltDel:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_DEL'
VectKCtrlDel:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_DEL'
VectKShiftDel:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_BACKSPACE'
VectKBackspace:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ENTER'
VectEnter:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_INSERT'
VectKIns:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_INSERT'
VectKAltIns:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_INSERT'
VectKCtrlIns:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_INSERT'
VectKShiftIns:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ESC'
VectKESC:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_LEFT'
VectKCtrlLeft:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_RIGHT'
VectKCtrlRight:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_UP'
VectKCtrlUp:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_DOWN'
VectKCtrlDown:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_LEFT'
VectKShiftLeft:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_RIGHT'
VectKShiftRight:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_UP'
VectKShiftUp:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_DOWN'
VectKShiftDown:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_F1'
VectKF1:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_F2'
VectKF2:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_F3'
VectKF3:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_F4'
VectKF4:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_F5'
VectKF5:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_F6'
VectKF6:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_F7'
VectKF7:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_F8'
VectKF8:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_F9'
VectKF9:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_F10'
VectKF10:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_F11'
VectKF11:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_F12'
VectKF12:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_F1'
VectKShiftF1:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_F2'
VectKShiftF2:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_F3'
VectKShiftF3:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_F4'
VectKShiftF4:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_F5'
VectKShiftF5:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_F6'
VectKShiftF6:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_F7'
VectKShiftF7:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_F8'
VectKShiftF8:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_F9'
VectKShiftF9:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_F10'
VectKShiftF10:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_F11'
VectKShiftF11:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_SHIFT_F12'
VectKShiftF12:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_F1'
VectKCtrlF1:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_F2'
VectKCtrlF2:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_F3'
VectKCtrlF3:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_F4'
VectKCtrlF4:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_F5'
VectKCtrlF5:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_F6'
VectKCtrlF6:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_F7'
VectKCtrlF7:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_F8'
VectKCtrlF8:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_F9'
VectKCtrlF9:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_F10'
VectKCtrlF10:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_F11'
VectKCtrlF11:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_F12'
VectKCtrlF12:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_F1'
VectKAltF1:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_F2'
VectKAltF2:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_F3'
VectKAltF3:
	mov	eax, ForthNoop
	call	eax
	ret

; FWORD   'K_ALT_F4'
; VectKF4:
;         mov     eax, ForthNoop
;         call    eax
;         ret

FWORD	'K_ALT_F5'
VectKAltF5:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_F6'
VectKAltF6:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_F7'
VectKAltF7:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_F8'
VectKAltF8:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_F9'
VectKAltF9:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_F10'
VectKAltF10:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_F11'
VectKAltF11:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_F12'
VectKAltF12:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_0'
VectKAlt0:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_0'
VectKCtrl0:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_1'
VectKAlt1:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_1'
VectKCtrl1:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_2'
VectKAlt2:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_2'
VectKCtrl2:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_3'
VectKAlt3:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_3'
VectKCtrl3:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_4'
VectKAlt4:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_4'
VectKCtrl4:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_5'
VectKAlt5:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_5'
VectKCtrl5:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_6'
VectKAlt6:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_6'
VectKCtrl6:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_7'
VectKAlt7:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_7'
VectKCtrl7:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_8'
VectKAlt8:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_8'
VectKCtrl8:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_9'
VectKAlt9:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_9'
VectKCtrl9:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_A'
VectKAltA:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_A'
VectKCtrlA:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_B'
VectKAltB:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_B'
VectKCtrlB:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_C'
VectKAltC:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_C'
VectKCtrlC:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_D'
VectKAltD:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_D'
VectKCtrlD:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_E'
VectKAltE:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_E'
VectKCtrlE:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_F'
VectKAltF:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_F'
VectKCtrlF:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_G'
VectKAltG:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_G'
VectKCtrlG:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_H'
VectKAltH:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_H'
VectKCtrlH:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_I'
VectKAltI:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_I'
VectKCtrlI:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_J'
VectKAltJ:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_J'
VectKCtrlJ:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_K'
VectKAltK:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_K'
VectKCtrlK:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_L'
VectKAltL:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_L'
VectKCtrlL:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_M'
VectKAltM:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_M'
VectKCtrlM:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_N'
VectKAltN:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_N'
VectKCtrlN:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_O'
VectKAltO:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_O'
VectKCtrlO:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_P'
VectKAltP:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_P'
VectKCtrlP:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_Q'
VectKAltQ:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_Q'
VectKCtrlQ:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_R'
VectKAltR:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_R'
VectKCtrlR:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_S'
VectKAltS:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_S'
VectKCtrlS:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_T'
VectKAltT:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_T'
VectKCtrlT:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_U'
VectKAltU:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_U'
VectKCtrlU:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_V'
VectKAltV:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_V'
VectKCtrlV:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_W'
VectKAltW:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_W'
VectKCtrlW:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_X'
VectKAltX:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_X'
VectKCtrlX:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_Y'
VectKAltY:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_Y'
VectKCtrlY:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_ALT_Z'
VectKAltZ:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'K_CTRL_Z'
VectKCtrlZ:
	mov	eax, ForthNoop
	call	eax
	ret



FWORD	'KEYDOWN'
ProcessKeyDown:
	mov	eax, ForthNoop
	call	eax
	ret

FWORD	'KEYUP'
ProcessKeyUp:
	mov	eax, ForthNoop
	call	eax
	ret


; -----------------------------------------------------------

LatestLabel:

JumpGate:
	jmp	eax
	ret

proc	StartUp
;        enter
;        mov     eax, latest
;        sub     eax, 4
;        mov     [ForthLatest], eax

;        mov     eax, [CodeStart]
;        mov     [cdp], eax
;        mov     eax, [DataStart]
;        mov     [ddp], eax

	call	TibClear
	mov	dword [sDepth], 0

; ***** Loading file from command line *****

ProcessCommandLine:

       invoke	GetCommandLine
       mov	ecx, eax

GetCommandLine0:

       mov	al, [ecx]
       cmp	al, 0
       je	GetCommandLine4
       cmp	al, '.'
       je	GetCommandLine1
       inc	ecx
       jmp	GetCommandLine0

GetCommandLine1:

       mov	al, [ecx]
       cmp	al, 0
       je	GetCommandLine4
       cmp	al, 32
       je	GetCommandLine2
       inc	ecx
       jmp	GetCommandLine1

GetCommandLine2:

       mov	al, [ecx]
       cmp	al, 0
       je	GetCommandLine4
       cmp	al, 32
       jne	GetCommandLine3
       inc	ecx
       jmp	GetCommandLine2

GetCommandLine3:

       cmp	byte [ecx], '"'
       jne	GetCommandLine4
       inc	ecx

GetCommandLine4:

       mov	dword [ParamStr], ecx

GetCommandLineKillQuote:

       mov	al, [ecx]
       cmp	al, 0
       je	GetCommandLine4a
       cmp	al, '"'
       jne	GetCommandLineNextKill
       mov	al, 0
       mov	[ecx], al
       jmp	GetCommandLine4a

GetCommandLineNextKill:

       inc	ecx
       jmp	GetCommandLineKillQuote

GetCommandLine4a:

       mov	ecx, [ParamStr]
       mov	al, [ecx]
       cmp	al, 0
       je	GetCommandLine5
       mov	eax, ecx
       mov	ecx, [Depth]
       mov	[Dstack+ecx*4], eax
       inc	dword [Depth]
       call	ForthLoadFile

GetCommandLine5:

; ********* Start of test section **********


	ret
endp

proc	Forth
	mov eax, 55
	ret
endp

proc	SetHWindow newvalue
	mov	eax, [newvalue]
	mov	[hwnd], eax
	ret
endp

proc	Init

	push	ebx edx esi edi


	mov	eax, [climit]
	invoke	GlobalAlloc, GPTR, eax
	mov	[CodeStart], eax
	mov	[CodeStart], VocStart
	mov	eax, [limit]
	invoke	GlobalAlloc, GPTR, eax
	mov	[DataStart], eax
	cmp	eax, 0
	jne	AllocatedNorm

; else try to allocate 1 Mb

	mov	eax, 1048576
	invoke	GlobalAlloc, GPTR, eax
	mov	[DataStart], eax


AllocatedNorm:

	fninit

	mov	eax, latest
	sub	eax, 4
	mov	[ForthLatest], eax
	mov	eax, ForthLatest
	mov	[Context], eax
	mov	[Current], eax

	mov	eax, [CodeStart]
	mov	[cdp], eax
	mov	eax, [DataStart]
	mov	[ddp], eax

	xor	eax, eax
	mov	[Depth], eax
	mov	[sDepth], eax
	mov	[lDepth], eax
	mov	[cfDepth], eax
	mov	[localDepth], eax
	mov	[frameDepth], eax

	mov	ecx, 10
	xor	eax, eax
	mov	edx, ToolButtonGlyph
ClearFnames1:
	mov	[edx], eax
	add	edx, 256
	jecxz	ClearFnames1

	mov	ecx, 10
	xor	eax, eax
	mov	edx, ToolButtonScript
ClearFnames2:
	mov	[edx], eax
	add	edx, 256
	jecxz	ClearFnames2
	pop	edi esi edx ebx

	mov	eax, 1
	ret
endp

proc	Done
	mov	eax, [CodeStart]
	invoke	GlobalFree, eax
	mov	eax, [DataStart]
	invoke	GlobalFree, eax
	invoke	wglDeleteContext, [hdc]
	invoke	ReleaseDC, [hwnd], [hdc]
endp

proc	GetCode
	mov	eax, [CodeStart]
	ret
endp

proc	GetData
	mov	eax, [DataStart]
	ret
endp

proc	GetStack
	mov	eax, Dstack
	ret
endp

proc	GetDepth
	mov	eax, [Depth]
	ret
endp

proc	GetTop
	mov	eax, [Depth]
	mov	eax, [Dstack+eax*4-4]
	ret
endp

proc	PopStack
	dec	dword [Depth]
	mov	eax, [Depth]
	mov	eax, [Dstack+eax*4]
	ret
endp

proc	GetScreen
	mov	eax, screen
	ret
endp

VocStart:

	rb 1048576

section '.idata' import data readable writeable

  library kernel,'KERNEL32.DLL',\
	  user,'USER32.DLL',\
	  gdi,'GDI32.DLL',\
	  opengl,'OPENGL32.DLL',\
	  glu,'GLU32.DLL'

  import kernel,\
	 GetModuleHandle,'GetModuleHandleA',\
	 LoadLibraryA,'LoadLibraryA',\
	 GetProcAddress,'GetProcAddress',\
	 GlobalAlloc,'GlobalAlloc',\
	 GlobalReAlloc,'GlobalReAlloc',\
	 GlobalFree,'GlobalFree',\
	 CreateFileA,'CreateFileA',\
	 ReadFile,'ReadFile',\
	 WriteFile,'WriteFile',\
	 CloseHandle,'CloseHandle',\
	 SetFilePointer,'SetFilePointer',\
	 GetFileSize,'GetFileSize',\
	 GetLocalTime,'GetLocalTime',\
	 BuildCommDCB,'BuildCommDCBA',\
	 GetCommState,'GetCommState',\
	 SetCommState,'SetCommState',\
	 GetCommandLine,'GetCommandLineA',\
	 Sleep,'Sleep',\
	 GetTickCount,'GetTickCount',\
	 ExitProcess,'ExitProcess'

  import user,\
	 RegisterClass,'RegisterClassA',\
	 CreateWindowEx,'CreateWindowExA',\
	 DefWindowProc,'DefWindowProcA',\
	 GetMessage,'GetMessageA',\
	 TranslateMessage,'TranslateMessage',\
	 DispatchMessage,'DispatchMessageA',\
	 GetKeyState, 'GetKeyState',\
	 LoadCursor,'LoadCursorA',\
	 LoadIcon,'LoadIconA',\
	 LoadMenu,'LoadMenuA',\
	 GetClientRect,'GetClientRect',\
	 InvalidateRect,'InvalidateRect',\
	 GetDC,'GetDC',\
	 ReleaseDC,'ReleaseDC',\
	 MessageBox,'MessageBoxA',\
	 DialogBoxParam,'DialogBoxParamA',\
	 CheckRadioButton,'CheckRadioButton',\
	 GetDlgItemText,'GetDlgItemTextA',\
	 IsDlgButtonChecked,'IsDlgButtonChecked',\
	 EndDialog,'EndDialog',\
	 PostQuitMessage,'PostQuitMessage'



  import gdi,\
	 ChoosePixelFormat,'ChoosePixelFormat',\
	 SetPixelFormat,'SetPixelFormat',\
	 SwapBuffers,'SwapBuffers'

  import opengl,\
	 glAccum,'glAccum',\
	 glAlphaFunc,'glAlphaFunc',\
	 glAreTexturesResident,'glAreTexturesResident',\
	 glArrayElement,'glArrayElement',\
	 glBegin,'glBegin',\
	 glBindTexture,'glBindTexture',\
	 glBitmap,'glBitmap',\
	 glBlendFunc,'glBlendFunc',\
	 glCallList,'glCallList',\
	 glCallLists,'glCallLists',\
	 glClear,'glClear',\
	 glClearAccum,'glClearAccum',\
	 glClearColor,'glClearColor',\
	 glClearDepth,'glClearDepth',\
	 glClearIndex,'glClearIndex',\
	 glClearStencil,'glClearStencil',\
	 glClipPlane,'glClipPlane',\
	 glColor3b,'glColor3b',\
	 glColor3bv,'glColor3bv',\
	 glColor3d,'glColor3d',\
	 glColor3dv,'glColor3dv',\
	 glColor3f,'glColor3f',\
	 glColor3fv,'glColor3fv',\
	 glColor3i,'glColor3i',\
	 glColor3iv,'glColor3iv',\
	 glColor3s,'glColor3s',\
	 glColor3sv,'glColor3sv',\
	 glColor3ub,'glColor3ub',\
	 glColor3ubv,'glColor3ubv',\
	 glColor3ui,'glColor3ui',\
	 glColor3uiv,'glColor3uiv',\
	 glColor3us,'glColor3us',\
	 glColor3usv,'glColor3usv',\
	 glColor4b,'glColor4b',\
	 glColor4bv,'glColor4bv',\
	 glColor4d,'glColor4d',\
	 glColor4dv,'glColor4dv',\
	 glColor4f,'glColor4f',\
	 glColor4fv,'glColor4fv',\
	 glColor4i,'glColor4i',\
	 glColor4iv,'glColor4iv',\
	 glColor4s,'glColor4s',\
	 glColor4sv,'glColor4sv',\
	 glColor4ub,'glColor4ub',\
	 glColor4ubv,'glColor4ubv',\
	 glColor4ui,'glColor4ui',\
	 glColor4uiv,'glColor4uiv',\
	 glColor4us,'glColor4us',\
	 glColor4usv,'glColor4usv',\
	 glColorMask,'glColorMask',\
	 glColorMaterial,'glColorMaterial',\
	 glColorPointer,'glColorPointer',\
	 glCopyPixels,'glCopyPixels',\
	 glCopyTexImage1D,'glCopyTexImage1D',\
	 glCopyTexImage2D,'glCopyTexImage2D',\
	 glCopyTexSubImage1D,'glCopyTexSubImage1D',\
	 glCopyTexSubImage2D,'glCopyTexSubImage2D',\
	 glCullFace,'glCullFace',\
	 glDeleteLists,'glDeleteLists',\
	 glDeleteTextures,'glDeleteTextures',\
	 glDepthFunc,'glDepthFunc',\
	 glDepthMask,'glDepthMask',\
	 glDepthRange,'glDepthRange',\
	 glDisable,'glDisable',\
	 glDisableClientState,'glDisableClientState',\
	 glDrawArrays,'glDrawArrays',\
	 glDrawBuffer,'glDrawBuffer',\
	 glDrawElements,'glDrawElements',\
	 glDrawPixels,'glDrawPixels',\
	 glEdgeFlag,'glEdgeFlag',\
	 glEdgeFlagPointer,'glEdgeFlagPointer',\
	 glEdgeFlagv,'glEdgeFlagv',\
	 glEnable,'glEnable',\
	 glEnableClientState,'glEnableClientState',\
	 glEnd,'glEnd',\
	 glEndList,'glEndList',\
	 glEvalCoord1d,'glEvalCoord1d',\
	 glEvalCoord1dv,'glEvalCoord1dv',\
	 glEvalCoord1f,'glEvalCoord1f',\
	 glEvalCoord1fv,'glEvalCoord1fv',\
	 glEvalCoord2d,'glEvalCoord2d',\
	 glEvalCoord2dv,'glEvalCoord2dv',\
	 glEvalCoord2f,'glEvalCoord2f',\
	 glEvalCoord2fv,'glEvalCoord2fv',\
	 glEvalMesh1,'glEvalMesh1',\
	 glEvalMesh2,'glEvalMesh2',\
	 glEvalPoint1,'glEvalPoint1',\
	 glEvalPoint2,'glEvalPoint2',\
	 glFeedbackBuffer,'glFeedbackBuffer',\
	 glFinish,'glFinish',\
	 glFlush,'glFlush',\
	 glFogf,'glFogf',\
	 glFogfv,'glFogfv',\
	 glFogi,'glFogi',\
	 glFogiv,'glFogiv',\
	 glFrontFace,'glFrontFace',\
	 glFrustum,'glFrustum',\
	 glGenLists,'glGenLists',\
	 glGenTextures,'glGenTextures',\
	 glGetBooleanv,'glGetBooleanv',\
	 glGetClipPlane,'glGetClipPlane',\
	 glGetDoublev,'glGetDoublev',\
	 glGetError,'glGetError',\
	 glGetFloatv,'glGetFloatv',\
	 glGetIntegerv,'glGetIntegerv',\
	 glGetLightfv,'glGetLightfv',\
	 glGetLightiv,'glGetLightiv',\
	 glGetMapdv,'glGetMapdv',\
	 glGetMapfv,'glGetMapfv',\
	 glGetMapiv,'glGetMapiv',\
	 glGetMaterialfv,'glGetMaterialfv',\
	 glGetMaterialiv,'glGetMaterialiv',\
	 glGetPixelMapfv,'glGetPixelMapfv',\
	 glGetPixelMapuiv,'glGetPixelMapuiv',\
	 glGetPixelMapusv,'glGetPixelMapusv',\
	 glGetPointerv,'glGetPointerv',\
	 glGetPolygonStipple,'glGetPolygonStipple',\
	 glGetString,'glGetString',\
	 glGetTexEnvfv,'glGetTexEnvfv',\
	 glGetTexEnviv,'glGetTexEnviv',\
	 glGetTexGendv,'glGetTexGendv',\
	 glGetTexGenfv,'glGetTexGenfv',\
	 glGetTexGeniv,'glGetTexGeniv',\
	 glGetTexImage,'glGetTexImage',\
	 glGetTexLevelParameterfv,'glGetTexLevelParameterfv',\
	 glGetTexLevelParameteriv,'glGetTexLevelParameteriv',\
	 glGetTexParameterfv,'glGetTexParameterfv',\
	 glGetTexParameteriv,'glGetTexParameteriv',\
	 glHint,'glHint',\
	 glIndexMask,'glIndexMask',\
	 glIndexPointer,'glIndexPointer',\
	 glIndexd,'glIndexd',\
	 glIndexdv,'glIndexdv',\
	 glIndexf,'glIndexf',\
	 glIndexfv,'glIndexfv',\
	 glIndexi,'glIndexi',\
	 glIndexiv,'glIndexiv',\
	 glIndexs,'glIndexs',\
	 glIndexsv,'glIndexsv',\
	 glIndexub,'glIndexub',\
	 glIndexubv,'glIndexubv',\
	 glInitNames,'glInitNames',\
	 glInterleavedArrays,'glInterleavedArrays',\
	 glIsEnabled,'glIsEnabled',\
	 glIsList,'glIsList',\
	 glIsTexture,'glIsTexture',\
	 glLightModelf,'glLightModelf',\
	 glLightModelfv,'glLightModelfv',\
	 glLightModeli,'glLightModeli',\
	 glLightModeliv,'glLightModeliv',\
	 glLightf,'glLightf',\
	 glLightfv,'glLightfv',\
	 glLighti,'glLighti',\
	 glLightiv,'glLightiv',\
	 glLineStipple,'glLineStipple',\
	 glLineWidth,'glLineWidth',\
	 glListBase,'glListBase',\
	 glLoadIdentity,'glLoadIdentity',\
	 glLoadMatrixd,'glLoadMatrixd',\
	 glLoadMatrixf,'glLoadMatrixf',\
	 glLoadName,'glLoadName',\
	 glLogicOp,'glLogicOp',\
	 glMap1d,'glMap1d',\
	 glMap1f,'glMap1f',\
	 glMap2d,'glMap2d',\
	 glMap2f,'glMap2f',\
	 glMapGrid1d,'glMapGrid1d',\
	 glMapGrid1f,'glMapGrid1f',\
	 glMapGrid2d,'glMapGrid2d',\
	 glMapGrid2f,'glMapGrid2f',\
	 glMaterialf,'glMaterialf',\
	 glMaterialfv,'glMaterialfv',\
	 glMateriali,'glMateriali',\
	 glMaterialiv,'glMaterialiv',\
	 glMatrixMode,'glMatrixMode',\
	 glMultMatrixd,'glMultMatrixd',\
	 glMultMatrixf,'glMultMatrixf',\
	 glNewList,'glNewList',\
	 glNormal3b,'glNormal3b',\
	 glNormal3bv,'glNormal3bv',\
	 glNormal3d,'glNormal3d',\
	 glNormal3dv,'glNormal3dv',\
	 glNormal3f,'glNormal3f',\
	 glNormal3fv,'glNormal3fv',\
	 glNormal3i,'glNormal3i',\
	 glNormal3iv,'glNormal3iv',\
	 glNormal3s,'glNormal3s',\
	 glNormal3sv,'glNormal3sv',\
	 glNormalPointer,'glNormalPointer',\
	 glOrtho,'glOrtho',\
	 glPassThrough,'glPassThrough',\
	 glPixelMapfv,'glPixelMapfv',\
	 glPixelMapuiv,'glPixelMapuiv',\
	 glPixelMapusv,'glPixelMapusv',\
	 glPixelStoref,'glPixelStoref',\
	 glPixelStorei,'glPixelStorei',\
	 glPixelTransferf,'glPixelTransferf',\
	 glPixelTransferi,'glPixelTransferi',\
	 glPixelZoom,'glPixelZoom',\
	 glPointSize,'glPointSize',\
	 glPolygonMode,'glPolygonMode',\
	 glPolygonOffset,'glPolygonOffset',\
	 glPolygonStipple,'glPolygonStipple',\
	 glPopAttrib,'glPopAttrib',\
	 glPopClientAttrib,'glPopClientAttrib',\
	 glPopMatrix,'glPopMatrix',\
	 glPopName,'glPopName',\
	 glPrioritizeTextures,'glPrioritizeTextures',\
	 glPushAttrib,'glPushAttrib',\
	 glPushClientAttrib,'glPushClientAttrib',\
	 glPushMatrix,'glPushMatrix',\
	 glPushName,'glPushName',\
	 glRasterPos2d,'glRasterPos2d',\
	 glRasterPos2dv,'glRasterPos2dv',\
	 glRasterPos2f,'glRasterPos2f',\
	 glRasterPos2fv,'glRasterPos2fv',\
	 glRasterPos2i,'glRasterPos2i',\
	 glRasterPos2iv,'glRasterPos2iv',\
	 glRasterPos2s,'glRasterPos2s',\
	 glRasterPos2sv,'glRasterPos2sv',\
	 glRasterPos3d,'glRasterPos3d',\
	 glRasterPos3dv,'glRasterPos3dv',\
	 glRasterPos3f,'glRasterPos3f',\
	 glRasterPos3fv,'glRasterPos3fv',\
	 glRasterPos3i,'glRasterPos3i',\
	 glRasterPos3iv,'glRasterPos3iv',\
	 glRasterPos3s,'glRasterPos3s',\
	 glRasterPos3sv,'glRasterPos3sv',\
	 glRasterPos4d,'glRasterPos4d',\
	 glRasterPos4dv,'glRasterPos4dv',\
	 glRasterPos4f,'glRasterPos4f',\
	 glRasterPos4fv,'glRasterPos4fv',\
	 glRasterPos4i,'glRasterPos4i',\
	 glRasterPos4iv,'glRasterPos4iv',\
	 glRasterPos4s,'glRasterPos4s',\
	 glRasterPos4sv,'glRasterPos4sv',\
	 glReadBuffer,'glReadBuffer',\
	 glReadPixels,'glReadPixels',\
	 glRectd,'glRectd',\
	 glRectdv,'glRectdv',\
	 glRectf,'glRectf',\
	 glRectfv,'glRectfv',\
	 glRecti,'glRecti',\
	 glRectiv,'glRectiv',\
	 glRects,'glRects',\
	 glRectsv,'glRectsv',\
	 glRenderMode,'glRenderMode',\
	 glRotated,'glRotated',\
	 glRotatef,'glRotatef',\
	 glScaled,'glScaled',\
	 glScalef,'glScalef',\
	 glScissor,'glScissor',\
	 glSelectBuffer,'glSelectBuffer',\
	 glShadeModel,'glShadeModel',\
	 glStencilFunc,'glStencilFunc',\
	 glStencilMask,'glStencilMask',\
	 glStencilOp,'glStencilOp',\
	 glTexCoord1d,'glTexCoord1d',\
	 glTexCoord1dv,'glTexCoord1dv',\
	 glTexCoord1f,'glTexCoord1f',\
	 glTexCoord1fv,'glTexCoord1fv',\
	 glTexCoord1i,'glTexCoord1i',\
	 glTexCoord1iv,'glTexCoord1iv',\
	 glTexCoord1s,'glTexCoord1s',\
	 glTexCoord1sv,'glTexCoord1sv',\
	 glTexCoord2d,'glTexCoord2d',\
	 glTexCoord2dv,'glTexCoord2dv',\
	 glTexCoord2f,'glTexCoord2f',\
	 glTexCoord2fv,'glTexCoord2fv',\
	 glTexCoord2i,'glTexCoord2i',\
	 glTexCoord2iv,'glTexCoord2iv',\
	 glTexCoord2s,'glTexCoord2s',\
	 glTexCoord2sv,'glTexCoord2sv',\
	 glTexCoord3d,'glTexCoord3d',\
	 glTexCoord3dv,'glTexCoord3dv',\
	 glTexCoord3f,'glTexCoord3f',\
	 glTexCoord3fv,'glTexCoord3fv',\
	 glTexCoord3i,'glTexCoord3i',\
	 glTexCoord3iv,'glTexCoord3iv',\
	 glTexCoord3s,'glTexCoord3s',\
	 glTexCoord3sv,'glTexCoord3sv',\
	 glTexCoord4d,'glTexCoord4d',\
	 glTexCoord4dv,'glTexCoord4dv',\
	 glTexCoord4f,'glTexCoord4f',\
	 glTexCoord4fv,'glTexCoord4fv',\
	 glTexCoord4i,'glTexCoord4i',\
	 glTexCoord4iv,'glTexCoord4iv',\
	 glTexCoord4s,'glTexCoord4s',\
	 glTexCoord4sv,'glTexCoord4sv',\
	 glTexCoordPointer,'glTexCoordPointer',\
	 glTexEnvf,'glTexEnvf',\
	 glTexEnvfv,'glTexEnvfv',\
	 glTexEnvi,'glTexEnvi',\
	 glTexEnviv,'glTexEnviv',\
	 glTexGend,'glTexGend',\
	 glTexGendv,'glTexGendv',\
	 glTexGenf,'glTexGenf',\
	 glTexGenfv,'glTexGenfv',\
	 glTexGeni,'glTexGeni',\
	 glTexGeniv,'glTexGeniv',\
	 glTexImage1D,'glTexImage1D',\
	 glTexImage2D,'glTexImage2D',\
	 glTexParameterf,'glTexParameterf',\
	 glTexParameterfv,'glTexParameterfv',\
	 glTexParameteri,'glTexParameteri',\
	 glTexParameteriv,'glTexParameteriv',\
	 glTexSubImage1D,'glTexSubImage1D',\
	 glTexSubImage2D,'glTexSubImage2D',\
	 glTranslated,'glTranslated',\
	 glTranslatef,'glTranslatef',\
	 glVertex2d,'glVertex2d',\
	 glVertex2dv,'glVertex2dv',\
	 glVertex2f,'glVertex2f',\
	 glVertex2fv,'glVertex2fv',\
	 glVertex2i,'glVertex2i',\
	 glVertex2iv,'glVertex2iv',\
	 glVertex2s,'glVertex2s',\
	 glVertex2sv,'glVertex2sv',\
	 glVertex3d,'glVertex3d',\
	 glVertex3dv,'glVertex3dv',\
	 glVertex3f,'glVertex3f',\
	 glVertex3fv,'glVertex3fv',\
	 glVertex3i,'glVertex3i',\
	 glVertex3iv,'glVertex3iv',\
	 glVertex3s,'glVertex3s',\
	 glVertex3sv,'glVertex3sv',\
	 glVertex4d,'glVertex4d',\
	 glVertex4dv,'glVertex4dv',\
	 glVertex4f,'glVertex4f',\
	 glVertex4fv,'glVertex4fv',\
	 glVertex4i,'glVertex4i',\
	 glVertex4iv,'glVertex4iv',\
	 glVertex4s,'glVertex4s',\
	 glVertex4sv,'glVertex4sv',\
	 glVertexPointer,'glVertexPointer',\
	 glViewport,'glViewport',\
	 wglGetProcAddress,'wglGetProcAddress',\
	 wglCopyContext,'wglCopyContext',\
	 wglCreateContext,'wglCreateContext',\
	 wglCreateLayerContext,'wglCreateLayerContext',\
	 wglDeleteContext,'wglDeleteContext',\
	 wglDescribeLayerPlane,'wglDescribeLayerPlane',\
	 wglGetCurrentContext,'wglGetCurrentContext',\
	 wglGetCurrentDC,'wglGetCurrentDC',\
	 wglGetLayerPaletteEntries,'wglGetLayerPaletteEntries',\
	 wglMakeCurrent,'wglMakeCurrent',\
	 wglRealizeLayerPalette,'wglRealizeLayerPalette',\
	 wglSetLayerPaletteEntries,'wglSetLayerPaletteEntries',\
	 wglShareLists,'wglShareLists',\
	 wglSwapLayerBuffers,'wglSwapLayerBuffers',\
	 wglSwapMultipleBuffers,'wglSwapMultipleBuffers',\
	 wglUseFontBitmapsA,'wglUseFontBitmapsA',\
	 wglUseFontOutlinesA,'wglUseFontOutlinesA',\
	 wglUseFontBitmapsW,'wglUseFontBitmapsW',\
	 wglUseFontOutlinesW,'wglUseFontOutlinesW',\
	 wglUseFontBitmaps,'wglUseFontBitmaps',\
	 wglUseFontOutlines,'wglUseFontOutlines',\
	 glDrawRangeElements,'glDrawRangeElements',\
	 glTexImage3D,'glTexImage3D',\
	 glBlendColor,'glBlendColor',\
	 glBlendEquation,'glBlendEquation',\
	 glColorSubTable,'glColorSubTable',\
	 glCopyColorSubTable,'glCopyColorSubTable',\
	 glColorTable,'glColorTable',\
	 glCopyColorTable,'glCopyColorTable',\
	 glColorTableParameteriv,'glColorTableParameteriv',\
	 glColorTableParameterfv,'glColorTableParameterfv',\
	 glGetColorTable,'glGetColorTable',\
	 glGetColorTableParameteriv,'glGetColorTableParameteriv',\
	 glGetColorTableParameterfv,'glGetColorTableParameterfv',\
	 glConvolutionFilter1D,'glConvolutionFilter1D',\
	 glConvolutionFilter2D,'glConvolutionFilter2D',\
	 glCopyConvolutionFilter1D,'glCopyConvolutionFilter1D',\
	 glCopyConvolutionFilter2D,'glCopyConvolutionFilter2D',\
	 glGetConvolutionFilter,'glGetConvolutionFilter',\
	 glSeparableFilter2D,'glSeparableFilter2D',\
	 glGetSeparableFilter,'glGetSeparableFilter',\
	 glConvolutionParameteri,'glConvolutionParameteri',\
	 glConvolutionParameteriv,'glConvolutionParameteriv',\
	 glConvolutionParameterf,'glConvolutionParameterf',\
	 glConvolutionParameterfv,'glConvolutionParameterfv',\
	 glGetConvolutionParameteriv,'glGetConvolutionParameteriv',\
	 glGetConvolutionParameterfv,'glGetConvolutionParameterfv',\
	 glHistogram,'glHistogram',\
	 glResetHistogram,'glResetHistogram',\
	 glGetHistogram,'glGetHistogram',\
	 glGetHistogramParameteriv,'glGetHistogramParameteriv',\
	 glGetHistogramParameterfv,'glGetHistogramParameterfv',\
	 glMinmax,'glMinmax',\
	 glResetMinmax,'glResetMinmax',\
	 glGetMinmax,'glGetMinmax',\
	 glGetMinmaxParameteriv,'glGetMinmaxParameteriv',\
	 glGetMinmaxParameterfv,'glGetMinmaxParameterfv'

  import glu,\
	 gluBeginCurve,'gluBeginCurve',\
	 gluBeginPolygon,'gluBeginPolygon',\
	 gluBeginSurface,'gluBeginSurface',\
	 gluBeginTrim,'gluBeginTrim',\
	 gluBuild1DMipmaps,'gluBuild1DMipmaps',\
	 gluBuild2DMipmaps,'gluBuild2DMipmaps',\
	 gluCylinder,'gluCylinder',\
	 gluDeleteNurbsRenderer,'gluDeleteNurbsRenderer',\
	 gluDeleteQuadric,'gluDeleteQuadric',\
	 gluDeleteTess,'gluDeleteTess',\
	 gluDisk,'gluDisk',\
	 gluEndCurve,'gluEndCurve',\
	 gluEndPolygon,'gluEndPolygon',\
	 gluEndSurface,'gluEndSurface',\
	 gluEndTrim,'gluEndTrim',\
	 gluErrorString,'gluErrorString',\
	 gluGetNurbsProperty,'gluGetNurbsProperty',\
	 gluGetString,'gluGetString',\
	 gluGetTessProperty,'gluGetTessProperty',\
	 gluLoadSamplingMatrices,'gluLoadSamplingMatrices',\
	 gluLookAt,'gluLookAt',\
	 gluNewNurbsRenderer,'gluNewNurbsRenderer',\
	 gluNewQuadric,'gluNewQuadric',\
	 gluNewTess,'gluNewTess',\
	 gluNextContour,'gluNextContour',\
	 gluNurbsCallback,'gluNurbsCallback',\
	 gluNurbsCurve,'gluNurbsCurve',\
	 gluNurbsProperty,'gluNurbsProperty',\
	 gluNurbsSurface,'gluNurbsSurface',\
	 gluOrtho2D,'gluOrtho2D',\
	 gluPartialDisk,'gluPartialDisk',\
	 gluPerspective,'gluPerspective',\
	 gluPickMatrix,'gluPickMatrix',\
	 gluProject,'gluProject',\
	 gluPwlCurve,'gluPwlCurve',\
	 gluQuadricCallback,'gluQuadricCallback',\
	 gluQuadricDrawStyle,'gluQuadricDrawStyle',\
	 gluQuadricNormals,'gluQuadricNormals',\
	 gluQuadricOrientation,'gluQuadricOrientation',\
	 gluQuadricTexture,'gluQuadricTexture',\
	 gluScaleImage,'gluScaleImage',\
	 gluSphere,'gluSphere',\
	 gluTessBeginContour,'gluTessBeginContour',\
	 gluTessBeginPolygon,'gluTessBeginPolygon',\
	 gluTessCallback,'gluTessCallback',\
	 gluTessEndContour,'gluTessEndContour',\
	 gluTessEndPolygon,'gluTessEndPolygon',\
	 gluTessNormal,'gluTessNormal',\
	 gluTessProperty,'gluTessProperty',\
	 gluTessVertex,'gluTessVertex',\
	 gluUnProject,'gluUnProject'


section '.edata' export data readable

  export 'forth.dll',\
	 ProcessEvaluate, 'Evaluate',\
	 ProcEvaluateStdCall, 'EvaluateC',\
	 Init, 'Init',\
	 Done, 'Done',\
	 SetHWindow, 'SetHWindow',\
	 GetCode, 'GetCode',\
	 GetData, 'GetData',\
	 GetStack, 'GetStack',\
	 GetDepth, 'GetDepth',\
	 GetTop, 'GetTop',\
	 PopStack, 'PopStack',\
	 GetScreen, 'GetScreen',\
	 Forth, 'ForthInfo'

section '.reloc' fixups data discardable

section '.rsrc' resource data readable

  directory RT_DIALOG,dialogs

  resource dialogs,\
	   37, LANG_ENGLISH+SUBLANG_DEFAULT, inputdialog

  dialog inputdialog,'Input',70,170,190,90,WS_CAPTION+WS_POPUP+WS_SYSMENU+DS_MODALFRAME+WS_VISIBLE+WS_EX_TOPMOST
    dialogitem 'STATIC','Caption:',-1,10,10,70,8,WS_VISIBLE
    dialogitem 'EDIT','',ID_MESSAGE,10,20,170,13,WS_VISIBLE+WS_BORDER+WS_TABSTOP +ES_AUTOHSCROLL
    dialogitem 'BUTTON','&OK',IDOK,20,60,50,15,WS_VISIBLE+WS_TABSTOP+BS_DEFPUSHBUTTON
    dialogitem 'BUTTON','C&ancel',IDCANCEL,120,60,50,15,WS_VISIBLE+WS_TABSTOP+BS_PUSHBUTTON
  enddialog

