rule4IndexVtable:
     jsr doJumpTable    
    .word render, handlekeyi, select, deselect, empty, render_index, empty, empty

handlekeyi: 
        jsr construct
        loadBoxField(boxRule4Index,box_select)
        beq done_i

        lda keypress
        cmp #KEY_CSR_UP
        beq increment_i
        cmp #KEY_CSR_DOWN
        beq decrement_i
        jmp done_i
read_i: jsr rdBank
done_i: jmp empty


increment_i:
        loadBoxChecked(boxRule4Index)
        jsr writeBank
        clc
        adc #1
wrapnread_i:
        and #$0F
        saveBoxChecked(boxRule4Index)
        jmp read_i

decrement_i:
        loadBoxChecked(boxRule4Index)
        jsr writeBank
        sec
        sbc #1
        jmp wrapnread_i
       
render_index:
        // jsr construct             
        loadBoxField(boxRule4Index,box_x)
        tay
        iny
        loadBoxField(boxRule4Index,box_y)
        tax
        inx
        clc
        jsr plot
        lda box_colour
        sta chrout_colour                 
        loadBoxChecked(boxRule4Index)
        jsr _hexDigit
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