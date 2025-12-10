//------------------------------------------------------------------------------
// Description: DMA Engine Wrapper Module
// Author:      Zhantong Zhu <zhu_20021122@stu.pku.edu.cn> [Peking University]
//------------------------------------------------------------------------------

`include "axi_typedef.svh"
`include "axi_assign.svh"
`include "reg_typedef.svh"
`include "reg_assign.svh"

module dma_wrapper #(
    parameter int unsigned AXI_ADDR_WIDTH = 64,
    parameter int unsigned AXI_DATA_WIDTH = 64,
    parameter int unsigned AXI_SLAVE_ID_WIDTH = 4,
    parameter int unsigned AXI_MASTER_ID_WIDTH = 4,
    parameter int unsigned AXI_USER_WIDTH = 1
) (
    input logic clk_i,
    input logic rst_ni,
    AXI_BUS.Slave  slave,
    AXI_BUS.Master master
);

    // Define AXI types
    // We need separate types for Slave (Reg) and Master (DMA) because of ID width
    `AXI_TYPEDEF_ALL(dma_slave_axi, logic [AXI_ADDR_WIDTH-1:0], logic [AXI_SLAVE_ID_WIDTH-1:0], logic [AXI_DATA_WIDTH-1:0], logic [AXI_DATA_WIDTH/8-1:0], logic [AXI_USER_WIDTH-1:0])
    `AXI_TYPEDEF_ALL(dma_master_axi, logic [AXI_ADDR_WIDTH-1:0], logic [AXI_MASTER_ID_WIDTH-1:0], logic [AXI_DATA_WIDTH-1:0], logic [AXI_DATA_WIDTH/8-1:0], logic [AXI_USER_WIDTH-1:0])

    // Define Reg Bus types
    `REG_BUS_TYPEDEF_ALL(dma_reg, logic [AXI_ADDR_WIDTH-1:0], logic [AXI_DATA_WIDTH-1:0], logic [AXI_DATA_WIDTH/8-1:0])

    // Signals for Register Interface
    dma_reg_req_t reg_req;
    dma_reg_rsp_t reg_rsp;

    // Instantiate AXI to Reg Interface
    REG_BUS #(
        .ADDR_WIDTH ( AXI_ADDR_WIDTH ),
        .DATA_WIDTH ( AXI_DATA_WIDTH )
    ) reg_bus (clk_i);

    axi_to_reg_intf #(
        .ADDR_WIDTH ( AXI_ADDR_WIDTH ),
        .DATA_WIDTH ( AXI_DATA_WIDTH ),
        .ID_WIDTH   ( AXI_SLAVE_ID_WIDTH ),
        .USER_WIDTH ( AXI_USER_WIDTH )
    ) i_axi_to_reg_intf (
        .clk_i      ( clk_i   ),
        .rst_ni     ( rst_ni  ),
        .testmode_i ( 1'b0    ),
        .in         ( slave   ),
        .reg_o      ( reg_bus )
    );

    `REG_BUS_ASSIGN_TO_REQ(reg_req, reg_bus)
    `REG_BUS_ASSIGN_FROM_RSP(reg_bus, reg_rsp)

    // Signals for DMA Backend
    dma_master_axi_req_t axi_read_req, axi_write_req;
    dma_master_axi_resp_t axi_read_rsp, axi_write_rsp;
    
    // Define the dma_req_t struct based on idma_backend_rw_axi requirements
    typedef struct packed {
        logic [AXI_ADDR_WIDTH-1:0] src_addr;
        logic [AXI_ADDR_WIDTH-1:0] dst_addr;
        logic [AXI_ADDR_WIDTH-1:0] length; // TFLenWidth
	logic [AXI_USER_WIDTH-1:0] user;
        struct packed {
            idma_pkg::protocol_e src_protocol;
            idma_pkg::protocol_e dst_protocol;
            idma_pkg::axi_options_t src;
            idma_pkg::axi_options_t dst;
            idma_pkg::backend_options_t beo;
            logic last;
        } opt;
    } idma_req_t;

    typedef struct packed {
        logic last;
        logic error;
        struct packed {
            idma_pkg::err_type_e err_type;
        } pld;
    } idma_rsp_t;

    idma_req_t dma_req;
    logic      dma_req_valid;
    logic      dma_req_ready;
    
    idma_rsp_t dma_rsp;
    logic      dma_rsp_valid;
    logic      dma_rsp_ready;

    idma_pkg::idma_busy_t busy;

    // Signals from Custom Regs
    logic [AXI_ADDR_WIDTH-1:0] reg_src_addr;
    logic [AXI_ADDR_WIDTH-1:0] reg_dst_addr;
    logic [AXI_ADDR_WIDTH-1:0] reg_length;
    logic [31:0]               reg_config;
    logic                      reg_launch;

    // Instantiate Custom DMA Registers
    dma_regs #(
        .reg_req_t      ( dma_reg_req_t ),
        .reg_rsp_t      ( dma_reg_rsp_t ),
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH )
    ) i_dma_regs (
        .clk_i      ( clk_i         ),
        .rst_ni     ( rst_ni        ),
        .req_i      ( reg_req       ),
        .rsp_o      ( reg_rsp       ),
        .src_addr_o ( reg_src_addr  ),
        .dst_addr_o ( reg_dst_addr  ),
        .length_o   ( reg_length    ),
        .config_o   ( reg_config    ),
        .launch_o   ( reg_launch    ),
        .busy_i     ( busy.buffer_busy | busy.r_dp_busy | busy.w_dp_busy ), // Simple busy aggregation
        .error_i    ( dma_rsp.error ),
        .ready_i    ( dma_req_ready )
    );

    // Map Register Outputs to DMA Request
    always_comb begin
        dma_req = '0;
        dma_req.src_addr = reg_src_addr;
        dma_req.dst_addr = reg_dst_addr;
        dma_req.length   = reg_length;
	dma_req.user	 = '0;        

        // Default Configuration
        dma_req.opt.src_protocol = idma_pkg::AXI;
        dma_req.opt.dst_protocol = idma_pkg::AXI;
        dma_req.opt.src.burst    = axi_pkg::BURST_INCR;
        dma_req.opt.dst.burst    = axi_pkg::BURST_INCR;
        dma_req.opt.src.cache    = axi_pkg::CACHE_MODIFIABLE;
        dma_req.opt.dst.cache    = axi_pkg::CACHE_MODIFIABLE;
        
        // Map Config Register bits to options if needed
        // Example: reg_config[0] -> decouple_aw
        // dma_req.opt.beo.decouple_aw = reg_config[0];
        dma_req.opt.beo.decouple_aw = 1'b0;
        dma_req.opt.beo.decouple_rw = reg_config[1];
        
        dma_req.opt.last = 1'b1; // Single transfer is always last
    end

    assign dma_req_valid = reg_launch;

    // Instantiate IDMA Backend
    idma_backend_rw_axi #(
        .DataWidth            ( AXI_DATA_WIDTH               ),
        .AddrWidth            ( AXI_ADDR_WIDTH               ),
        .UserWidth            ( AXI_USER_WIDTH               ),
        .AxiIdWidth           ( AXI_MASTER_ID_WIDTH          ),
	    .TFLenWidth	          ( AXI_ADDR_WIDTH		         ),
        .idma_req_t           ( idma_req_t                   ),
        .idma_rsp_t           ( idma_rsp_t                   ),
        .idma_eh_req_t        ( idma_pkg::idma_eh_req_t      ),
        .idma_busy_t          ( idma_pkg::idma_busy_t	     ),
        .axi_req_t            ( dma_master_axi_req_t         ),
        .axi_rsp_t            ( dma_master_axi_resp_t        ),
        .read_meta_channel_t  ( dma_master_axi_ar_chan_t     ),
        .write_meta_channel_t ( dma_master_axi_aw_chan_t     )
    ) i_idma_backend (
        .clk_i            ( clk_i           ),
        .rst_ni           ( rst_ni          ),
        .testmode_i       ( 1'b0            ),
        .idma_req_i       ( dma_req         ),
        .req_valid_i      ( dma_req_valid   ),
        .req_ready_o      ( dma_req_ready   ),
        .idma_rsp_o       ( dma_rsp         ),
        .rsp_valid_o      ( dma_rsp_valid   ),
        .rsp_ready_i      ( 1'b1            ), // Always ready to accept response
        .idma_eh_req_i    ( '0              ),
        .eh_req_valid_i   ( 1'b0            ),
        .eh_req_ready_o   (                 ),
        .axi_read_req_o   ( axi_read_req    ),
        .axi_read_rsp_i   ( axi_read_rsp    ),
        .axi_write_req_o  ( axi_write_req   ),
        .axi_write_rsp_i  ( axi_write_rsp   ),
        .busy_o           ( busy            )
    );

    // Combine AXI Read and Write requests to Master Interface
    dma_master_axi_req_t master_req;
    dma_master_axi_resp_t master_resp;

    always_comb begin
        master_req = '0;
        
        // AR Channel
        master_req.ar       = axi_read_req.ar;
        master_req.ar_valid = axi_read_req.ar_valid;
        master_req.r_ready  = axi_read_req.r_ready;

        // AW Channel
        master_req.aw       = axi_write_req.aw;
        master_req.aw_valid = axi_write_req.aw_valid;
        master_req.b_ready  = axi_write_req.b_ready;

        // W Channel
        master_req.w        = axi_write_req.w;
        master_req.w_valid  = axi_write_req.w_valid;
    end

    // Split Master Response to Read and Write responses
    always_comb begin
        axi_read_rsp = '0;
        axi_write_rsp = '0;

        // Read Response
        axi_read_rsp.ar_ready = master_resp.ar_ready;
        axi_read_rsp.r        = master_resp.r;
        axi_read_rsp.r_valid  = master_resp.r_valid;

        // Write Response
        axi_write_rsp.aw_ready = master_resp.aw_ready;
        axi_write_rsp.w_ready  = master_resp.w_ready;
        axi_write_rsp.b        = master_resp.b;
        axi_write_rsp.b_valid  = master_resp.b_valid;
    end

    // Assign to/from Master Interface
    `AXI_ASSIGN_FROM_REQ(master, master_req)
    `AXI_ASSIGN_TO_RESP(master_resp, master)

endmodule
