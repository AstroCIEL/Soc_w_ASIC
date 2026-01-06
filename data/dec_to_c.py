import sys
import os

def convert_dec_to_c_array(input_file, array_name):
    try:
        with open(input_file, 'r') as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"Error: File {input_file} not found.")
        return

    print(f"static const int8_t {array_name}[] = {{")
    
    for line in lines:
        line = line.strip()
        if not line or line.startswith('#'):
            continue
            
        # Split line by spaces to get individual numbers
        numbers = line.split()
        row_str = []
        
        for num_str in numbers:
            try:
                val = int(num_str)
                row_str.append(str(val))
            except ValueError:
                continue
        
        if row_str:
            print(f"    {', '.join(row_str)},")
            
    print("};")

if __name__ == "__main__":
    input_path = "../data/layer1_output_before_relu.txt"
    if len(sys.argv) > 1:
        input_path = sys.argv[1]
        
    convert_dec_to_c_array(input_path, "golden_result")
