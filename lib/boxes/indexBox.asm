rule4IndexVtable:
     jsr doJumpTable    
    .word render, handlekeyi, select, deselect, empty, render_index, empty, empty       



handlekeyi: {
        jsr construct
        lda box_select
        beq done

        lda keypress
        cmp #KEY_CSR_UP
        beq increment
        cmp #KEY_CSR_DOWN
        beq decrement
        jmp done
read:   jsr rdBank
done:   jmp empty


increment:
        loadObjectByte(box_check)
        jsr writeBank
        clc
        adc #1
wrapnread:
        and #$0F
        saveObjectByte(box_check)
        jmp read

decrement:
        loadObjectByte(box_check)
        jsr writeBank
        sec
        sbc #1
        jmp wrapnread
}

        
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
        jmp empty

_bankPtrs:
        clc
        asl
        asl
        asl
        asl
        sta SAREG
        lda #<rule4bank
        sta _chptr
        lda #>rule4bank
        sta _chptr+1
        clc
        lda _chptr
        adc SAREG
        sta _chptr
        lda _chptr+1
        adc #0
        sta _chptr+1

        lda #<rule4
        sta _tempptr
        lda #>rule4
        sta _tempptr+1
        rts
        
writeBank:
        enterProc()
        jsr _bankPtrs          
        ldy #10
!:      dey
        lda (_tempptr),Y
        sta (_chptr),Y
        cpy #0     
        bne !-
        leaveProc()
        rts     

rdBank:
        enterProc()
        jsr _bankPtrs
        ldy #10
!:      dey
        lda (_chptr),Y
        sta (_tempptr),Y
        cpy #0
        bne !-
        leaveProc()
        rts

rule4bank:
.byte 1,2,3,0,1,2,2,0,3,2,0,0,0,0,0,0
.byte 2,0,1,2,2,2,3,3,0,2,0,0,0,0,0,0
.byte 1,2,0,0,1,3,1,1,0,1,0,0,0,0,0,0
.byte 2,2,2,2,2,1,2,3,2,3,0,0,0,0,0,0

.byte 3,0,1,0,0,0,2,0,0,0,0,0,0,0,0,0
.byte 2,1,3,1,2,1,3,3,0,1,0,0,0,0,0,0
.byte 2,0,1,1,2,0,3,3,2,2,0,0,0,0,0,0
.byte 3,3,3, 3,3,3, 3,3,3, 3, 0,0,0,0,0,0

.byte 0,0,0, 0,0,0, 0,0,0, 0, 6,5,7,2,0,0
.byte 1,1,1, 1,1,1, 1,1,1, 1, 6,5,7,2,0,0
.byte 2,2,2, 2,2,2, 2,2,2, 2, 6,5,7,2,0,0
.byte 3,3,3, 3,3,3, 3,3,3, 3, 6,5,7,2,0,0

.byte 0,0,0, 0,0,0, 0,0,0, 0, 6,5,7,2,0,0
.byte 1,1,1, 1,1,1, 1,1,1, 1, 6,5,7,2,0,0
.byte 2,2,2, 2,2,2, 2,2,2, 2, 6,5,7,2,0,0
.byte 3,3,3, 3,3,3, 3,3,3, 3, 6,5,7,2,0,0
rule4bankend: