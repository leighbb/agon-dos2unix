/*
 * Title:		unix2dos
 * Author:		Leigh Brown
 * Created:		18/06/2023
 * Last Updated:	18/06/2023
 * 
 * Modinfo:
 * 18/06/2023:		Initial version
 */

#include <ez80.h>
#include <stdio.h>
#include <stdlib.h>
#include <ERRNO.H>

#include "mos-interface.h"

int errno; // needed by standard library

#define BUFFER_SIZE 4096

// NB: buf_out must be twice as big as buf_in in case every character is '\n'
static char buf_in[BUFFER_SIZE];
static char buf_out[BUFFER_SIZE*2];

void usage(void)
{
	printf("Usage: unix2dos <input filename> <output filename>\r\n");
	return;
}

int main(int argc, char * argv[])
{
	unsigned char fd_in, fd_out;

	if (argc != 3) {
		usage();
		return ERR_INVALID_PARAMETER;
	}

	fd_in = mos_fopen(argv[1], fa_read | fa_open_existing);
	if (fd_in == 0) {
		printf("Could not open '%s' for reading\r\n", argv[1]);
		return ERR_INVALID_PARAMETER;
	}

	fd_out = mos_fopen(argv[2], fa_write | fa_create_always);
	if (fd_out == 0) {
		mos_fclose(fd_in);
		printf("Could not open '%s' for writing\r\n", argv[2]);
		return ERR_INVALID_PARAMETER;
	}

	while (1) {
		unsigned int i, j;
		unsigned int wrote, got;
		char c;

		// Read buffer
		got = mos_fread(fd_in, buf_in, sizeof(buf_in));
		if (got == 0)
			break;

		// Convert (simply deletes \r not sure if that is the best way)
		j = 0;
		for (i = 0; i < got; ++i) {
			c = buf_in[i];
			if (c == '\n')
				buf_out[j++] = '\r';
			buf_out[j++] = buf_in[i];
		}

		// write out output buffer
		wrote = mos_fwrite(fd_out, buf_out, j);
		if (wrote != j) {
			printf("Error writing to '%s'\r\n", argv[2]);
			mos_fclose(fd_in);
			mos_fclose(fd_out);
			return ERR_INVALID_PARAMETER;
		}
	}

	mos_fclose(fd_in);
	mos_fclose(fd_out);
	
	return 0;
}

