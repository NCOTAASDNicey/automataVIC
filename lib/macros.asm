#importonce

.macro  screen_col(col,border) {
        lda #[col*16]|border|8
        sta VIC_screen
}

.macro cls() {
        lda #147
        jsr chrout
}

.macro enterProc(){
        sta SAREG
        pha
        tya
        pha
        txa
        pha
        lda SAREG
}

.macro leaveProc(){
        pla
        tax
        pla
        tay
        pla
}

.macro enterFn(){
        sta SAREG
        tya
        pha
        txa
        pha
        lda SAREG
}

.macro leaveFn(){
        sta SAREG
        pla
        tax
        pla
        tay
        lda SAREG
}
