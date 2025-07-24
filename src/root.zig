const Console = @import("console.zig");

const MultibootHeader = extern struct {
    magic: u32,
    flags: u32,
    checksum: u32,
};

export const multiboot_header align(4) linksection(".multiboot") = multiboot: {
    const MAGIC: u32 = 0x1BADB002;
    const ALIGN: u32 = 1 << 0;
    const MEMINFO: u32 = 1 << 1;
    const FLAGS: u32 = ALIGN | MEMINFO;

    break :multiboot MultibootHeader{
        .magic = MAGIC,
        .flags = FLAGS,
        .checksum = ~(MAGIC +% FLAGS) +% 1,
    };
};

export var stack_bytes: [16 * 1024]u8 align(16) linksection(".bss") = undefined;
const stack_bytes_slice = stack_bytes[0..];

export fn _start() void {
    asm volatile (
        \\ push %rbp
        \\ jmp %[start:P]
        :
        : [start] "X" (&kmain),
    );
}

fn kmain() void {
    const console: Console = Console.new();
    console.putCharAt('H', 15, 1, 1);

    while (true) {}
}
