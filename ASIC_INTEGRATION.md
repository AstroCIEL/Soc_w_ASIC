# ASIC 集成指南 - 向量矩阵乘加速器

本文档详细说明如何将一个向量矩阵乘加速器（VecMatMul ASIC）集成到 ARA SoC 中。该 ASIC 作为 AXI 协处理器，内部带有 DMA 可以主动访问系统内存。

---

## 1. ASIC 规格定义

### 1.1 功能规格

**VecMatMul Accelerator** 执行以下运算：

```
Y = W × X

其中：
- W: 权重矩阵 [M × N]，存储在系统内存
- X: 输入向量 [N × 1]，存储在系统内存  
- Y: 输出向量 [M × 1]，写回系统内存
- 支持数据类型: int8, int16, fp16, fp32（可配置）
```

**关键特性：**
- 矩阵尺寸可配置（M, N 最大 1024）
- 内部带 SRAM 缓存权重块
- 内置 DMA 自动从系统内存加载权重/输入，写回输出
- 通过 AXI4 从接口接收配置命令
- 通过 AXI4 主接口访问系统内存
- 计算完成后产生中断信号

### 1.2 接口架构

```
┌─────────────────────────────────────────────────────────────┐
│                 VecMatMul Accelerator                       │
│                      (vmma_top)                             │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐      ┌──────────────────────────┐      │
│  │  AXI4 Slave     │      │      Control Unit        │      │
│  │  (Config/Status)│◄────►│  - 解析命令               │      │
│  │基址: 0x7000_0000 │      │  - 配置寄存器             │      │
│  │  数据宽度: 64bit │      │  - 状态管理               │      │
│  └────────┬────────┘      └──────────┬───────────────┘      │
│           │         ┌────────────────┴────────────┐         │
│  ┌────────▼────────┐│  ┌──────────────┐  ┌────────▼──┐      │
│  │   Register      ││  │   Compute    │  │  Internal │      │
│  │   Bank (MMIO)   ││  │   Engine     │  │   SRAM    │      │
│  │   - CMD_REG     │└─►│  (MAC Array) │◄►│ (Weight   │      │
│  │   - STATUS_REG  │   │              │  │  Buffer)  │      │
│  │   - W_ADDR_REG  │   └──────────────┘  └───────────┘      │
│  │   - X_ADDR_REG  │                                        │
│  │   - Y_ADDR_REG  │   ┌──────────────────────────────┐     │
│  │   - M_REG       │   │         DMA Engine           │     │
│  │   - N_REG       │   │    ┌─────┐  ┌─────┐  ┌────┐  │     │
│  │   - STRIDE_REG  │◄──┤    │ Rd  │  │ Wr  │  │Ctrl│  │     │
│  └─────────────────┘   │    │Chan │  │Chan │  │    │  │     │
│                        │    └──┬──┘  └──┬──┘  └────┘  │     │
│                        │       └────┬───┘             │     │
│                        └────────────┼─────────────────┘     │
│                          ┌──────────▼──────────┐            │
│                          │   AXI4 Master       │            │
│                          │   (Memory Access)   │            │
│                          │   数据宽度: 64bit    │            │
│                          └──────────┬──────────┘            │
│                          ┌──────────▼──────────┐            │
│                          │      irq_o          │            │
│                          │  (完成中断输出)      │            │
│                          └─────────────────────┘            │
└─────────────────────────────────────────────────────────────┘
```

### 1.3 寄存器映射（AXI Slave 接口）

基地址：`0x7000_0000`

| 偏移地址 | 寄存器名 | 读写 | 宽度 | 描述 |
|----------|----------|------|------|------|
| 0x00 | CMD | RW | 32 | 命令寄存器（bit0: start, bit1: clear_done） |
| 0x04 | STATUS | RO | 32 | 状态寄存器（bit0: busy, bit1: done, bit[7:4]: error_code） |
| 0x08 | CTRL | RW | 32 | 控制寄存器（bit[1:0]: dtype, bit[3:2]: reserved） |
| 0x10 | M_DIM | RW | 32 | 输出向量维度 M |
| 0x14 | N_DIM | RW | 32 | 输入向量维度 N |
| 0x20 | W_ADDR | RW | 64 | 权重矩阵系统内存地址 |
| 0x28 | X_ADDR | RW | 64 | 输入向量系统内存地址 |
| 0x30 | Y_ADDR | RW | 64 | 输出向量系统内存地址 |
| 0x38 | W_STRIDE | RW | 32 | 权重矩阵行stride（字节） |
| 0x40 | CYCLE_CNT | RO | 64 | 执行周期计数（性能计数器） |
| 0x50 | IRQ_MASK | RW | 32 | 中断使能掩码 |
| 0x54 | IRQ_STATUS | RW | 32 | 中断状态（写1清除） |

### 1.4 时序规范

#### AXI Slave 接口时序（配置访问）

```
Clock:    ___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___
          
AWVALID:  ____/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\_____________________________
AWADDR:   ----<W_ADDR[31:0]>--------------------------------
AWREADY:  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\_____/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

WVALID:   ______/‾‾‾‾‾‾‾‾‾‾‾‾‾‾\____________________________
WDATA:    --------<config_data>------------------------------
WREADY:   ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\___/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

BVALID:   ______________________/‾‾‾\______________________
BRESP:    ------------------------<OKAY>-------------------
BREADY:   ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\___/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
          
ARVALID:  ____/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\___________________________
ARADDR:   ----<STATUS_REG>-----------------------------------
ARREADY:  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\____/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

RVALID:   ______________________/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\________
RDATA:    ------------------------<status_val>--------------
RREADY:   ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\___/‾‾‾‾‾‾‾‾
```

#### AXI Master 接口时序（DMA 内存访问）

**读突发传输（Burst Read）：**
```
ARVALID:  ____/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\__________________
ARADDR:   ----<start_addr>---------------------------------
ARLEN:    --------<burst_len-1>----------------------------
ARSIZE:   --------<data_size>------------------------------
ARREADY:  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\_____/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

RVALID:   __________________________/‾‾‾\__/‾‾‾\__/‾‾‾\__/‾‾‾\__
RDATA:    ----------------------------<D0>-<D1>-<D2>-<D3>----
RLAST:    ______________________________________________/‾‾‾\
RREADY:   ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
```

**写突发传输（Burst Write）：**
```
AWVALID:  ____/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\__________________
AWADDR:   ----<start_addr>---------------------------------
AWLEN:    --------<burst_len-1>----------------------------
WVALID:   ______/‾‾‾\__/‾‾‾\__/‾‾‾\__/‾‾‾\__________________
WDATA:    --------<D0>-<D1>-<D2>-<D3>----------------------
WLAST:    ________________________________/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\__
BVALID:   ____________________________________________/‾‾‾\__
BREADY:   ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\___
```

---

## 2. ASIC RTL 设计

### 2.1 目录结构

创建以下目录结构：

```
hardware/user_ip/vmma/
├── rtl/
│   ├── vmma_top.sv           # ASIC 顶层模块
│   ├── vmma_ctrl.sv          # 控制单元
│   ├── vmma_dma.sv           # DMA 引擎
│   ├── vmma_compute.sv       # 计算引擎（MAC阵列）
│   ├── vmma_sram.sv          # 内部 SRAM
│   └── vmma_regbank.sv       # 寄存器组
├── include/
│   └── vmma_pkg.sv           # 包定义
├── tb/
│   └── vmma_tb.sv            # 测试台（可选）
└── filelist.f                # 文件列表
```

### 2.2 包定义 (`vmma_pkg.sv`)

```systemverilog
// vmma_pkg.sv
package vmma_pkg;

    // 数据类型枚举
    typedef enum logic [1:0] {
        DTYPE_INT8  = 2'b00,
        DTYPE_INT16 = 2'b01,
        DTYPE_FP16  = 2'b10,
        DTYPE_FP32  = 2'b11
    } dtype_e;

    // 寄存器地址偏移
    localparam logic [15:0] REG_CMD        = 16'h0000;
    localparam logic [15:0] REG_STATUS     = 16'h0004;
    localparam logic [15:0] REG_CTRL       = 16'h0008;
    localparam logic [15:0] REG_M_DIM      = 16'h0010;
    localparam logic [15:0] REG_N_DIM      = 16'h0014;
    localparam logic [15:0] REG_W_ADDR_LO  = 16'h0020;
    localparam logic [15:0] REG_W_ADDR_HI  = 16'h0024;
    localparam logic [15:0] REG_X_ADDR_LO  = 16'h0028;
    localparam logic [15:0] REG_X_ADDR_HI  = 16'h002C;
    localparam logic [15:0] REG_Y_ADDR_LO  = 16'h0030;
    localparam logic [15:0] REG_Y_ADDR_HI  = 16'h0034;
    localparam logic [15:0] REG_W_STRIDE  = 16'h0038;
    localparam logic [15:0] REG_CYCLE_CNT  = 16'h0040;
    localparam logic [15:0] REG_IRQ_MASK  = 16'h0050;
    localparam logic [15:0] REG_IRQ_STATUS = 16'h0054;

    // 命令位定义
    localparam logic CMD_START_BIT      = 0;
    localparam logic CMD_CLEAR_DONE_BIT = 1;

    // 状态位定义
    localparam logic STATUS_BUSY_BIT    = 0;
    localparam logic STATUS_DONE_BIT    = 1;
    localparam logic STATUS_ERROR_BIT   = 2;

    // 配置参数
    localparam int MAC_ARRAY_WIDTH      = 32;   // 并行MAC单元数
    localparam int SRAM_DEPTH           = 4096; // 权重SRAM深度
    localparam int MAX_BURST_LEN        = 16;   // AXI最大突发长度
    localparam int AXI_ADDR_WIDTH       = 64;
    localparam int AXI_DATA_WIDTH       = 64;
    localparam int AXI_ID_WIDTH         = 4;
    localparam int AXI_USER_WIDTH       = 1;

endpackage
```

### 2.3 ASIC 顶层 (`vmma_top.sv`)

```systemverilog
// vmma_top.sv
module vmma_top import vmma_pkg::*; (
    input  logic                            clk_i,
    input  logic                            rst_ni,
    
    // 中断输出
    output logic                            irq_o,
    
    // AXI4 Slave 接口 - 配置访问
    input  logic                            slv_awvalid_i,
    output logic                            slv_awready_o,
    input  logic [AXI_ADDR_WIDTH-1:0]       slv_awaddr_i,
    input  logic [AXI_ID_WIDTH-1:0]         slv_awid_i,
    input  logic [7:0]                      slv_awlen_i,
    input  logic [2:0]                      slv_awsize_i,
    input  logic [1:0]                      slv_awburst_i,
    
    input  logic                            slv_wvalid_i,
    output logic                            slv_wready_o,
    input  logic [AXI_DATA_WIDTH-1:0]       slv_wdata_i,
    input  logic [AXI_DATA_WIDTH/8-1:0]     slv_wstrb_i,
    input  logic                            slv_wlast_i,
    
    output logic                            slv_bvalid_o,
    input  logic                            slv_bready_i,
    output logic [AXI_ID_WIDTH-1:0]         slv_bid_o,
    output logic [1:0]                      slv_bresp_o,
    
    input  logic                            slv_arvalid_i,
    output logic                            slv_arready_o,
    input  logic [AXI_ADDR_WIDTH-1:0]       slv_araddr_i,
    input  logic [AXI_ID_WIDTH-1:0]         slv_arid_i,
    input  logic [7:0]                      slv_arlen_i,
    input  logic [2:0]                      slv_arsize_i,
    input  logic [1:0]                      slv_arburst_i,
    
    output logic                            slv_rvalid_o,
    input  logic                            slv_rready_i,
    output logic [AXI_ID_WIDTH-1:0]         slv_rid_o,
    output logic [AXI_DATA_WIDTH-1:0]       slv_rdata_o,
    output logic [1:0]                      slv_rresp_o,
    output logic                            slv_rlast_o,
    
    // AXI4 Master 接口 - DMA内存访问
    output logic                            mst_awvalid_o,
    input  logic                            mst_awready_i,
    output logic [AXI_ADDR_WIDTH-1:0]       mst_awaddr_o,
    output logic [AXI_ID_WIDTH-1:0]         mst_awid_o,
    output logic [7:0]                      mst_awlen_o,
    output logic [2:0]                      mst_awsize_o,
    output logic [1:0]                      mst_awburst_o,
    
    output logic                            mst_wvalid_o,
    input  logic                            mst_wready_i,
    output logic [AXI_DATA_WIDTH-1:0]       mst_wdata_o,
    output logic [AXI_DATA_WIDTH/8-1:0]     mst_wstrb_o,
    output logic                            mst_wlast_o,
    
    input  logic                            mst_bvalid_i,
    output logic                            mst_bready_o,
    input  logic [AXI_ID_WIDTH-1:0]         mst_bid_i,
    input  logic [1:0]                      mst_bresp_i,
    
    output logic                            mst_arvalid_o,
    input  logic                            mst_arready_i,
    output logic [AXI_ADDR_WIDTH-1:0]       mst_araddr_o,
    output logic [AXI_ID_WIDTH-1:0]         mst_arid_o,
    output logic [7:0]                      mst_arlen_o,
    output logic [2:0]                      mst_arsize_o,
    output logic [1:0]                      mst_arburst_o,
    
    input  logic                            mst_rvalid_i,
    output logic                            mst_rready_o,
    input  logic [AXI_ID_WIDTH-1:0]         mst_rid_i,
    input  logic [AXI_DATA_WIDTH-1:0]       mst_rdata_i,
    input  logic [1:0]                      mst_rresp_i,
    input  logic                            mst_rlast_i
);

    // 内部信号声明
    // 寄存器组 ↔ 控制单元
    logic [31:0] reg_cmd, reg_status, reg_ctrl;
    logic [31:0] reg_m_dim, reg_n_dim, reg_w_stride;
    logic [63:0] reg_w_addr, reg_x_addr, reg_y_addr;
    logic [31:0] reg_irq_mask, reg_irq_status;
    logic [63:0] cycle_cnt;
    
    // 控制单元 ↔ DMA
    logic dma_start;
    logic [63:0] dma_src_addr, dma_dst_addr;
    logic [31:0] dma_xfer_len;
    logic dma_done;
    logic dma_error;
    
    // DMA ↔ Compute Engine
    logic [AXI_DATA_WIDTH-1:0] weight_data, input_data;
    logic weight_valid, input_valid;
    logic weight_ready, input_ready;
    logic [AXI_DATA_WIDTH-1:0] output_data;
    logic output_valid;
    
    // 寄存器组实例化
    vmma_regbank i_regbank (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        // AXI Slave
        .slv_awvalid_i      (slv_awvalid_i),
        .slv_awready_o      (slv_awready_o),
        .slv_awaddr_i       (slv_awaddr_i),
        .slv_awid_i         (slv_awid_i),
        .slv_wvalid_i       (slv_wvalid_i),
        .slv_wready_o       (slv_wready_o),
        .slv_wdata_i        (slv_wdata_i),
        .slv_wstrb_i        (slv_wstrb_i),
        .slv_bvalid_o       (slv_bvalid_o),
        .slv_bready_i       (slv_bready_i),
        .slv_bid_o          (slv_bid_o),
        .slv_bresp_o        (slv_bresp_o),
        .slv_arvalid_i      (slv_arvalid_i),
        .slv_arready_o      (slv_arready_o),
        .slv_araddr_i       (slv_araddr_i),
        .slv_arid_i         (slv_arid_i),
        .slv_rvalid_o       (slv_rvalid_o),
        .slv_rready_i       (slv_rready_i),
        .slv_rid_o          (slv_rid_o),
        .slv_rdata_o        (slv_rdata_o),
        .slv_rresp_o        (slv_rresp_o),
        .slv_rlast_o        (slv_rlast_o),
        // 寄存器接口
        .reg_cmd_o          (reg_cmd),
        .reg_status_i       (reg_status),
        .reg_ctrl_o         (reg_ctrl),
        .reg_m_dim_o        (reg_m_dim),
        .reg_n_dim_o        (reg_n_dim),
        .reg_w_addr_o       (reg_w_addr),
        .reg_x_addr_o       (reg_x_addr),
        .reg_y_addr_o       (reg_y_addr),
        .reg_w_stride_o     (reg_w_stride),
        .reg_irq_mask_o     (reg_irq_mask),
        .reg_irq_status_o   (reg_irq_status),
        .reg_cycle_cnt_i    (cycle_cnt)
    );

    // 控制单元实例化
    vmma_ctrl i_ctrl (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        // 寄存器接口
        .reg_cmd_i          (reg_cmd),
        .reg_status_o       (reg_status),
        .reg_ctrl_i         (reg_ctrl),
        .reg_m_dim_i        (reg_m_dim),
        .reg_n_dim_i        (reg_n_dim),
        .reg_w_addr_i       (reg_w_addr),
        .reg_x_addr_i       (reg_x_addr),
        .reg_y_addr_i       (reg_y_addr),
        .reg_w_stride_i     (reg_w_stride),
        .reg_irq_mask_i     (reg_irq_mask),
        .reg_irq_status_o   (reg_irq_status),
        .cycle_cnt_o        (cycle_cnt),
        // DMA控制
        .dma_start_o        (dma_start),
        .dma_src_addr_o     (dma_src_addr),
        .dma_dst_addr_o     (dma_dst_addr),
        .dma_xfer_len_o     (dma_xfer_len),
        .dma_done_i         (dma_done),
        .dma_error_i        (dma_error),
        // 中断
        .irq_o              (irq_o)
    );

    // DMA引擎实例化
    vmma_dma i_dma (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        // 控制接口
        .start_i            (dma_start),
        .src_addr_i         (dma_src_addr),
        .dst_addr_i         (dma_dst_addr),
        .xfer_len_i         (dma_xfer_len),
        .done_o             (dma_done),
        .error_o            (dma_error),
        // AXI Master
        .mst_awvalid_o      (mst_awvalid_o),
        .mst_awready_i      (mst_awready_i),
        .mst_awaddr_o       (mst_awaddr_o),
        .mst_awid_o         (mst_awid_o),
        .mst_awlen_o        (mst_awlen_o),
        .mst_awsize_o       (mst_awsize_o),
        .mst_wvalid_o       (mst_wvalid_o),
        .mst_wready_i       (mst_wready_i),
        .mst_wdata_o        (mst_wdata_o),
        .mst_wstrb_o        (mst_wstrb_o),
        .mst_wlast_o        (mst_wlast_o),
        .mst_bvalid_i       (mst_bvalid_i),
        .mst_bready_o       (mst_bready_o),
        .mst_bresp_i        (mst_bresp_i),
        .mst_arvalid_o      (mst_arvalid_o),
        .mst_arready_i      (mst_arready_i),
        .mst_araddr_o       (mst_araddr_o),
        .mst_arid_o         (mst_arid_o),
        .mst_arlen_o        (mst_arlen_o),
        .mst_arsize_o       (mst_arsize_o),
        .mst_rvalid_i       (mst_rvalid_i),
        .mst_rready_o       (mst_rready_o),
        .mst_rdata_i        (mst_rdata_i),
        .mst_rresp_i        (mst_rresp_i),
        .mst_rlast_i        (mst_rlast_i),
        // 数据接口
        .weight_data_o      (weight_data),
        .weight_valid_o     (weight_valid),
        .weight_ready_i     (weight_ready),
        .input_data_o       (input_data),
        .input_valid_o      (input_valid),
        .input_ready_i      (input_ready),
        .output_data_i      (output_data),
        .output_valid_i     (output_valid)
    );

    // 计算引擎实例化
    vmma_compute i_compute (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        // 数据接口
        .weight_data_i      (weight_data),
        .weight_valid_i     (weight_valid),
        .weight_ready_o     (weight_ready),
        .input_data_i       (input_data),
        .input_valid_i      (input_valid),
        .input_ready_o      (input_ready),
        .output_data_o      (output_data),
        .output_valid_o     (output_valid),
        // 配置
        .dtype_i            (reg_ctrl[1:0]),
        .m_dim_i            (reg_m_dim),
        .n_dim_i            (reg_n_dim)
    );

endmodule
```

### 2.4 文件列表 (`filelist.f`)

```
// hardware/user_ip/vmma/filelist.f
+incdir+../include

// Package
../include/vmma_pkg.sv

// RTL
../rtl/vmma_regbank.sv
../rtl/vmma_ctrl.sv
../rtl/vmma_dma.sv
../rtl/vmma_compute.sv
../rtl/vmma_sram.sv
../rtl/vmma_top.sv
```

---

## 3. 硬件集成步骤

### 3.1 修改 SoC 配置包

编辑 `hardware/soc/maximum/ariane_soc_pkg.sv`：

```systemverilog
package ariane_soc;
    // ... 现有配置 ...

    // 修改枚举 - 添加新的 AXI 从设备
    typedef enum int unsigned {
        DRAM     = 0,
        GPIO     = 1,
        // ... 现有设备 ...
        DMA      = 10,
        VMMA     = 11,        // <-- 添加 VMMA 加速器
        NB_PERIPHERALS = 12   // <-- 更新总数
    } axi_slaves_t;

    // 修改枚举 - 添加新的 AXI 主设备（VMMA 的 DMA）
    typedef enum int unsigned {
        AraMst   = 0,
        DebugMst = 1,
        DMAMst   = 2,
        VMMAMst  = 3,         // <-- 添加 VMMA DMA 主设备
        NrSlaves = 4          // <-- 更新总数
    } axi_masters_t;

    // 添加 VMMA 地址空间
    localparam logic[63:0] VMMALength = 64'h1000;  // 4KB

    // 修改地址映射枚举
    typedef enum logic [63:0] {
        DebugBase    = 64'h0000_0000,
        ROMBase      = 64'h0001_0000,
        // ... 现有基地址 ...
        DMABase      = 64'h6000_0000,
        VMMABase     = 64'h7000_0000,  // <-- 添加 VMMA 基地址
        DRAMBase     = 64'h8000_0000,
        CtrlBase     = 64'hD000_0000
    } soc_bus_start_t;

endpackage
```

### 3.2 修改外设集成模块

编辑 `hardware/soc/maximum/ariane_peripherals.sv`，添加 VMMA 实例化：

```systemverilog
module ariane_peripherals #(
    // ... 参数 ...
) (
    // ... 现有端口 ...
    AXI_BUS.Slave      dma_cfg,
    AXI_BUS.Master     dma_mst,
    AXI_BUS.Slave      vmma_cfg,    // <-- 添加 VMMA Slave 端口
    AXI_BUS.Master     vmma_mst,    // <-- 添加 VMMA Master 端口
    // ...
    output logic [1:0] irq_o
);

    // ... 现有外设 ...

    // ================================================================
    // VMMA Accelerator Instance
    // ================================================================
    
    // AXI 类型定义
    typedef logic [AxiAddrWidth-1:0]   vmma_addr_t;
    typedef logic [AxiDataWidth-1:0]   vmma_data_t;
    typedef logic [AxiDataWidth/8-1:0] vmma_strb_t;
    typedef logic [AxiIdWidth-1:0]     vmma_id_t;
    typedef logic [AxiUserWidth-1:0]   vmma_user_t;
    typedef logic [ariane_axi_soc::IdWidth-1:0] vmma_mst_id_t;
    
    `AXI_TYPEDEF_ALL(vmma_slv, vmma_addr_t, vmma_id_t, vmma_data_t, vmma_strb_t, vmma_user_t)
    `AXI_TYPEDEF_ALL(vmma_mst, vmma_addr_t, vmma_mst_id_t, vmma_data_t, vmma_strb_t, vmma_user_t)
    
    vmma_slv_req_t  vmma_slv_req;
    vmma_slv_resp_t vmma_slv_rsp;
    vmma_mst_req_t  vmma_mst_req;
    vmma_mst_resp_t vmma_mst_rsp;
    
    `AXI_ASSIGN_TO_REQ   (vmma_slv_req, vmma_cfg)
    `AXI_ASSIGN_FROM_RESP(vmma_cfg,     vmma_slv_rsp)
    `AXI_ASSIGN_FROM_REQ (vmma_mst,     vmma_mst_req)
    `AXI_ASSIGN_TO_RESP  (vmma_mst_rsp, vmma_mst)
    
    // VMMA 加速器实例化
    vmma_top i_vmma (
        .clk_i              (clk_i),
        .rst_ni             (rst_ni),
        // 中断
        .irq_o              (irq_sources[7]),  // 使用 PLIC 中断源 7
        // AXI Slave - 配置
        .slv_awvalid_i      (vmma_slv_req.aw_valid),
        .slv_awready_o      (vmma_slv_rsp.aw_ready),
        .slv_awaddr_i       (vmma_slv_req.aw.addr),
        .slv_awid_i         (vmma_slv_req.aw.id),
        .slv_awlen_i        (vmma_slv_req.aw.len),
        .slv_awsize_i       (vmma_slv_req.aw.size),
        .slv_awburst_i      (vmma_slv_req.aw.burst),
        .slv_wvalid_i       (vmma_slv_req.w_valid),
        .slv_wready_o       (vmma_slv_rsp.w_ready),
        .slv_wdata_i        (vmma_slv_req.w.data),
        .slv_wstrb_i        (vmma_slv_req.w.strb),
        .slv_wlast_i        (vmma_slv_req.w.last),
        .slv_bvalid_o       (vmma_slv_rsp.b_valid),
        .slv_bready_i       (vmma_slv_req.b_ready),
        .slv_bid_o          (vmma_slv_rsp.b.id),
        .slv_bresp_o        (vmma_slv_rsp.b.resp),
        .slv_arvalid_i      (vmma_slv_req.ar_valid),
        .slv_arready_o      (vmma_slv_rsp.ar_ready),
        .slv_araddr_i       (vmma_slv_req.ar.addr),
        .slv_arid_i         (vmma_slv_req.ar.id),
        .slv_arlen_i        (vmma_slv_req.ar.len),
        .slv_arsize_i       (vmma_slv_req.ar.size),
        .slv_arburst_i      (vmma_slv_req.ar.burst),
        .slv_rvalid_o       (vmma_slv_rsp.r_valid),
        .slv_rready_i       (vmma_slv_req.r_ready),
        .slv_rid_o          (vmma_slv_rsp.r.id),
        .slv_rdata_o        (vmma_slv_rsp.r.data),
        .slv_rresp_o        (vmma_slv_rsp.r.resp),
        .slv_rlast_o        (vmma_slv_rsp.r.last),
        // AXI Master - DMA
        .mst_awvalid_o      (vmma_mst_req.aw_valid),
        .mst_awready_i      (vmma_mst_rsp.aw_ready),
        .mst_awaddr_o       (vmma_mst_req.aw.addr),
        .mst_awid_o         (vmma_mst_req.aw.id),
        .mst_awlen_o        (vmma_mst_req.aw.len),
        .mst_awsize_o       (vmma_mst_req.aw.size),
        .mst_awburst_o      (vmma_mst_req.aw.burst),
        .mst_wvalid_o       (vmma_mst_req.w_valid),
        .mst_wready_i       (vmma_mst_rsp.w_ready),
        .mst_wdata_o        (vmma_mst_req.w.data),
        .mst_wstrb_o        (vmma_mst_req.w.strb),
        .mst_wlast_o        (vmma_mst_req.w.last),
        .mst_bvalid_i       (vmma_mst_rsp.b_valid),
        .mst_bready_o       (vmma_mst_req.b_ready),
        .mst_bid_i          (vmma_mst_rsp.b.id),
        .mst_bresp_i        (vmma_mst_rsp.b.resp),
        .mst_arvalid_o      (vmma_mst_req.ar_valid),
        .mst_arready_i      (vmma_mst_rsp.ar_ready),
        .mst_araddr_o       (vmma_mst_req.ar.addr),
        .mst_arid_o         (vmma_mst_req.ar.id),
        .mst_arlen_o        (vmma_mst_req.ar.len),
        .mst_arsize_o       (vmma_mst_req.ar.size),
        .mst_arburst_o      (vmma_mst_req.ar.burst),
        .mst_rvalid_i       (vmma_mst_rsp.r_valid),
        .mst_rready_o       (vmma_mst_req.r_ready),
        .mst_rid_i          (vmma_mst_rsp.r.id),
        .mst_rdata_i        (vmma_mst_rsp.r.data),
        .mst_rresp_i        (vmma_mst_rsp.r.resp),
        .mst_rlast_i        (vmma_mst_rsp.r.last)
    );

endmodule
```

### 3.3 修改 SoC 顶层

编辑 `hardware/soc/maximum/ariane_soc_top.sv`：

```systemverilog
// 1. 在 AXI 总线声明处添加 VMMA 端口
AXI_BUS #(
    .AXI_ADDR_WIDTH ( AXI_ADDRESS_WIDTH            ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH               ),
    .AXI_ID_WIDTH   ( ariane_axi_soc::IdWidthSlave ),
    .AXI_USER_WIDTH ( AXI_USER_WIDTH               )
) slave[ariane_soc::NrSlaves-1:0]();  // 更新为 NrSlaves=4

// 2. 修改 AXI Xbar 配置
axi_pkg::xbar_rule_64_t [ariane_soc::NB_PERIPHERALS-1:0] addr_map;

assign addr_map = '{
    '{ idx: ariane_soc::Debug,    start_addr: ariane_soc::DebugBase,    end_addr: ariane_soc::DebugBase + ariane_soc::DebugLength       },
    // ... 现有映射 ...
    '{ idx: ariane_soc::DMA,      start_addr: ariane_soc::DMABase,      end_addr: ariane_soc::DMABase + ariane_soc::DMALength       },
    '{ idx: ariane_soc::VMMA,     start_addr: ariane_soc::VMMABase,     end_addr: ariane_soc::VMMABase + ariane_soc::VMMALength       },  // <-- 添加
    '{ idx: ariane_soc::DRAM,     start_addr: ariane_soc::DRAMBase,     end_addr: ariane_soc::DRAMBase + ariane_soc::DRAMLength         }
};

// 3. 修改外设实例化 - 添加 VMMA 接口连接
ariane_peripherals #(
    // ... 参数 ...
) i_ariane_peripherals (
    // ... 现有连接 ...
    .dma_cfg        ( master[ariane_soc::DMA]      ),
    .dma_mst        ( slave [ariane_soc::DMAMst]   ),
    .vmma_cfg       ( master[ariane_soc::VMMA]     ),  // <-- 添加
    .vmma_mst       ( slave [ariane_soc::VMMAMst]  ),  // <-- 添加
    .irq_o          ( irqs                         ),
    // ...
);

// 4. 更新 Xbar 配置
localparam axi_pkg::xbar_cfg_t AXI_XBAR_CFG = '{
    NoSlvPorts: unsigned'(ariane_soc::NrSlaves),      // 更新为 4
    NoMstPorts: unsigned'(ariane_soc::NB_PERIPHERALS), // 更新为 12
    // ...
};
```

### 3.4 更新仿真文件列表

编辑 `sim/filelist.f`，添加 VMMA 文件：

```
// ... 现有文件列表 ...

// user ip
-f ../hardware/user_ip/default_slave/filelist_sim.f
-f ../hardware/user_ip/vmma/filelist.f    // <-- 添加 VMMA
```

---

## 4. 软件驱动开发

### 4.1 创建 VMMA 驱动头文件

创建 `software/soc/include/vmma.h`：

```c
// vmma.h - VMMA Accelerator Driver Header

#ifndef VMMA_H
#define VMMA_H

#include <stdint.h>
#include "soc.h"

// VMMA 基地址（必须与硬件一致）
#define VMMA_BASE_ADDR      0x70000000ULL

// 寄存器偏移
#define VMMA_REG_CMD        0x00
#define VMMA_REG_STATUS     0x04
#define VMMA_REG_CTRL       0x08
#define VMMA_REG_M_DIM      0x10
#define VMMA_REG_N_DIM      0x14
#define VMMA_REG_W_ADDR     0x20
#define VMMA_REG_X_ADDR     0x28
#define VMMA_REG_Y_ADDR     0x30
#define VMMA_REG_W_STRIDE   0x38
#define VMMA_REG_CYCLE_CNT  0x40
#define VMMA_REG_IRQ_MASK   0x50
#define VMMA_REG_IRQ_STATUS 0x54

// 命令位
#define VMMA_CMD_START      (1 << 0)
#define VMMA_CMD_CLEAR_DONE (1 << 1)

// 状态位
#define VMMA_STATUS_BUSY    (1 << 0)
#define VMMA_STATUS_DONE    (1 << 1)
#define VMMA_STATUS_ERROR   (1 << 2)

// 数据类型
typedef enum {
    VMMA_DTYPE_INT8  = 0,
    VMMA_DTYPE_INT16 = 1,
    VMMA_DTYPE_FP16  = 2,
    VMMA_DTYPE_FP32  = 3
} vmma_dtype_t;

// VMMA 配置结构
typedef struct {
    vmma_dtype_t dtype;
    uint32_t m;           // 输出维度
    uint32_t n;           // 输入维度
    uint64_t w_addr;      // 权重矩阵地址
    uint64_t x_addr;      // 输入向量地址
    uint64_t y_addr;      // 输出向量地址
    uint32_t w_stride;    // 权重矩阵行stride
} vmma_config_t;

// 函数声明

/**
 * @brief 初始化 VMMA 加速器
 */
void vmma_init(void);

/**
 * @brief 配置 VMMA 加速器
 * @param config 配置参数指针
 */
void vmma_configure(const vmma_config_t *config);

/**
 * @brief 启动 VMMA 计算
 */
void vmma_start(void);

/**
 * @brief 等待 VMMA 完成（轮询）
 * @return 0 成功，非0 错误码
 */
int vmma_wait_done(void);

/**
 * @brief 检查是否忙碌
 * @return 1 忙碌，0 空闲
 */
int vmma_is_busy(void);

/**
 * @brief 清除完成标志
 */
void vmma_clear_done(void);

/**
 * @brief 获取执行周期数
 * @return 周期计数
 */
uint64_t vmma_get_cycle_count(void);

/**
 * @brief 执行完整的矩阵向量乘法
 * @param config 配置参数
 * @return 0 成功，非0 错误码
 */
int vmma_execute(const vmma_config_t *config);

/**
 * @brief 使用中断方式执行（需要PLIC配置）
 * @param config 配置参数
 * @return 0 成功，非0 错误码
 */
int vmma_execute_irq(const vmma_config_t *config);

#endif // VMMA_H
```

### 4.2 创建 VMMA 驱动实现

创建 `software/soc/src/vmma.c`：

```c
// vmma.c - VMMA Accelerator Driver Implementation

#include "vmma.h"
#include "printf.h"

// 内联读写辅助函数
static inline void vmma_write32(uintptr_t offset, uint32_t value) {
    *(volatile uint32_t *)(VMMA_BASE_ADDR + offset) = value;
}

static inline uint32_t vmma_read32(uintptr_t offset) {
    return *(volatile uint32_t *)(VMMA_BASE_ADDR + offset);
}

static inline void vmma_write64(uintptr_t offset, uint64_t value) {
    *(volatile uint64_t *)(VMMA_BASE_ADDR + offset) = value;
}

static inline uint64_t vmma_read64(uintptr_t offset) {
    return *(volatile uint64_t *)(VMMA_BASE_ADDR + offset);
}

void vmma_init(void) {
    // 清除所有状态
    vmma_write32(VMMA_REG_CMD, VMMA_CMD_CLEAR_DONE);
    vmma_write32(VMMA_REG_IRQ_MASK, 0);
    vmma_write32(VMMA_REG_IRQ_STATUS, 0xFFFFFFFF); // 清除所有中断
}

void vmma_configure(const vmma_config_t *config) {
    // 等待空闲
    while (vmma_is_busy()) {
        // 可以添加超时
    }
    
    // 配置数据类型和控制
    uint32_t ctrl = (config->dtype & 0x3);
    vmma_write32(VMMA_REG_CTRL, ctrl);
    
    // 配置维度
    vmma_write32(VMMA_REG_M_DIM, config->m);
    vmma_write32(VMMA_REG_N_DIM, config->n);
    
    // 配置地址
    vmma_write64(VMMA_REG_W_ADDR, config->w_addr);
    vmma_write64(VMMA_REG_X_ADDR, config->x_addr);
    vmma_write64(VMMA_REG_Y_ADDR, config->y_addr);
    
    // 配置 stride
    vmma_write32(VMMA_REG_W_STRIDE, config->w_stride);
}

void vmma_start(void) {
    vmma_write32(VMMA_REG_CMD, VMMA_CMD_START);
}

int vmma_wait_done(void) {
    // 超时计数（假设500MHz时钟，等待最多10秒）
    const uint64_t timeout = 5000000000ULL;
    volatile uint64_t count = 0;
    
    while (vmma_is_busy()) {
        count++;
        if (count > timeout) {
            printf("VMMA timeout!\n");
            return -1;  // 超时错误
        }
    }
    
    uint32_t status = vmma_read32(VMMA_REG_STATUS);
    if (status & VMMA_STATUS_ERROR) {
        printf("VMMA error! status=0x%x\n", status);
        return -2;  // 硬件错误
    }
    
    return 0;
}

int vmma_is_busy(void) {
    return (vmma_read32(VMMA_REG_STATUS) & VMMA_STATUS_BUSY) != 0;
}

void vmma_clear_done(void) {
    vmma_write32(VMMA_REG_CMD, VMMA_CMD_CLEAR_DONE);
}

uint64_t vmma_get_cycle_count(void) {
    return vmma_read64(VMMA_REG_CYCLE_CNT);
}

int vmma_execute(const vmma_config_t *config) {
    // 配置
    vmma_configure(config);
    
    // 启动
    vmma_start();
    
    // 等待完成
    int result = vmma_wait_done();
    
    // 清除完成标志
    if (result == 0) {
        vmma_clear_done();
    }
    
    return result;
}

// 全局标志用于中断处理
static volatile int vmma_irq_done = 0;

void vmma_irq_handler(void) {
    uint32_t irq_status = vmma_read32(VMMA_REG_IRQ_STATUS);
    
    if (irq_status & 0x1) {
        vmma_irq_done = 1;
        // 清除中断
        vmma_write32(VMMA_REG_IRQ_STATUS, 0x1);
    }
}

int vmma_execute_irq(const vmma_config_t *config) {
    // 需要预先在 main 中配置 PLIC 中断
    vmma_irq_done = 0;
    
    // 使能中断
    vmma_write32(VMMA_REG_IRQ_MASK, 0x1);
    
    // 配置并启动
    vmma_configure(config);
    vmma_start();
    
    // 等待中断（实际应用中应该睡眠等待）
    while (!vmma_irq_done) {
        // 等待中断
    }
    
    // 清除状态
    vmma_clear_done();
    vmma_write32(VMMA_REG_IRQ_MASK, 0);
    
    return 0;
}
```

---

## 5. 测试应用开发

### 5.1 创建测试应用

创建目录 `software/app/vmma_test/`，包含以下文件：

#### `app.mk`

```makefile
# vmma_test/app.mk

vmma_test_SRCS := \
    $(BSP_DIR)/app/vmma_test/main.c \
    $(SOC_DIR)/src/vmma.c

vmma_test_CFLAGS := -mcmodel=medany -O2
```

#### `main.c`

```c
// vmma_test/main.c

#include <stdio.h>
#include <string.h>
#include "vmma.h"
#include "util.h"

// 矩阵维度
#define M 64
#define N 64

// 数据缓冲区（放置在 .l2 section，即 DRAM）
__attribute__((aligned(64), section(".l2"))) 
int16_t weight_matrix[M * N];

__attribute__((aligned(64), section(".l2"))) 
int16_t input_vector[N];

__attribute__((aligned(64), section(".l2"))) 
int16_t output_vector[M];

__attribute__((aligned(64), section(".l2"))) 
int16_t golden_output[M];

// 初始化测试数据
void init_data(void) {
    // 初始化权重矩阵（行优先）
    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) {
            weight_matrix[i * N + j] = (i + j) % 256;
        }
    }
    
    // 初始化输入向量
    for (int j = 0; j < N; j++) {
        input_vector[j] = j % 16;
    }
    
    // 计算 golden 结果（CPU 软件计算）
    for (int i = 0; i < M; i++) {
        int32_t sum = 0;
        for (int j = 0; j < N; j++) {
            sum += weight_matrix[i * N + j] * input_vector[j];
        }
        golden_output[i] = (int16_t)(sum & 0xFFFF);
    }
    
    // 清零输出缓冲区
    memset(output_vector, 0, sizeof(output_vector));
}

// 验证结果
int verify_result(void) {
    int errors = 0;
    for (int i = 0; i < M; i++) {
        if (output_vector[i] != golden_output[i]) {
            printf("Mismatch at [%d]: hw=%d, golden=%d\n", 
                   i, output_vector[i], golden_output[i]);
            errors++;
            if (errors > 10) break;  // 最多显示10个错误
        }
    }
    return errors;
}

int main(void) {
    printf("\n");
    printf("================================\n");
    printf("=   VMMA Accelerator Test      =\n");
    printf("================================\n");
    printf("\n");
    
    // 初始化数据
    printf("Initializing test data...\n");
    init_data();
    
    // 初始化 VMMA
    printf("Initializing VMMA...\n");
    vmma_init();
    
    // 配置 VMMA
    vmma_config_t config = {
        .dtype = VMMA_DTYPE_INT16,
        .m = M,
        .n = N,
        .w_addr = (uint64_t)weight_matrix,
        .x_addr = (uint64_t)input_vector,
        .y_addr = (uint64_t)output_vector,
        .w_stride = N * sizeof(int16_t)  // 每行字节数
    };
    
    printf("Configuration:\n");
    printf("  M=%d, N=%d, dtype=INT16\n", M, N);
    printf("  W_addr=0x%lx, X_addr=0x%lx, Y_addr=0x%lx\n",
           config.w_addr, config.x_addr, config.y_addr);
    
    // 启动性能计数
    start_timer();
    
    // 执行矩阵向量乘法
    printf("Starting VMMA computation...\n");
    int result = vmma_execute(&config);
    
    // 停止计时
    stop_timer();
    
    if (result != 0) {
        printf("ERROR: VMMA execution failed with code %d\n", result);
        return result;
    }
    
    uint64_t cycles = get_timer();
    uint64_t hw_cycles = vmma_get_cycle_count();
    
    printf("\n");
    printf("Computation completed!\n");
    printf("  Total cycles (SW): %llu\n", cycles);
    printf("  HW cycles: %llu\n", hw_cycles);
    printf("  Performance: %.2f MACs/cycle\n", 
           (double)(M * N) / (double)hw_cycles);
    
    // 验证结果
    printf("\nVerifying results...\n");
    int errors = verify_result();
    
    if (errors == 0) {
        printf("PASS: All results match!\n");
    } else {
        printf("FAIL: %d mismatches found!\n", errors);
        return errors;
    }
    
    printf("\nTest completed successfully.\n");
    return 0;
}
```

---

## 6. 编译与测试

### 6.1 编译硬件

```bash
# 1. 确保 VMMA 文件列表已添加到 sim/filelist.f

# 2. 编译仿真
cd sim
make vcs

# 或 Verilator
make verilate
```

### 6.2 编译软件

```bash
cd software

# 编译 VMMA 驱动和测试应用
make vmma_test

# 查看生成的文件
ls -la build/bin/vmma_test*
```

### 6.3 运行仿真

```bash
cd sim

# 运行测试
make vcs-run app=../software/build/bin/vmma_test

# 带波形（调试用）
make vcs-wave app=../software/build/bin/vmma_test
make verdi
```

---

## 7. 调试指南

### 7.1 常见问题

| 问题 | 可能原因 | 解决方法 |
|------|----------|----------|
| 无法访问寄存器 | 地址映射错误 | 检查 `ariane_soc_pkg.sv` 的基地址 |
| DMA 读写出错 | AXI 协议违规 | 检查地址对齐和突发长度 |
| 结果错误 | 数据类型不匹配 | 确认 dtype 配置与数据一致 |
| 仿真挂起 | 死锁或无响应 | 检查 AXI ready/valid 握手 |

### 7.2 波形调试信号

在 Verdi 中关注以下信号：

```
// VMMA 配置访问
dut.i_ariane_peripherals.i_vmma.slv_*

// VMMA DMA 访问
dut.i_ariane_peripherals.i_vmma.mst_*

// VMMA 内部状态
dut.i_ariane_peripherals.i_vmma.i_ctrl.*
dut.i_ariane_peripherals.i_vmma.i_dma.*

// AXI Crossbar
dut.i_axi_xbar.*
```

---

## 8. 性能优化建议

1. **数据对齐**：确保权重、输入、输出缓冲区 64 字节对齐
2. **批量处理**：对于小矩阵，考虑批量处理多个向量
3. **双缓冲**：使用乒乓缓冲隐藏 DMA 传输延迟
4. **数据类型**：根据精度要求选择最小数据类型（INT8 最快）

---

## 附录 A: 完整文件清单

**硬件文件：**
```
hardware/user_ip/vmma/
├── include/vmma_pkg.sv
├── rtl/vmma_top.sv
├── rtl/vmma_regbank.sv
├── rtl/vmma_ctrl.sv
├── rtl/vmma_dma.sv
├── rtl/vmma_compute.sv
├── rtl/vmma_sram.sv
└── filelist.f
```

**修改的现有文件：**
```
hardware/soc/maximum/ariane_soc_pkg.sv
hardware/soc/maximum/ariane_peripherals.sv
hardware/soc/maximum/ariane_soc_top.sv
sim/filelist.f
```

**软件文件：**
```
software/soc/include/vmma.h
software/soc/src/vmma.c
software/app/vmma_test/
├── app.mk
└── main.c
```

