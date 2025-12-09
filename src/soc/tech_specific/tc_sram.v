//////////////////////////////////////////////////////////////////////////////////
// Designer:        Mingxuan Li [Peking University] <miangxuanli_siris@163.com>
// Description:     SRAM Tech-Specific Module
//////////////////////////////////////////////////////////////////////////////////

module sram_be_1024x64 (
    input  wire         clk_i           ,
    input  wire         chip_enable_i   ,
    input  wire         write_enable_i  ,
    input  wire [9:0]   addr_i          ,
    input  wire [63:0]  write_data_i    ,
    input  wire [63:0]  bit_enable_i    ,
    output wire [63:0]  read_data_o
);

`ifdef FPGA
    wire [7:0] byte_mask;
    assign byte_mask = {
        bit_enable_i[56], bit_enable_i[48], bit_enable_i[40], bit_enable_i[32],
        bit_enable_i[24], bit_enable_i[16], bit_enable_i[8], bit_enable_i[0]
    };
    bram_be_1024x64 sram_inst (         // WITH byte enable!!!
        .clka       ( clk_i         ),
        .ena        ( chip_enable_i ),
        .wea        ( write_enable_i ? byte_mask : '0 ),
        .addra      ( addr_i        ),
        .dina       ( write_data_i  ),
        .douta      ( read_data_o   )
    );
`else
    TSMC_SRAM_BITMASK_1024x64 sram_inst (
        .CLK      ( clk_i           ),
        .CEB      ( ~chip_enable_i  ),
        .WEB      ( ~write_enable_i ),
        .BWEB     ( ~bit_enable_i   ),
        .A        ( addr_i          ),
        .D        ( write_data_i    ),
        .Q        ( read_data_o     ),
        .WTSEL    ( 2'b00           ),
        .RTSEL    ( 2'b01           )
    );
`endif

endmodule

module rf_be_128x46 (
    input  wire         clk_i           ,
    input  wire         chip_enable_i   ,
    input  wire         write_enable_i  ,
    input  wire [6:0]   addr_i          ,
    input  wire [45:0]  write_data_i    ,
    input  wire [45:0]  bit_enable_i    ,
    output wire [45:0]  read_data_o
);

`ifdef FPGA
    bram_wo_be_128x46 rf_inst (         // NO byte enable!!!
      .clka   ( clk_i          ),       // input wire clka
      .ena    ( chip_enable_i  ),       // input wire ena
      .wea    ( write_enable_i ),       // input wire [0 : 0] wea
      .addra  ( addr_i         ),       // input wire [6 : 0] addra
      .dina   ( write_data_i   ),       // input wire [45 : 0] dina
      .douta  ( read_data_o    )        // output wire [45 : 0] douta
    );
`else
    TSMC_RF_BITMASK_128x46 rf_inst (
        .CLK      ( clk_i           ),
        .BWEB     ( ~bit_enable_i   ),
        .CEB      ( ~chip_enable_i  ),
        .WEB      ( ~write_enable_i ),
        .A        ( addr_i          ),
        .D        ( write_data_i    ),
        .Q        ( read_data_o     ),
        .WTSEL    ( 2'b01           ),
        .RTSEL    ( 2'b01           )
    );
`endif

endmodule

module rf_be_128x128 (
    input  wire         clk_i           ,
    input  wire         chip_enable_i   ,
    input  wire         write_enable_i  ,
    input  wire [6:0]   addr_i          ,
    input  wire [127:0] write_data_i    ,
    input  wire [127:0] bit_enable_i    ,
    output wire [127:0] read_data_o
);

`ifdef FPGA
    bram_wo_be_128x128 rf_inst (        // NO byte enable!!!
      .clka   ( clk_i          ),       // input wire clka
      .ena    ( chip_enable_i  ),       // input wire ena
      .wea    ( write_enable_i ),       // input wire [0 : 0] wea
      .addra  ( addr_i         ),       // input wire [6 : 0] addra
      .dina   ( write_data_i   ),       // input wire [127 : 0] dina
      .douta  ( read_data_o    )        // output wire [127 : 0] douta
    );
`else
    TSMC_RF_BITMASK_128x128 rf_inst (
        .CLK      ( clk_i           ),
        .BWEB     ( ~bit_enable_i   ),
        .CEB      ( ~chip_enable_i  ),
        .WEB      ( ~write_enable_i ),
        .A        ( addr_i          ),
        .D        ( write_data_i    ),
        .Q        ( read_data_o     ),
        .WTSEL    ( 2'b01           ),
        .RTSEL    ( 2'b01           )
    );
`endif

endmodule
