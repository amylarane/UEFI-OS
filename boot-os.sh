#! /bin/bash

qemu-system-x86_64 -bios "OVMF.fd" -drive file=fat:rw:.,format=raw 2>/dev/null
