const std = @import("std");
const uefi = std.os.uefi;
const GraphicsOutput = uefi.protocol.GraphicsOutput;

pub fn main() noreturn {
    const graphics_output = locate_graphics_protocol() catch |err| {
        @panic(err);
    } orelse {
        @panic("The GraphicsOutput is null");
    };
    const vram_addr = graphics_output.mode.frame_buffer_base;
    const vram_byte_size = graphics_output.mode.frame_buffer_size;
    var vram: []u32 = @as([*]u32, @ptrFromInt(vram_addr))[0 .. vram_byte_size / @sizeOf(u32)];
    mainloop(&vram);

    while (true) {
        asm volatile ("hlt");
    }
}

fn mainloop(vram: *[]u32) void {
    var color: Color = Color.zero();

    while (true) {
        manage_color(&color);
        fill_color(vram, color);
    }
}

const Color = packed struct {
    const Self = @This();

    r: u8,
    g: u8,
    b: u8,
    a: u8,

    pub fn red() Self {
        return .{
            .r = 0,
            .g = 0,
            .b = 0,
            .a = 255,
        };
    }

    pub fn green() Self {
        return .{
            .r = 0,
            .g = 255,
            .b = 0,
            .a = 0,
        };
    }

    pub fn blue() Self {
        return .{
            .r = 0,
            .g = 0,
            .b = 255,
            .a = 0,
        };
    }

    pub fn zero() Self {
        return .{
            .r = 0,
            .g = 0,
            .b = 0,
            .a = 0,
        };
    }
};

fn manage_color(color: *Color) void {
    if (color.r == 255) {
        color.*.r = 0;
    }
    if (color.g == 255) {
        color.*.g = 0;
    }
    if (color.b == 255) {
        color.*.b = 0;
    }

    color.*.r += 1;
    color.*.g += 1;
    color.*.b += 1;
}

fn fill_color(vram: *[]u32, color: Color) void {
    for (0..vram.len) |i| {
        vram.*[i] = @bitCast(color);
    }
}

const EfiVoid = u8;

fn locate_graphics_protocol() !?*GraphicsOutput {
    var gop: ?*uefi.protocol.GraphicsOutput = null;
    const boot_services = uefi.system_table.boot_services orelse return null;
    const status = boot_services.locateProtocol(
        &GraphicsOutput.guid,
        null,
        @ptrCast(&gop),
    );

    if (status != .success) return null;

    return gop;
}
