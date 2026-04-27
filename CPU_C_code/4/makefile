RISCV :=/home/EDAtools/Xilinx/Vivado/2024.2/gnu/riscv/lin/riscv64-unknown-elf/bin



all:
	$(RISCV)/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -nostdlib -nostartfiles -ffreestanding  -mcmodel=medany -fno-pic -fno-pie -T test_sram.ld -o test_sram.elf start.S test_sram.c

	$(RISCV)/riscv64-unknown-elf-objcopy -O binary test_sram.elf test_sram.bin

	python3 bin2hex.py
	
	$(RISCV)/riscv64-unknown-elf-objdump -D test_sram.elf > test_sram.lst

clean:
	rm *.bin *.lst *.hex *.elf


