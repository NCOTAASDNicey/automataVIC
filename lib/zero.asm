#importonce
#import "lib/kernal.asm"

.const FULLSCREEN_BIT=0
.const MULTI_BIT=1

* = $a7 virtual
.zp {
 scrmode: .byte 0
}
* = zero_page_rs_232 virtual
.zp {
this: .word 0
_chptr: .word 0
_styleptr: .word 0
_tempptr: .word 0
}
