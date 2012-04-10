/*
* fbe_ldscript.ld
*  
* written by sjrct
*
* Note: if decided to align sections, header must be adjusted accordingly
*/

OUTPUT_FORMAT("binary")
ENTRY(main)

INPUT("../../lib/cstd.a", "../../lib/fapi.a")

/* defined by Frosk */
text_virt_addr = 0x20;
data_virt_addr = 0x14;

/* can be changed freely, on the small side right now */
heap_size = 0x10000;
stack_size = 0x10000;

SECTIONS
{
	/* FBE Header Data */
	.fbehdr :
	{
		LONG(0xfbe0fbe0)
		LONG(SIZEOF(.fbehdr))
		LONG(SIZEOF(.text))
		LONG(SIZEOF(.fbehdr) + SIZEOF(.text))
		LONG(SIZEOF(.data))
	}
	
	/* Code Section */
	.text text_virt_addr : AT(SIZEOF(.fbehdr))
	{
		* (.text)
	} = 0x0

	/* Data Sections */
	.data data_virt_addr : AT(SIZEOF(.fbehdr) + SIZEOF(.text))
	{
		* (.rdata .rodata);
		* (.data);
	/* FIXME */
/*	} = 0x0

	.bss data_virt_addr + SIZEOF(.data) :
		AT(SIZEOF(.fbehdr) + SIZEOF(.text) + SIZEOF(.data))
	{
*/
		* (COMMON)
		* (.bss)
	} = 0x0
	
	end = .;

	/* Pfft. We don't need this crap */
	/DISCARD/ :
	{
		* (.eh_frame)
		* (.comment)
	}

	end = .;
}
