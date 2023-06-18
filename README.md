# Agon MOS versions of dos2unix and unix2dos

## About

This project builds two small utilities for Agon MOS:
- dos2unix.bin
- unix2dos.bin

They can be used to convert between Unix line-endings (0x0A/"\\n"/\<LF\>) and
DOS line-endings (0x0D 0x0A/"\\r\\n"/\<CR\>\<LF\>).

## Installation

Copy dos2unix.bin and unix2dos.bin into the MOS directory on your Agon MOS
MicroSD card.

## Usage

    dos2unix <input_file> <output_file>

    unix2dos <input_file> <output_file>


