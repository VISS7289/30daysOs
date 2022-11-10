//naskfunc.nas:
; naskfunc
; TAB = 4

[FORMAT "WCOFF"]    ;制作的目标文件的模式,因为要与c文件对接，因此需要生成一个中间的文件
[BITS 32]           ;制作32位的机器语言模式

;制作目标文件的信息
[FILE "naskfunc.nas"]   ;源文件名信息
         
         GLOBAL     _io_hlt     ;程序中包含的函数名，一定要以_开头，为了衔接c语言的函数库

; 以下是实际的函数内容
[SECTION .text]          ;目标文件中写了这些之后再写程序

_io_hlt:   ;void io_hlt(void);
        HLT 
        RET          
