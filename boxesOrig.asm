.include "kernal.inc"
.include "macros.inc"
.outfile "Drive8/boxes.prg"


.word $1201
.org  $1201

        .word next, 10       ; Next line and current line number
        .byte $9e," 8193",0  ; SYS 8193
next:   .word 0              ; End of program

.advance $1fff

.word   $2001
.org	$2001

.alias JOY_SENSE $1

.text
    `cls
    `screen_col black, black    

    LDA #2
    STA selected
    `callMethod method_render, _boxlist

_main_loop:   
    JSR waitkey
    STY	keypress
    `callMethod method_key, _boxList
    LDA return
    PHA    
    `callMethod method_render, _boxlist
    PLA
    CMP #0
    BNE done
    JMP _main_loop    
       
done:
    JSR leave_fullscreen
    LDA #<boxFinal
    LDX #>boxFinal
    LDY #0
    JSR invokevirtual
   	LDA #0
	RTS
	
waitJiffy:
	PHA
	TYA
	PHA
	TXA
	PHA
	
	JSR rdtim
	ADC #2
	STA _scratch
*	JSR rdtim
	CMP _scratch
	BNE -
		
	PLA
	TAX
	PLA
	TAY
	PLA
	RTS

; return KEY equiv in Y	
joystick:
	PHA
	TXA
	PHA
	LDA #$0
	STA VIA1_ddr
	LDA VIA1_output
	EOR #[JOY_SW0|JOY_SW1|JOY_SW2|JOY_SW4]
	LSR 
	LSR
	AND #$0F
	PHA
	LDA VIA2_ddr
	PHA
	LDA	#127
	STA VIA2_ddr
	LDA VIA2_output
	EOR #JOY_SW3
	LSR
	LSR
	LSR
	AND #$10
	STA _scratch
	PLA
	STA VIA2_ddr
	PLA
	ORA _scratch	

	LSR
	ROL JOY_U
	LSR
	ROL JOY_D
	LSR
	ROL JOY_L
	LSR
	ROL JOY_F
	LSR
	ROL JOY_R
	
	JSR waitJiffy		

	LDA #$0
	LDX #JOY_SENSE
	CPX JOY_L
	BCS +
	STA	JOY_L
	LDA #KEY_CSR_LEFT
	JMP joystick_return
		
*	CPX JOY_R
	BCS +
	STA	JOY_R
	LDA #KEY_CSR_RIGHT
	JMP joystick_return
	
*	CPX JOY_U
	BCS +
	STA	JOY_U
	LDA #KEY_CSR_UP
	JMP joystick_return
	
*	CPX JOY_D
	BCS +
	STA	JOY_U
	LDA #KEY_CSR_DOWN
	JMP joystick_return
	
*	CPX JOY_F
	BCS joystick_return
	STA	JOY_F
	LDA #KEY_RETURN
joystick_return:
	TAY
	PLA
	TAX
	PLA
	RTS			



waitkey:
*       JSR joystick
        TYA	
        CMP #$0
        BNE +
        LDA $C5
        BEQ -
        JSR getin
        CMP #$0
	BEQ -
*	TAY
        RTS

printstr:
        TAY
        LDA _chptr
        PHA
        LDA _chptr+1
        PHA
        TYA
        STA _chptr
        STX _chptr+1
        LDY #$00
_loop:  LDA (_chptr),y
        BEQ +
        JSR chrout
        INY
        BNE _loop
*       PLA
        STA _chptr+1
        PLA
        STA _chptr
        RTS

.data zp
.org 73
.space this 2
.org zero_page_rs_232
.space _chptr 2
.space _styleptr 2
.space _tempptr 2

.text

.macro getInstanceVariable
    ; _1 variable
    ; _2 Instance
    ; Box instance
        LDA #[_1-box_origin]
        STA var
        LDA #<_2
        LDX #>_2
        LDY #method_get
        JSR invokevirtual           
.macend

get:
        JSR construct
        LDY var
        LDA (this),Y
        RTS      

select:
        JSR construct
        `loadObjectByte box_select
        ORA #1
        STA (this),Y
        RTS
        
deselect:
        JSR construct
        `loadObjectByte box_select
        AND #255-1
        STA (this),Y
        RTS
                       
toggle:
        JSR construct
        `loadObjectByte box_check                        
        EOR #1
        STA (this),Y
        LDA #0                     
        RTS
        
render_toggle:
        JSR construct
        CLC
        LDA box_origin
        ADC #X_CHARS+1
        STA _chptr
        LDA box_origin+1
        ADC #0 
        STA _chptr+1                

        `loadObjectByte box_check        
        CMP #0
        BEQ +
        LDA #87        
        JMP ++
*       LDA #81
*       LDY #0
        STA (_chptr),Y
        LDA #0              
        RTS                     

render:
        JSR construct
        LDA #1
        CMP fullscreen
        BNE +        
        RTS
*       LDA box_height
        STA box_height_working
        
        `loadObjectByte box_select                
        AND #1
        BEQ _notselected
        LDA #<style2
        STA _styleptr
        LDA #>style2
        STA _styleptr+1        
        JMP _style_done         
        
_notselected:
        `loadObjectPointer box_style, _styleptr        
               
_style_done:        
        `loadObjectPointer box_origin, _chptr             
                                               
        ; Top line
        LDY box_width
        DEY
        STY box_width_working
        LDY #top_right
        LDA (_styleptr),Y
        LDY box_width_working                     
        STA (_chptr),Y
        
        STY box_width_working
        LDY #top
        LDA (_styleptr),Y
        LDY box_width_working                     
        
*       DEY        
        STA (_chptr),y
        BNE -
        
        STY box_width_working
        LDY #top_left
        LDA (_styleptr),Y
        LDY box_width_working                               
        STA (_chptr),y

        DEC box_height_working

        ; middle lines
_mid:   CLC
        LDA #X_CHARS
        ADC _chptr
        STA _chptr
        LDA #0
        ADC _chptr+1
        STA _chptr+1
        LDY box_width
           
        STY box_width_working
        LDY #right
        LDA (_styleptr),Y
        LDY box_width_working                
        DEY
        STA (_chptr),y
        STY box_width_working
        LDY #fill
        LDA (_styleptr),Y
        LDY box_width_working         
*       DEY        
        STA (_chptr),y
        BNE -
        STY box_width_working
        LDY #left
        LDA (_styleptr),Y
        LDY box_width_working                     
        STA (_chptr),y
            
        DEC box_height_working
        BNE _mid        
                
        ; bottom line
        LDY box_width
        STY box_width_working
        LDY #bottom_right
        LDA (_styleptr),Y
        LDY box_width_working              
        DEY
        STA (_chptr),y
        STY box_width_working
        LDY #bottom
        LDA (_styleptr),Y
        LDY box_width_working
*       DEY        
        STA (_chptr),y
        BNE -
        STY box_width_working
        LDY #bottom_left
        LDA (_styleptr),Y
        LDY box_width_working                      
        STA (_chptr),y
 
;Fill in colour

        LDA box_col_origin  
        STA _chptr
        LDA box_col_origin+1 
        STA _chptr+1
        
        LDA box_height
        STA box_height_working
        LDA box_width
        STA box_width_working
        LDA #0
        CMP box_edited
        BEQ +
        LDA #red
        JMP +++
*       LDA #$1       
       	AND box_select
        BEQ +        
        LDA #cyan
        JMP ++        
*       LDA box_frame_colour
*       STA box_colour_working
        JSR _colframe

        CLC
        LDA box_col_origin
        ADC #X_CHARS+1  
        STA _chptr
        LDA box_col_origin+1 
        ADC #0
        STA _chptr+1
        CLC
        LDA box_height
        SBC #1
        STA box_height_working
        CLC
        LDA box_width
        SBC #1
        STA box_width_working
        LDA box_colour
        STA box_colour_working
        JSR _colbox
        
;print legend
        LDA box_legend
        CMP #0
        BEQ ++
        CLC
        LDX box_y
        LDY box_x
        JSR plot
        
        LDA box_colour
        STA chrout_colour
        
        LDA #1
        CMP box_select
        BEQ +
        LDA #0
*       STA 199        
        
        LDA box_legend
        LDX box_legend+1       
        JSR printstr               
*       LDA #0                                                  
        RTS        
        
_colframe:                
        LDA box_colour_working
        LDY box_width_working
*       DEY
        STA (_chptr),Y
        BNE -
        DEC box_height_working
        
*       CLC
        LDA #X_CHARS
        ADC _chptr
        STA _chptr
        LDA #0
        ADC _chptr+1
        STA _chptr+1
        LDY box_width_working
        DEY
        LDA box_colour_working        
        STA (_chptr),Y
        LDY #0        
        STA (_chptr),Y     
        DEC box_height_working
        BNE -
        
        LDY box_width_working
*       DEY
        STA (_chptr),Y
        BNE -
        LDA #0                                   
        RTS
        
_colbox:                
*       LDA box_colour_working
        LDY box_width_working
*       DEY
        STA (_chptr),Y
        BNE -
        CLC
        LDA #X_CHARS
        ADC _chptr
        STA _chptr
        LDA #0
        ADC _chptr+1
        STA _chptr+1        
        DEC box_height_working
        BNE --
        LDY #method_detail
        JSR reinvokevirtual        
        LDA #0                    
        RTS 


enter_fullscreen:
        LDA #0
        STA multicolour
        JMP _enter_fullscreen

enter_fullscreen_multi:
        LDA #8
        STA multicolour
        JMP _enter_fullscreen

_enter_fullscreen:
        LDA #1
        EOR fullscreen
        STA fullscreen
        CMP #0
        BNE +
        JMP ++++++
*       LDA #144
        JSR chrout
        `cls
        LDY #[box_colour-box_origin]
        CLC      
        LDA [boxColB+jmp_header_size],Y        
        ASL
        ASL
        ASL
        ASL
        ORA #8
        ORA [boxColR+jmp_header_size],Y      
        STA VIC_screen
        
        LDA [boxColA+jmp_header_size],Y        
        ASL
        ASL
        ASL
        ASL     
        STA VIC_volume               
        
        LDA VIC_rows
        AND #129
        ORA #1+[2*11]
        STA VIC_rows
        LDA VIC_char_mem
        AND #240
        ORA #12
        STA VIC_char_mem
        
        LDA VIC_columns
        AND #128
        ORA #20
        STA VIC_columns
        
        LDA VIC_h_center
        AND #254
        ORA #6
        STA VIC_h_center

        LDA #46
        STA VIC_v_center                         
        
        ;Clear character map
        LDA #<bitmap
        STA _chptr
        LDA #>bitmap
        STA _chptr+1
*       LDA #$0
        LDY #0
*       STA (_chptr),Y
        DEY
        BNE -
        INC _chptr+1
        LDA _chptr+1
        CMP #$20
        BNE --
        
        ;character grid
chargrid:
        LDA #16
        LDY #0
        CLC
*       STA screen_mem_hi,Y
        ADC #1
        INY
        CPY #242
        BNE -

        ;Character colour
        LDY #[box_colour-box_origin]
        LDA [boxColP+jmp_header_size],Y
        
        ORA multicolour ; set multicolour mode
              
        LDY #0
*       STA colour_mem_hi,Y
        INY
        CPY #242
        BNE -
        
        RTS

leave_fullscreen:
        LDA #0
        CMP fullscreen
        BEQ +
        STA fullscreen
*      `cls
       `screen_col black, black
       
        LDA VIC_rows
        AND #128
        ORA #[2*23]
        STA VIC_rows
        
        LDA VIC_columns
        AND #128
        ORA #22
        STA VIC_columns
        
        LDA VIC_h_center
        AND #128
        ORA #12      
        STA VIC_h_center 
        
        LDA #38
        STA VIC_v_center                
        
        LDA VIC_char_mem
        AND #240
        STA VIC_char_mem
        LDA #0           
        RTS       
 
automata:
        JSR enter_fullscreen
        LDA #0
        CMP fullscreen
        BEQ +
        JSR initialise_ptrs_automata
        JSR initialise_cells_automata
*       LDA #0
        RTS
        
continue:
        LDA #0
        CMP fullscreen
        BEQ +
        JSR initialise_ptrs_automata4
        JSR _render_automata_row
*       LDA #0
        RTS         
        
initialise_ptrs_automata:
        ; initate pointers
        LDA #<bitmap
        STA row_start
        LDA #>bitmap
        STA row_start+1
        
        LDA #[11*16]
        STA row_counter
        
        LDA  cellsrc
        STA _tempptr
        LDA  cellsrc+1
        STA _tempptr+1
        RTS

initialise_cells_automata:        
        ; clear and initailise src buffer
        LDY #[box_check-box_origin]
        LDA [boxRandom+jmp_header_size],Y
        CMP #0
        BEQ _random_init              

_one_cell_init:      
        LDY #[8*20]        
        LDA #0
*       STA (_tempptr),Y
        DEY
        BNE -
        LDA #01
        STA cellbuffer1+80
        JMP  _render_automata_row
       
_random_init:
       LDY #[8*20]                
*      LDA 0,Y
       AND #01
       STA (_tempptr),Y
       DEY
       BNE -
                              
_render_automata_row:
        CLC
        LDA  cellsrc
        ADC #1
        STA _tempptr
        LDA  cellsrc+1
        ADC #0
        STA _tempptr+1

        LDA row_start
        STA _chptr
        LDA row_start+1
        STA _chptr+1

        LDA #20
        STA col_counter      
        
        ; render new row
        
_render_automata_col:                
        ;collect 8 pixels from buffer
        LDX #8
        LDY #0
*       CLC
        LDA pixel_acc
        ASL
        STA pixel_acc
        LDA (_tempptr),Y
        AND #01
        ORA pixel_acc
        STA pixel_acc
        INY       
        DEX
        BNE -
        PHA
        CLC
        LDA #8
        ADC _tempptr
        STA _tempptr
        LDA #0
        ADC _tempptr+1
        STA _tempptr+1 
        PLA     
        
                
        ;write 8 pixels to screen
        LDY #0
        STA (_chptr),Y
        
        ;advance screen pointer to next 8 pixels
        CLC
        LDA _chptr
        ADC #$10
        STA _chptr
        LDA _chptr+1
        ADC #0
        STA _chptr+1
                
        ;repeat till end of buffer
        DEC col_counter
        BNE _render_automata_col
        
        ;repeat till end of screen
        ;advance row start
        DEC row_counter
        CLC
        LDA #$01
        ADC row_start
        STA row_start
        LDA #$00
        ADC row_start+1    
        STA row_start+1        
        
        LDA row_counter
        AND #$0F
        CMP #0
        BNE + 
        CLC
        LDA #$30
        ADC row_start
        STA row_start
        LDA #$01
        ADC row_start+1    
        STA row_start+1  
       
        ; calculate new row into dst using src
*       LDA cellsrc
        STA _chptr
        LDA cellsrc+1
        STA _chptr+1
        
        LDA celldst
        STA _tempptr
        LDA celldst+1
        STA _tempptr+1
               
        ;exchange last first and cells
        LDY #160
        LDA (_chptr),Y
        LDY #0
        STA (_chptr),Y
        LDY #1     
        LDA (_chptr),Y
        LDY #161        
        STA (_chptr),Y                         
                             
        LDY #1
        
*       LDX #0
        STX _styleptr               
        DEY
        TXA
        CMP (_chptr),Y
        BEQ +
        LDA _styleptr       
        ORA #1
        STA _styleptr       
        
*       INY
        TXA
        CMP (_chptr),Y
        BEQ + 
        LDA _styleptr       
        ORA #2
        STA _styleptr
                              
*       INY
        TXA
        CMP (_chptr),Y
        BEQ +
        LDA _styleptr       
        ORA #4
        STA _styleptr        
                
*       TYA
        PHA
        
        LDY _styleptr                  
        LDX rule,Y 
                
        PLA
        TAY
        
        TXA
        DEY     
        STA (_tempptr),Y
        INY       
         
        CPY #161
        BNE ----                     

        ;swap pointers
        LDA _chptr
        STA celldst
        LDA _chptr+1
        STA celldst+1
        
        LDA _tempptr
        STA cellsrc
        LDA _tempptr+1
        STA cellsrc+1       
       
        LDA row_counter
        CMP #0
        BEQ +
        JMP _render_automata_row
                
*       LDA #0 ;Dont signal exit 
        RTS


automata4:
        JSR enter_fullscreen_multi
        LDA #0
        CMP fullscreen
        BEQ +
        JSR initialise_ptrs_automata4
        JSR initialise_cells_automata4
*       LDA #0
        RTS
        
continue4:
        LDA #0
        CMP fullscreen
        BEQ +
        JSR initialise_ptrs_automata4
        JSR _render_automata_row4
*       LDA #0
        RTS            
        
initialise_ptrs_automata4:
        ; initate pointers
        LDA #<bitmap
        STA row_start
        LDA #>bitmap
        STA row_start+1
        
        LDA #[11*16]
        STA row_counter        
        
        LDA  cellsrc
        STA _tempptr
        LDA  cellsrc+1
        STA _tempptr+1
        RTS

initialise_cells_automata4:     
        ; clear and initailise src buffer
        LDY #[box_check-box_origin]
        LDA [boxRandom+jmp_header_size],Y
        CMP #0
        BEQ _random_init4              

_one_cell_init4:      
        LDY #[4*20]+2        
        LDA #0
*       STA (_tempptr),Y
        DEY
        BNE -
        LDA #03
        STA cellbuffer1+40
        JMP  _render_automata_row4
       
_random_init4:
       LDA $A2
       CLC
       LDY #[4*20]+2                
*      ADC 0,Y
       PHA
       AND #03
       STA (_tempptr),Y
       PLA
       DEY
       BNE -
                              
_render_automata_row4:
        CLC
        LDA  cellsrc
        ADC #1          ;Start 1 cell in to allow for wrapping
        STA _tempptr
        LDA  cellsrc+1
        ADC #0
        STA _tempptr+1

        LDA row_start
        STA _chptr
        LDA row_start+1
        STA _chptr+1

        LDA #20
        STA col_counter      
        
        ; render new row
        
_render_automata_col4:                
        ;collect 4 pixels from buffer
        LDX #4
        LDY #0
        STY pixel_acc        
*       CLC
        LDA pixel_acc
        ASL
        ASL
        STA pixel_acc
        LDA (_tempptr),Y
        AND #03
        ORA pixel_acc
        STA pixel_acc
        INY       
        DEX
        BNE -
        PHA
        CLC
        LDA #4
        ADC _tempptr
        STA _tempptr
        LDA #0
        ADC _tempptr+1
        STA _tempptr+1 
        PLA     
        
                
        ;write 4 multicolour pixels to screen
        LDY #0
        STA (_chptr),Y
        
        ;advance screen pointer to next 4 pixels
        CLC
        LDA _chptr
        ADC #$10        ;bytes in a double height programmable character
        STA _chptr
        LDA _chptr+1
        ADC #0
        STA _chptr+1
                
        ;repeat till end of buffer
        DEC col_counter
        BNE _render_automata_col4
        
        ;repeat till end of screen
        ;advance row start
        DEC row_counter
        CLC
        LDA #$01
        ADC row_start
        STA row_start
        LDA #$00
        ADC row_start+1    
        STA row_start+1        
        
        LDA row_counter
        AND #$0F
        CMP #0
        BNE + 
        CLC
        LDA #$30
        ADC row_start
        STA row_start
        LDA #$01
        ADC row_start+1    
        STA row_start+1  
       
        ; calculate new row into dst using src
*       LDA cellsrc
        STA _chptr
        LDA cellsrc+1
        STA _chptr+1
        
        LDA celldst
        STA _tempptr
        LDA celldst+1
        STA _tempptr+1
               
        ;exchange last first and cells
        LDY #80
        LDA (_chptr),Y
        LDY #0
        STA (_chptr),Y

        LDY #1     
        LDA (_chptr),Y
        LDY #81        
        STA (_chptr),Y                         
                             
        LDY #0
        
*       DEY
        LDA (_chptr),Y    ;Previous cell          
        INY
        ADC (_chptr),Y    ;Current cell                        
        INY
        ADC (_chptr),Y    ;Next cell
        DEY               ;Set cell index back to current
        TAX               ;Summed cells to X                                          
        TYA
        PHA               ;Push current index
            
        TXA  
        TAY        
        LDX rule4,Y        ;Look up summed value via rule into X
                
        PLA               ;Recover index from stack
        TAY
        
        TXA
        STA (_tempptr),Y  ;Save new cell value at current index on output ptr
        INY               ;Advance current index
         
        CPY #81          ;Repeat until all cells processed
        BNE -                    

        ;swap pointers
        LDA _chptr
        STA celldst
        LDA _chptr+1
        STA celldst+1
        
        LDA _tempptr
        STA cellsrc
        LDA _tempptr+1
        STA cellsrc+1       
       
        LDA row_counter
        CMP #0
        BEQ +
        JMP _render_automata_row4
                
*       LDA #0 ;Dont signal exit 
        RTS


update_ruleb:
        SEC
        SBC #49
        TAY        
        LDA rule,Y
        EOR #1
        STA rule,Y
        CMP #1
        BEQ +
        LDA #48
        JMP ++    
*       LDA #49
*       STA @rule,Y    
        LDA #0
        RTS
        
render_ruleb:
        LDY #0 
*       LDA rule,Y
        CMP #1
        BEQ +
        LDA #48
        JMP ++    
*       LDA #49
*       STA @rule,Y
        INY
        CPY #8
        BNE --- 

        JSR render
        RTS        
        
        
update_rule4:
        SEC
        SBC #49 ; Key=index, 0=9, 1=0, 2=1, 3=2 ...
        BPL +
        LDA  #9        
     *  TAY
        LDA #<rule4
        STA _chptr
        LDA #>rule4
        STA _chptr+1
                
        LDA #<@rule4
        STA _styleptr
        LDA #>@rule4
        STA _styleptr+1
        
        LDA (_chptr),Y
        CLC
        ADC #1
        AND #3
        STA (_chptr),Y
        ADC #48
        STA (_styleptr),Y
        JSR writeBank        
        LDA #0
        RTS
        
renderrule4:
        LDA #<rule4
        STA _chptr
        LDA #>rule4
        STA _chptr+1
                
        LDA #<@rule4
        STA _styleptr
        LDA #>@rule4
        STA _styleptr+1
        
        LDY #0
*       LDA (_chptr),Y
        CLC
        ADC #48
        STA (_styleptr),Y
        INY
        CPY #10
        BNE -
        JSR render
        RTS              
    

handlekey:
        JSR construct
        LDA #1
        CMP box_select
        BNE ++
              
        LDA #KEY_RETURN
        CMP keypress
        BNE +
        LDY #method_action
        JSR reinvokevirtual
        RTS
        
*       LDA #KEY_SPACE
        CMP keypress
        BNE +
        LDY #method_continue
        JSR reinvokevirtual
        RTS         
        
        
*       LDA #KEY_ESC
        CMP keypress
        BNE +
        LDY #method_escape
        JSR reinvokevirtual
        RTS                
                
*       LDA #0 ;Dont signal program end
        RTS

handlerulekeyb:
        JSR construct
        LDA #1
        CMP box_select
        BNE +
        LDA keypress      
        CMP #48
        BCC + 
        CMP #57
        BCS +        
        LDY #method_action
        JSR reinvokevirtual
*       LDA #0 ;Dont signal program end
        RTS
        
handlerulekey4:
        JSR construct
        LDA #1
        CMP box_select
        BNE +
        LDA keypress      
        CMP #48
        BCC + 
        CMP #58
        BCS +        
        LDY #method_action
        JSR reinvokevirtual
        JSR construct
        LDA #1
        `saveObjectByte box_edited
        LDA #0 ;Dont signal program end
        RTS
                
     *  CMP #83 ;S for Save 
        BNE ++

        LDA #0
        LDX $BA
        BNE +
        LDX #DEVICE
     *  LDY #0
        JSR setlfs

        LDA #[@rule-@filenameS]
        LDX #<@filenameS   
        LDY #>@filenameS
        JSR setnam

        LDA #<rule4bank
        STA _chptr
        LDA #>rule4bank
        STA _chptr+1        
        LDX #<rule4bankend
        LDY #>rule4bankend
        LDA #247        
        JSR save
        LDA #0
        `saveObjectByte box_edited        
        LDA #0 ;Dont signal program end
        RTS
                
	 *  CMP #76 ;L for Load 
        BNE ++

        LDA #0
        LDX	$BA
        BNE +
        LDX #DEVICE
     *  LDY #0
        JSR setlfs

        LDA #[@filenameS-@filenameL]
        LDX #<@filenameL  
        LDY #>@filenameL
        JSR setnam

        LDA #0      ;Load
        LDX #<rule4bank
        LDY #>rule4bank
        JSR load
        JMP +
        `getInstanceVariable box_check, boxRule4Index
        ; STA 4536

        JSR readBank
                
*       LDA #0 ;Dont signal program end
        RTS 
        
.alias DEVICE 8
.alias FILENO 1       
        
handlekeyc:
        JSR construct
        LDA #1
        CMP box_select
        BNE +
        LDY #[box_colour-box_origin]        
        LDA keypress      
        CMP #KEY_CSR_UP
        BEQ ++
        CMP #KEY_CSR_DOWN
        BEQ ++++
*       LDA #0 ;Dont signal program end
        RTS
*       LDA (this),Y
        CLC
        ADC #1
*       AND #7
        STA (this),Y
        LDA #1
        `saveObjectByte box_edited              
        JMP ---
*       LDA (this),Y
        SEC
        SBC #1
        JMP --

handlekeyi:        
        JSR construct
        LDA #1
        CMP box_select
        BNE ++
        LDY #[box_check-box_origin]        
        LDA keypress      
        CMP #KEY_CSR_UP
        BEQ +++
        CMP #KEY_CSR_DOWN
        BEQ +++++
        JMP ++
*       JSR readBank
*       LDA #0 ;Dont signal program end        
        RTS
*       LDA (this),Y
        CLC
        ADC #1
*       AND #$0F
        STA (this),Y
        STA rule4index        
        JMP ----
*       LDA (this),Y
        SEC
        SBC #1
        JMP --
        
writeBank:
        PHA
        TYA
        PHA
        TXA
        PHA
        
        LDA #<rule4bank
        STA _chptr
        LDA #>rule4bank
        STA _chptr+1
        LDA rule4index
        CLC
        ASL
        ASL
        ASL
        ASL
        ADC _chptr
        STA _chptr
        LDA #0
        ADC _chptr+1
        STA _chptr+1 

        LDA #<rule4
        STA _tempptr
        LDA #>rule4
        STA _tempptr+1        
          
        LDY #10
*       DEY
        LDA (_tempptr),Y
        STA (_chptr),Y
        CPY #0     
        BNE -    
        
        PLA
        TAX
        PLA
        TAY
        PLA
        RTS
        
        
readBank:
        PHA
        STA _scratch        
        TYA
        PHA
        TXA
        PHA

        LDA #<rule4bank
        STA _chptr
        LDA #>rule4bank
        STA _chptr+1
        LDA _scratch
        CLC
        ASL
        ASL
        ASL
        ASL
        ADC _chptr
        STA _chptr
        LDA #0
        ADC _chptr+1
        STA _chptr+1 


        LDA #<rule4
        STA _tempptr
        LDA #>rule4
        STA _tempptr+1        
          
        LDY #10
*       DEY
        LDA (_chptr),Y
        STA (_tempptr),Y
        CPY #0     
        BNE -
        
        PLA
        TAX
        PLA
        TAY
        PLA
        RTS               
        
render_index:
        JSR construct
        CLC
        LDA box_origin
        ADC #X_CHARS+1
        STA _chptr
        LDA box_origin+1
        ADC #0 
        STA _chptr+1                

        `loadObjectByte box_check
        TAX
        CPX #10
        BCC +   ;10 or more        
        SBC #9        
        JMP ++
*       ADC #48
*       LDY #0
        STA (_chptr),Y
        LDA #0              
        RTS               
                                            
flowKey:    
    LDA keypress  
    
    CMP #KEY_CSR_LEFT
    BNE _not_leftf
    DEC selected
    JMP _key_handledf
_not_leftf:
    CMP #KEY_CSR_RIGHT
    BNE +++
    INC selected
    
_key_handledf:
    `callMethod method_deselect, _boxlist
    
    ; skip any boxes with bit 1 or selected set
;    LDA #[box_select-box_origin]
;    STA var    
;    LDA #method_get
;    STA method
;    LDA selected
;	JSR _boxListAt
;	AND #$2
;	BEQ flowKey

    LDA #method_select
    STA method
    LDA selected    
    CMP #0
    BNE +
    LDA #boxes_list_size-1
    JMP ++
*   CMP #boxes_list_size
    BNE +
    LDA #1
*   STA selected                         
    JSR _boxlistAt
*   LDA #0 ;Dont signal exit
    RTS

_boxList:
    LDY #0
    STY return
*   LDA boxes+1,Y
    INY
    LDX boxes+1,Y
    INY
    STY _scratch+1
    LDY method
    JSR invokevirtual
    CMP #0
    BEQ +
    STA return
*   LDY _scratch+1 
    CPY boxes
    BCC --
    BEQ --
    RTS

_boxListAt:
    ASL
    TAY
    LDA boxes+1,Y
    LDX boxes+2,Y
    LDY method
    JMP invokevirtual ;JSR,RTS
    
construct:
        LDY #3
        LDA (this),Y ; Fetch size of variables
        PHA        
        INY
        LDA (this),Y ; Fetch fixed variable pointer low byte
        STA _chptr
        INY
        LDA (this),Y ; Fetch fixed variable pointer high byte
        STA _chptr+1 
        CLC        ;advance this pointer over vtable to point at data
        LDA this
        ADC #jmp_header_size
        STA this
        LDA this+1
        ADC #0
        STA this+1
        
        PLA
        TAY
*       LDA (this),Y
        STA (_chptr),Y
        DEY
        BPL -           
        RTS

doJumpTable:
         sta _scratch
         pla
         sta _tempptr
         pla
         sta _tempptr+1
         tya
         asl
         tay
         iny
         lda (_tempptr), y
         sta _target
         iny
         lda (_tempptr), y
         sta _target+1
         lda _scratch
         jmp (_target)
             
            
invokevirtual:
         STA this
         STX this+1
         JMP (this)
         
reinvokevirtual:
        PHA
        SEC        ;return this pointer to vtable
        LDA this
        SBC #jmp_header_size
        STA this
        LDA this+1
        SBC #0
        STA this+1
        PLA
        JMP (this)
         
empty:
        LDA #0
        RTS
        
exit:
        JSR leave_fullscreen
        LDA #1
        RTS

.alias method_render 0    
.alias method_key 1
.alias method_get 2        
.alias method_select 3    
.alias method_deselect 4
.alias method_action 5
.alias method_detail 6
.alias method_escape 7
.alias method_continue 8
    
.alias jmp_header_size 6  
      
flow:
 JMP flow'vtable
.byte 1
.word keys_pressed 
.byte 0   

title:
 JMP lable'vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 0 + [X_CHARS*0]
.word colour_mem_hi + 0 + [X_CHARS*0]
.byte 1,1,22,3
.byte yellow,yellow
.word styleTitle
.word @automata
.byte 2
.byte 0
.byte 0
  
boxRun:
 JMP confirmboxes'vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 17 + [X_CHARS*4]
.word colour_mem_hi + 17 + [X_CHARS*4]
.byte 18,6,5,5
.byte cyan,white
.word style1
.word @run
.byte 0
.byte 0
.byte 0

boxRuleBinary:
 JMP binaryrule'vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 0 + [X_CHARS*5]
.word colour_mem_hi + 0 + [X_CHARS*5]
.byte 1,6,10,3
.byte white,white
.word style3
.word @rule
.byte 1
.byte 0
.byte 0


boxRandom:
 JMP toggleBoxes'vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 2 + [X_CHARS*12]
.word colour_mem_hi + 2 + [X_CHARS*12]
.byte 2,11,3,3
.byte cyan,white
.word style1
.word @rnd
.byte 0
.byte 0
.byte 0

boxColB:
 JMP colourboxes'vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 7 + [X_CHARS*12]
.word colour_mem_hi + 7 + [X_CHARS*12]
.byte 7,11,3,3
.byte blue,white
.word style3
.word @back
.byte 0
.byte 0
.byte 0

boxColR:
 JMP colourboxes'vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 11 + [X_CHARS*12]
.word colour_mem_hi + 11 + [X_CHARS*12]
.byte 11,11,3,3
.byte green,white
.word style3
.word @bord
.byte 0
.byte 0
.byte 0

boxColP:
 JMP colourboxes'vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 15 + [X_CHARS*12]
.word colour_mem_hi + 15 + [X_CHARS*12]
.byte 15,11,3,3
.byte yellow,white
.word style3
.word @pen
.byte 0
.byte 0
.byte 0

boxColA:
 JMP colourboxes'vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 19 + [X_CHARS*12]
.word colour_mem_hi + 19 + [X_CHARS*12]
.byte 19,11,3,3
.byte red,white
.word style3
.word @aux
.byte 0
.byte 0
.byte 0

boxRule4Index:
 JMP rule4Index'vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 0 + [X_CHARS*16]
.word colour_mem_hi + 0 + [X_CHARS*16]
.byte 0,15,3,3
.byte white,white
.word style3
.word @ind
.byte 0
.byte 0
.byte 0

boxRuleBit4:
 JMP bit4rule'vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 3 + [X_CHARS*15]
.word colour_mem_hi + 3 + [X_CHARS*15]
.byte 5,17,14,5
.byte white,white
.word style3
.word @rule4
.byte 0
.byte 0
.byte 0

boxRun4:
 JMP confirmboxes4'vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 17 + [X_CHARS*15]
.word colour_mem_hi + 17 + [X_CHARS*15]
.byte 18,17,5,5
.byte cyan,white
.word style1
.word @run
.byte 0
.byte 0
.byte 0
    
boxExit:
 JMP exitboxes'vtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem_hi + 16 + [X_CHARS*20]
.word colour_mem_hi + 16 + [X_CHARS*20]
.byte 17,21,6,3
.byte cyan,white
.word style1
.word @exit
.byte 0
.byte 0
.byte 0

boxFinal:
 JMP boxes'vtable
.byte [box_width_working-box_origin]-1
.word box_origin  
.word screen_mem_hi + 1 + [X_CHARS*1]
.word colour_mem_hi + 1 + [X_CHARS*1]
.byte 2,2,X_CHARS-2,Y_CHARS-2
.byte white,red
.word style2
.word 0
.byte 0
.byte 0
.byte 0

cellsrc:
.word cellbuffer1
celldst:
.word cellbuffer2
rule:
.byte 0,1,1, 1,1,0, 0,0
ruledec:
.byte 30
rule4:
.byte 1,2,3, 0,1,2, 2,0,3, 2
endrule4:

rule4index:
.byte 0

rule4bank:
.byte 1,2,3, 0,1,2, 2,0,3, 2, 0,0,0,0,0,0
.byte 2,0,1,2,2,2,3,3,0,2,0,0,0,0,0,0
.byte 1,2,0,0,1,3,1,1,0,1,0,0,0,0,0,0
.byte 2,2,2,2,2,1,2,3,2,3,0,0,0,0,0,0

.byte 3,0,1,0,0,0,2,0,0,0,0,0,0,0,0,0
.byte 2,1,3,1,2,1,3,3,0,1,0,0,0,0,0,0
.byte 2,0,1,1,2,0,3,3,2,2,0,0,0,0,0,0
.byte 3,3,3, 3,3,3, 3,3,3, 3, 0,0,0,0,0,0

.byte 0,0,0, 0,0,0, 0,0,0, 0, 0,0,0,0,0,0
.byte 1,1,1, 1,1,1, 1,1,1, 1, 0,0,0,0,0,0
.byte 2,2,2, 2,2,2, 2,2,2, 2, 0,0,0,0,0,0
.byte 3,3,3, 3,3,3, 3,3,3, 3, 0,0,0,0,0,0

.byte 0,0,0, 0,0,0, 0,0,0, 0, 0,0,0,0,0,0
.byte 1,1,1, 1,1,1, 1,1,1, 1, 0,0,0,0,0,0
.byte 2,2,2, 2,2,2, 2,2,2, 2, 0,0,0,0,0,0
.byte 3,3,3, 3,3,3, 3,3,3, 3, 0,0,0,0,0,0
rule4bankend:



.alias boxes_list_size 13 ;Update this when you add more boxes

boxes:
.byte 24
.word flow
.word title
.word boxRuleBinary
.word boxRun
.word boxRandom
.word boxColB
.word boxColR
.word boxColP
.word boxColA
.word boxRule4Index
.word boxRuleBit4
.word boxRun4
.word boxExit

@exit: .byte "EXIT", 0
@run: .byte "RUN", 0
@back: .byte "BCK", 0
@pen: .byte "PEN", 0
@aux: .byte "AUX", 0
@bord: .byte "BOR", 0
@rnd: .byte "RND", 0
@ind: .byte "IND", 0
@automata: .byte"1D CELLULAR AUTOMATA",0
@filenameL: .byte "RULE"
@filenameS: .byte "@0:RULE"
@rule: .byte "********", 0
@rule4: .byte "**********", 0
@debug: .byte "*",0
style1: .byte 64, 64, 93, 93, 110, 112, 125, 109, 102
style2: .byte 98, 98+128, 97, 97+128, 123, 108, 126, 124, 160
style3: .byte 64, 64, 93, 93, 73, 85, 75, 74, 102
style4: .byte 98+128, 98, 97+128, 97, 127, 255, 255, 127, 102
styleTitle: .byte 98+128, 98, 97+128, 97, 127, 127+128, 127+128, 127, 127+128

lable'vtable:
    JSR doJumpTable
    .word render, handlekey, empty, empty, empty, empty, empty, empty, empty

boxes'vtable:
    JSR doJumpTable
    .word render, handlekey, get, select, deselect, empty, empty, empty, empty
 
exitboxes'vtable:
    JSR doJumpTable 
    .word render, handlekey, get, select, deselect, exit, empty, empty, empty

confirmboxes'vtable:
    JSR doJumpTable    
    .word render, handlekey, get, select, deselect, automata, empty, leave_fullscreen, continue
    
confirmboxes4'vtable:
    JSR doJumpTable    
    .word render, handlekey, get, select, deselect, automata4, empty, leave_fullscreen, continue4   
    
colourboxes'vtable:
    JSR doJumpTable    
    .word render, handlekeyc, get, select, deselect, empty, empty, empty, empty       
    
rule4Index'vtable:
    JSR doJumpTable    
    .word render, handlekeyi, get, select, deselect, empty, render_index, empty, empty       
    
binaryrule'vtable:
    JSR doJumpTable
    .word render_ruleb, handlerulekeyb, get, select, deselect, update_ruleb, empty, empty, empty    

bit4rule'vtable:
    JSR doJumpTable
    .word renderrule4, handlerulekey4, get, select, deselect, update_rule4, empty, empty, empty
    
flow'vtable:
    JSR doJumpTable
    .word empty, flowKey, get, empty, empty, empty, empty, empty
    
toggleBoxes'vtable:
    JSR doJumpTable
   .word render, handlekey, get, select, deselect, toggle, render_toggle, empty, empty


.alias top 0
.alias bottom 1
.alias right 2
.alias left 3
.alias top_right 4
.alias top_left 5
.alias bottom_right 6
.alias bottom_left 7
.alias fill 8
.checkpc $2F00

.data
.org $2F00
; globals
.space _target 2
.space _scratch 4
.space method 1
.space var 1
.space selected 1
.space keypress 1
.space fullscreen 1
.space return 1
.space JOY_U 1
.space JOY_D 1
.space JOY_L 1
.space JOY_R 1
.space JOY_F 1

;automata globals
.space row_counter 1
.space col_counter 1
.space row_start 2
.space multicolour 1


; args for box
.space box_origin 2
.space box_col_origin 2
.space box_x 1
.space box_y 1
.space box_width 1
.space box_height 1
.space box_colour 1
.space box_frame_colour 1
.space box_style 2
.space box_legend 2
.space box_select 1
.space box_check 1
.space box_edited 1


.space box_width_working 1
.space box_height_working 1
.space box_colour_working 1

; args for flow
.space keys_pressed 1

.space cellbuffer1 162
.space cellbuffer2 162
.space pixel_acc 1

.alias bitmap $1100
 


