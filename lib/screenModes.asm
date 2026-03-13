#import "lib/kernal.asm"
#import "macros.asm"
#import "zero.asm"

fullscreen_cols:
.byte 0
fullscreen_rows:
.byte 0
fullscreen_dhrows:
.byte 0
fullscreen_total:
.byte 0
cells_width_1bit:
.byte 0
cells_width_2bit:
.byte 0

.macro setFullscreenSize(x,y) {
        lda #x
        sta fullscreen_cols
        lda #x*8
        sta cells_width_1bit
        lda #x
        sta cells_width_2bit                
        lda #y
        sta fullscreen_rows
        lda #y>>1
        sta fullscreen_dhrows        
        lda #x*y
        sta fullscreen_total
        rts         
}

setFullscreenSize20x22:
        setFullscreenSize(20,24)      

enter_fullscreen:
        lda #0
        sta multicolour
        jmp _enter_fullscreen

enter_fullscreen_multi:
        lda #8
        sta multicolour

_enter_fullscreen:        
        lda fullscreen
        beq !+
        jmp !++++++
!:      cls()
        ldy #[box_colour-box_origin]
        clc      
        lda [boxColR+jmp_header_size],Y        
        asl
        asl
        asl
        asl
        ora #8
        ora [boxColB+jmp_header_size],Y      
        sta VIC_screen
        
        lda [boxColA+jmp_header_size],Y        
        asl
        asl
        asl
        asl     
        sta VIC_volume               
        
        lda VIC_rows
        and #129
        ora #1+[2*11]
        sta VIC_rows
        lda VIC_char_mem
        and #240
        ora fullscreen_dhrows
        sta VIC_char_mem
        
        lda VIC_columns
        and #128
        ora fullscreen_cols
        sta VIC_columns
        
        lda VIC_h_center
        and #254
        ora #6
        sta VIC_h_center

        lda #46
        sta VIC_v_center                         
        
        //Clear character map
        lda #<bitmap
        sta _chptr
        lda #>bitmap
        sta _chptr+1
!:      lda #$0
        ldy #0
!:      sta (_chptr),Y
        dey
        bne !-
        inc _chptr+1
        lda _chptr+1
        cmp #$20
        bne !--
        
        //character grid
        lda #16
        ldy #0
        clc
!:      sta screen_mem_hi,Y
        adc #1
        iny
        cpy #242
        bne !-

        //Character colour
        ldy #[box_colour-box_origin]
        lda [boxColP+jmp_header_size],Y
        
        ora multicolour // set multicolour mode
              
        ldy #0
!:      sta colour_mem_hi,Y
        iny
        cpy #fullscreen_total
        bne !-
!:      lda #1
        sta fullscreen        
        rts

leave_fullscreen:
        lda fullscreen
        beq !+
        cls()
        screen_col(black, black)
       
        lda VIC_rows
        and #128
        ora #[2*23]
        sta VIC_rows
        
        lda VIC_columns
        and #128
        ora #22
        sta VIC_columns
        
        lda VIC_h_center
        and #128
        ora #12      
        sta VIC_h_center 
        
        lda #38
        sta VIC_v_center                
        
        lda VIC_char_mem
        and #240
        sta VIC_char_mem
 !:     lda #0
        sta fullscreen
        rts