#importonce
#import "lib/boxes/indexBox.asm"
#import "lib/boxes/toggleBox.asm"
#import "lib/boxes/colourBox.asm"
#import "lib/boxes/ruleBox.asm"

styleAction: .byte 64, 64, 93, 93, 110, 112, 125, 109, 102
styleSelected: .byte 98, 98+128, 97, 97+128, 123, 108, 126, 124, 160
styleWidget: .byte 64, 64, 93, 93, 73, 85, 75, 74, 102
styleTitle: .byte 98+128, 98, 97+128, 97, 127, 127+128, 127+128, 127, 102
styleHelp: .byte 64, 64, 93, 93, 110, 112, 125, 109, 96

.var hl=@"\$98\$12\$05"
.var ml=@"\$12\$9E"
.var ll=@"\$98\$92"
.var arr_u=@"\$61"
.var arr_d=@"\$73"
.var arr_l=@"\$78"
.var arr_r=@"\$7A"
.var return_char=@"\$7E"

str_exit: str("EXIT")
str_run: str("RUN")
str_back: str("BCK")
str_pen: str("PEN")
str_aux: str("AUX")
str_bord: str("BRD")
str_rnd: str("RND")
str_rndr: str("RND-RULE")
str_ind: str("IND")
str_scroll: str("SCROLL")
str_automata: str(" 1D CELLULAR AUTOMATA ")
str_help_rule: str(ml+"0-9"+ll+" RULE EDIT "+hl+"S"+ll+"AVE "+hl+"L"+ll+"OAD");
str_help_rnd: str(hl+"R"+ll+"ANDOM RULE "+ml+return_char+ll+" TOGGLE ");
str_help_scroll: str(ll+"SCR"+hl+"O"+ll+"LL "+ml+return_char+ll+" TOGGLE ");
str_help_exit: str(ll+"E"+hl+"X"+ll+"IT");
str_help_csr: str(ml+arr_u+ll+" "+ml+arr_d+ll+" CHANGE");
str_help_run: str(ll+"RU"+hl+"N"+ll+" "+ml+return_char+ll+" NEXT "+ml+"SPACE"+ll+" SCROLL");

str_help_blank: str(ll+"                            ");
str_rule4: str("**********")

lableVtable:
    jsr doJumpTable
    .word render, handlekey, empty, empty, empty, empty, empty, empty
 
exitboxesVtable:
     jsr doJumpTable 
    .word render, handlekey, select, deselect, exit, empty, empty, empty
    
confirmboxes4Vtable:
     jsr doJumpTable    
    .word render, handlekey, select, deselect, render4, empty, returnToGui, continue8rows   

flowVtable:
     jsr doJumpTable
    .word empty, flowKey, empty, empty, empty, empty, empty


flow:
  jmp flowVtable
.byte 1
.word keys_pressed 
.byte 0


.macro box(vtable,str,help,x,y,w,h,xo,yo,scol,ecol,style,selected) {
  jmp vtable
  .byte BOX_DATA_SIZE
  .word box_origin 
  .word screen_mem + x + [X_CHARS*y]
  .word colour_mem + x + [X_CHARS*y]
  .byte x+xo,y+yo,w,h
  .byte scol,ecol
  .word style
  .word str
  .word help
  .byte selected
  .byte 0
  .byte 0  
}

.const row2=5
.const row1=13
.const grp1=8
.const grp2=2
.const grp3=22

title:
box(lableVtable,str_automata,0,0,0,40,3,9,1,LIGHT_BLUE,BLUE,styleTitle,0)

helpArea:
box(lableVtable,0,0,0,22,32,3,1,1,DARK_GREY,GREY,styleHelp,0)

boxRule4Index:
box(rule4IndexVtable,str_ind,str_help_csr,grp1,row2+1,3,3,0,-1,edge_col,edge_col,styleWidget,0)

boxRuleBit4:
box(bit4ruleVtable,str_rule4,str_help_rule,grp1+3,row2,14,5,2,2,edge_col,edge_col,styleWidget,0)

boxRun4:
box(confirmboxes4Vtable,str_run,str_help_run,grp1+17,row2,5,5,1,2,selected_col,edge_col,styleAction,0)

boxRR:
toggleBox(str_rnd,str_help_rnd,grp2,row1,0,-1)

boxScroll:
toggleBox(str_scroll,str_help_scroll,grp2+6,row1,-2,-1)

boxColB:
colourBox(str_bord,grp3,row1,GREEN)

boxColR:
colourBox(str_back,grp3+4,row1,RED)

boxColP:
colourBox(str_pen,grp3+8,row1,YELLOW)

boxColA:
colourBox(str_aux,grp3+12,row1,BLUE)
    
boxExit:
box(exitboxesVtable,str_exit,str_help_exit,32,22,8,3,2,1,selected_col,edge_col,styleAction,0)

.var boxesList = List().add(boxRule4Index,boxRuleBit4,boxRun4,boxRR,boxScroll,boxColB,boxColR,boxColP,boxColA,boxExit)
.const boxes_interactive_size = boxesList.size()
.eval boxesList.add(title,helpArea,flow)
.const boxes_list_size = boxesList.size()

boxes:
.for (var i=0; i<boxesList.size(); i++) {
        .word boxesList.get(i)
}
