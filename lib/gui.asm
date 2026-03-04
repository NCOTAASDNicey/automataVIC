.const top = 0
.const bottom = 1
.const right = 2
.const left = 3
.const top_right = 4
.const top_left = 5
.const bottom_right = 6
.const bottom_left = 7
.const fill = 8

.const COLUMNS=40
.const ROWS=25
.const PIXELS_PER_BYTE=4
.const BYTES_PER_CHAR=8
.const BUFFER_LENGTH=COLUMNS*PIXELS_PER_BYTE
.const RULE_LENGTH=10
.const HELP_COL=1
.const HELP_ROW=23

get:
        jsr construct
        ldy variable
        lda (this),Y
        rts

select:
        jsr construct
        ldy #[box_select-box_origin]
        lda #1
        sta (this),Y
        jmp empty
        
deselect:
        jsr construct
        ldy #[box_select-box_origin]
        lda #0
        sta (this),Y
        jmp empty

render:
        jsr construct
        lda scrmode
        beq !+
        jmp empty

!:      lda box_height
        sta box_height_working
        lda box_select
        beq _notselected
        lda #<styleSelected
        sta _styleptr
        lda #>styleSelected
        sta _styleptr+1
        jmp _style_done
        
_notselected:
        loadObjectPointer(box_style, _styleptr)
_style_done:
        loadObjectPointer(box_origin, _chptr)
                                               
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
        cmp #96
        bne useFill
        ldy #0
        jmp noFill
useFill:
        ldy box_width_working
!:      dey
        sta (_chptr),y
        bne !-
noFill:        
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
!:      dey
        sta (_chptr),y
        bne !-
        sty box_width_working
        ldy #bottom_left
        lda (_styleptr),Y
        ldy box_width_working
        sta (_chptr),y
 
//Fill in colour frame
        lda box_col_origin
        sta _chptr
        lda box_col_origin+1
        sta _chptr+1

        lda box_height
        sta box_height_working
        lda box_width
        sta box_width_working
        lda box_edited
        beq !+
        lda #edited_col
        jmp !+++
!:      lda box_select
        beq !+
        lda #active_col
        jmp !++
!:      lda box_frame_colour
!:      sta box_colour_working
        jsr _colframe

//Fill in colour content
        ldy #fill
        lda (_styleptr),Y
        cmp #96
        beq noColourFill

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
noColourFill:
        
//print legend
        lda box_legend
        beq !++

        lda box_colour
        sta chrout_colour
        lda #1
        cmp box_select
        beq !+
        lda #0
!:      sta 199

        printptratpos(box_legend,box_x,box_y)

//print help
 !:     lda box_help
        beq !+
        lda box_select
        beq !+
        printat(str_help_blank,HELP_COL,HELP_ROW)
        lda #0 // test
        printptrat(box_help,HELP_COL,HELP_ROW)
!:      jmp empty
       
        
_colframe:
        lda box_colour_working
        ldy box_width_working
!:      dey
        sta (_chptr),Y
        bne !-
        dec box_height_working

!:      clc
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
!:      dey
        sta (_chptr),Y
        bne !-
        lda #0
        rts
        
_colbox:
!:      lda box_colour_working
        ldy box_width_working
!:      dey
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

        
handlekey:
        jsr construct
        lda box_select
        beq !+++

        lda #KEY_RETURN
        cmp keypress
        bne !+
        ldy #method_action
        jmp reinvokevirtual
        
!:      lda #KEY_SPACE
        cmp keypress
        bne !+
        ldy #method_continue
        jmp reinvokevirtual       

!:      lda #KEY_ESC
        cmp keypress
        bne !+
        ldy #method_escape
        jmp reinvokevirtual

        !:     lda #0 //Dont signal program end
        rts
                  
                                            
flowKey:
        lda keypress  

        cmp #KEY_CSR_LEFT
        bne _not_leftf
        dec selected
        bpl _key_handledf
        lda #boxes_interactive_size-1
        sta selected
        jmp _key_handledf
_not_leftf:
        cmp #KEY_CSR_RIGHT
        bne !+
        inc selected
        lda selected
        cmp #boxes_interactive_size
        bcc _key_handledf
        lda #0
        sta selected       

_key_handledf:
        callMethod(method_deselect, _boxlist)
        lda #method_select
        sta method
        lda selected
        jsr _boxListAt

!:      cmp #83 //S for Save
        bne !+
        isBoxChecked(boxRule4Index)
        jsr writeBank        
        jsr saveRule
        lda #0
        markBoxUnEdited(boxRuleBit4)
        jmp empty        

!:      cmp #76 //L for Load
        bne !+
        jsr loadRule
        isBoxChecked(boxRule4Index)
        jsr rdBank
        jmp empty        

!:      cmp #82 //R for Random rule
        bne !+
        toggleBoxChecked(boxRR)

!:      cmp #79 //O for Scroll
        bne !+
        toggleBoxChecked(boxScroll)         

!:      cmp #88 //X for Exit
        bne !+
        jmp exit

!:      cmp #78 //N for run
        bne !+
        lda #method_deselect
        sta method
        lda selected
        jsr _boxListAt

        lda #2
        sta selected

        lda #method_select
        sta method
        lda selected
        jsr _boxListAt

        lda #method_action
        sta method
        lda selected
        jsr _boxListAt                      

!:      jmp empty



_boxlist:
        ldy #0
        sty return
!:      lda boxes,Y
        iny
        ldx boxes,Y
        iny
        sty SYREG

        ldy method
        jsr invokevirtual
        cmp #0
        beq !+
        sta return 
!:      ldy SYREG 
        cpy #boxes_list_size*2
        bcc !--
        lda return
        rts


_boxListAt:
        asl
        tay
        lda boxes,Y
        ldx boxes+1,Y
        ldy method
        jmp invokevirtual //JSR,RTS
    
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
        sta SAREG
        pla
        sta _tempptr
        pla
        sta _tempptr+1
        tya
        asl
        tay
        iny
        lda (_tempptr), y
        sta destination
        iny
        lda (_tempptr), y
        sta destination+1
        lda SAREG
        jmp (destination)
             
            
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
        lda #1
        rts
