### synch cells Constraints
# Use wildcard matching directly (XDC doesn't support foreach loops)
set_max_delay -through [get_pins -hierarchical -filter {NAME=~"*sync*/*reg_q_reg[0]/D"}] 20.000
set_false_path -hold -through [get_pins -hierarchical -filter {NAME=~"*sync*/*reg_q_reg[0]/D"}]

