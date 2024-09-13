const console = @import("console.zig");

export fn _start() linksection(".text.boot") callconv(.Naked) noreturn {
    console.setColors(.White, .Blue);
    console.clear();
    console.putString("Hello, world");
    console.setForegroundColor(.LightRed);
    console.putChar('!');

    while (true) {}
}
