export PATH := $(abspath tools/x86_64-elf-cross/bin):$(PATH)






OS_NAME = uefios

BUILD_DIR = $(abspath build)
SOURCE_DIR = $(abspath src)
DATA_DIR = $(abspath files)

OVMF_BINARIES_DIR = ovmf-bins
GNU_EFI_DIR = gnu-efi

EFI_TARGET = loader.efi
ELF_TARGET = kernel.elf

EMU = qemu-system-x86_64
DBG = gdb
CC = x86_64-elf-gcc
AC = nasm
LD = x86_64-elf-ld

LDS = $(abspath src/kernel/Linker.ld)

EMU_BASE_FLAGS = -drive file=$(BUILD_DIR)/$(OS_NAME).img,format=raw \
				-m 256M \
				-cpu qemu64 \
				-vga std \
				-drive if=pflash,format=raw,unit=0,file="$(OVMF_BINARIES_DIR)/OVMF_CODE-pure-efi.fd",readonly=on \
				-drive if=pflash,format=raw,unit=1,file="$(OVMF_BINARIES_DIR)/OVMF_VARS-pure-efi.fd" \
				-net none \
				-machine q35

EMU_DBG_FLAGS = -s -d guest_errors,cpu_reset,int -no-reboot -no-shutdown

DBG_FLAGS = -ex "target remote localhost:1234" \
			-ex "symbol-file $(BUILD_DIR)/kernel/$(ELF_TARGET)" \
			-ex "set disassemble-next-line on" \
			-ex "set step-mode on"

CFLAGS = -g -ffreestanding -fshort-wchar -mno-red-zone -m64 -Wall -Werror -nostdlib -nostdinc \
		-fno-builtin -fno-stack-protector -nostartfiles -nodefaultlibs

ACFLAGS = -f elf64

LDFLAGS = -T $(LDS) -static -Bsymbolic -nostdlib






partial: build update-img

all: init-img startup-nsh build-gnu-efi partial

build: build-bootloader build-kernel

build-gnu-efi:
	$(MAKE) -C $(GNU_EFI_DIR) all

build-bootloader:
	@mkdir -p $(BUILD_DIR)
	$(MAKE) -C $(SOURCE_DIR)/bootloader EFI_TARGET="$(EFI_TARGET)" BUILD_DIR="$(BUILD_DIR)/bootloader" all
	$(MAKE) -C $(SOURCE_DIR)/bootloader EFI_TARGET="$(EFI_TARGET).debug" BUILD_DIR="$(BUILD_DIR)/bootloader" all

build-kernel:
	@mkdir -p $(BUILD_DIR)
	$(MAKE) -C $(SOURCE_DIR)/kernel ELF_TARGET="$(ELF_TARGET)" \
									BUILD_DIR="$(BUILD_DIR)/kernel" \
									CC="$(CC)" \
									LD="$(LD)" \
									AC="$(AC)" \
									CFLAGS="$(CFLAGS)" \
									LDFLAGS="$(LDFLAGS)" \
									ACFLAGS="$(ACFLAGS)" \
									all

update-img:
	mformat -i $(BUILD_DIR)/$(OS_NAME).img -F ::
	mmd -i $(BUILD_DIR)/$(OS_NAME).img ::/EFI
	mmd -i $(BUILD_DIR)/$(OS_NAME).img ::/EFI/BOOT
	mcopy -i $(BUILD_DIR)/$(OS_NAME).img $(BUILD_DIR)/bootloader/$(EFI_TARGET) ::/EFI/BOOT
	mcopy -i $(BUILD_DIR)/$(OS_NAME).img $(BUILD_DIR)/bootloader/startup.nsh ::
	mcopy -i $(BUILD_DIR)/$(OS_NAME).img $(BUILD_DIR)/kernel/$(ELF_TARGET) ::
	mcopy -si $(BUILD_DIR)/$(OS_NAME).img $(DATA_DIR)/* ::

init-img:
	@mkdir -p $(BUILD_DIR)
	dd if=/dev/zero of=$(BUILD_DIR)/$(OS_NAME).img bs=512 count=93750

run:
	$(EMU) $(EMU_BASE_FLAGS)

debug:
	$(EMU) $(EMU_BASE_FLAGS) $(EMU_DBG_FLAGS) &
	$(DBG) $(DBG_FLAGS)

clean-all: clean
	$(MAKE) -C gnu-efi clean
	rm -rf $(BUILD_DIR)

clean:
	find $(SOURCE_DIR) -name "*.o" -type f -delete
	find $(BUILD_DIR) -name "*.o" -type f -delete
	find $(BUILD_DIR) -name "*.so" -type f -delete
	find $(BUILD_DIR) -name "*.efi" -type f -delete
	find $(BUILD_DIR) -name "*.efi.debug" -type f -delete
	find $(BUILD_DIR) -name "*.elf" -type f -delete

startup-nsh:
	@mkdir -p $(BUILD_DIR)/bootloader
	printf "@echo -off\n\
	mode 80 25\n\
	cls\n\
	if exists .\EFI\BOOT\$(EFI_TARGET) then\n\
		.\EFI\BOOT\$(EFI_TARGET)\n\
		goto END\n\
	endif\n\
	if exists FS0:\EFI\BOOT\$(EFI_TARGET) then\n\
		FS0:\n\
		echo \"Found bootloader on FS0.\"\n\
		EFI\BOOT\$(EFI_TARGET)\n\
		goto END\n\
	endif\n\
	if exists FS1:\EFI\BOOT\$(EFI_TARGET) then\n\
		FS1:\n\
		echo \"Found bootloader on FS1.\"\n\
		EFI\BOOT\$(EFI_TARGET)\n\
		goto END\n\
	endif\n\
	if exists FS2:\EFI\BOOT\$(EFI_TARGET) then\n\
		FS2:\n\
		echo \"Found bootloader on FS2.\"\n\
		EFI\BOOT\$(EFI_TARGET)\n\
		goto END\n\
	endif\n\
	if exists FS3:\EFI\BOOT\$(EFI_TARGET) then\n\
		FS3:\n\
		echo \"Found bootloader on FS3.\"\n\
		EFI\BOOT\$(EFI_TARGET)\n\
		goto END\n\
	endif\n\
	if exists FS4:\EFI\BOOT\$(EFI_TARGET) then\n\
		FS4:\n\
		echo \"Found bootloader on FS4.\"\n\
		EFI\BOOT\$(EFI_TARGET)\n\
		goto END\n\
	endif\n\
	if exists FS5:\EFI\BOOT\$(EFI_TARGET) then\n\
		FS5:\n\
		echo \"Found bootloader on FS5.\"\n\
		EFI\BOOT\$(EFI_TARGET)\n\
		goto END\n\
	endif\n\
	if exists FS6:\EFI\BOOT\$(EFI_TARGET) then\n\
		FS6:\n\
		echo \"Found bootloader on FS6.\"\n\
		EFI\BOOT\$(EFI_TARGET)\n\
		goto END\n\
	endif\n\
	if exists FS7:\EFI\BOOT\$(EFI_TARGET) then\n\
		FS7:\n\
		echo \"Found bootloader on FS7.\"\n\
		EFI\BOOT\$(EFI_TARGET)\n\
		goto END\n\
	endif\n\
	echo \"Unable to find bootloader.\"\n\
	:END" > $(BUILD_DIR)/bootloader/startup.nsh