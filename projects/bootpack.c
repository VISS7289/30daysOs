// bootpack.c
#include <stdio.h>
void io_hlt(void);
void io_cli(void);
void io_out8(int port, int data);
int io_load_eflags(void);
void io_store_eflags(int eflags);

void init_palette(void);
void set_palette(int start, int end, unsigned char *rgb);
void boxfill8(unsigned char *vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1);
void putfont8(unsigned char *vram, int xsize, int x, int y, char c, char *font);
void initScr(unsigned char *vram, int xsize, int ysize);
void putfont8_asc(unsigned char *vram, int xsize, int x, int y, char c, unsigned char *s);
void init_mouse_cursor8(char *mouse, char bc);

#define COL8_000000 0  // 0黑
#define COL8_FF0000 1  // 1亮红
#define COL8_00FF00 2  // 2亮绿
#define COL8_FFFF00 3  // 3亮黄
#define COL8_0000FF 4  // 4亮蓝
#define COL8_FF00FF 5  // 5亮紫
#define COL8_00FFFF 6  // 6浅亮蓝
#define COL8_FFFFFF 7  // 7白
#define COL8_C6C6C6 8  // 8亮灰
#define COL8_840000 9  // 9暗红
#define COL8_008400 10 // 10暗绿
#define COL8_848400 11 // 11暗黄
#define COL8_000084 12 // 12暗青
#define COL8_840084 13 // 13暗紫
#define COL8_008484 14 // 14浅暗蓝
#define COL8_848484 15 // 15暗灰

struct BOOTINFO
{
	char cyls, leds, vmode, reserve;
	short scrnx, scrny;
	char *vram;
};

void HariMain(void)
{
	struct BOOTINFO *bootinfo = (struct BOOTINFO *)0x0ff0;
	char s[40], mcursor[256];
	int mx, my;
	mx = (bootinfo->scrnx - 16) / 2;
	my = (bootinfo->scrny - 28 - 16) / 2;
	
	init_palette(); // 设置调色盘
	initScr(bootinfo->vram, bootinfo->scrnx, bootinfo->scrny);

	init_mouse_cursor8(mcursor, COL8_008484);
	putblock8_8(bootinfo->vram, bootinfo->scrnx, 16, 16, mx, my, mcursor, 16);

	sprintf(s, "(%d,%d)", mx, my);
	putfont8_asc(bootinfo->vram, bootinfo->scrnx, 16, 20, COL8_FFFFFF, s);
	for (;;)
	{
		io_hlt();
	}
}

void initScr(unsigned char *vram, int xsize, int ysize)
{
	// 背景
	boxfill8(vram, xsize, COL8_008484, 0, 0, xsize - 1, ysize - 29); // 整体背景
	// 导航栏
	boxfill8(vram, xsize, COL8_C6C6C6, 0, ysize - 28, xsize - 1, ysize - 28); // 灰色margin
	boxfill8(vram, xsize, COL8_FFFFFF, 0, ysize - 27, xsize - 1, ysize - 27); // 白色margin
	boxfill8(vram, xsize, COL8_C6C6C6, 0, ysize - 26, xsize - 1, ysize - 1);  //  底部导航栏
	// 按钮
	boxfill8(vram, xsize, COL8_FFFFFF, 3, ysize - 24, 59, ysize - 24); // 白色margin上
	boxfill8(vram, xsize, COL8_FFFFFF, 2, ysize - 24, 2, ysize - 4);   // 白色margin左
	boxfill8(vram, xsize, COL8_848484, 3, ysize - 4, 59, ysize - 4);   // 灰色margin下
	boxfill8(vram, xsize, COL8_848484, 59, ysize - 23, 59, ysize - 5); // 灰色margin右
	boxfill8(vram, xsize, COL8_000000, 2, ysize - 3, 59, ysize - 3);   // 黑色margin下
	boxfill8(vram, xsize, COL8_000000, 60, ysize - 24, 60, ysize - 3); // 黑色margin右
	// 框
	boxfill8(vram, xsize, COL8_848484, xsize - 47, ysize - 24, xsize - 4, ysize - 24); // 灰色padding上
	boxfill8(vram, xsize, COL8_848484, xsize - 47, ysize - 23, xsize - 47, ysize - 4); // 灰色padding左
	boxfill8(vram, xsize, COL8_FFFFFF, xsize - 47, ysize - 3, xsize - 4, ysize - 3);   // 白色padding下
	boxfill8(vram, xsize, COL8_FFFFFF, xsize - 3, ysize - 24, xsize - 3, ysize - 3);   // 白色padding右
}

void init_mouse_cursor8(char *mouse, char bc)
/* 准备鼠标指针16x16 */
{
	static char cursor[16][16] = {
		"**************..",
		"*OOOOOOOOOOO*...",
		"*OOOOOOOOOO*....",
		"*OOOOOOOOO*.....",
		"*OOOOOOOO*......",
		"*OOOOOOO*.......",
		"*OOOOOOO*.......",
		"*OOOOOOOO*......",
		"*OOOO**OOO*.....",
		"*OOO*..*OOO*....",
		"*OO*....*OOO*...",
		"*O*......*OOO*..",
		"**........*OOO*.",
		"*..........*OOO*",
		"............*OO*",
		".............***"
	};
	int x, y;

	for (y = 0; y < 16; y++) {
		for (x = 0; x < 16; x++) {
			if (cursor[y][x] == '*') {
				mouse[y * 16 + x] = COL8_000000;
			}
			if (cursor[y][x] == 'O') {
				mouse[y * 16 + x] = COL8_FFFFFF;
			}
			if (cursor[y][x] == '.') {
				mouse[y * 16 + x] = bc;
			}
		}
	}
	return;
}

void putblock8_8(char *vram, int vxsize, int pxsize, int pysize, 
	int px0, int py0, char *buf, int bxsize)
{
	int x,y;
	for(y=0;y<pysize;y++){
		for(x=0;x<pxsize;x++){
			vram[(py0+y)*vxsize+(px0+x)]=buf[y*bxsize+x];
		}
	}
}

void putfont8_asc(unsigned char *vram, int xsize, int x, int y, char c, unsigned char *s)
{
	extern char hankaku[4096];
	for (; *s != 0x00; s++)
	{
		putfont8(vram, xsize, x, y, c, hankaku + *s * 16);
		x += 8;
	}
	return;
}
void putfont8(unsigned char *vram, int xsize, int x, int y, char c, char *font)
{
	int i;
	char d, *p;
	for (i = 0; i < 16; i++)
	{
		d = font[i];
		p = vram + (y + i) * xsize + x;
		if ((d & 0x80) != 0)
			p[0] = c;
		if ((d & 0x40) != 0)
			p[1] = c;
		if ((d & 0x20) != 0)
			p[2] = c;
		if ((d & 0x10) != 0)
			p[3] = c;
		if ((d & 0x08) != 0)
			p[4] = c;
		if ((d & 0x04) != 0)
			p[5] = c;
		if ((d & 0x02) != 0)
			p[6] = c;
		if ((d & 0x01) != 0)
			p[7] = c;
	}
	return;
}

void init_palette(void)
{
	static unsigned char table_rgb[16 * 3] = {
		0x00, 0x00, 0x00, // 0黑
		0xff, 0x00, 0x00, // 1亮红
		0x00, 0xff, 0x00, // 2亮绿
		0xff, 0xff, 0x00, // 3亮黄
		0x00, 0x00, 0xff, // 4亮蓝
		0xff, 0x00, 0xff, // 5亮紫
		0x00, 0xff, 0xff, // 6浅亮蓝
		0xff, 0xff, 0xff, // 7白
		0xc6, 0xc6, 0xc6, // 8亮灰
		0x84, 0x00, 0x00, // 9暗红
		0x00, 0x84, 0x00, // 10暗绿
		0x84, 0x84, 0x00, // 11暗黄
		0x00, 0x00, 0x84, // 12暗青
		0x84, 0x00, 0x84, // 13暗紫
		0x00, 0x84, 0x84, // 14浅暗蓝
		0x84, 0x84, 0x84  // 15暗灰
	};
	set_palette(0, 15, table_rgb);
	return;
}

void set_palette(int start, int end, unsigned char *rgb)
{
	int i, eflags;
	eflags = io_load_eflags(); // 记录中断许可标志的值
	io_cli();				   // 将中断许可标志设为0，禁止中断
	io_out8(0x03c8, start);
	for (i = start; i <= end; i++)
	{
		io_out8(0x03c9, rgb[0] / 4);
		io_out8(0x03c9, rgb[1] / 4);
		io_out8(0x03c9, rgb[2] / 4);
		rgb += 3;
	}
	io_store_eflags(eflags); //复原中断标志
	return;
}

void boxfill8(unsigned char *vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1)
{
	int x, y;
	for (y = y0; y <= y1; y++)
	{
		for (x = x0; x <= x1; x++)
			vram[y * xsize + x] = c;
	}
	return;
}