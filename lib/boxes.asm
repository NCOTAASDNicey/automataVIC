#importonce
#import "lib/boxes/indexBox.asm"
#import "lib/boxes/toggleBox.asm"
#import "lib/boxes/colourBox.asm"
#import "lib/boxes/ruleBox.asm"

.var hl=@"\$1f\$12\$05"
.var ml=@"\$12\$9E"
.var ll=@"\$1f\$92"
.var arr_u=@"\$61"
.var arr_d=@"\$73"
.var arr_l=@"\$78"
.var arr_r=@"\$7A"
.var return_char=@"\$7E"

exitStr: str("EXIT")
runStr: str("RUN")
backStr: str("BCK")
penStr: str("PEN")
auxStr: str("AUX")
bordStr: str("BOR")
rndCStr: str("R/C")
rndRStr: str("R/R")
indStr: str("IND")
automataStr: str("1D CELLULAR AUTOMATA")
str_help_ruleb: str(ml+"0-7"+ll+" EDIT ");
str_help_rule: str(ml+"0-9"+ll+" EDIT "+hl+"S"+ll+"AVE "+hl+"L"+ll+"OAD");
str_help_rnd: str(ll+"RANDOM "+hl+"C"+ll+"ELLS ");
str_help_rndr: str(ll+"RANDOM "+hl+"R"+ll+"ULE ");
str_help_run1: str("1 BIT "+hl+"F1"+ll);
str_help_run2: str("2 BIT "+hl+"F2"+ll);

str_help_exit: str(ll+"E"+hl+"X"+ll+"IT");
str_help_csr: str(ml+arr_u+ll+" "+ml+arr_d+ll+" CHANGE");
str_help_run: str(ll+"RU"+hl+"N"+ll+" "+ml+return_char+ll+" NEXT "+ml+"SPACE"+ll+" SCROLL");
ruleStr: str("********")
str_rule4: str("**********")
styleAction: .byte 64, 64, 93, 93, 110, 112, 125, 109, 102
styleSelected: .byte 98, 98+128, 97, 97+128, 123, 108, 126, 124, 160
styleWidget: .byte 64, 64, 93, 93, 73, 85, 75, 74, 102
styleTitle: .byte 98+128, 98, 97+128, 97, 127, 127+128, 127+128, 127, 127+128
styleHelp: .byte 64, 64, 93, 93, 110, 112, 125, 109, 96
str_help_blank: str(ll+"                    ");
.const selected_col=cyan
.const edge_col=white

flow:
  jmp flow_vtable
.byte 1
.word keys_pressed 
.byte 0

.macro boxflagged(vtable,str,help,x,y,w,h,xo,yo,scol,ecol,style,selected,checked) {
  jmp vtable
  .byte BOX_DATA_SIZE
  .word box_origin
  .word screen_mem_hi + x + [X_CHARS*y]
  .word colour_mem_hi + x + [X_CHARS*y]
  .byte x,y,w,h,x+xo,y+yo
  .byte scol,ecol
  .word style
  .word str
  .word help
  .byte selected
  .byte checked
  .byte 0  
}

.macro box(vtable,str,help,x,y,w,h,xo,yo,scol,ecol,style) {
  boxflagged(vtable,str,help,x,y,w,h,xo,yo,scol,ecol,style,0,0)
}

.const row1=0
.const row2=3
.const row4=8
.const row3=14
.const row5=17
.const row6=20

title:
box(lable_vtable,automataStr,0,0,row1,22,3,1,1,yellow,yellow,styleTitle)

boxHelp:
box(lable_vtable,0,0,0,row6,22,3,1,1,blue,blue,styleHelp)

boxRuleBinary:
boxflagged(binaryrule_vtable,ruleStr,str_help_ruleb,4,row2,12,5,2,2,white,white,styleWidget,1,0)

boxRun:
box(confirmboxes_vtable,runStr,str_help_run1,17,row2,5,5,1,2,selected_col,edge_col,styleAction)

boxRule4Index:
box(rule4IndexVtable,indStr,str_help_csr,0,row4+1,3,3,0,-1,white,white,styleWidget)

boxRuleBit4:
box(bit4rule_vtable,str_rule4,str_help_rule,3,row4,14,5,2,2,white,white,styleWidget)

boxRun4:
box(confirmboxes4_vtable,runStr,str_help_run2,17,row4,5,5,1,2,selected_col,edge_col,styleAction)

boxRandom:
toggleBox(rndCStr,str_help_rnd,0,row3,0,-1,1)

boxRandomR:
toggleBox(rndRStr,str_help_rndr,3,row3,0,-1,1)

boxColB:
colourBox(bordStr,7,row3,green)

boxColR:
colourBox(backStr,11,row3,red)

boxColP:
colourBox(penStr,15,row3,yellow)

boxColA:
colourBox(auxStr,19,row3,blue)
    
boxExit:
box(exitboxes_vtable,exitStr,str_help_exit,16,row5,6,3,1,1,red,red,styleAction)

boxFinal:
box(boxes_vtable,exitStr,0,1,1,X_CHARS-2,Y_CHARS-2,2,2,white,red,styleSelected)

.var boxesList = List().add(boxRuleBinary,boxRun,boxRule4Index,boxRuleBit4,boxRun4,boxRandom,boxRandomR,boxColB,boxColR,boxColP,boxColA,boxExit)
.const boxes_interactive_size = boxesList.size()
.eval boxesList.add(title,boxHelp,flow)
.const boxes_list_size = boxesList.size()

boxes:
.for (var i=0; i<boxesList.size(); i++) {
        .word boxesList.get(i)
}
