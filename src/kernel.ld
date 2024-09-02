ENTRY(_start)

SECTIONS {
	. = 0x80200000;
	__kernel_base = .;

	.text : {
		KEEP(*(.text.boot));
		*(.text .text.*);
	}

	.rodata : {
		*(.rodata.*)
		. = ALIGN(4);
	}

	.data : {
		*(.data*);
		. = ALIGN(4);
	}

	.bss : {
		*(.bss*);
		. = ALIGN(4);
	}
}
