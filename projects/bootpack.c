//bootpack.c
void io_hlt(void);

void HariMain(void)
{
	fin:
	    io_hlt();
	    //自建的hlt函数，源目标程序在naskfunc.nas中，c语言本身没有hlt这个命令
	    goto fin;
}
