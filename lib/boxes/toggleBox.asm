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
        clc
        lda box_origin
        adc #X_CHARS+1
        sta _chptr
        lda box_origin+1
        adc #0 
        sta _chptr+1                

        lda box_check
        bne !+
        lda #87        
        jmp !++
!:      lda #81
!:      ldy #0
        sta (_chptr),Y
        jmp empty

.macro toggleBox(str,help,x,y,xo,yo){
    box(toggleBoxesVtable,str,help,x,y,3,3,xo,yo,selected_col,edge_col,styleAction,0)
}

