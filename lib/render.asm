#importonce

cellsrc:
.word cellbuffer1
celldst:
.word cellbuffer2

rule4index:
.byte 0

automata:
        jsr setFullscreenSize20x22
        jsr enter_fullscreen
        jsr initialise_ptrs_automata
        jsr initialise_cells_automata
        jmp empty
        
continue:
        lda fullscreen
        beq !+
        jsr initialise_ptrs_automata4
        jsr _render_automata_row
!:      jmp empty
         
        
initialise_ptrs_automata:
        // initate pointers
        lda #<bitmap
        sta row_start
        lda #>bitmap
        sta row_start+1
        
        lda fullscreen_dhrows
        asl
        asl
        asl
        asl
        sta row_counter
        
        lda  cellsrc
        sta _tempptr
        lda  cellsrc+1
        sta _tempptr+1
        rts

initialise_cells_automata:        
        // clear and initailise src buffer
        loadBoxChecked(boxRandom)
        bne _random_init              

_one_cell_init:      
        ldy cells_width_1bit        
        lda #0
!:      sta (_tempptr),Y
        dey
        bne !-
        lda cells_width_1bit
        clc
        ror
        tay
        lda #01
        sta (_tempptr),Y
        jmp  _render_automata_row
       
_random_init:
       ldy cells_width_1bit                
!:      lda 0,Y
       and #01
       sta (_tempptr),Y
       dey
       bne !-
                              
_render_automata_row:
        clc
        lda  cellsrc
        adc #1
        sta _tempptr
        lda  cellsrc+1
        adc #0
        sta _tempptr+1

        lda row_start
        sta _chptr
        lda row_start+1
        sta _chptr+1

        lda #20
        sta col_counter      
        
        // render new row
        
_render_automata_col:                
        //collect 8 pixels from buffer
        ldx #8
        ldy #0
!:       clc
        lda pixel_acc
        asl
        sta pixel_acc
        lda (_tempptr),Y
        and #01
        ora pixel_acc
        sta pixel_acc
        iny       
        dex
        bne !-
        pha
        clc
        lda #8
        adc _tempptr
        sta _tempptr
        lda #0
        adc _tempptr+1
        sta _tempptr+1 
        pla       
                
        //write 8 pixels to screen
        ldy #0
        sta (_chptr),Y
        
        //advance screen pointer to next 8 pixels
        clc
        lda _chptr
        adc #$10
        sta _chptr
        lda _chptr+1
        adc #0
        sta _chptr+1
                
        //repeat till end of buffer
        dec col_counter
        bne _render_automata_col
        
        //repeat till end of screen
        //advance row start
        dec row_counter
        clc
        lda #$01
        adc row_start
        sta row_start
        lda #$00
        adc row_start+1    
        sta row_start+1        
        
        lda row_counter
        and #$0F
        cmp #0
        bne !+ 
        clc
        lda #$30
        adc row_start
        sta row_start
        lda #$01
        adc row_start+1    
        sta row_start+1  
       
        // calculate new row into dst using src
!:      lda cellsrc
        sta _chptr
        lda cellsrc+1
        sta _chptr+1
        
        lda celldst
        sta _tempptr
        lda celldst+1
        sta _tempptr+1
               
        //exchange last first and cells
        ldy #160
        lda (_chptr),Y
        ldy #0
        sta (_chptr),Y
        ldy #1     
        lda (_chptr),Y
        ldy #161        
        sta (_chptr),Y                         
                             
        ldy #1
        
!:      ldx #0
        stx _styleptr               
        dey
        txa
        cmp (_chptr),Y
        beq !+
        lda _styleptr       
        ora #1
        sta _styleptr       
        
!:      iny
        txa
        cmp (_chptr),Y
        beq !+ 
        lda _styleptr       
        ora #2
        sta _styleptr
                              
!:      iny
        txa
        cmp (_chptr),Y
        beq !+
        lda _styleptr       
        ora #4
        sta _styleptr        
                
!:      tya
        pha
        
        ldy _styleptr                  
        ldx rule,Y 
                
        pla
        tay
        
        txa
        dey     
        sta (_tempptr),Y
        iny       
         
        cpy #161
        bne !----                     

        //swap pointers
        lda _chptr
        sta celldst
        lda _chptr+1
        sta celldst+1
        
        lda _tempptr
        sta cellsrc
        lda _tempptr+1
        sta cellsrc+1       
       
        lda row_counter
        cmp #0
        beq !+
        jmp _render_automata_row                
!:      jmp empty



automata4:
        jsr setFullscreenSize20x22
        jsr enter_fullscreen_multi
        jsr initialise_ptrs_automata4
        jsr initialise_cells_automata4
        jmp empty
        
continue4:
        lda fullscreen
        beq !+
        jsr initialise_ptrs_automata4
        jsr _render_automata_row4
!:      jmp empty           
        
initialise_ptrs_automata4:
        // initate pointers
        lda #<bitmap
        sta row_start
        lda #>bitmap
        sta row_start+1
        
        lda fullscreen_dhrows
        asl
        asl
        asl
        asl
        sta row_counter        
        
        lda  cellsrc
        sta _tempptr
        lda  cellsrc+1
        sta _tempptr+1
        rts

initialise_cells_automata4:     
        // clear and initailise src buffer
        loadBoxChecked(boxRandom)
        bne _random_init4              

_one_cell_init4:      
        ldy cells_width_2bit        
        lda #0
!:      sta (_tempptr),Y
        dey
        bne !-
        lda cells_width_2bit
        clc
        ror
        tay
        lda #03
        sta (_tempptr),Y
        jmp  _randomize_rule
       
_random_init4:
        lda $A2
        clc
        ldy cells_width_2bit                
!:      adc 0,Y
        pha
        and #03
        sta (_tempptr),Y
        pla
        dey
        bne !-

_randomize_rule:
        loadBoxChecked(boxRandomR)
        beq _render_automata_row4

        jsr basic_random
        ldy FPA1_mantissa+2
        ldx #03
 !:     tya
        and #$03
        sta rule4,X
        tya
        clc
        ror
        ror
        tay
        dex
        bne !-
        jsr basic_random
        ldy FPA1_mantissa+2
        ldx #03
 !:     tya
        and #$03
        sta rule4+4,X
        tya
        clc
        ror
        ror
        tay
        dex
        bne !-
        jsr basic_random
        ldy FPA1_mantissa+2
        ldx #01
 !:     tya
        and #$03
        sta rule4+8,X
        tya
        clc
        ror
        ror
        tay
        dex
        bne !-        
                              
_render_automata_row4:
        clc
        lda cellsrc
        adc #1          //Start 1 cell in to allow for wrapping
        sta _tempptr
        lda  cellsrc+1
        adc #0
        sta _tempptr+1

        lda row_start
        sta _chptr
        lda row_start+1
        sta _chptr+1

        lda fullscreen_cols
        sta col_counter      
        
        // render new row        
_render_automata_col4:                
        //collect 4 pixels from buffer
        ldx #4
        ldy #0
        sty pixel_acc        
!:      clc
        lda pixel_acc
        asl
        asl
        sta pixel_acc
        lda (_tempptr),Y
        and #03
        ora pixel_acc
        sta pixel_acc
        iny       
        dex
        bne !-
        pha
        clc
        lda #4
        adc _tempptr
        sta _tempptr
        lda #0
        adc _tempptr+1
        sta _tempptr+1 
        pla      
                
        //write 4 multicolour pixels to screen
        ldy #0
        sta (_chptr),Y
        
        //advance screen pointer to next 4 pixels
        clc
        lda _chptr
        adc #$10        //bytes in a double height programmable character
        sta _chptr
        lda _chptr+1
        adc #0
        sta _chptr+1
                
        //repeat till end of buffer
        dec col_counter
        bne _render_automata_col4
        
        //repeat till end of screen
        //advance row start
        dec row_counter
        clc
        lda #$01
        adc row_start
        sta row_start
        lda #$00
        adc row_start+1    
        sta row_start+1        
        
        lda row_counter
        and #$0F
        cmp #0
        bne !+ 
        clc
        lda #$30
        adc row_start
        sta row_start
        lda #$01
        adc row_start+1    
        sta row_start+1  
       
        // calculate new row into dst using src
!:      lda cellsrc
        sta _chptr
        lda cellsrc+1
        sta _chptr+1
        
        lda celldst
        sta _tempptr
        lda celldst+1
        sta _tempptr+1
               
        //exchange last first and cells
        ldy #80
        lda (_chptr),Y
        ldy #0
        sta (_chptr),Y

        ldy #1     
        lda (_chptr),Y
        ldy #81        
        sta (_chptr),Y                         
                             
        ldy #0
        
!:      dey
        lda (_chptr),Y    //Previous cell          
        iny
        adc (_chptr),Y    //Current cell                        
        iny
        adc (_chptr),Y    //Next cell
        dey               //Set cell index back to current
        tax               //Summed cells to X                                          
        tya
        pha               //Push current index
            
        txa  
        tay        
        ldx rule4,Y        //Look up summed value via rule into X
                
        pla               //Recover index from stack
        tay
        
        txa
        sta (_tempptr),Y  //Save new cell value at current index on output ptr
        iny               //Advance current index
         
        cpy #81          //Repeat until all cells processed
        bne !-                    

        //swap pointers
        lda _chptr
        sta celldst
        lda _chptr+1
        sta celldst+1
        
        lda _tempptr
        sta cellsrc
        lda _tempptr+1
        sta cellsrc+1       
       
        lda row_counter
        cmp #0
        beq !+
        jmp _render_automata_row4
                
!:      jmp empty
