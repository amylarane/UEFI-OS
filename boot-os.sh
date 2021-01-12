#! /bin/bash

qemu-system-x86_64 -enable-kvm \
	-m 2G \
	-drive if=pflash,format=raw,readonly,file=./ovmf/OVMF_CODE.fd \
	-drive if=pflash,format=raw,file=./ovmf/OVMF_VARS.fd \
	-drive file=fat:rw:.,format=raw 2>/dev/null
