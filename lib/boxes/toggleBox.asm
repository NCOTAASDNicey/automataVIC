toggleBoxesVtable:
     jsr doJumpTable
   .word render, handlekey, select, deselect, toggle, render_toggle, empty, empty

toggle:
        jsr construct
        loadObjectByte(box_check)
        eor #1
        sta (this),Y
        jmp empty
        
render_toggle:
        jsr construct
        ldy box_x
        iny
        ldx box_y
        inx
        clc
        jsr plot         
        lda box_colour
        sta chrout_colour
        lda box_check
        bne !+
        lda #119        
        jmp !++
!:      lda #113
!:      jsr chrout
        jmp empty

.macro toggleBox(str,help,x,y,xo,yo,state){
    boxflagged(toggleBoxesVtable,str,help,x,y,3,3,xo,yo,selected_col,edge_col,styleAction,0,state)
}

