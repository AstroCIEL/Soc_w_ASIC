import sys
import os

def convert_hex_to_c_array(input_file, array_name):
    try:
        with open(input_file, 'r') as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"Error: File {input_file} not found.")
        return

    print(f"static const uint64_t {array_name}[] = {{")
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        # Pad line to multiple of 16 chars (64 bits)
        rem = len(line) % 16
        if rem != 0:
            line = '0' * (16 - rem) + line
            
        # Split into 16-char chunks
        # The hex string is Big Endian (MSB first).
        # We want to store it in memory such that the first 64-bit word contains the LSBs of the wide word.
        # So we split into chunks and reverse the order of chunks.
        line_chunks = [line[i:i+16] for i in range(0, len(line), 16)]
        line_chunks.reverse()
        
        for chunk in line_chunks:
            print(f"    0x{chunk}ULL,")
            
    print("};")

if __name__ == "__main__":
    input_path = "/input_hex.txt"
    if len(sys.argv) > 1:
        input_path = sys.argv[1]
        
    convert_hex_to_c_array(input_path, "input_data")
