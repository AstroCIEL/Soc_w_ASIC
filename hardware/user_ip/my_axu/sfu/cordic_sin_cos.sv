`include "registers.svh"
import posit_types_pkg::*;

// 先把大致的时序和逻辑弄对，然后再考虑输入的分段讨论、最后分类输出的情况
module cordic_sin_cos#(
    parameter int unsigned n_i = 16,                 // posit字长
    parameter int unsigned es_i = 2,                // exponent size
    parameter int unsigned n_o = 16,
    parameter int unsigned es_o = 2,
    parameter int unsigned ALIGN_WIDTH = 32,         // alignment width
    parameter int unsigned NUM_ITER=7  //迭代次数
)(
    input  logic clk_i,
    input  logic rstn_i,
    
    input logic calc_start_i,
    output logic calc_done_o,

    input logic [n_i-1:0] theta_i,
    output logic [n_o-1:0] sin_o,
    output logic [n_o-1:0] cos_o
);
    // ==============================================
    // 1. CORDIC 常量：Posit16_2 编码 
    // ==============================================
    // localparam logic [n_i-1:0] POSIT_ZERO   = 16'h0000;
    // CORDIC 初始增益 K = 0.60725 (Posit16_2 编码)
    // localparam logic [n_i-1:0] CORDIC_K     = 16'h39b8; 
    // 全0解码结果：rg_exp=-60=11000100?
    localparam posit_acc_t POSIT_ZERO ='{sign:1'b0, rg_exp:-8'sd60, mant: 14'h0000};
    //mant符合1.f的形式
    localparam posit_acc_t CORDIC_K='{sign:1'b0, rg_exp:-8'sd1, mant: 14'h26e0};
    localparam posit_acc_t NEG_CORDIC_K='{sign:1'b1, rg_exp:-8'sd1, mant: 14'h26e0};
    // localparam posit_acc_t CORDIC_K='{sign:1'b0, rg_exp:-8'sd1, mant: 14'h9b8};


    // 移位因子：2^-j 1位符号位，7位rg_exp，12位mant
    // localparam logic [n_i-1:0] SHIFT_FACTOR [0:NUM_ITER-1] = '{
    //     16'h4000,  // 2^0  rg_exp=000010
    //     16'h3800,  // 2^-1 rg_exp=11111
    //     16'h3000,  // 2^-2 rg_exp=11110
    //     16'h2800,  // 2^-3 rg_exp=11101
    //     16'h2000,  // 2^-4  rg_exp=11100
    //     16'h1c00,  i=5
    //     16'h1800,  i=6
    //     16'h1400,  i=7
    //     16'h1000,  i=8
         
    // };
    // // 相位表：arctan(2^-j) (Posit16_2 编码)
    // localparam logic [n_i-1:0] PHASE [0:NUM_ITER-1] = '{
    //     16'h3c91,  // 45.0°=pai/4=0.7853981633974
    //     16'h36d6,  // 26.565°=0.4636467157922
    //     16'h2fae,  // 14.036°=0.2449744138099
    //     16'h27eb,  // 7.125°=0.1243547092045
    //     16'h1ffd  // 3.576°=0.0624129740513
    //     16'h1bff  //1.790°=0.0312413936106
    //     16'h17ff  //  0.895°=0.015620698053
    //     16'h1400       // 弧度=0.0078123410601
    //     16'h1000     //弧度=0.0039062301319
    // };
    //不需要这么多迭代次数的话可以注释掉后面几行
    localparam posit_in_t SHIFT_FACTOR [0:8] = '{
        '{sign:1'b0, rg_exp:7'sd0, mant:12'h800},
        '{sign:1'b0, rg_exp:-7'sd1, mant:12'h800},
        '{sign:1'b0, rg_exp:-7'sd2, mant:12'h800},
        '{sign:1'b0, rg_exp:-7'sd3, mant:12'h800},
        '{sign:1'b0, rg_exp:-7'sd4, mant:12'h800},
        '{sign:1'b0, rg_exp:-7'sd5, mant:12'h800},
        '{sign:1'b0, rg_exp:-7'sd6, mant:12'h800},
        '{sign:1'b0, rg_exp:-7'sd7, mant:12'h800},
        '{sign:1'b0, rg_exp:-7'sd8, mant:12'h800}
    };
    localparam posit_in_t PHASE [0:8]='{
        '{sign:1'b0, rg_exp:-7'sd1, mant:12'hC91},
        '{sign:1'b0, rg_exp:-7'sd2, mant:12'hed6},
        '{sign:1'b0, rg_exp:-7'sd3, mant:12'hfae},
        '{sign:1'b0, rg_exp:-7'sd4, mant:12'hfeb},
        '{sign:1'b0, rg_exp:-7'sd5, mant:12'hffa},
        '{sign:1'b0, rg_exp:-7'sd6, mant:12'hffe},
        '{sign:1'b0, rg_exp:-7'sd7, mant:12'hffe},
        '{sign:1'b0, rg_exp:-7'sd7, mant:12'h800},
        '{sign:1'b0, rg_exp:-7'sd8, mant:12'h800}
    };
    localparam posit_in_t HALF_PAI='{sign:1'b0, rg_exp:7'sd0,mant:12'hc91};
    localparam posit_in_t PAI='{sign:1'b0, rg_exp:7'sd1,mant:12'hc91};
    localparam posit_in_t ZERO_IN='{sign:1'b0,rg_exp:-7'sd60,mant:12'h000};


    // ==============================================
    // 2. 全流水线寄存器：存储每级迭代的 x / y / θ /比较的区间信息
    // ==============================================
    posit_acc_t x_pipe [NUM_ITER:0];
    posit_acc_t y_pipe [NUM_ITER:0];
    posit_in_t theta_pipe [NUM_ITER:0]; //定义为结构体，一直以解码后的形式传递
    logic greater [NUM_ITER:0];         //初始的theta与pai/2的大小关系
    // 【新增】使能信号寄存器：和数据同拍传递
     // 使能信号寄存器
    logic pipe_en [NUM_ITER:0];
    logic pipe_en_d1 [NUM_ITER-1:0];
    logic pipe_en_d2 [NUM_ITER-1:0];

    //==========3. 第0级：CORDIC 初始状态 已经是解码状态=============
    //先比较输入与pai/2的大小关系，确定所在的区间是(-pai/2, pai/2)还是(pai/2,3pai/2),再选择x_pipe[0]
    assign greater[0] = (theta_pipe[0].sign==1'b0) && 
                        (theta_pipe[0].rg_exp > HALF_PAI.rg_exp || 
                        (theta_pipe[0].rg_exp == HALF_PAI.rg_exp && 
                        theta_pipe[0].mant > HALF_PAI.mant));   
    assign x_pipe[0]  = greater[0] ? NEG_CORDIC_K : CORDIC_K;
    assign y_pipe[0]  = POSIT_ZERO;
    // assign x_pipe[0]     = CORDIC_K; 
    // assign y_pipe[0]     = POSIT_ZERO;
    //对输入的theta进行解码,通过组合逻辑传到第0级
    posit_decoder#(
        .n(n_i), .es(es_i)
    ) u_theta_decoder (
        .operand_i(theta_i),
        .sign_o(theta_pipe[0].sign),
        .rg_exp_o(theta_pipe[0].rg_exp),
        .mant_norm_o(theta_pipe[0].mant)
    );
    // 第0级使能：直接接输入使能
    assign pipe_en[0] = calc_start_i;
   


    // ==============================================
    // 4. 核心：展开迭代 + 3周期fma 
    // ==============================================
    generate
        for (genvar j = 0; j < NUM_ITER; j++) begin : gen_cordic_iteration

            // ==============================
            // 4.1 比较当前级 theta 与基准(0或pai)的大小关系
            // ==============================
            logic theta_sign;
            // assign theta_sign = theta_pipe[j].sign; // 1=负 0=正 
            assign theta_sign = greater[j]?~((theta_pipe[j].sign==0)&&(theta_pipe[j].rg_exp> PAI.rg_exp || (theta_pipe[j].rg_exp==PAI.rg_exp && theta_pipe[j].mant>PAI.mant))):theta_pipe[j].sign;    

            // ==============================
            // 4.2 选择移位因子和相位的正负
            // ==============================
            posit_in_t shift_sel, phase_sel;
            assign shift_sel.sign = theta_sign ? ~SHIFT_FACTOR[j].sign : SHIFT_FACTOR[j].sign; //这个和y一致，x计算时要取反(x本身是减法)
            assign shift_sel.rg_exp = SHIFT_FACTOR[j].rg_exp;
            assign shift_sel.mant = SHIFT_FACTOR[j].mant;
            
            assign phase_sel.sign = theta_sign ? 1'b0 : 1'b1;
            assign phase_sel.rg_exp = PHASE[j].rg_exp;
            assign phase_sel.mant = PHASE[j].mant;

            // ==============================
            // 4.3 类型转换：posit_acc_t -> posit_in_t
            // ==============================
            posit_in_t y_as_in, x_as_in;
            assign y_as_in.sign = y_pipe[j].sign;
            assign y_as_in.rg_exp = y_pipe[j].rg_exp[EXP_I_W-1:0];
            assign y_as_in.mant = y_pipe[j].mant[ACC_MANT_W-1:ACC_MANT_W-MANT_I_W];
            
            assign x_as_in.sign = x_pipe[j].sign;
            assign x_as_in.rg_exp = x_pipe[j].rg_exp[EXP_I_W-1:0];
            assign x_as_in.mant = x_pipe[j].mant[ACC_MANT_W-1:ACC_MANT_W-MANT_I_W];


            // ==============================
            // 4.4 用专门用于cordic模块的kernel 计算 x_new = x-sigma* y*shift (PE_line)
            // ==============================         
            posit_acc_t x_new;
            cordic_mac_kernel #(
                .n_i(n_i), .es_i(es_i),
                .n_o(n_o), .es_o(es_o),
                .ALIGN_WIDTH(ALIGN_WIDTH)
            ) u_mac_x (
                .clk_i(clk_i), .rstn_i(rstn_i),
                // 【直接复用现有使能，无需单独打拍】
                .en_i_1(pipe_en[j]),
                .en_i_2(pipe_en_d1[j]),
                .en_i_3(pipe_en_d2[j]),
                
                .act_sign_i(y_as_in.sign),
                .act_rg_exp_i(y_as_in.rg_exp),
                .act_mant_i(y_as_in.mant),
                
                .wgt_sign_i(~shift_sel.sign),
                .wgt_rg_exp_i(shift_sel.rg_exp),
                .wgt_mant_i(shift_sel.mant),
                
                .acc_sign_i(x_pipe[j].sign),
                .acc_rg_exp_i(x_pipe[j].rg_exp),
                .acc_mant_i(x_pipe[j].mant),
                
                .acc_sign_o(x_new.sign),
                .acc_rg_exp_o(x_new.rg_exp),
                .acc_mant_o(x_new.mant)
            );

            // ==============================
            // 4.5 计算 y_new = y+ sigma*x*shift 
            // ==============================
            posit_acc_t y_new;
            cordic_mac_kernel #(
                .n_i(n_i), .es_i(es_i),
                .n_o(n_o), .es_o(es_o),
                .ALIGN_WIDTH(ALIGN_WIDTH)
            ) u_mac_y (
                .clk_i(clk_i), .rstn_i(rstn_i),
                // 【和x完全同步，复用同一组使能】
                .en_i_1(pipe_en[j]),
                .en_i_2(pipe_en_d1[j]),
                .en_i_3(pipe_en_d2[j]),
                
                .act_sign_i(x_as_in.sign),
                .act_rg_exp_i(x_as_in.rg_exp),
                .act_mant_i(x_as_in.mant),
                
                .wgt_sign_i(shift_sel.sign),
                .wgt_rg_exp_i(shift_sel.rg_exp),
                .wgt_mant_i(shift_sel.mant),
                
                .acc_sign_i(y_pipe[j].sign),
                .acc_rg_exp_i(y_pipe[j].rg_exp),
                .acc_mant_i(y_pipe[j].mant),
                
                .acc_sign_o(y_new.sign),
                .acc_rg_exp_o(y_new.rg_exp),
                .acc_mant_o(y_new.mant)
            );

            // ==============================
            //4.6 计算theta_new：用PE_kernel改的一个二输入加法器，3周期
            // ==============================
            posit_in_t theta_new; 
            //TODO:theta_pipe精度是posit_in_t，但是adder的输出是posit_add_t精度，不匹配。精度更高的的方法应该是a+b=c都用acc精度，但这里选择直接截取sum_mant_o
            posit_acc_t sum; //避免综合时位宽不匹配
            posit_add_kernel#(
                .n_i(n_i), .es_i(es_i), .n_o(n_o), .es_o(es_o),.ALIGN_WIDTH(ALIGN_WIDTH)
            )u_posit_add_kernel(
                .clk_i(clk_i),
                .rstn_i(rstn_i),
                .en_i_1(pipe_en[j]),
                .en_i_2(pipe_en_d1[j]),
                .en_i_3(pipe_en_d2[j]),
                
                .a_sign_i(theta_pipe[j].sign),
                .a_rg_exp_i(theta_pipe[j].rg_exp),
                .a_mant_i(theta_pipe[j].mant),
                .b_sign_i(phase_sel.sign), //用theta_sign来选择是+phase还是-phase 若theta_sign=0则-phase
                .b_rg_exp_i(phase_sel.rg_exp),
                .b_mant_i(phase_sel.mant),
                .sum_sign_o(theta_new.sign),
                .sum_rg_exp_o(sum.rg_exp), //theta_new.rg_exp也比输出的rg_exp窄一位,截取低位
                .sum_mant_o(sum.mant) //theta_new.mant比输出尾数窄
            );
            assign theta_new.rg_exp=sum.rg_exp;
            assign theta_new.mant=sum.mant[ACC_MANT_W-1:ACC_MANT_W-MANT_I_W]; //截取高位

            // ==============================
            // 4.7 传递到下一级（3周期后自动对齐）
            // ==============================
            `FFARN(pipe_en_d1[j], pipe_en[j],   0, clk_i, rstn_i);
            `FFARN(pipe_en_d2[j], pipe_en_d1[j],0, clk_i, rstn_i);
            `FFARN(pipe_en[j+1],  pipe_en_d2[j],0, clk_i, rstn_i);
            // ==============================
            // 【新增】greater 同步3周期传递
            // ==============================
            logic greater_d1, greater_d2;
            `FFARN(greater_d1, greater[j],    0, clk_i, rstn_i);
            `FFARN(greater_d2, greater_d1,     0, clk_i, rstn_i);
            `FFARN(greater[j+1], greater_d2,   0, clk_i, rstn_i);

    
            assign x_pipe[j+1]=x_new;
            assign y_pipe[j+1]=y_new;
            assign theta_pipe[j+1]=theta_new; 
            
        end
    endgenerate

    // ==============================================
    // 5. 最终输出 (每周期输出1组结果) 编码回原始posit格式 组合逻辑
    // ==============================================
    assign calc_done_o = pipe_en[NUM_ITER];

    posit_encoder #(
        .n(n_o), .es(es_o),.EXP_WIDTH(ACC_EXP_W-1),.MANT_WIDTH(ACC_MANT_W-1)
    ) u_encoder_cos (
        .sign_i(x_pipe[NUM_ITER].sign),
        .rg_exp_i(x_pipe[NUM_ITER].rg_exp),
        .mant_norm_i(x_pipe[NUM_ITER].mant),
        .result_o(cos_o)
    );

    posit_encoder #(
        .n(n_o), .es(es_o),.EXP_WIDTH(ACC_EXP_W-1),.MANT_WIDTH(ACC_MANT_W-1)
    ) u_encoder_sin (
        .sign_i(y_pipe[NUM_ITER].sign),
        .rg_exp_i(y_pipe[NUM_ITER].rg_exp),
        .mant_norm_i(y_pipe[NUM_ITER].mant),
        .result_o(sin_o)
    );

endmodule