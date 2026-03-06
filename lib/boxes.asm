#importonce
#import "lib/boxes/indexBox.asm"
#import "lib/boxes/toggleBox.asm"
#import "lib/boxes/colourBox.asm"
#import "lib/boxes/ruleBox.asm"

.var hl=@"\$98\$12\$05"
.var ml=@"\$12\$9E"
.var ll=@"\$98\$92"
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
rndStr: str("RND")
indStr: str("IND")
automataStr: str("1D CELLULAR AUTOMATA")
filenameLStr: .text "RULE"
filenameSStr: .text "0Str:RULE"
ruleStr: str("********")
rule4Str: str("**********")
str_rule4: str("**********")
styleAction: .byte 64, 64, 93, 93, 110, 112, 125, 109, 102
styleSelected: .byte 98, 98+128, 97, 97+128, 123, 108, 126, 124, 160
styleWidget: .byte 64, 64, 93, 93, 73, 85, 75, 74, 102
styleTitle: .byte 98+128, 98, 97+128, 97, 127, 127+128, 127+128, 127, 127+128
styleHelp: .byte 64, 64, 93, 93, 110, 112, 125, 109, 96
str_help_blank: str(ll+"                ");
.const selected_col=cyan
.const edge_col=white

flow:
  jmp flow_vtable
.byte 1
.word keys_pressed 
.byte 0

.macro box(vtable,str,help,x,y,w,h,xo,yo,scol,ecol,style,selected) {
  jmp vtable
  .byte BOX_DATA_SIZE
  .word box_origin 
  .word screen_mem_hi + x + [X_CHARS*y]
  .word colour_mem_hi + x + [X_CHARS*y]
  .byte x+xo,y+yo,w,h
  .byte scol,ecol
  .word style
  .word str
  .word help
  .byte selected
  .byte 0
  .byte 0  
}

.const row1=0
.const row2=3
.const row4=8
.const row3=14
.const row5=17
.const row6=20

title:
box(lable_vtable,automataStr,0,0,row1,22,3,1,1,yellow,yellow,styleTitle,0)

boxHelp:
box(lable_vtable,0,0,0,row6,22,3,1,1,blue,blue,styleHelp,0)

boxRuleBinary:
box(binaryrule_vtable,ruleStr,0,0,row2+1,10,3,1,1,white,white,styleWidget,0)

boxRun:
box(confirmboxes_vtable,runStr,0,17,row2,5,5,1,2,selected_col,edge_col,styleAction,0)

boxRule4Index:
box(rule4IndexVtable,indStr,0,0,row4+1,3,3,0,-1,white,white,styleWidget,0)

boxRuleBit4:
box(bit4rule_vtable,str_rule4,0,3,row4,14,5,2,2,white,white,styleWidget,0)

boxRun4:
box(confirmboxes4_vtable,runStr,0,17,row4,5,5,1,2,selected_col,edge_col,styleAction,0)

boxRandom:
toggleBox(rndStr,0,2,row3,0,-1)

boxColB:
colourBox(bordStr,7,row3,green)

boxColR:
colourBox(backStr,11,row3,red)

boxColP:
colourBox(penStr,15,row3,yellow)

boxColA:
colourBox(auxStr,19,row3,blue)
    
boxExit:
box(exitboxes_vtable,exitStr,0,16,row5,6,3,1,1,white,red,styleAction,0)

boxFinal:
box(boxes_vtable,exitStr,0,1,1,X_CHARS-2,Y_CHARS-2,2,2,white,red,styleSelected,0)

.var boxesList = List().add(boxRuleBinary,boxRun,boxRule4Index,boxRuleBit4,boxRun4,boxRandom,boxColB,boxColR,boxColP,boxColA,boxExit)
.const boxes_interactive_size = boxesList.size()
.eval boxesList.add(title,boxHelp,flow)
.const boxes_list_size = boxesList.size()

boxes:
.for (var i=0; i<boxesList.size(); i++) {
        .word boxesList.get(i)
}
