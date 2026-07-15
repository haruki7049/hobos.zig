const std = @import("std");

pub const console = @import("./console.zig");

test {
    std.testing.refAllDecls(console);
    try std.testing.expectEqual(0, 1);
}
