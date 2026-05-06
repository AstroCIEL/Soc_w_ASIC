// Minimal fesvr/elf.h stub for simulation
#ifndef FESVR_ELF_H
#define FESVR_ELF_H

#include <stdint.h>
#include <stdlib.h>

typedef uint64_t reg_t;

class elf_t {
public:
    elf_t() {}
    ~elf_t() {}
    
    static elf_t* from_buffer(const char* buffer, size_t len) {
        (void)buffer;
        (void)len;
        return new elf_t();
    }
    
    size_t get_num_sections() { return 0; }
    reg_t get_section_addr(size_t i) {
        (void)i;
        return 0;
    }
    reg_t get_section_size(size_t i) {
        (void)i;
        return 0;
    }
    const char* get_section_name(size_t i) {
        (void)i;
        return "";
    }
    void* get_section_data(size_t i) {
        (void)i;
        return nullptr;
    }
    reg_t get_entry() { return 0; }
};

#endif
