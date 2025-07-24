const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const Writer = std.io.Writer;
const Self = @This();

const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;
const VGA_SIZE = VGA_WIDTH * VGA_HEIGHT;

pub const ConsoleColors = enum(u8) {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGray = 7,
    DarkGray = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    LightBrown = 14,
    White = 15,
};

row: usize = 0,
column: usize = 0,
color: u8 = vgaEntryColor(ConsoleColors.White, ConsoleColors.Black),
buffer: [*]volatile u16 = @ptrFromInt(0xB8000),

fn vgaEntryColor(fg: ConsoleColors, bg: ConsoleColors) u8 {
    return @intFromEnum(fg) | (@intFromEnum(bg) << 4);
}

fn vgaEntry(uc: u8, new_color: u8) u16 {
    const c: u16 = new_color;

    return uc | (c << 8);
}

pub fn new() Self {
    const self = Self{};
    clear(self);

    return self;
}

pub fn clear(self: Self) void {
    @memset(self.buffer[0..VGA_SIZE], vgaEntry(' ', self.color));
}

pub fn putCharAt(self: Self, c: u8, new_color: u8, x: usize, y: usize) void {
    const index = y * VGA_WIDTH + x;
    self.buffer[index] = vgaEntry(c, new_color);
}

pub fn putChar(self: Self, c: u8) void {
    self.putCharAt(c, self.color, self.column, self.row);
    self.column += 1;
    if (self.column == VGA_WIDTH) {
        self.column = 0;
        self.row += 1;
        if (self.row == VGA_HEIGHT)
            self.row = 0;
    }
}

pub fn puts(self: Self, data: []const u8) void {
    for (data) |c|
        putChar(self, c);
}
