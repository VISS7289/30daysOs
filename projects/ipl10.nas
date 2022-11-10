; haribote-ipl
; TAB=4

CYLS	EQU		10

		ORG		0x7c00			; 启动程序的装载地址一般为0x7c00~0x7dff

; 标准的FAT12格式软盘的必备专用的代码 Stand FAT12 format floppy code，即书写在开头的文件描述系统

		JMP		entry
		DB		0x90
		DB		"HARIBOTE"		; 启动扇区名称（8字节）
		DW		512				; 每个扇区（sector）大小（必须512字节）
		DB		1				; 簇（cluster）大小（必须为1个扇区）
		DW		1				; FAT起始位置（一般为第一个扇区）
		DB		2				; FAT个数（必须为2）
		DW		224				; 根目录大小（一般为224项）
		DW		2880			; 该磁盘大小（必须为2880扇区1440*1024/512）
		DB		0xf0			; 磁盘类型（必须为0xf0）
		DW		9				; FAT的长度（必须是9扇区）
		DW		18				; 一个磁道（track）有几个扇区（必须为18）
		DW		2				; 磁头数（必须是2）
		DD		0				; 不使用分区，必须是0
		DD		2880			; 重写一次磁盘大小
		DB		0,0,0x29		; 意义不明（固定）
		DD		0xffffffff		; （可能是）卷标号码
		DB		"HARIBOTEOS "	; 磁盘的名称（必须为11字字节，不足填空格）
		DB		"FAT12   "		; 磁盘格式名称（必须8字，不足填空格）
		RESB	18				; 先空出18字节

; 程序主主体

entry:
		MOV		AX,0			; 将启动区的初始段地址（0000）设置给以及将启动扇区的偏移地址（7c00)进行设置到栈和数据段中
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX

; 磁盘读取部分

		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; 柱面0
		MOV		DH,0			; 磁头0
		MOV		CL,2			; 扇区2
readloop:
		MOV		SI,0			; 记录失败的次数
retry:
		MOV		AH,0x02			; AH=0x02 : 读入磁盘
		MOV		AL,1			; 1个扇区
		MOV		BX,0
		MOV		DL,0x00			; A驱动器
		INT		0x13			; 调用磁盘BIOS
		JNC		next			; 没出错就跳转到next
		ADD		SI,1			; SI+1 失败次数+1
		CMP		SI,5			; SI >= 5 时，跳转到error
		JAE		error			; 系统复位，bios里的功能，即复位软盘
		MOV		AH,0x00
		MOV		DL,0x00			; 重置a驱动器
		INT		0x13
		JMP		retry
next:
		MOV		AX,ES			; 把内存地址后移0x200，因为一个扇区512字节！！！ 且段地址算法是先乘以16的，但是这里不需要逻辑上乘16 因此直接加上0x0020
		ADD		AX,0x0020
		MOV		ES,AX
		ADD		CL,1
		CMP		CL,18			; CL< = 18则跳转
		JBE		readloop
		MOV		CL,1
		ADD		DH,1
		CMP		DH,2
		JB		readloop		; 如果DH<2则跳转到readloop
		MOV		DH,0
		ADD		CH,1
		CMP		CH,CYLS
		JB		readloop		; 如果CH<CYLS，则跳转到readloop


		MOV		[0x0ff0],CH		; 将CYLS的值移动到0x0ff0当中，为了告诉haribote.sys磁盘装载内容的结束地址，因为CYLS代表了10个柱面
		JMP		0xc200

error:
		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			; 给SI加1,循环打印
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			; 显示一个文字，调用0x0e号子中断程序
		MOV		BX,15
		INT		0x10			; 设置中断程序。10h号中断代表显示字符串，调用bios的中断
		JMP		putloop
fin:
		HLT						; cpu停止运行，等待指令，节约资源
		JMP		fin				; 无限循环
msg:
		DB		0x0a, 0x0a		; 换行两次
		DB		"load error"
		DB		0x0a			; 换行
		DB		0

		RESB	0x7dfe-$		; 填写0x00直到0x001fe

		DB		0x55, 0xaa		;这里标志着有启动程序，因为计算机一般先读最后两字节进行判断是否含启动程序的！！