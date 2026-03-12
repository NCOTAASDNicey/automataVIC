binaryrule_vtable:
    jsr doJumpTable
    .word render_ruleb, handlerulekeyb, select, deselect, update_ruleb, empty, empty, empty
        
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
        loadBoxField(boxRuleBinary,box_select)
        beq !+
        lda keypress      
        cmp #48
        bcc !+ 
        cmp #57
        bcs !+        
        jsr update_ruleb
        markBoxEdited(boxRuleBit4)
!:      jmp empty

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
        
rule:
.byte 0,1,1, 1,1,0, 0,0