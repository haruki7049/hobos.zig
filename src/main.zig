const std = @import("std");

pub fn main() noreturn {
    _ = std.os.uefi.handle;
    _ = std.os.uefi.system_table;

    while (true) {
        asm volatile ("hlt");
    }
}
