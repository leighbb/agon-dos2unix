/*
 * Title:		AGON MOS - MOS c header interface
 * Author:		Jeroen Venema
 * Updated by:		Leigh Brown
 * Created:		15/10/2022
 * Last Updated:	18/06/2023
 * 
 * Modinfo:
 * 15/10/2022:		Added putch, getch
 * 22/10/2022:		Added waitvblank, mos_f* functions
 * 18/06/2023:		Added struct mos_sysvar struct
 */

#ifndef MOS_H
#define MOS_H

#include <defines.h>

// Error returns
#define ERR_INVALID_PARAMETER	19

// File access modes - from mos_api.inc
#define fa_read				0x01
#define fa_write			0x02
#define fa_open_existing	0x00
#define fa_create_new		0x04
#define fa_create_always	0x08
#define fa_open_always		0x10
#define fa_open_append		0x30

// Indexes into sysvar - from mos_api.inc
#define sysvar_time		0x00
#define sysvar_vpd_pflags	0x04
#define sysvar_keyascii		0x05
#define sysvar_keymods		0x06
#define sysvar_cursorX		0x07
#define sysvar_cursorY		0x08
#define sysvar_scrchar		0x09
#define sysvar_scrpixel		0x0A
#define sysvar_audioChannel	0x0D
#define sysvar_audioSuccess	0x0E

#define VDPP_FLAG_CURSOR        (1 << 0)
#define VDPP_FLAG_SCRCHAR       (1 << 1)
#define VDPP_FLAG_POINT         (1 << 2)
#define VDPP_FLAG_AUDIO         (1 << 3)
#define VDPP_FLAG_MODE          (1 << 4)
#define VDPP_FLAG_RTC           (1 << 5)

struct mos_sysvars {
	unsigned long	clock;
	unsigned char	vdp_protocol_flags;
	unsigned char	keyascii;
	unsigned char	keymods;
	unsigned char	cursorX;
	unsigned char	cursorY;
	unsigned char	scrchar;
	unsigned int	scrpixel;
	unsigned char	audioChannel;
	unsigned char	audioSuccess;
	unsigned short 	scrwidth;
	unsigned short	scrheight;
	unsigned char	scrcols;
	unsigned char	scrrows;
	unsigned char	scrcolours;
	unsigned char	scrPixelIndex;
	unsigned char	keycode;
	unsigned char	keydown;
	unsigned char	keycount;
	struct {
		unsigned char	year;
		unsigned char	month;
		unsigned char	day;
		unsigned char	dayOfWeek;
		unsigned char	hour;
		unsigned char	minute;
		unsigned char	second;
	} time;
	unsigned short	keydelay;
	unsigned short	keyrate;
	unsigned char	keyled;
	unsigned char	scrmode;
};

extern void putch(char c);
extern char getch(void);
extern struct mos_sysvars *mos_sysvars(void);

extern unsigned char mos_fopen(char * filename, unsigned char mode); // returns filehandle, or 0 on error
extern unsigned char mos_fclose(unsigned char fh);					 // returns number of still open files
extern unsigned int mos_fgetc(unsigned char fh); // returns character from file
extern void mos_fputc(unsigned char fh, char c); // writes character to file
extern unsigned char mos_feof(unsigned char fh); // returns 1 if EOF, 0 otherwise
extern unsigned int mos_fread(unsigned char fh, char *buf, unsigned int btr);
extern unsigned int mos_fwrite(unsigned char fh, char *buf, unsigned int btw);
extern void mos_puts(const char *buf);
extern void mos_write(const char *buf, unsigned int btw);
extern char mos_oscli(const char *cmd);
//
#endif MOS_H
