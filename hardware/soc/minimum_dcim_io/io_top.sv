//输入型
// PDDWUW0408SDGH_V I_refclk (
//     .OEN    (1'b1),      // 输出使能关
//     .IE     (1'b1),      // 输入使能开
//     .PU     (1'b0),      // 上拉关闭
//     .DS     (1'b0),      // 驱动强度配置
//     .PAD    (refclk),    // 连接到顶层输入
//     .C      (refclk_int),// 连接到处理器内部
//     .PD     (1'b0),      // 下拉关闭
//     .I      (1'b0)       // 未用(输入模式)
// );

//输出型
// PDDWUW0408SDGH_H I_tdo (
//     .OEN    (1'b0),      // 输出使能开
//     .IE     (1'b0),      // 输入使能关
//     .PU     (1'b0),      // 上拉关闭
//     .DS     (1'b1),      // 驱动强度增强
//     .PAD    (tdo),       // 连接到顶层输出
//     .C      (),          // 未用(输出模式)
//     .PD     (1'b0),      // 下拉关闭
//     .I      (tdo_int)    // 来自处理器输出
// );

module io_top(
    input         IO_dco_ext_clk_i,
    input         IO_dco_en_i,

    input  [5:0]  IO_dco_cc_sel_i,

    input  [5:0]  IO_dco_fc_sel_i,

    input         IO_dco_clk_sel_i,

    input  [1:0]  IO_dco_freq_sel_i,

    output        IO_dco_clk_div_o,
    input         IO_rst_ni,
    input         IO_uart_rx_i,
    output        IO_uart_tx_o,
    output        IO_exit_o,
    input         IO_jtag_tck_i,
    input         IO_jtag_tms_i,
    input         IO_jtag_tdi_i,
    input         IO_jtag_trst_ni,
    output        IO_jtag_tdo_o,
    output        IO_jtag_tdo_driven_o,
    input         IO_debug_enable_i 
);

logic        core_dco_ext_clk_i;
logic        core_dco_en_i;
logic [5:0]  core_dco_cc_sel_i;
logic [5:0]  core_dco_fc_sel_i;
logic        core_dco_clk_sel_i;
logic [1:0]  core_dco_freq_sel_i;
logic        core_dco_clk_div_o;
logic        core_rst_ni;
logic        core_uart_rx_i;
logic        core_uart_tx_o;
logic        core_exit_o;
logic        core_jtag_tck_i;
logic        core_jtag_tms_i;
logic        core_jtag_tdi_i;
logic        core_jtag_trst_ni;
logic        core_jtag_tdo_o;
logic        core_jtag_tdo_driven_o;
logic        core_debug_enable_i;




ariane_soc_top u_ariane_soc_top (
    .dco_ext_clk_i(core_dco_ext_clk_i),
    .dco_en_i(core_dco_en_i),
    .dco_cc_sel_i(core_dco_cc_sel_i),
    .dco_fc_sel_i(core_dco_fc_sel_i),
    .dco_clk_sel_i(core_dco_clk_sel_i),
    .dco_freq_sel_i(core_dco_freq_sel_i),
    .dco_clk_div_o(core_dco_clk_div_o),
    .rst_ni(core_rst_ni),
    .uart_rx_i(core_uart_rx_i),
    .uart_tx_o(core_uart_tx_o),
    .exit_o(core_exit_o),
    .jtag_tck_i(core_jtag_tck_i),
    .jtag_tms_i(core_jtag_tms_i),
    .jtag_tdi_i(core_jtag_tdi_i),
    .jtag_trst_ni(core_jtag_trst_ni),
    .jtag_tdo_o(core_jtag_tdo_o),
    .jtag_tdo_driven_o(core_jtag_tdo_driven_o),
    .debug_enable_i (core_debug_enable_i)
);



////////////////////////////////////////////////////////////////////////////
// 左侧
//输入型
PDDWUW0408SDGH_H u_pad_jtag_tms_i (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_jtag_tms_i),    // 连接到顶层输入
    .C      (core_jtag_tms_i),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);

//输入型
PDDWUW0408SDGH_H u_pad_jtag_tdi_i (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_jtag_tdi_i),    // 连接到顶层输入
    .C      (core_jtag_tdi_i),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);

//输入型
PDDWUW0408SDGH_H u_pad_jtag_trst_ni (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_jtag_trst_ni),    // 连接到顶层输入
    .C      (core_jtag_trst_ni),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);

//输入型
PDDWUW0408SDGH_H u_pad_jtag_tck_i (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_jtag_tck_i),    // 连接到顶层输入
    .C      (core_jtag_tck_i),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);

//输出型
PDDWUW0408SDGH_H u_pad_jtag_tdo_driven_o (
    .OEN    (1'b0),      // 输出使能开
    .IE     (1'b0),      // 输入使能关
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b1),      // 驱动强度增强
    .PAD    (IO_jtag_tdo_driven_o),       // 连接到顶层输出
    .C      (),          // 未用(输出模式)
    .PD     (1'b0),      // 下拉关闭
    .I      (core_jtag_tdo_driven_o)    // 来自处理器输出
);
//输出型
PDDWUW0408SDGH_H u_pad_jtag_tdo_o (
    .OEN    (1'b0),      // 输出使能开
    .IE     (1'b0),      // 输入使能关
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b1),      // 驱动强度增强
    .PAD    (IO_jtag_tdo_o),       // 连接到顶层输出
    .C      (),          // 未用(输出模式)
    .PD     (1'b0),      // 下拉关闭
    .I      (core_jtag_tdo_o)    // 来自处理器输出
);

////////////////////////////////////////////////////////////////////////
// 上侧
//输入型
PDDWUW0408SDGH_V u_pad_uart_rx_i (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_uart_rx_i),    // 连接到顶层输入
    .C      (core_uart_rx_i),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);

//输出型
PDDWUW0408SDGH_V u_pad_uart_tx_o (
    .OEN    (1'b0),      // 输出使能开
    .IE     (1'b0),      // 输入使能关
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b1),      // 驱动强度增强
    .PAD    (IO_uart_tx_o),       // 连接到顶层输出
    .C      (),          // 未用(输出模式)
    .PD     (1'b0),      // 下拉关闭
    .I      (core_uart_tx_o)    // 来自处理器输出
);

//输出型
PDDWUW0408SDGH_V u_pad_exit_o (
    .OEN    (1'b0),      // 输出使能开
    .IE     (1'b0),      // 输入使能关
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b1),      // 驱动强度增强
    .PAD    (IO_exit_o),       // 连接到顶层输出
    .C      (),          // 未用(输出模式)
    .PD     (1'b0),      // 下拉关闭
    .I      (core_exit_o)    // 来自处理器输出
);
//输入型
PDDWUW0408SDGH_V u_pad_debug_enable_i (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_debug_enable_i),    // 连接到顶层输入
    .C      (core_debug_enable_i),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);
//输入型
PDDWUW0408SDGH_V u_pad_rst_ni (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_rst_ni),    // 连接到顶层输入
    .C      (core_rst_ni),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);

////////////////////////////////////////////////////////////////////////////
// 右侧
//输出型
PDDWUW0408SDGH_H u_pad_dco_clk_div_o (
    .OEN    (1'b0),      // 输出使能开
    .IE     (1'b0),      // 输入使能关
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b1),      // 驱动强度增强
    .PAD    (IO_dco_clk_div_o),       // 连接到顶层输出
    .C      (),          // 未用(输出模式)
    .PD     (1'b0),      // 下拉关闭
    .I      (core_dco_clk_div_o)    // 来自处理器输出
);



//输入型
PDDWUW0408SDGH_H u_pad_dco_clk_sel_i (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_dco_clk_sel_i),    // 连接到顶层输入
    .C      (core_dco_clk_sel_i),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);

//输入型
PDDWUW0408SDGH_H u_pad_dco_freq_sel_i_0 (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_dco_freq_sel_i[0]),    // 连接到顶层输入
    .C      (core_dco_freq_sel_i[0]),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);

//输入型
PDDWUW0408SDGH_H u_pad_dco_freq_sel_i_1 (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_dco_freq_sel_i[1]),    // 连接到顶层输入
    .C      (core_dco_freq_sel_i[1]),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);

//输入型
PDDWUW0408SDGH_H u_pad_dco_fc_sel_i_0 (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_dco_fc_sel_i[0]),    // 连接到顶层输入
    .C      (core_dco_fc_sel_i[0]),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);

//输入型
PDDWUW0408SDGH_H u_pad_dco_fc_sel_i_1 (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_dco_fc_sel_i[1]),    // 连接到顶层输入
    .C      (core_dco_fc_sel_i[1]),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);

//输入型
PDDWUW0408SDGH_H u_pad_dco_fc_sel_i_2 (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_dco_fc_sel_i[2]),    // 连接到顶层输入
    .C      (core_dco_fc_sel_i[2]),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);

//输入型
PDDWUW0408SDGH_H u_pad_dco_fc_sel_i_3 (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_dco_fc_sel_i[3]),    // 连接到顶层输入
    .C      (core_dco_fc_sel_i[3]),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);

//输入型
PDDWUW0408SDGH_H u_pad_dco_fc_sel_i_4 (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_dco_fc_sel_i[4]),    // 连接到顶层输入
    .C      (core_dco_fc_sel_i[4]),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);

//输入型
PDDWUW0408SDGH_H u_pad_dco_fc_sel_i_5 (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_dco_fc_sel_i[5]),    // 连接到顶层输入
    .C      (core_dco_fc_sel_i[5]),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);


////////////////////////////////////////////////////////////////////////////
// 下侧
//输入型
PDDWUW0408SDGH_V u_pad_dco_ext_clk_i (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_dco_ext_clk_i),    // 连接到顶层输入
    .C      (core_dco_ext_clk_i),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);
//输入型
PDDWUW0408SDGH_V u_pad_dco_en_i (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_dco_en_i),    // 连接到顶层输入
    .C      (core_dco_en_i),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);
//输入型
PDDWUW0408SDGH_V u_pad_dco_cc_sel_i_0 (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_dco_cc_sel_i[0]),    // 连接到顶层输入
    .C      (core_dco_cc_sel_i[0]),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);
//输入型
PDDWUW0408SDGH_V u_pad_dco_cc_sel_i_1 (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_dco_cc_sel_i[1]),    // 连接到顶层输入
    .C      (core_dco_cc_sel_i[1]),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);
//输入型
PDDWUW0408SDGH_V u_pad_dco_cc_sel_i_2 (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_dco_cc_sel_i[2]),    // 连接到顶层输入
    .C      (core_dco_cc_sel_i[2]),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);

//输入型
PDDWUW0408SDGH_V u_pad_dco_cc_sel_i_3 (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_dco_cc_sel_i[3]),    // 连接到顶层输入
    .C      (core_dco_cc_sel_i[3]),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);
//输入型
PDDWUW0408SDGH_V u_pad_dco_cc_sel_i_4 (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_dco_cc_sel_i[4]),    // 连接到顶层输入
    .C      (core_dco_cc_sel_i[4]),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);

//输入型
PDDWUW0408SDGH_V u_pad_dco_cc_sel_i_5 (
    .OEN    (1'b1),      // 输出使能关
    .IE     (1'b1),      // 输入使能开
    .PU     (1'b0),      // 上拉关闭
    .DS     (1'b0),      // 驱动强度配置
    .PAD    (IO_dco_cc_sel_i[5]),    // 连接到顶层输入
    .C      (core_dco_cc_sel_i[5]),// 连接到处理器内部
    .PD     (1'b0),      // 下拉关闭
    .I      (1'b0)       // 未用(输入模式)
);





endmodule