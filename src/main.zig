const std = @import("std");
const uefi = std.os.uefi;
const GraphicsOutput = uefi.protocol.GraphicsOutput;

pub fn main() noreturn {
    const graphics_output = locate_graphics_protocol().?;
    const vram_addr = graphics_output.mode.frame_buffer_base;
    const vram_byte_size = graphics_output.mode.frame_buffer_size;
    var vram: []u32 = @as([*]u32, @ptrFromInt(vram_addr))[0 .. vram_byte_size / @sizeOf(u32)];
    for (0..vram.len) |i| {
        vram[i] = 0xffffff;
    }

    while (true) {
        asm volatile ("hlt");
    }
}

const EfiVoid = u8;

fn locate_graphics_protocol() ?*GraphicsOutput {
    var gop: ?*uefi.protocol.GraphicsOutput = null;
    const boot_services = uefi.system_table.boot_services orelse return null;

    // Locate the protocol
    const status = boot_services.locateProtocol(
        &GraphicsOutput.guid,
        null,
        // The interface is returned as *?*anyopaque
        @ptrCast(&gop),
    );

    if (status != .success) return null;

    return gop;
}
