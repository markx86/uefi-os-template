CC = x86_64-elf-gcc
AC = nasm
LD = x86_64-elf-ld

LDS = Linker.ld

BUILD_DIR = .
SOURCE_DIR = .
LIBC_DIR = $(SOURCE_DIR)/../libc

ELF_TARGET = kernel.elf

C_SRCS = $(shell find $(SOURCE_DIR) -name '*.c') $(shell find $(LIBC_DIR) -name '*.c')
C_HDRS = $(shell find $(SOURCE_DIR) -name '*.h') $(shell find $(LIBC_DIR) -name '*.h')
C_OBJS = $(patsubst $(SOURCE_DIR)%.c, $(BUILD_DIR)%.o, $(C_SRCS))

ASM_SRCS = $(shell find $(SOURCE_DIR) -name '*.asm')
ASM_OBJS = $(patsubst $(SOURCE_DIR)%.asm, $(BUILD_DIR)%_asm.o, $(ASM_SRCS))

# Default flags
CFLAGS = -g -ffreestanding -fshort-wchar -mno-red-zone -m64 -Wall -Werror -nostdlib -nostdinc \
		-fno-builtin -fno-stack-protector -nostartfiles -nodefaultlibs
ACFLAGS = -f elf64
LDFLAGS = -T $(LDS) -static -Bsymbolic -nostdlib

all: $(C_OBJS) $(ASM_OBJS)
	$(LD) $(LDFLAGS) -o $(BUILD_DIR)/$(ELF_TARGET) $(C_OBJS) $(ASM_OBJS)

$(BUILD_DIR)/%.o: $(SOURCE_DIR)/%.c $(C_HDRS)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -I$(abspath $(LIBC_DIR)) -c $< -o $@

$(BUILD_DIR)/%_asm.o: $(SOURCE_DIR)/%.asm
	@mkdir -p $(dir $@)
	$(AC) $(ACFLAGS) -o $@ $<