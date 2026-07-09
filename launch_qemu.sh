#!/bin/sh -e

PROJ_ROOT="$(dirname $(dirname ${BASH_SOURCE:-$0}))"
cd "${PROJ_ROOT}"

qemu-system-x86_64 -kernel zig-out/bin/kernel.elf

RETCODE=$?
set -e

if [ $RETCODE -eq 0 ]; then
  exit 0
elif [ $RETCODE -eq 3 ]; then
  printf "\nPASS\n"
  exit 0
else
  printf "\nFAIL: QEMU returned $RETCODE\n"
  exit 1
fi
