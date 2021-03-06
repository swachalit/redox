build/bootloader: bootloader/$(ARCH)/**
	mkdir -p build
	nasm -f bin -o $@ -D ARCH_$(ARCH) -ibootloader/$(ARCH)/ bootloader/$(ARCH)/disk.asm

build/harddrive.bin: build/filesystem.bin bootloader/$(ARCH)/**
	nasm -f bin -o $@ -D ARCH_$(ARCH) -D FILESYSTEM=$< -ibootloader/$(ARCH)/ bootloader/$(ARCH)/disk.asm

build/harddrive.bin.gz: build/harddrive.bin
	gzip -k -f $<

build/livedisk.bin: build/kernel_live bootloader/$(ARCH)/**
	nasm -f bin -o $@ -D ARCH_$(ARCH) -D KERNEL=$< -ibootloader/$(ARCH)/ bootloader/$(ARCH)/disk.asm

build/livedisk.bin.gz: build/livedisk.bin
	gzip -k -f $<

build/livedisk.iso: build/livedisk.bin.gz
	rm -rf build/iso/
	mkdir -p build/iso/
	cp -RL isolinux build/iso/
	cp $< build/iso/livedisk.gz
	genisoimage -o $@ -b isolinux/isolinux.bin -c isolinux/boot.cat \
					-no-emul-boot -boot-load-size 4 -boot-info-table \
					build/iso/
	isohybrid $@
