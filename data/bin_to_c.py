import sys
import os

def convert_bin_to_c_array(input_file, array_name):
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
            
        # Convert binary string to integer
        try:
            val = int(line, 2)
        except ValueError:
            print(f"// Warning: Skipping invalid line: {line}")
            continue
            
        # Print as 64-bit hex value
        print(f"    0x{val:016X}ULL,")
            
    print("};")

if __name__ == "__main__":
    input_path = "../instruction/ins.txt"
    if len(sys.argv) > 1:
        input_path = sys.argv[1]
        
    convert_bin_to_c_array(input_path, "ins_data")
