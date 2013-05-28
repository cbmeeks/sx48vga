;=======================================================================
;TITLE:         sx52_vga_01
;
;PURPOSE:       SX52 based GPU
;
;AUTHOR:        cbmeeks
;
;CONNECTIONS:
;
;        TAPE = VSYNC
;        hsync = rc.1
;        vsync = rc.0
;
;DETAILS:
;
;
;              470
;    RB.0---\/\/--|
;              1.5k  +------------- RED  (0.0 - 0.7V)
;    RB.1---\/\/--|
;
;              470
;    RB.2---\/\/--|
;              1.5k  +------------- GREEN  (0.0 - 0.7V)
;    RB.3---\/\/--|
;
;              470
;    RB.4---\/\/--|
;              1.5k  +------------- BLUE  (0.0 - 0.7V)
;    RB.5---\/\/--|
;
;
;
;    RC.0------------------------ VSYNC (5v OK)
;    RC.1------------------------ HSYNC (5v OK)
;
;
;        RB is used for the image signal.
;        You have 8 bits to do what you want.
;        I recommend using 6 bits so that you get 2 bits
;        per color (RGB) giving you 64 colors.
;
;        Make sure RB doesn't go over 1 volt!  (0.7v is the spec)
;
;
;        If you have any questions, please ask!
;
;        cbmeeks
;        cbmeeks@gmail.com
;        http://www.codershangout.com
;
;=======================================================================


;-------------------------- DEVICE DIRECTIVES --------------------------
DEVICE    SX52,CARRYX
FREQ    80_000_000

DEVICE    OSCHS3                  ; High-speed external oscillator
DEVICE    IFBD                    ; Crystal feedback disabled
DEVICE    XTLBUFD                 ; Crystal drive disabled
IRC_CAL IRC_SLOW        ; Calibrate Internal Crystal to the slowest setting

RESET    Initialize


;===============================================================================================
;    REGISTERS
;===============================================================================================


;===============================================================================================
;    VARIABLES
;===============================================================================================
org $10
bank_0
d1        ds    1    ; general counter
d2        ds    1    ; general counter
d3        ds    1    ; general counter
d4        ds    1    ; general counter
Pixel        ds    1    ; current pixel
ScanLine    ds    1    ; current scanline
PixelCount    ds    1    ; number of pixels wide

hsync        equ    rc.1
vsync        equ    rc.0

WHITE        equ    %00111111
BLACK        equ    %00000000

;------------------------ INITIALIZATION ROUTINE -----------------------
org $02        ;allow 2 for the debugger        (PAGE 0)


;===============================================================================================
;    HORIZONTAL SCANLINE        31.77µS
;===============================================================================================
HScanline
;SYNC PULSE 3.77us 
    clrb hsync            ;(1)
    mov    w, #$4B
    mov    d1, w
hsync_0:
    decsz    d1
    jmp    hsync_0            ;(300)


;BACK PORCH 1.89us
    setb hsync            ;(1)
    mov rb, #%00000000        ;(2)
    mov    w, #$25
    mov    d1, w
backporch_0:
    decsz    d1
    jmp    backporch_0


;ACTIVE VIDEO 25.17us
    mov rb, #%00001011        ;(2) ORANGE HERE


    mov    w, #$1F
    mov    d1, w
    mov    w, #$02
    mov    d2, w
active_0:
    decsz    d1
    jmp    $+2
    decsz    d2
    jmp    active_0
    nop
    nop


;FRONT PORCH 0.94us
    mov rb, #%00000000        ;(2)
    mov    w, #$10
    mov    d1, w
frontporch_0:
    decsz    d1
    jmp    frontporch_0
    jmp    $+1


    ret



BlankLine
;SYNC PULSE 3.77us 
    clrb hsync            ;(1)
    mov    w, #$4B
    mov    d1, w
bhsync_0:
    decsz    d1
    jmp    bhsync_0            ;(300)


;BACK PORCH 1.89us
    setb hsync            ;(1)
    mov rb, #%00000000        ;(2)
    mov    w, #$25
    mov    d1, w
bbackporch_0:
    decsz    d1
    jmp    bbackporch_0


;ACTIVE VIDEO 25.17us
    mov rb, #%00000000        ;(2)
    mov    w, #$1F
    mov    d1, w
    mov    w, #$02
    mov    d2, w
bactive_0:
    decsz    d1
    jmp    $+2
    decsz    d2
    jmp    bactive_0
    nop
    nop


;FRONT PORCH 0.94us
    mov rb, #%00000000        ;(2)
    mov    w, #$10
    mov    d1, w
bfrontporch_0:
    decsz    d1
    jmp    bfrontporch_0
    jmp    $+1




    ret



;===============================================================================================
;    SETUP
;===============================================================================================
Initialize
    ;Configure port settings
    mov    rb, #%00000000        ;Port B output zero
    mov    !rb,#%00000000        ;Port B all output
    mov    rc, #%00000000        ;Port C output zero
    mov    !rc,#%00000000        ;Port C all output

    ;other setup



;===============================================================================================
;    MAIN LOOP
;===============================================================================================
Main

;SYNC LENGTH    0.06ms
    clrb vsync
    call BlankLine
    call BlankLine

;BACK PORCH    1.02ms
    setb vsync            ;(1)
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine



;ACTIVE VIDEO 480 lines (15.25ms)
    mov ScanLine, #240
LOOP1
    call HScanline
    call HScanline
    djnz ScanLine, LOOP1



;FRONT PORCH 0.35ms
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine
    call BlankLine




;===============================================================================================
;    JUMP BACK TO MAIN        -    Total lines:  
;===============================================================================================
    jmp    Main                ;goto main
    
