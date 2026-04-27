# CVA6 SRAM读写测试

项目路径：EDA01上/data/home/x_long32/data_share/SOC_CVA6_ORI

## 将SRAM挂载到AXI总线上

### RTL代码修改

#### 增加文件

|文件 | 路径 | 说明|
|---|---|---|
|sram_1024_64_lx.v | src/sram/sram_1024_64_lx/sram_1024_64_lx.v | 需要接上去的sram文件，1024x64，单端口|
|sram_1024_64_wrapper.sv | src/sram/sram_1024_64_lx/sram_1024_64_wrapper.sv | 模仿TPU里面的main_mem_wrapper写了一个sram_1024_64_lx的wrapper，用于在soc.sv里面对接axi2mem|

#### 修改的代码

1. soc_pkg.sv中给sram_1024_64_lx增加地址分配和slave端口。

```sv
  typedef enum int unsigned {
        Debug       = 0,
        ROM         = 1,
        CLINT       = 2,
        PLIC        = 3,
        Timer       = 4,
        DCO         = 5,
        CIM         = 6,
        SRAM        = 7,
        SRAM_1024_64 = 8 //新增的sram_1024_64_lx的slave
  } axi_slaves_t;
  localparam NB_PERIPHERALS = SRAM_1024_64 + 1; //外设数量修改
  
  ……
  
    typedef enum logic [63:0] {
    DebugBase    = 64'h0000_0000,
    ROMBase      = 64'h0001_0000,
    CLINTBase    = 64'h0200_0000,
    PLICBase     = 64'h0C00_0000,
    TimerBase    = 64'h1800_0000,
    DCOBase      = 64'h2000_0000,
    CIMBase      = 64'h3000_0000,
    SRAMBase     = 64'h8000_0000,
    SRAM_1024_64Base = 64'hC000_0000
  } soc_bus_start_t;
```

增加基地址和内存大小设置：

```sv
  //sram_1024_64_lx的大小,1024*8byte=2^13
  localparam logic[63:0] SRAM_1024_64Length = 64'h2000;
 typedef enum logic [63:0] {
    DebugBase    = 64'h0000_0000,
    ROMBase      = 64'h0001_0000,
    CLINTBase    = 64'h0200_0000,
    PLICBase     = 64'h0C00_0000,
    TimerBase    = 64'h1800_0000,
    DCOBase      = 64'h2000_0000,
    CIMBase      = 64'h3000_0000,
    SRAMBase     = 64'h8000_0000,
    SRAM_1024_64Base = 64'hC000_0000  //新增的sram的基地址
  } soc_bus_start_t;
```

2. soc.sv：
addr_map增加自己接上去的sram，要和soc_pkg.sv命名一致。

```sv
axi_pkg::xbar_rule_64_t [soc_pkg::NB_PERIPHERALS-1:0] addr_map;
//增加sram_1024_64_lx的addr_map
assign addr_map = '{
  '{ idx: soc_pkg::Debug,    start_addr: soc_pkg::DebugBase,    end_addr: soc_pkg::DebugBase + soc_pkg::DebugLength  },
  '{ idx: soc_pkg::ROM,      start_addr: soc_pkg::ROMBase,      end_addr: soc_pkg::ROMBase + soc_pkg::ROMLength      },
  '{ idx: soc_pkg::CLINT,    start_addr: soc_pkg::CLINTBase,    end_addr: soc_pkg::CLINTBase + soc_pkg::CLINTLength  },
  '{ idx: soc_pkg::PLIC,     start_addr: soc_pkg::PLICBase,     end_addr: soc_pkg::PLICBase + soc_pkg::PLICLength    },
  '{ idx: soc_pkg::Timer,    start_addr: soc_pkg::TimerBase,    end_addr: soc_pkg::TimerBase + soc_pkg::TimerLength  },
  '{ idx: soc_pkg::DCO,      start_addr: soc_pkg::DCOBase,      end_addr: soc_pkg::DCOBase + soc_pkg::DCOLength      },
  '{ idx: soc_pkg::CIM,      start_addr: soc_pkg::CIMBase,      end_addr: soc_pkg::CIMBase + soc_pkg::CIMLength      },
  '{ idx: soc_pkg::SRAM,     start_addr: soc_pkg::SRAMBase,     end_addr: soc_pkg::SRAMBase + soc_pkg::SRAMLength    },
  '{ idx: soc_pkg::SRAM_1024_64, start_addr: soc_pkg::SRAM_1024_64Base, end_addr: soc_pkg::SRAM_1024_64Base + soc_pkg::SRAM_1024_64Length}
};
```

实例化axi2mem和wrapper，把sram接到axi上：

```sv
// ---------------
// 使用 sram_1024_64_wrapper 挂载 SRAM (sram_1024_64_lx, 64-bit) 
// ---------------
logic                       sram_req;
logic                       sram_we;
logic [AxiAddrWidth-1:0]    sram_addr;
logic [AxiDataWidth/8-1:0]  sram_be;
logic [AxiDataWidth-1:0]    sram_wdata;
logic [AxiDataWidth-1:0]    sram_rdata;
logic [AxiUserWidth-1:0]    sram_ruser;

assign sram_ruser = '0;

axi2mem #(
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_USER_WIDTH ( AxiUserWidth     )
) i_axi2sram (
    .clk_i  ( clk                     ),
    .rst_ni ( ndmreset_n              ),
    .slave  ( master[soc_pkg::SRAM_1024_64]   ),
    .req_o  ( sram_req                ),
    .we_o   ( sram_we                 ),
    .addr_o ( sram_addr               ),
    .be_o   ( sram_be                 ),
    .user_o (                         ),
    .data_o ( sram_wdata              ),
    .user_i ( sram_ruser              ),
    .data_i ( sram_rdata              )
);

sram_1024_64_wrapper #(
    .AXI_ADDR_WIDTH   ( AxiAddrWidth   ),
    .AXI_DATA_WIDTH   ( AxiDataWidth   ),
    .AXI_ADDR_OFFSET  ( 3              ),
    .NUM_MACROS       ( 1              ),
    .MACRO_ADDR_WIDTH ( 10             )
) i_sram_1024_64_wrapper (
    .clk_i           ( clk             ),
    .rstn_i          ( ndmreset_n      ),
    .axi_req_i       ( sram_req        ),
    .axi_write_en_i  ( sram_we         ),
    .axi_addr_i      ( sram_addr       ),
    .axi_byte_en_i   ( sram_be         ),
    .axi_wdata_i     ( sram_wdata      ),
    .axi_rdata_o     ( sram_rdata      )
);
```

## 测试CPU对SRAM的读写

### 软件代码

1. 在SOC_CVA6_ORI下新建CPU_C_code文件夹，增加了一个test_sram.c文件。

```c
//////////////////////////////////////////////////////////////////////////////////
// Description:     Simple SRAM Read/Write test for CVA6 SoC
//////////////////////////////////////////////////////////////////////////////////

#include <stdint.h>
#include <stddef.h>

// ------------------------------
// 地址映射（来自 cva6-eda/soc_pkg.sv）
// ------------------------------

// soc_pkg::SRAMBase = 0x8000_0000
#define MAIN_MEM_ADDR    0x80000000UL

// 测试数据区：放在sram_1024_64_lx的地址空间
#define TEST_DATA_BASE    0xC0000000UL
#define TEST_WORD_NUM     256UL   // 256 * 8B = 2KB

// 日志与标志位
#define LOG_BASE_ADDR     (MAIN_MEM_ADDR + 0x0C00UL)  // 测试数据区之后
#define ERROR_FLAG_ADDR   (MAIN_MEM_ADDR + 0x1000UL)

int main(void)
{
    // 测试数据写/读到 TEST_DATA_BASE
    volatile uint64_t* const sram =
        (volatile uint64_t* const)(uintptr_t)TEST_DATA_BASE;
    volatile uint64_t* const log_ptr = 
        (volatile uint64_t* const)(uintptr_t)LOG_BASE_ADDR;
    volatile uint64_t* const error_flag =
        (volatile uint64_t* const)(uintptr_t)ERROR_FLAG_ADDR;

    // 先清掉 error_flag
    *error_flag = 0ULL;

    // 1) 写入测试数据
    for (uint64_t i = 0; i < TEST_WORD_NUM; ++i) {
        // 构造一个容易识别的图案：高 32bit = index，低 32bit = 固定常数
        uint64_t pattern = (i << 32) | 0xA5A5A5A5UL;
        sram[i] = pattern;
    } 
    // 2) 读回校验
    uint64_t error_count = 0;
    for (uint64_t i = 0; i < TEST_WORD_NUM; ++i) {
        uint64_t expected = (i << 32) | 0xA5A5A5A5UL;
        uint64_t readback = sram[i];

        if (readback != expected) {
            // 只记录前几个错误
            if (error_count < 4) {
                log_ptr[error_count * 3 + 0] = i;         // 出错 index
                log_ptr[error_count * 3 + 1] = expected;  // 期望值
                log_ptr[error_count * 3 + 2] = readback;  // 读回值
            }
            error_count++;
        }
    }

    if (error_count == 0) {
        // PASS：约定一个固定值
        *error_flag = 0x1234567812345678ULL;
    } else {
        // FAIL：记录错误个数 + 特殊标记
        log_ptr[32] = error_count; // 额外记一下一共多少错
        *error_flag = 0xDEADBEEFDEADBEEFULL;
    }

    return 0;
}
```

2. 在CPU_C_code文件夹下新建start.S和test_sram.ld文件用于编译。

```
/* 适配 boot_addr_i=ROMBase：CPU 从 ROM 启动，bootrom 跳 0x8000_0000；
   程序整体链接在 RAM，TB 将 hex 载入 主存SRAM 后从 0x8000_0000 执行 */
MEMORY
{
  RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 8K /*LENGTH可以根据主存的大小修改，基地址只要不变不用修改。*/
}

SECTIONS
{
  /DISCARD/ : {
    *(.note.gnu.build-id)
    *(.note*)
  }

  .text : {
    *(.text.entry)
    *(.text*)
    *(.rodata*)
  } > RAM

  .data : {
    *(.data*)
    *(.sdata*)
  } > RAM

  .bss (NOLOAD) : {
    __bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(COMMON)
    __bss_end = .;
  } > RAM
}
```

```
    .section .text.entry
    .globl _start
_start:
    la   sp, __stack_top   

    call main             

.Lhang:
    wfi
    j    .Lhang

    

     .section .bss.stack, "aw", @nobits
    .align 12                  /* 2^12 = 4096-byte align */

    .globl __stack_bottom
__stack_bottom:
    .space 0x1000              /* 4 KB stack 如果运行别的更长的文件，需要增大栈的空间，修改space，其他地方不用改*/

    .globl __stack_top
__stack_top:
```

3. 增加bin2hex.py用于将bin文件转换为hex文件。

```python
python3 - << 'EOF'
import sys

in_file  = "test_sram.bin"
out_file = "test_sram.hex"

data = open(in_file, "rb").read()

# 按 8 字节（64bit）一组，不足 8 字节的最后一组补 0
words = []
for i in range(0, len(data), 8):
    chunk = data[i:i+8]
    if len(chunk) < 8:
        chunk = chunk + b'\x00' * (8 - len(chunk))
    val = int.from_bytes(chunk, byteorder="little")  # RISC-V 是 little-endian
    words.append(val)

with open(out_file, "w") as f:
    for w in words:
        f.write(f"{w:016x}\n")  # 每行 16 个十六进制字符，对应 64bit

print(f"wrote {len(words)} 64-bit words to", out_file)
EOF
```

4. 增加makefile，把编译产生hex的指令放进去。

```makefile
RISCV :=/home/EDAtools/Xilinx/Vivado/2024.2/gnu/riscv/lin/riscv64-unknown-elf/bin #临时把编译器路径添加到当前终端PATH

all:
    #用gcc编译生成elf 
    $(RISCV)/riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d -nostdlib -nostartfiles -ffreestanding  -mcmodel=medany -fno-pic -fno-pie -T test_sram.ld -o test_sram.elf start.S test_sram.c
    #objcopy转换为bin
    $(RISCV)/riscv64-unknown-elf-objcopy -O binary test_sram.elf test_sram.bin
    #调用python转换为hex
    python3 bin2hex.py
    #objdump反编译hex，可以看到实际的指令，以及start位置。
    $(RISCV)/riscv64-unknown-elf-objdump -D test_sram.elf > test_sram.lst

clean:
    rm *.bin *.lst *.hex *.elf
```

make all生成test_sram.hex文件。

### 硬件代码

1. 在sim文件夹下新增testbench：cpu_sram_tb.sv。

```sv
`timescale 1ns/1ps

module cpu_sram_tb;

  // 时钟 & 复位
  logic clk;
  logic rst_n;

  // DCO 观测口（SIM 下才有）
  logic [5:0] dco_cc_sel_o;
  logic [5:0] dco_fc_sel_o;
  logic [1:0] dco_freq_sel_o;
  logic [2:0] dco_div_sel_o;

  // 其余顶层 IO
  logic clk_led;
  logic tck, tms, tdi;
  logic tdo;
  logic ext_clk;
  logic dco_en;
  logic clk_sel;
  logic div_rst_n;

  // DUT 实例
  soc i_soc (
  `ifdef SIM
    .clk           ( clk            ),
    .dco_cc_sel_o  ( dco_cc_sel_o   ),
    .dco_fc_sel_o  ( dco_fc_sel_o   ),
    .dco_freq_sel_o( dco_freq_sel_o ),
    .dco_div_sel_o ( dco_div_sel_o  ),
  `endif
    .rst_n         ( rst_n          ),
    .clk_led       ( clk_led        ),
    .tck           ( tck            ),
    .tms           ( tms            ),
    .tdi           ( tdi            ),
    .tdo           ( tdo            ),
    .ext_clk       ( ext_clk        ),
    .dco_en        ( dco_en         ),
    .clk_sel       ( clk_sel        ),
    .div_rst_n     ( div_rst_n      )
  );

  // 50 MHz 时钟
  initial clk = 1'b0;
  always #10 clk = ~clk;

  initial begin
    $fsdbDumpfile("cpu_sram_tb.fsdb");
    $fsdbDumpvars(0, cpu_sram_tb);
  end

  // 其他 IO 默认拉成安全值
  initial begin
    tck       = 1'b0;
    tms       = 1'b0;
    tdi       = 1'b0;
    ext_clk   = 1'b0;
    dco_en    = 1'b0;
    clk_sel   = 1'b0;
    div_rst_n = 1'b1;
  end

  // 复位流程
  initial begin
    rst_n = 1'b0;
    repeat (10) @(posedge clk);
    rst_n = 1'b1;

    #20;
    // 指令+数据均在 SRAM：将 test_sram.hex 载入 主存SRAM 低地址，CPU 从 SRAM 取指；数据放在sram_1024_64_lx
    //makefile里面有SIM,用的是tc_sram.sv，存储是sram[1023:0] 
    // $display("[TB] Loading test_sram.hex into main mem...");
    // $readmemh("../../CPU_C_code/test_sram.hex", i_soc.i_sram.gen_cut[0].i_tc_sram_wrapper.i_tc_sram.sram);
    // $display("[TB] Load done.");

  end

  // 监视 ERROR_FLAG_ADDR = 0x8000_1000 （word index = 512）
  localparam int ERROR_WORD_INDEX = 512;

  initial begin
    logic [63:0]  error_flag_word;

    // 等程序运行一段时间
    repeat (500000) @(posedge clk);

    error_flag_word = i_soc.i_sram.gen_cut[0].i_tc_sram_wrapper.i_tc_sram.sram[ERROR_WORD_INDEX];

    $display("[TB] error_flag_word = 0x%016h", error_flag_word);
    if (error_flag_word == 64'h1234567812345678) begin
      $display("[TB] SRAM TEST PASS.");
    end else if (error_flag_word == 64'hDEADBEEFDEADBEEF) begin
      $display("[TB] SRAM TEST FAIL (flag set).");
    end else begin
      $display("[TB] SRAM TEST UNKNOWN (flag not set to expected values).");
    end

    $finish;
  end

endmodule
```

2. 修改了tc_sram.sv(定义SIM时用到的，作为主存的sram行为模型)：修改初始化设置，使其载入测试脚本编译出的hex文件。

```sv
 // SRAM simulation initialization
  data_t init_val[NumWords-1:0];
`ifdef SIM
  initial begin : proc_sram_init
  if (SimInit == "file")
    // $readmemh("../init_mem.hex", init_val);
    $readmemh("/data/home/x_long32/Documents/RTL_PROJECT/SOC_CVA6_ORI/CPU_C_code/4/test_sram.hex", init_val);
  else
    for (int unsigned i = 0; i < NumWords; i++) begin
      case (SimInit)
        "zeros":  init_val[i] = {DataWidth{1'b0}};
        "ones":   init_val[i] = {DataWidth{1'b1}};
        "random": init_val[i] = {DataWidth{$urandom()}};
        default:  init_val[i] = {DataWidth{1'bx}};
      endcase
    end
  end
`else
  initial begin : proc_sram_init
  for (int unsigned i = 0; i < NumWords; i++) begin
    case (SimInit)
      "zeros":  init_val[i] = {DataWidth{1'b0}};
      "ones":   init_val[i] = {DataWidth{1'b1}};
      "random": init_val[i] = {DataWidth{$urandom()}};
      default:  init_val[i] = {DataWidth{1'bx}};
    endcase
  end
  end
`endif
```

3. src/filelist.f 中需要把自己增加的文件添加进去：

```
//增加sram_1024_64_lx文件
${SRC_DIR}/sram/sram_1024_64_lx/sram_1024_64_lx.v
${SRC_DIR}/sram/sram_1024_64_lx/sram_1024_64_wrapper.sv
${SRC_DIR}/../sim/cpu_sram_tb.sv
```

4. 然后直接利用sim下已有的makefile进行vcs仿真，导航到sim文件夹：

```bash
# 编译并直接运行仿真
make vcs TOP=cpu_sram_tb
```

生成的仿真结果保存在sim/build_cpu_sram_tb文件夹中。

5. 打开fsdb波形：

```bash
verdi -sv +define+SIM -file ../../src/filelist.f -top cpu_sram_tb -ssf cpu_sram_tb.fsdb &
```

或者在/sim执行make verdi TOP=cpu_sram_test打开，可以关联RTL文件。
波形符合测试文件，先对sram写入数据，再读数据。
现在正确结果保存在CPU_C_code/4中。

## 遗留问题

1. 现在用的载入方式是，用主存sram本身的init载入hex，虽然现在能跑通但是不确定这样是否正确，以及需要考虑后续如何把测试文件“输到”cpu。
2. makefile里面gate_vcs有设置工艺库的路径（LIB_SRC和IO_SRC），但是现在没有修改路径，没有跑过make gate_vcs（门级模型？），现在只是行为模型。
3. 如果实际硬件中想要先对写数据，运算完了之后再读回来，C脚本应该怎么写？
4. 之前遇到过疑似反复跑main停不下来的问题，怀疑是start.S脚本给栈留的空间不够，向下生长时污染了data& text段，导致返回出现异常。但是debug时没有复现出来这个错误，后面遇到了再说。
5. DMA模块。
