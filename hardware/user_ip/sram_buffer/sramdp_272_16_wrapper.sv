// Wrapper for ARM Memory Compiler generated sramdp_272_16 dual-port SRAM.
// Provides user-friendly interface with standard signal polarities:
//   - cen_a/cen_b: active-low chip enable (0 = enabled)
//   - wen_a/wen_b: active-high write enable (1 = write, 0 = read)
// The wrapper handles signal polarity conversion and ties off test/EMA signals
// to safe default values for normal operation.
//
// SRAM Specifications:
//   - Depth: 272 words
//   - Width: 16 bits
//   - Address: 9 bits (272 < 2^9 = 512)
//   - Dual-port: Port A and Port B can operate independently

module sramdp_272_16_wrapper #(
    parameter int DATA_WIDTH = 16,
    parameter int ADDR_WIDTH = 9,
    parameter int DEPTH      = 272
)(
    input  logic                  clk,
    
    // Port A (read/write shared)
    input  logic                  cen_a,    // active-low chip enable
    input  logic                  wen_a,    // active-high write enable (1=write, 0=read)
    input  logic [ADDR_WIDTH-1:0] addr_a,
    input  logic [DATA_WIDTH-1:0] din_a,
    output logic [DATA_WIDTH-1:0] dout_a,
    
    // Port B (read/write shared)
    input  logic                  cen_b,    // active-low chip enable
    input  logic                  wen_b,    // active-high write enable (1=write, 0=read)
    input  logic [ADDR_WIDTH-1:0] addr_b,
    input  logic [DATA_WIDTH-1:0] din_b,
    output logic [DATA_WIDTH-1:0] dout_b
);

    // Signal polarity conversion for ARM SRAM
    // ARM SRAM uses active-low write enable (wena/wenb: 0=write, 1=read)
    wire cena_n = cen_a;           // Keep active-low
    wire wena_n = ~wen_a;          // Convert: high-active → low-active
    wire cenb_n = cen_b;           // Keep active-low
    wire wenb_n = ~wen_b;          // Convert: high-active → low-active

    // EMA (Extra Margin Adjustment) settings for optimal timing/power.
    // ARM Memory Compiler recommended defaults for this instance.
    wire [2:0] emaa  = 3'b100;     // Port A read margin (recommended: 7)
    wire [1:0] emawa = 2'b10;      // Port A write margin (recommended: 3)
    wire       emasa = 1'b0;       // Port A sense amp margin (recommended: 1)
    wire [2:0] emab  = 3'b100;     // Port B read margin (recommended: 7)
    wire [1:0] emawb = 2'b10;      // Port B write margin (recommended: 3)
    wire       emasb = 1'b0;       // Port B sense amp margin (recommended: 1)

    // Test and DFT signals - tied off for normal operation
    wire       ret1n     = 1'b1;   // Retention mode disabled (normal operation)
    wire       tena      = 1'b1;   // Test mode A disabled
    wire       tenb      = 1'b1;   // Test mode B disabled
    wire       tcena     = 1'b0;   // Test chip enable A
    wire       twena     = 1'b0;   // Test write enable A
    wire [8:0] taa       = 9'b0;   // Test address A
    wire [15:0] tda      = 16'b0;  // Test data A
    wire       tcenb     = 1'b0;   // Test chip enable B
    wire       twenb     = 1'b0;   // Test write enable B
    wire [8:0] tab       = 9'b0;   // Test address B
    wire [15:0] tdb      = 16'b0;  // Test data B
    wire [1:0] sia       = 2'b0;   // Scan input A
    wire       sea       = 1'b0;   // Scan enable A
    wire [1:0] sib       = 2'b0;   // Scan input B
    wire       seb       = 1'b0;   // Scan enable B
    wire       dftrambyp = 1'b0;   // DFT RAM bypass disabled
    wire       colldisn  = 1'b1;   // Collision disable (enable collision detection)

    // Unused output ports from ARM SRAM
    wire       cenya;              // Chip enable output A (for test)
    wire       wenya;              // Write enable output A (for test)
    wire [8:0] aya;                // Address output A (for test)
    wire       cenyb;              // Chip enable output B (for test)
    wire       wenyb;              // Write enable output B (for test)
    wire [8:0] ayb;                // Address output B (for test)
    wire [1:0] soa;                // Scan output A
    wire [1:0] sob;                // Scan output B

    // Instantiate ARM Memory Compiler generated SRAM
    sramdp_272_16 u_sramdp_272_16 (
        // Port A
        .clka   (clk),
        .cena   (cena_n),
        .wena   (wena_n),
        .aa     (addr_a),
        .da     (din_a),
        .qa     (dout_a),
        
        // Port B
        .clkb   (clk),
        .cenb   (cenb_n),
        .wenb   (wenb_n),
        .ab     (addr_b),
        .db     (din_b),
        .qb     (dout_b),
        
        // EMA settings
        .emaa   (emaa),
        .emawa  (emawa),
        .emasa  (emasa),
        .emab   (emab),
        .emawb  (emawb),
        .emasb  (emasb),
        
        // Test and DFT signals
        .ret1n     (ret1n),
        .tena      (tena),
        .tcena     (tcena),
        .twena     (twena),
        .taa       (taa),
        .tda       (tda),
        .tenb      (tenb),
        .tcenb     (tcenb),
        .twenb     (twenb),
        .tab       (tab),
        .tdb       (tdb),
        .sia       (sia),
        .sea       (sea),
        .sib       (sib),
        .seb       (seb),
        .dftrambyp (dftrambyp),
        .colldisn  (colldisn),
        
        // Test outputs (unused)
        .cenya  (cenya),
        .wenya  (wenya),
        .aya    (aya),
        .cenyb  (cenyb),
        .wenyb  (wenyb),
        .ayb    (ayb),
        .soa    (soa),
        .sob    (sob)
    );

endmodule
