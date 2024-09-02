ENTRY(_start)

SECTIONS {
	. = 0x80200000;
	__kernel_base = .;

	.text : {
		KEEP(*(.text.boot));
		*(.text .text.*);
	}
}
