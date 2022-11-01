; hello-os
; TAB=4

		ORG		0x7c00		; ָ������װ�ص�ַ

; ���¸�ʽ���ڱ�׼FAT12��ʽ����

		JMP		entry
		DB		0x90
		DB		"HELLOIPL"		; ���������ƣ������������ַ�����8�ֽ�
		DW		512			; ÿ��������С��������512�ֽ�
		DB		1			; ����С������Ϊ1������
		DW		1			; FAT��ʼλ�ã�һ��ӵ�һ��������ʼ
		DB		2			; FAT����������Ϊ2
		DW		224			; ��Ŀ¼��С��һ��Ϊ224��
		DW		2880			; �ô��̴�С������Ϊ2880����
		DB		0xf0			; �������࣬������0xf0
		DW		9			; FAT���ȣ�����Ϊ9����
		DW		18			; 1���ŵ��м�������������Ϊ18
		DW		2			; ��ͷ��������Ϊ2
		DD		0			; ��ʹ�÷�����������0
		DD		2880			; ��дһ����̴�С
		DB		0,0,0x29		; ���岻�����̶�
		DD		0xffffffff		; �����Ǿ�����
		DB		"HELLO-OS   "	; �������ƣ�11�ֽ�
		DB		"FAT12   "		; ���̸�ʽ���ƣ�8�ֽ�
		RESB	18				; �ȿճ�18�ֽ�

; ��������

entry:
		MOV		AX,0			; ��ʼ���Ĵ���
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX
; װ����һ��512�ֽ����ݣ����������ӡ"load error"
		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; ����0
		MOV		DH,0			; ��ͷ0
		MOV		CL,2			; ����2

		MOV		SI,0			;��¼ʧ�ܴ����Ĵ���
retry:
		MOV		AH,0x02		; AH=0x02 : ����
		MOV		AL,1			; 1������
		MOV		BX,0
		MOV		DL,0x00		; A������
		INT		0x13			; ���ô���BIOS
		JNC		fin			; û���������fin
		ADD		SI,1			; SI+1
		CMP		SI,5			; �Ƚ�SI��5
		JAE		error			; SI >= 5 ������error
		MOV		AH,0x00
		MOV		DL,0x00		; A������
		INT		0x13			; ϵͳ��λBIOS
		JMP		retry

fin:
		HLT					; ��CPUֹͣ���ȴ�ָ��
		JMP		fin			; ����ѭ��

error:
		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			; ��SI��1
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e		; ��ʾһ������
		MOV		BX,15			; ָ���ַ���ɫ
		INT		0x10			; �����Կ�BIOS
		JMP		putloop
msg:
		DB		0x0a, 0x0a		; ��������
		DB		"load error"
		DB		0x0a			; ��������
		DB		0

		RESB	0x7dfe-$		; ��д0x00ֱ��0x7dfe

		DB		0x55, 0xaa
