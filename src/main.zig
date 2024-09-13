const console = @import("console.zig");

export fn _start() linksection(".text.boot") callconv(.Naked) noreturn {
    console.setColors(.White, .Blue);
    console.clear();

    while (true) {}
}
