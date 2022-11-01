; hello-os
; TAB=4

		ORG		0x7c00		; 指明程序装载地址

; 以下格式用于标准FAT12格式软盘

		JMP		entry
		DB		0x90
		DB		"HELLOIPL"		; 启动区名称，可以是任意字符串，8字节
		DW		512			; 每个扇区大小，必须是512字节
		DB		1			; 蔟大小，必须为1个扇区
		DW		1			; FAT起始位置，一般从第一个扇区开始
		DB		2			; FAT个数，必须为2
		DW		224			; 根目录大小，一般为224项
		DW		2880			; 该磁盘大小，必须为2880扇区
		DB		0xf0			; 磁盘种类，必须是0xf0
		DW		9			; FAT长度，必须为9扇区
		DW		18			; 1个磁道有几个扇区，必须为18
		DW		2			; 磁头数，必须为2
		DD		0			; 不使用分区，必须是0
		DD		2880			; 重写一遍磁盘大小
		DB		0,0,0x29		; 意义不明，固定
		DD		0xffffffff		; 可能是卷标号码
		DB		"HELLO-OS   "	; 磁盘名称，11字节
		DB		"FAT12   "		; 磁盘格式名称，8字节
		RESB	18				; 先空出18字节

; 程序主体

entry:
		MOV		AX,0			; 初始化寄存器
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX
; 装载下一个512字节内容，如果出错，打印"load error"
		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; 柱面0
		MOV		DH,0			; 磁头0
		MOV		CL,2			; 扇区2

		MOV		SI,0			;记录失败次数寄存器
retry:
		MOV		AH,0x02		; AH=0x02 : 读盘
		MOV		AL,1			; 1个扇区
		MOV		BX,0
		MOV		DL,0x00		; A驱动器
		INT		0x13			; 调用磁盘BIOS
		JNC		fin			; 没出错就跳到fin
		ADD		SI,1			; SI+1
		CMP		SI,5			; 比较SI与5
		JAE		error			; SI >= 5 就跳到error
		MOV		AH,0x00
		MOV		DL,0x00		; A驱动器
		INT		0x13			; 系统复位BIOS
		JMP		retry

fin:
		HLT					; 让CPU停止，等待指令
		JMP		fin			; 无限循环

error:
		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			; 给SI加1
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e		; 显示一个文字
		MOV		BX,15			; 指定字符颜色
		INT		0x10			; 调用显卡BIOS
		JMP		putloop
msg:
		DB		0x0a, 0x0a		; 换行两次
		DB		"load error"
		DB		0x0a			; 换行两次
		DB		0

		RESB	0x7dfe-$		; 填写0x00直到0x7dfe

		DB		0x55, 0xaa
