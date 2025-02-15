{ writeShellApplication
, qemu_full
, hobos
}:

writeShellApplication {
  name = "runner";
  runtimeInputs = [
    qemu_full
  ];

  text = ''
    qemu-system-riscv32 -machine virt -bios default -serial mon:stdio -kernel ${hobos}/bin/hobos.elf
  '';
}
