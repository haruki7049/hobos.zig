pub fn main() noreturn {
    while (true) {
        asm volatile ("hlt");
    }
}
