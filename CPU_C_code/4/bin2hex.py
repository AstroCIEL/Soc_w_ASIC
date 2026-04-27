
import sys

in_file  = "test_sram.bin"
out_file = "test_sram.hex"

data = open(in_file, "rb").read()


words = []
for i in range(0, len(data), 8):
    chunk = data[i:i+8]
    if len(chunk) < 8:
        chunk = chunk + b'\x00' * (8 - len(chunk))
    val = int.from_bytes(chunk, byteorder="little")  
    words.append(val)

with open(out_file, "w") as f:
    for w in words:
        f.write(f"{w:016x}\n")  

print(f"wrote {len(words)} 64-bit words to", out_file)

