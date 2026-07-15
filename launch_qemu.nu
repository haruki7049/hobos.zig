#!/usr/bin/env nu

def main [] {
  let proj_root = $env.FILE_PWD
  cd $proj_root

  do -i { ^qemu-system-x86_64 -kernel ($proj_root | path join zig-out/bin/kernel.elf) }
  let retcode = $env.LAST_EXIT_CODE

  if $retcode == 0 {
    exit 0
  } else if $retcode == 3 {
    print "\nPASS"
    exit 0
  } else {
    print $"\nFAIL: QEMU returned ($retcode)"
    exit 1
  }
}
