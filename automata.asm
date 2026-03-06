.const  bitmap= $1100

.const JOY_SENSE= $1
#import "lib/kernal.asm"
.const edited_col=red
.const active_col=cyan

.const COLUMNS=22
.const ROWS=23
.const PIXELS_PER_BYTE=4
.const MONO_PIXELS_PER_BYTE=8
.const BYTES_PER_CHAR=8
.const BUFFER_LENGTH=COLUMNS*PIXELS_PER_BYTE
.const MONO_BUFFER_LENGTH=COLUMNS*MONO_PIXELS_PER_BYTE
.const RULE_LENGTH=10
.const HELP_COL=1
.const HELP_ROW=23

#import "lib/macros.asm"
#import "lib/zero.asm"

*= $1201 "Basic Upstart"
:BasicUpstart(mainProg)

*= $2000 "Program"
#import "lib/data.asm"
#import "lib/objects.asm"
#import "lib/boxes.asm"
#import "lib/file.asm"
#import "lib/gui.asm"
mainProg:
        cls()
        screen_col(black, black)

        lda #2
        sta selected
        callMethod(method_render, _boxlist)

_main_loop:   
        jsr waitkey
        sty keypress
        callMethod(method_key, _boxlist)
        lda return
        pha    
        callMethod(method_render, _boxlist)
        pla
        cmp #0
        bne done
        jmp _main_loop    
       
done:
        jsr leave_fullscreen
        lda #<boxFinal
        ldx #>boxFinal
        ldy #0
        jsr invokevirtual
        lda #0
	rts
	
waitJiffy:
	pha
	tya
	pha
	txa
	pha
	
	jsr rdtim
	adc #2
	sta _scratch
!:	jsr rdtim
	cmp _scratch
	bne !-
		
	pla
	tax
	pla
	tay
	pla
	rts

// return KEY equiv in Y	
joystick:
	pha
	txa
	pha
	lda #$0
	sta VIA1_ddr
	lda VIA1_output
	eor #[JOY_SW0|JOY_SW1|JOY_SW2|JOY_SW4]
	lsr 
	lsr
	and #$0F
	pha
	lda VIA2_ddr
	pha
	lda	#127
	sta VIA2_ddr
	lda VIA2_output
	eor #JOY_SW3
	lsr
	lsr
	lsr
	and #$10
	sta _scratch
	pla
	sta VIA2_ddr
	pla
	ora _scratch	

	lsr
	rol JOY_U
	lsr
	rol JOY_D
	lsr
	rol JOY_L
	lsr
	rol JOY_F
	lsr
	rol JOY_R
	
	jsr waitJiffy		

	lda #$0
	ldx #JOY_SENSE
	cpx JOY_L
	bcs !+
	sta	JOY_L
	lda #KEY_CSR_LEFT
	jmp joystick_return
		
!:	cpx JOY_R
	bcs !+
	sta	JOY_R
	lda #KEY_CSR_RIGHT
	jmp joystick_return
	
!:	cpx JOY_U
	bcs !+
	sta	JOY_U
	lda #KEY_CSR_UP
	jmp joystick_return
	
!:	cpx JOY_D
	bcs !+
	sta	JOY_U
	lda #KEY_CSR_DOWN
	jmp joystick_return
	
!:	cpx JOY_F
	bcs joystick_return
	sta	JOY_F
	lda #KEY_RETURN
joystick_return:
	tay
	pla
	tax
	pla
	rts

// waitkey:
// !:      
//         jsr joystick
//         tya	
//         cmp #$0
//         bne !+
//         lda $C5
//         beq !-
//         jsr getin
//         cmp #$0
// 	beq !-
// !:	tay
//         rts

waitkey:
    jsr getin
    cmp #0
    beq waitkey    
    rts

#import "lib/print.asm"
#import "lib/screenModes.asm"   
#import "lib/render.asm"   

update_ruleb:
        sec
        sbc #49
        tay        
        lda rule,Y
        eor #1
        sta rule,Y
        cmp #1
        beq !+
        lda #48
        jmp !++    
!:      lda #49
!:      sta ruleStr,Y    
        lda #0
        rts
        
render_ruleb:
        ldy #0 
!:      lda rule,Y
        cmp #1
        beq !+
        lda #48
        jmp !++    
!:      lda #49
!:      sta ruleStr,Y
        iny
        cpy #8
        bne !--- 

        jsr render
        rts        
        
handlerulekeyb:
        jsr construct
        lda #1
        cmp box_select
        bne !+
        lda keypress      
        cmp #48
        bcc !+ 
        cmp #57
        bcs !+        
        ldy #method_action
        jsr reinvokevirtual
!:      lda #0 //Dont signal program end
        rts


lable_vtable:
    jsr doJumpTable
    .word render, handlekey, empty, empty, empty, empty, empty, empty

boxes_vtable:
    jsr doJumpTable
    .word render, handlekey, select, deselect, empty, empty, empty, empty
 
exitboxes_vtable:
    jsr doJumpTable 
    .word render, handlekey, select, deselect, exit, empty, empty, empty

confirmboxes_vtable:
    jsr doJumpTable
    .word render, handlekey, select, deselect, automata, empty, leave_fullscreen, continue
    
confirmboxes4_vtable:
    jsr doJumpTable    
    .word render, handlekey, select, deselect, automata4, empty, leave_fullscreen, continue4   
    
colourboxes_vtable:
    jsr doJumpTable    
    .word render, handlekeyc, select, deselect, empty, empty, empty, empty       
    
rule4Index_vtable:
    jsr doJumpTable    
    .word render, handlekeyi, select, deselect, empty, render_index, empty, empty       
    
binaryrule_vtable:
    jsr doJumpTable
    .word render_ruleb, handlerulekeyb, select, deselect, update_ruleb, empty, empty, empty    

bit4rule_vtable:
    jsr doJumpTable
    .word renderrule4, handlerulekey4, select, deselect, update_rule4, empty, empty, empty
    
flow_vtable:
    jsr doJumpTable
    .word empty, flowKey, empty, empty, empty, empty, empty
    
toggleBoxes_vtable:
    jsr doJumpTable
   .word render, handlekey, select, deselect, toggle, render_toggle, empty, empty





 


