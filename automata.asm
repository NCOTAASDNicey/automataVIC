.const  top = 0
.const  bottom= 1
.const  right= 2
.const  left= 3
.const  top_right= 4
.const  top_left= 5
.const  bottom_right= 6
.const  bottom_left= 7
.const  fill= 8
.const  bitmap= $1100

.const COLUMNS=22
.const ROWS=23
.const PIXELS_PER_BYTE=4
.const BYTES_PER_CHAR=8
.const BUFFER_LENGTH=COLUMNS*PIXELS_PER_BYTE
.const RULE_LENGTH=10
.const JOY_SENSE= $1
.const DEVICE= 8
.const FILENO= 1

.const  boxes_list_size= 13 //Update this when you add more boxes

#import "lib/kernal.asm"
#import "lib/macros.asm"
#import "lib/objects.asm"
#import "lib/zero.asm"
#import "lib/data.asm"

*= $1201 "Basic Upstart"
:BasicUpstart(mainProg)

*= $2000 "Program"
mainProg:
        cls()
        screen_col(black, black)

        lda #2
        sta selected
        callMethod(method_render, _boxList)

_main_loop:   
        jsr waitkey
        sty keypress
        callMethod(method_key, _boxList)
        lda return
        pha    
        callMethod(method_render, _boxList)
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

// .macro getInstanceVariable(field, box){
//     // _1 variable
//     // _2 Instance
//     // Box instance
//         lda #[field-box_origin]
//         sta field
//         lda #<box
//         ldx #>box
//         ldy #method_get
//         jsr invokevirtual           
// }

// get:
//         jsr construct
//         ldy field
//         lda (this),Y
//         rts      

select:
        jsr construct
        loadObjectByte(box_select)
        ora #1
        sta (this),Y
        rts
        
deselect:
        jsr construct
        loadObjectByte(box_select)
        and #255-1
        sta (this),Y
        rts
                       
toggle:
        jsr construct
        loadObjectByte(box_check)
        eor #1
        sta (this),Y
        lda #0                     
        rts
        
render_toggle:
        jsr construct
        clc
        lda box_origin
        adc #X_CHARS+1
        sta _chptr
        lda box_origin+1
        adc #0 
        sta _chptr+1                

        loadObjectByte(box_check)
        cmp #0
        beq !+
        lda #87        
        jmp !++
!:       lda #81
!:       ldy #0
        sta (_chptr),Y
        lda #0              
        rts                     

render:
        jsr construct
        lda #1
        cmp fullscreen
        bne !+        
        rts
!:      lda box_height
        sta box_height_working
        
        loadObjectByte(box_select)
        and #1
        beq _notselected
        lda #<style2
        sta _styleptr
        lda #>style2
        sta _styleptr+1        
        jmp _style_done         
        
_notselected:
        loadObjectPointer(box_style, _styleptr)
               
_style_done:        
        loadObjectPointer(box_origin, _chptr             )
                                               
        // Top line
        ldy box_width
        dey
        sty box_width_working
        ldy #top_right
        lda (_styleptr),Y
        ldy box_width_working                     
        sta (_chptr),Y
        
        sty box_width_working
        ldy #top
        lda (_styleptr),Y
        ldy box_width_working                     
        
!:      dey        
        sta (_chptr),y
        bne !-
        
        sty box_width_working
        ldy #top_left
        lda (_styleptr),Y
        ldy box_width_working                               
        sta (_chptr),y

        dec box_height_working

        // middle lines
_mid:   clc
        lda #X_CHARS
        adc _chptr
        sta _chptr
        lda #0
        adc _chptr+1
        sta _chptr+1
        ldy box_width
           
        sty box_width_working
        ldy #right
        lda (_styleptr),Y
        ldy box_width_working                
        dey
        sta (_chptr),y
        sty box_width_working
        ldy #fill
        lda (_styleptr),Y
        ldy box_width_working         
!:       dey        
        sta (_chptr),y
        bne !-
        sty box_width_working
        ldy #left
        lda (_styleptr),Y
        ldy box_width_working                     
        sta (_chptr),y
            
        dec box_height_working
        bne _mid        
                
        // bottom line
        ldy box_width
        sty box_width_working
        ldy #bottom_right
        lda (_styleptr),Y
        ldy box_width_working              
        dey
        sta (_chptr),y
        sty box_width_working
        ldy #bottom
        lda (_styleptr),Y
        ldy box_width_working
!:       dey        
        sta (_chptr),y
        bne !-
        sty box_width_working
        ldy #bottom_left
        lda (_styleptr),Y
        ldy box_width_working                      
        sta (_chptr),y
 
//Fill in colour
        lda box_col_origin  
        sta _chptr
        lda box_col_origin+1 
        sta _chptr+1
        
        lda box_height
        sta box_height_working
        lda box_width
        sta box_width_working
        lda #0
        cmp box_edited
        beq !+
        lda #red
        jmp !+++
!:       lda #$1       
       	and box_select
        beq !+        
        lda #cyan
        jmp !++        
!:       lda box_frame_colour
!:       sta box_colour_working
        jsr _colframe

        clc
        lda box_col_origin
        adc #X_CHARS+1  
        sta _chptr
        lda box_col_origin+1 
        adc #0
        sta _chptr+1
        clc
        lda box_height
        sbc #1
        sta box_height_working
        clc
        lda box_width
        sbc #1
        sta box_width_working
        lda box_colour
        sta box_colour_working
        jsr _colbox
        
//print legend
        lda box_legend
        cmp #0
        beq !++
        clc
        ldx box_y
        ldy box_x
        jsr plot
        
        lda box_colour
        sta chrout_colour
        
        lda #1
        cmp box_select
        beq !+
        lda #0
!:       sta 199        
        
        lda box_legend
        ldx box_legend+1       
        jsr printstr               
!:       lda #0                                                  
        rts        
        
_colframe:                
        lda box_colour_working
        ldy box_width_working
!:       dey
        sta (_chptr),Y
        bne !-
        dec box_height_working
        
!:       clc
        lda #X_CHARS
        adc _chptr
        sta _chptr
        lda #0
        adc _chptr+1
        sta _chptr+1
        ldy box_width_working
        dey
        lda box_colour_working        
        sta (_chptr),Y
        ldy #0        
        sta (_chptr),Y     
        dec box_height_working
        bne !-
        
        ldy box_width_working
!:       dey
        sta (_chptr),Y
        bne !-
        lda #0                                   
        rts
        
_colbox:                
!:       lda box_colour_working
        ldy box_width_working
!:       dey
        sta (_chptr),Y
        bne !-
        clc
        lda #X_CHARS
        adc _chptr
        sta _chptr
        lda #0
        adc _chptr+1
        sta _chptr+1        
        dec box_height_working
        bne !--
        ldy #method_detail
        jsr reinvokevirtual        
        lda #0                    
        rts 

#import "lib/screenModes.asm"   

automata:
        jsr enter_fullscreen
        lda #0
        cmp fullscreen
        beq !+
        jsr initialise_ptrs_automata
        jsr initialise_cells_automata
!:      lda #0
        rts
        
continue:
        lda #0
        cmp fullscreen
        beq !+
        jsr initialise_ptrs_automata4
        jsr _render_automata_row
!:       lda #0
        rts         
        
initialise_ptrs_automata:
        // initate pointers
        lda #<bitmap
        sta row_start
        lda #>bitmap
        sta row_start+1
        
        lda #[11*16]
        sta row_counter
        
        lda  cellsrc
        sta _tempptr
        lda  cellsrc+1
        sta _tempptr+1
        rts

initialise_cells_automata:        
        // clear and initailise src buffer
        ldy #[box_check-box_origin]
        lda [boxRandom+jmp_header_size],Y
        cmp #0
        beq _random_init              

_one_cell_init:      
        ldy #[8*20]        
        lda #0
!:       sta (_tempptr),Y
        dey
        bne !-
        lda #01
        sta cellbuffer1+80
        jmp  _render_automata_row
       
_random_init:
       ldy #[8*20]                
!:      lda 0,Y
       and #01
       sta (_tempptr),Y
       dey
       bne !-
                              
_render_automata_row:
        clc
        lda  cellsrc
        adc #1
        sta _tempptr
        lda  cellsrc+1
        adc #0
        sta _tempptr+1

        lda row_start
        sta _chptr
        lda row_start+1
        sta _chptr+1

        lda #20
        sta col_counter      
        
        // render new row
        
_render_automata_col:                
        //collect 8 pixels from buffer
        ldx #8
        ldy #0
!:       clc
        lda pixel_acc
        asl
        sta pixel_acc
        lda (_tempptr),Y
        and #01
        ora pixel_acc
        sta pixel_acc
        iny       
        dex
        bne !-
        pha
        clc
        lda #8
        adc _tempptr
        sta _tempptr
        lda #0
        adc _tempptr+1
        sta _tempptr+1 
        pla       
                
        //write 8 pixels to screen
        ldy #0
        sta (_chptr),Y
        
        //advance screen pointer to next 8 pixels
        clc
        lda _chptr
        adc #$10
        sta _chptr
        lda _chptr+1
        adc #0
        sta _chptr+1
                
        //repeat till end of buffer
        dec col_counter
        bne _render_automata_col
        
        //repeat till end of screen
        //advance row start
        dec row_counter
        clc
        lda #$01
        adc row_start
        sta row_start
        lda #$00
        adc row_start+1    
        sta row_start+1        
        
        lda row_counter
        and #$0F
        cmp #0
        bne !+ 
        clc
        lda #$30
        adc row_start
        sta row_start
        lda #$01
        adc row_start+1    
        sta row_start+1  
       
        // calculate new row into dst using src
!:      lda cellsrc
        sta _chptr
        lda cellsrc+1
        sta _chptr+1
        
        lda celldst
        sta _tempptr
        lda celldst+1
        sta _tempptr+1
               
        //exchange last first and cells
        ldy #160
        lda (_chptr),Y
        ldy #0
        sta (_chptr),Y
        ldy #1     
        lda (_chptr),Y
        ldy #161        
        sta (_chptr),Y                         
                             
        ldy #1
        
!:      ldx #0
        stx _styleptr               
        dey
        txa
        cmp (_chptr),Y
        beq !+
        lda _styleptr       
        ora #1
        sta _styleptr       
        
!:      iny
        txa
        cmp (_chptr),Y
        beq !+ 
        lda _styleptr       
        ora #2
        sta _styleptr
                              
!:      iny
        txa
        cmp (_chptr),Y
        beq !+
        lda _styleptr       
        ora #4
        sta _styleptr        
                
!:      tya
        pha
        
        ldy _styleptr                  
        ldx rule,Y 
                
        pla
        tay
        
        txa
        dey     
        sta (_tempptr),Y
        iny       
         
        cpy #161
        bne !----                     

        //swap pointers
        lda _chptr
        sta celldst
        lda _chptr+1
        sta celldst+1
        
        lda _tempptr
        sta cellsrc
        lda _tempptr+1
        sta cellsrc+1       
       
        lda row_counter
        cmp #0
        beq !+
        jmp _render_automata_row
                
!:      lda #0 //Dont signal exit 
        rts


automata4:
        jsr enter_fullscreen_multi
        lda #0
        cmp fullscreen
        beq !+
        jsr initialise_ptrs_automata4
        jsr initialise_cells_automata4
!:      lda #0
        rts
        
continue4:
        lda #0
        cmp fullscreen
        beq !+
        jsr initialise_ptrs_automata4
        jsr _render_automata_row4
!:      lda #0
        rts            
        
initialise_ptrs_automata4:
        // initate pointers
        lda #<bitmap
        sta row_start
        lda #>bitmap
        sta row_start+1
        
        lda #[11*16]
        sta row_counter        
        
        lda  cellsrc
        sta _tempptr
        lda  cellsrc+1
        sta _tempptr+1
        rts

initialise_cells_automata4:     
        // clear and initailise src buffer
        ldy #[box_check-box_origin]
        lda [boxRandom+jmp_header_size],Y
        cmp #0
        beq _random_init4              

_one_cell_init4:      
        ldy #[4*20]+2        
        lda #0
!:      sta (_tempptr),Y
        dey
        bne !-
        lda #03
        sta cellbuffer1+40
        jmp  _render_automata_row4
       
_random_init4:
       lda $A2
       clc
       ldy #[4*20]+2                
!:     adc 0,Y
       pha
       and #03
       sta (_tempptr),Y
       pla
       dey
       bne !-
                              
_render_automata_row4:
        clc
        lda cellsrc
        adc #1          //Start 1 cell in to allow for wrapping
        sta _tempptr
        lda  cellsrc+1
        adc #0
        sta _tempptr+1

        lda row_start
        sta _chptr
        lda row_start+1
        sta _chptr+1

        lda #20
        sta col_counter      
        
        // render new row
        
_render_automata_col4:                
        //collect 4 pixels from buffer
        ldx #4
        ldy #0
        sty pixel_acc        
!:      clc
        lda pixel_acc
        asl
        asl
        sta pixel_acc
        lda (_tempptr),Y
        and #03
        ora pixel_acc
        sta pixel_acc
        iny       
        dex
        bne !-
        pha
        clc
        lda #4
        adc _tempptr
        sta _tempptr
        lda #0
        adc _tempptr+1
        sta _tempptr+1 
        pla      
                
        //write 4 multicolour pixels to screen
        ldy #0
        sta (_chptr),Y
        
        //advance screen pointer to next 4 pixels
        clc
        lda _chptr
        adc #$10        //bytes in a double height programmable character
        sta _chptr
        lda _chptr+1
        adc #0
        sta _chptr+1
                
        //repeat till end of buffer
        dec col_counter
        bne _render_automata_col4
        
        //repeat till end of screen
        //advance row start
        dec row_counter
        clc
        lda #$01
        adc row_start
        sta row_start
        lda #$00
        adc row_start+1    
        sta row_start+1        
        
        lda row_counter
        and #$0F
        cmp #0
        bne !+ 
        clc
        lda #$30
        adc row_start
        sta row_start
        lda #$01
        adc row_start+1    
        sta row_start+1  
       
        // calculate new row into dst using src
!:      lda cellsrc
        sta _chptr
        lda cellsrc+1
        sta _chptr+1
        
        lda celldst
        sta _tempptr
        lda celldst+1
        sta _tempptr+1
               
        //exchange last first and cells
        ldy #80
        lda (_chptr),Y
        ldy #0
        sta (_chptr),Y

        ldy #1     
        lda (_chptr),Y
        ldy #81        
        sta (_chptr),Y                         
                             
        ldy #0
        
!:      dey
        lda (_chptr),Y    //Previous cell          
        iny
        adc (_chptr),Y    //Current cell                        
        iny
        adc (_chptr),Y    //Next cell
        dey               //Set cell index back to current
        tax               //Summed cells to X                                          
        tya
        pha               //Push current index
            
        txa  
        tay        
        ldx rule4,Y        //Look up summed value via rule into X
                
        pla               //Recover index from stack
        tay
        
        txa
        sta (_tempptr),Y  //Save new cell value at current index on output ptr
        iny               //Advance current index
         
        cpy #81          //Repeat until all cells processed
        bne !-                    

        //swap pointers
        lda _chptr
        sta celldst
        lda _chptr+1
        sta celldst+1
        
        lda _tempptr
        sta cellsrc
        lda _tempptr+1
        sta cellsrc+1       
       
        lda row_counter
        cmp #0
        beq !+
        jmp _render_automata_row4
                
!:      lda #0 //Dont signal exit 
        rts


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
        
        
update_rule4:
        sec
        sbc #49 // Key=index, 0=9, 1=0, 2=1, 3=2 ...
        bpl !+
        lda  #9        
!:      tay
        lda #<rule4
        sta _chptr
        lda #>rule4
        sta _chptr+1
                
        lda #<rule4Str
        sta _styleptr
        lda #>rule4Str
        sta _styleptr+1
        
        lda (_chptr),Y
        clc
        adc #1
        and #3
        sta (_chptr),Y
        adc #48
        sta (_styleptr),Y
        jsr writeBank        
        lda #0
        rts
        
renderrule4:
        lda #<rule4
        sta _chptr
        lda #>rule4
        sta _chptr+1
                
        lda #<rule4Str
        sta _styleptr
        lda #>rule4Str
        sta _styleptr+1
        
        ldy #0
!:      lda (_chptr),Y
        clc
        adc #48
        sta (_styleptr),Y
        iny
        cpy #10
        bne !-
        jsr render
        rts              
    

handlekey:
        jsr construct
        lda #1
        cmp box_select
        bne !++
              
        lda #KEY_RETURN
        cmp keypress
        bne !+
        ldy #method_action
        jsr reinvokevirtual
        rts
        
!:      lda #KEY_SPACE
        cmp keypress
        bne !+
        ldy #method_continue
        jsr reinvokevirtual
        rts         
        
        
!:      lda #KEY_ESC
        cmp keypress
        bne !+
        ldy #method_escape
        jsr reinvokevirtual
        rts                
                
!:      lda #0 //Dont signal program end
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
        
handlerulekey4:
        jsr construct
        lda #1
        cmp box_select
        bne !+
        lda keypress      
        cmp #48
        bcc !+ 
        cmp #58
        bcs !+        
        ldy #method_action
        jsr reinvokevirtual
        jsr construct
        lda #1
        saveObjectByte(box_edited)
        lda #0 //Dont signal program end
        rts
                
!:      cmp #83 //S for Save 
        bne !++

        lda #0
        ldx $BA
        bne !+
        ldx #DEVICE
!:      ldy #0
        jsr setlfs

        lda #[ruleStr-filenameSStr]
        ldx #<filenameSStr   
        ldy #>filenameSStr
        jsr setnam

        lda #<rule4bank
        sta _chptr
        lda #>rule4bank
        sta _chptr+1        
        ldx #<rule4bankend
        ldy #>rule4bankend
        lda #247        
        jsr save
        lda #0
        saveObjectByte(box_edited)        
        lda #0 //Dont signal program end
        rts
                
!:      cmp #76 //L for Load 
        bne !++

        lda #0
        ldx $BA
        bne !+
        ldx #DEVICE
!:      ldy #0
        jsr setlfs

        lda #[filenameSStr-filenameLStr]
        ldx #<filenameLStr  
        ldy #>filenameLStr
        jsr setnam

        lda #0      //Load
        ldx #<rule4bank
        ldy #>rule4bank
        jsr load
        jmp !+
        // getInstanceVariable(box_check, boxRule4Index)
        // sta 4536

        jsr readBank
                
!:      lda #0 //Dont signal program end
        rts     
        
handlekeyc:
        jsr construct
        lda #1
        cmp box_select
        bne !+
        ldy #[box_colour-box_origin]        
        lda keypress      
        cmp #KEY_CSR_UP
        beq !++
        cmp #KEY_CSR_DOWN
        beq !++++
!:      lda #0 //Dont signal program end
        rts
!:      lda (this),Y
        clc
        adc #1
!:      and #7
        sta (this),Y
        lda #1
        saveObjectByte(box_edited)              
        jmp !---
!:      lda (this),Y
        sec
        sbc #1
        jmp !--

handlekeyi:        
        jsr construct
        lda #1
        cmp box_select
        bne !++
        ldy #[box_check-box_origin]        
        lda keypress      
        cmp #KEY_CSR_UP
        beq !+++
        cmp #KEY_CSR_DOWN
        beq !+++++
        jmp !++
!:      jsr readBank
!:      lda #0 //Dont signal program end        
        rts
!:      lda (this),Y
        clc
        adc #1
!:      and #$0F
        sta (this),Y
        sta rule4index        
        jmp !----
!:      lda (this),Y
        sec
        sbc #1
        jmp !--
        
writeBank:
        pha
        tya
        pha
        txa
        pha
        
        lda #<rule4bank
        sta _chptr
        lda #>rule4bank
        sta _chptr+1
        lda rule4index
        clc
        asl
        asl
        asl
        asl
        adc _chptr
        sta _chptr
        lda #0
        adc _chptr+1
        sta _chptr+1 

        lda #<rule4
        sta _tempptr
        lda #>rule4
        sta _tempptr+1        
          
        ldy #10
!:      dey
        lda (_tempptr),Y
        sta (_chptr),Y
        cpy #0     
        bne !-    
        
        pla
        tax
        pla
        tay
        pla
        rts
        
        
readBank:
        pha
        sta _scratch        
        tya
        pha
        txa
        pha

        lda #<rule4bank
        sta _chptr
        lda #>rule4bank
        sta _chptr+1
        lda _scratch
        clc
        asl
        asl
        asl
        asl
        adc _chptr
        sta _chptr
        lda #0
        adc _chptr+1
        sta _chptr+1 


        lda #<rule4
        sta _tempptr
        lda #>rule4
        sta _tempptr+1        
          
        ldy #10
!:      dey
        lda (_chptr),Y
        sta (_tempptr),Y
        cpy #0     
        bne !-
        
        pla
        tax
        pla
        tay
        pla
        rts               
        
render_index:
        jsr construct
        clc
        lda box_origin
        adc #X_CHARS+1
        sta _chptr
        lda box_origin+1
        adc #0 
        sta _chptr+1                

        loadObjectByte(box_check)
        tax
        cpx #10
        bcc !+   //10 or more        
        sbc #9        
        jmp !++
!:      adc #48
!:      ldy #0
        sta (_chptr),Y
        lda #0              
        rts               
                                            
flowKey:    
    lda keypress  
    
    cmp #KEY_CSR_LEFT
    bne _not_leftf
    dec selected
    jmp _key_handledf
_not_leftf:
    cmp #KEY_CSR_RIGHT
    bne !+++
    inc selected
    
_key_handledf:
    callMethod(method_deselect, _boxList)
    
    // skip any boxes with bit 1 or selected set
    lda #method_select
    sta method
    lda selected    
    cmp #0
    bne !+
    lda #boxes_list_size-1
    jmp !++
!:  cmp #boxes_list_size
    bne !+
    lda #1
!:  sta selected                         
    jsr _boxListAt
!:  lda #0 //Dont signal exit
    rts

_boxList:
    ldy #0
    sty return
!:  lda boxes+1,Y
    iny
    ldx boxes+1,Y
    iny
    sty _scratch+1
    ldy method
    jsr invokevirtual
    cmp #0
    beq !+
    sta return
!:  ldy _scratch+1 
    cpy boxes
    bcc !--
    beq !--
    rts

_boxListAt:
    asl
    tay
    lda boxes+1,Y
    ldx boxes+2,Y
    ldy method
    jmp invokevirtual //JSR,rts
    
construct:
        ldy #3
        lda (this),Y // Fetch size of variables
        pha        
        iny
        lda (this),Y // Fetch fixed variable pointer low byte
        sta _chptr
        iny
        lda (this),Y // Fetch fixed variable pointer high byte
        sta _chptr+1 
        clc        //advance this pointer over vtable to point at data
        lda this
        adc #jmp_header_size
        sta this
        lda this+1
        adc #0
        sta this+1
        
        pla
        tay
!:      lda (this),Y
        sta (_chptr),Y
        dey
        bpl !-           
        rts

doJumpTable:
         sta _scratch
         pla
         sta _tempptr
         pla
         sta _tempptr+1
         tya
         asl
         tay
         iny
         lda (_tempptr), y
         sta _target
         iny
         lda (_tempptr), y
         sta _target+1
         lda _scratch
         jmp (_target)
             
            
invokevirtual:
         sta this
         stx this+1
         jmp (this)
         
reinvokevirtual:
        pha
        sec        //return this pointer to vtable
        lda this
        sbc #jmp_header_size
        sta this
        lda this+1
        sbc #0
        sta this+1
        pla
        jmp (this)
         
empty:
        lda #0
        rts
        
exit:
        jsr leave_fullscreen
        lda #1
        rts
      
flow:
 jmp flow_vtable
.byte 1
.word keys_pressed 
.byte 0   

title:
 jmp lable_vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 0 + [X_CHARS*0]
.word colour_mem_hi + 0 + [X_CHARS*0]
.byte 1,1,22,3
.byte yellow,yellow
.word styleTitle
.word automataStr
.byte 2
.byte 0
.byte 0
  
boxRun:
 jmp confirmboxes_vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 17 + [X_CHARS*4]
.word colour_mem_hi + 17 + [X_CHARS*4]
.byte 18,6,5,5
.byte cyan,white
.word style1
.word runStr
.byte 0
.byte 0
.byte 0

boxRuleBinary:
 jmp binaryrule_vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 0 + [X_CHARS*5]
.word colour_mem_hi + 0 + [X_CHARS*5]
.byte 1,6,10,3
.byte white,white
.word style3
.word ruleStr
.byte 1
.byte 0
.byte 0


boxRandom:
 jmp toggleBoxes_vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 2 + [X_CHARS*12]
.word colour_mem_hi + 2 + [X_CHARS*12]
.byte 2,11,3,3
.byte cyan,white
.word style1
.word rndStr
.byte 0
.byte 0
.byte 0

boxColB:
 jmp colourboxes_vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 7 + [X_CHARS*12]
.word colour_mem_hi + 7 + [X_CHARS*12]
.byte 7,11,3,3
.byte blue,white
.word style3
.word backStr
.byte 0
.byte 0
.byte 0

boxColR:
 jmp colourboxes_vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 11 + [X_CHARS*12]
.word colour_mem_hi + 11 + [X_CHARS*12]
.byte 11,11,3,3
.byte green,white
.word style3
.word bordStr
.byte 0
.byte 0
.byte 0

boxColP:
 jmp colourboxes_vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 15 + [X_CHARS*12]
.word colour_mem_hi + 15 + [X_CHARS*12]
.byte 15,11,3,3
.byte yellow,white
.word style3
.word penStr
.byte 0
.byte 0
.byte 0

boxColA:
 jmp colourboxes_vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 19 + [X_CHARS*12]
.word colour_mem_hi + 19 + [X_CHARS*12]
.byte 19,11,3,3
.byte red,white
.word style3
.word auxStr
.byte 0
.byte 0
.byte 0

boxRule4Index:
 jmp rule4Index_vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 0 + [X_CHARS*16]
.word colour_mem_hi + 0 + [X_CHARS*16]
.byte 0,15,3,3
.byte white,white
.word style3
.word indStr
.byte 0
.byte 0
.byte 0

boxRuleBit4:
 jmp bit4rule_vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 3 + [X_CHARS*15]
.word colour_mem_hi + 3 + [X_CHARS*15]
.byte 5,17,14,5
.byte white,white
.word style3
.word rule4Str
.byte 0
.byte 0
.byte 0

boxRun4:
 jmp confirmboxes4_vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 17 + [X_CHARS*15]
.word colour_mem_hi + 17 + [X_CHARS*15]
.byte 18,17,5,5
.byte cyan,white
.word style1
.word runStr
.byte 0
.byte 0
.byte 0
    
boxExit:
 jmp exitboxes_vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 16 + [X_CHARS*20]
.word colour_mem_hi + 16 + [X_CHARS*20]
.byte 17,21,6,3
.byte cyan,white
.word style1
.word exitStr
.byte 0
.byte 0
.byte 0

boxFinal:
 jmp boxes_vtable
.byte [box_width_working-box_origin]-1
.word box_origin  
.word screen_mem_hi + 1 + [X_CHARS*1]
.word colour_mem_hi + 1 + [X_CHARS*1]
.byte 2,2,X_CHARS-2,Y_CHARS-2
.byte white,red
.word style2
.word 0
.byte 0
.byte 0
.byte 0

cellsrc:
.word cellbuffer1
celldst:
.word cellbuffer2
rule:
.byte 0,1,1, 1,1,0, 0,0
ruledec:
.byte 30
rule4:
.byte 1,2,3, 0,1,2, 2,0,3, 2
endrule4:

rule4index:
.byte 0

rule4bank:
.byte 1,2,3, 0,1,2, 2,0,3, 2, 0,0,0,0,0,0
.byte 2,0,1,2,2,2,3,3,0,2,0,0,0,0,0,0
.byte 1,2,0,0,1,3,1,1,0,1,0,0,0,0,0,0
.byte 2,2,2,2,2,1,2,3,2,3,0,0,0,0,0,0

.byte 3,0,1,0,0,0,2,0,0,0,0,0,0,0,0,0
.byte 2,1,3,1,2,1,3,3,0,1,0,0,0,0,0,0
.byte 2,0,1,1,2,0,3,3,2,2,0,0,0,0,0,0
.byte 3,3,3, 3,3,3, 3,3,3, 3, 0,0,0,0,0,0

.byte 0,0,0, 0,0,0, 0,0,0, 0, 0,0,0,0,0,0
.byte 1,1,1, 1,1,1, 1,1,1, 1, 0,0,0,0,0,0
.byte 2,2,2, 2,2,2, 2,2,2, 2, 0,0,0,0,0,0
.byte 3,3,3, 3,3,3, 3,3,3, 3, 0,0,0,0,0,0

.byte 0,0,0, 0,0,0, 0,0,0, 0, 0,0,0,0,0,0
.byte 1,1,1, 1,1,1, 1,1,1, 1, 0,0,0,0,0,0
.byte 2,2,2, 2,2,2, 2,2,2, 2, 0,0,0,0,0,0
.byte 3,3,3, 3,3,3, 3,3,3, 3, 0,0,0,0,0,0
rule4bankend:

boxes:
.byte 24
.word flow
.word title
.word boxRuleBinary
.word boxRun
.word boxRandom
.word boxColB
.word boxColR
.word boxColP
.word boxColA
.word boxRule4Index
.word boxRuleBit4
.word boxRun4
.word boxExit

exitStr: str("EXIT")
runStr: str("RUN")
backStr: str("BCK")
penStr: str("PEN")
auxStr: str("AUX")
bordStr: str("BOR")
rndStr: str("RND")
indStr: str("IND")
automataStr: str("1D CELLULAR AUTOMATA")
filenameLStr: .text "RULE"
filenameSStr: .text "0Str:RULE"
ruleStr: str("********")
rule4Str: str("**********")
style1: .byte 64, 64, 93, 93, 110, 112, 125, 109, 102
style2: .byte 98, 98+128, 97, 97+128, 123, 108, 126, 124, 160
style3: .byte 64, 64, 93, 93, 73, 85, 75, 74, 102
style4: .byte 98+128, 98, 97+128, 97, 127, 255, 255, 127, 102
styleTitle: .byte 98+128, 98, 97+128, 97, 127, 127+128, 127+128, 127, 127+128

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





 


