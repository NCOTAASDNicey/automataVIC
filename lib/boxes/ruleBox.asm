bit4rule_vtable:
    jsr doJumpTable
    .word renderrule4, handlerulekey4, select, deselect, update_rule4, empty, empty, empty

renderrule4:
        ldy #0
!:      lda rule4,Y
        clc
        adc #48
        sta str_rule4,Y
        iny
        cpy #10
        bne !-
        jsr render
        rts

handlerulekey4: 
        loadBoxField(boxRuleBit4,box_select)
        beq !+

        lda keypress           
        cmp #48 // Numeric key
        bcc !+
        cmp #58
        bcs !+

        jsr update_rule4
        markBoxEdited(boxRuleBit4)
!:      jmp empty


update_rule4:
        sec
        sbc #49
        bpl !+
        lda #9
 !:     tay

        lda rule4,Y
        clc
        adc #1
        and #3
        sta rule4,Y
        adc #48
        sta str_rule4,Y
        lda #0
        rts
        
rule4:
.byte 1,2,3, 0,1,2, 2,0,3, 2
