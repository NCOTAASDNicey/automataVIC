.const FILENO=15
.const DEVICE=9
.const CMD=15

readFileName: str("RULE,S")
writeFileName: str("RULE,S,W")
renameBackupCommand: str("R:RULEOLD=RULEBACKUP")
renameRuleCommand: str("R:RULEBACKUP=RULE")
deleteFileName: str("S:RULEOLD")
filenameEND:

saveRule:
        lda #$C0
        jsr setmsg

        ldx #17
        ldy #0
        clc
        jsr plot        

        jsr renameBackupRule    // RULEBACKUP => RULEOLD
        jsr renameRuleRule      // RULE => RULEBACKUP
        jsr deleteRule          // RULEOLD => x
        jsr saveNewRule         // => RULE
        rts


renameBackupRule:
        lda #[renameRuleCommand-renameBackupCommand]-1
        ldx #<renameBackupCommand
        ldy #>renameBackupCommand
        jmp backup

renameRuleRule:
        lda #[deleteFileName-renameRuleCommand]-1
        ldx #<renameRuleCommand
        ldy #>renameRuleCommand
backup:
        jsr setnam

        lda #FILENO
        ldx #DEVICE
        ldy #CMD
        jsr setlfs
        jsr open
        jsr show_drive_status

        jsr clrchn
        lda #FILENO
        jsr close
        rts

rnlength:
        .byte 0
rnsource:
        .word 0

deleteRule:       
        lda #[filenameEND-deleteFileName]-1
        ldx #<deleteFileName
        ldy #>deleteFileName
        jsr setnam

        lda #FILENO
        ldx #DEVICE
        ldy #CMD
        jsr setlfs
       
        jsr open
        jsr show_drive_status

        jsr clrchn
        lda #FILENO
        jsr close
        rts        

saveNewRule:
        lda #FILENO
        ldx #DEVICE
        ldy #1
        jsr setlfs

        lda #[renameBackupCommand-writeFileName]-1
        ldx #<writeFileName
        ldy #>writeFileName
        jsr setnam

        lda #<rule4bank
        sta _chptr
        lda #>rule4bank
        sta _chptr+1
        ldx #<rule4bankend
        ldy #>rule4bankend
        lda #_chptr
        jsr save
        jsr show_drive_status
        rts

loadRule:
        lda #FILENO
        ldx #DEVICE
        ldy #0
        jsr setlfs

        lda #[writeFileName-readFileName]-1
        ldx #<readFileName
        ldy #>readFileName
        jsr setnam       

        lda #0      //Load
        ldx #<rule4bank
        ldy #>rule4bank
        jsr load
        jsr show_drive_status
        rts

show_drive_status: {
        lda #$00
        sta $90 // clear status flags
        lda #DEVICE // device number
        jsr listen
        lda #$6f // secondary address
        jsr second
        jsr unlsn
        lda $90
        bne sds_devnp // device not present
        lda #DEVICE
        jsr talk
        lda #$6f // secondary address
        jsr tksa
sds_loop:
        lda $90 // get status flags
        bne sds_eof
        jsr acptr
        jsr chrout
        jmp sds_loop
sds_eof:
        jsr untlk
        rts
sds_devnp:
        // handle device not present error handling
        rts
}