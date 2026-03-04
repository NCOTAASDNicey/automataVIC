bit4ruleVtable:
     jsr doJumpTable
    .word renderrule4, handlerulekey4, select, deselect, update_rule4, empty, empty, empty

renderrule4:
        lda #<rule4
        sta _chptr
        lda #>rule4
        sta _chptr+1

        lda #<str_rule4
        sta _styleptr
        lda #>str_rule4
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

handlerulekey4: 
        jsr construct
        lda box_select
        beq !+

        lda keypress           
        cmp #48 // Numeric key
        bcc !+
        cmp #58
        bcs !+

        ldy #method_action
        jsr reinvokevirtual
        jsr construct
        lda #1
        saveObjectByte(box_edited)
!:      jmp empty


update_rule4:
        sec
        sbc #49
        bpl !+
        lda #9
 !:     tay
        lda #<rule4
        sta _chptr
        lda #>rule4
        sta _chptr+1

        lda #<str_rule4
        sta _styleptr
        lda #>str_rule4
        sta _styleptr+1

        lda (_chptr),Y
        clc
        adc #1
        and #3
        sta (_chptr),Y
        adc #48
        sta (_styleptr),Y
        lda #0
        rts
        
rule:
.byte 0,1,1, 1,1,0, 0,0