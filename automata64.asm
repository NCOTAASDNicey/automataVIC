#import "lib/kernal.asm"
#import "lib/macros.asm"
#import "lib/zero.asm"

:BasicUpstart2(mainProg)
        * = $840

.const edge_col=WHITE
.const selected_col=CYAN
.const edited_col=RED
.const active_col=CYAN
.const gui_back_col=BLACK
.const gui_bor_col=LIGHT_GREY


#import "lib/data.asm"
#import "lib/objects.asm"
#import "lib/print.asm"
#import "lib/boxes.asm"
#import "lib/gui.asm"
#import "lib/screenModes.asm"
#import "lib/render4.asm"
#import "lib/scroll.asm"
#import "lib/file.asm"
#import "lib/charprogram.asm"


initRandom:
    lda #$FF  // maximum frequency value
    sta $D40E // voice 3 frequency low byte
    sta $D40F // voice 3 frequency high byte
    lda #$80  // noise waveform, gate bit off
    sta $D412 // voice 3 control register
    rts

.macro random() {
    lda $D41B
}    

mainProg:
    cls()
    jsr initRandom
    jsr setupForGui
    screen_col(gui_back_col, gui_bor_col)
    lda #0
    sta scrmode
    sta return
    sta selected
    jsr _key_handledf
    callMethod(method_render, _boxlist)    

_main_loop:
    jsr waitkey
    sta keypress    
    callMethod(method_key, _boxlist)
    pha // Use key methods return values
    callMethod(method_render, _boxlist)
    pla
    bne done
    jmp _main_loop

done:
    jsr leave_fullscreen
    jsr leaveProgramableCharMode
    cls()
    screen_col(BLUE,LIGHT_BLUE)
    lda #LIGHT_BLUE
    sta chrout_colour
    rts

waitkey:
    jsr getin
    cmp #0
    beq waitkey    
    rts

setupForGui:
    jsr enterProgramableCharMode
    jsr programChars
    rts

returnToGui:
    jsr leave_fullscreen
    jsr setupForGui
    jmp empty          

message: str("WOO YAY")
