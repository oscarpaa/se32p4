CROSS = riscv32-unknown-elf
CCPATH = /opt/riscv/bin
ARCH = rv32ic
ABI = ilp32

APP = sort

CC = $(CCPATH)/$(CROSS)-gcc
AS = $(CCPATH)/$(CROSS)-as
LD = $(CC)
OC = $(CCPATH)/$(CROSS)-objcopy
OD = $(CCPATH)/$(CROSS)-objdump

PROJ = app
LIBS_PATH = ./libs

CFLAGS  = -Os -Wall -march=$(ARCH) -mabi=$(ABI) -I$(LIBS_PATH)/inc --specs=nano.specs
ASFLAGS = -march=$(ARCH)
LDFLAGS = -T link.ld -march=$(ARCH) -mabi=$(ABI) -nostartfiles -nostdlib -lc_nano -lgcc -Wl,--no-warn-rwx-segments,-m,elf32lriscv,-Map=$(PROJ).map

OCFLAGS = -O binary
ODFLAGS = -d

APP_PATH = ./apps/$(APP)/main.c
SRCS = $(APP_PATH) $(wildcard $(LIBS_PATH)/*.c) banner.c
ASMS = $(SRCS:.c=.s) crt0.s
OBJS = $(ASMS:.s=.o)

.PHONY: clean all

all: $(PROJ).mem

%.s: %.c
	$(CC) $(CFLAGS) -S $< -o $@

%.o: %.s
	$(AS) $(ASFLAGS) -c $< -o $@

$(PROJ).o: $(OBJS) link.ld
	$(LD) $(OBJS) $(LDFLAGS) -o $@
	$(OD) $(ODFLAGS) $@ > $(PROJ).lst

$(PROJ).mem: $(PROJ).o
	$(OC) $(OCFLAGS) $< $(PROJ).bin
	hexdump -ve '1/2 "%04x\n"' $(PROJ).bin > $@
	wc -l $@
	@echo mem ok.

clean:
	rm -f $(filter-out crt0.s,$(ASMS)) $(OBJS) $(PROJ).bin $(PROJ).mem $(PROJ).o $(PROJ).lst $(PROJ).map
