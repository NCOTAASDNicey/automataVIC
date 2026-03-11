#importonce
#import "lib/data.asm"

.const method_render = 0
.const method_key = 1
.const method_select = 2
.const method_deselect = 3
.const method_action = 4
.const method_detail = 5
.const method_escape = 6
.const method_continue = 7

.const  jmp_header_size = 6

.macro chainInstanceMethod(m,i) {
        // _1 Method
        // _2 Instance
        ldy #m
        lda #<i
        ldx #>i       
        jmp invokevirtual
}

.macro callMethod(m,dest) {
        lda #m
        sta method                  
        jsr dest
}

.macro offsetFromThis(field) {
        ldy #[field-box_origin]
}

// 1 - offset from this
// 2 - target zero page pointer
.macro loadObjectPointer(field,ptr) {
        offsetFromThis(field)
        lda (this),Y
        sta ptr
        iny
        lda (this),Y
        sta ptr+1 
}

// 1 - offset from this
.macro loadObjectByte(field) {
        offsetFromThis(field)
        lda (this),Y
}

// 1 - offset from this
.macro saveObjectByte(field) {
        offsetFromThis(field)
        sta (this),Y
}

.macro loadBoxField(box,field) {
        lda [box+jmp_header_size+[field-box_origin]]        
}

.macro saveBoxField(box,field) {
        sta [box+jmp_header_size+[field-box_origin]]        
}

.macro loadBoxChecked(box) {
        loadBoxField(box,box_check)       
}

.macro saveBoxChecked(box) {
        saveBoxField(box,box_check)       
}

.macro toggleBoxChecked(box) {
        loadBoxChecked(box)
        eor #$1
        saveBoxChecked(box)
}

.macro markBoxEdited(box) {
        lda #1
        sta [box+jmp_header_size+[box_edited-box_origin]]        
}

.macro markBoxUnEdited(box) {
        lda #0
        sta [box+jmp_header_size+[box_edited-box_origin]]        
}
