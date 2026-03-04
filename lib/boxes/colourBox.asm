colourboxesVtable:
     jsr doJumpTable    
    .word render, handlekeyc, select, deselect, empty, empty, empty, empty       

handlekeyc:{
        jsr construct
        lda box_select
        beq done
        lda keypress
        cmp #KEY_CSR_UP
        beq increment
        cmp #KEY_CSR_DOWN
        beq decrement
done:   jmp empty

increment:      
        loadObjectByte(box_colour)
        clc
        adc #1
wrap:   and #15
        saveObjectByte(box_colour)
        lda #1
        saveObjectByte(box_edited)
        jmp done
decrement:
        loadObjectByte(box_colour)
        sec
        sbc #1
        jmp wrap
}

.macro colourBox(str,x,y,colour){
    box(colourboxesVtable,str,str_help_csr,x,y,3,3,0,-1,colour,edge_col,styleWidget,0)
}

