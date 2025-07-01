const console = @import("console.zig");

export fn panic() void {}

export fn _start() linksection(".text.boot") void {
    @call(.auto, kmain, .{});

    while (true) {}
}

fn kmain() void {
    console.initialize();
    console.puts("Hello world!");
}
