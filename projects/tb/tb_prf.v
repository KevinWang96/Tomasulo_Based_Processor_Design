/*
 * @Author: Yihao Wang
 * @Date: 2020-04-29 20:53:46
 * @LastEditTime: 2020-04-29 21:52:11
 * @LastEditors: Please set LastEditors
 * @Description: Testbench for prf.v
 * @FilePath: /Tomasulo_3_test1/projects/tb/tb_prf.v
 */
`timescale 1ns/1ps
module tb_prf;
    parameter CYCLE_TIME = 5;

    parameter PRF_DEPTH = 48;
    parameter PRF_ADDR_WIDTH = 6;
    parameter PRF_WIDTH = 32;

    reg clk, reset;

    reg int_rs_r_en, int_rt_r_en, mult_rs_r_en, mult_rt_r_en, div_rs_r_en, div_rt_r_en, lsq_r_en, sb_r_en; 
    reg [0:PRF_ADDR_WIDTH - 1] int_rs_r_addr, int_rt_r_addr, mult_rs_r_addr, mult_rt_r_addr, div_rs_r_addr, div_rt_r_addr, lsq_r_addr, sb_r_addr; 
    wire [0:PRF_WIDTH - 1] int_rs_dout, int_rt_dout, mult_rs_dout, mult_rt_dout, div_rs_dout, div_rt_dout, lsq_dout, sb_dout;

    reg cdb_w_en; 
    reg [0:PRF_ADDR_WIDTH - 1] cdb_w_addr; 
    reg [0:PRF_WIDTH - 1] cdb_din;

    always #(0.5 * CYCLE_TIME) clk = ~ clk;

    prf prf_dut (
        .clk(clk), .reset(reset),
        
        .int_rs_r_en(int_rs_r_en), .int_rs_r_addr(int_rs_r_addr), .int_rs_dout(int_rs_dout),
        .int_rt_r_en(int_rt_r_en), .int_rt_r_addr(int_rt_r_addr), .int_rt_dout(int_rt_dout),

        .mult_rs_r_en(mult_rs_r_en), .mult_rs_r_addr(mult_rs_r_addr), .mult_rs_dout(mult_rs_dout),
        .mult_rt_r_en(mult_rt_r_en), .mult_rt_r_addr(mult_rt_r_addr), .mult_rt_dout(mult_rt_dout),

        .div_rs_r_en(div_rs_r_en), .div_rs_r_addr(div_rs_r_addr), .div_rs_dout(div_rs_dout),
        .div_rt_r_en(div_rt_r_en), .div_rt_r_addr(div_rt_r_addr), .div_rt_dout(div_rt_dout),

        .lsq_r_en(lsq_r_en), .lsq_r_addr(lsq_r_addr), .lsq_dout(lsq_dout),

        .sb_r_en(sb_r_en), .sb_r_addr(sb_r_addr), .sb_dout(sb_dout),

        .cdb_w_en(cdb_w_en), .cdb_w_addr(cdb_w_addr), .cdb_din(cdb_din)
    );

    initial
    begin : test 
        integer i;

        clk = 1;
        reset = 1;
        
        int_rs_r_en = 0;
        int_rt_r_en = 0;
        mult_rs_r_en = 0;
        mult_rt_r_en = 0;
        div_rs_r_en = 0;
        div_rt_r_en = 0;
        lsq_r_en = 0;
        sb_r_en = 0;
        cdb_w_en = 0;

        #(3.5 * reset)
        reset = 0;
        
        cdb_w_en = 1;
        for(i = 0; i < PRF_DEPTH; i = i + 1)
        begin
            cdb_w_addr = i;
            cdb_din = 1000 + i;
            #(CYCLE_TIME);
        end
        cdb_w_en = 0;

        #(3 * CYCLE_TIME)
        int_rs_r_en = 1;
        for(i = 0; i < PRF_DEPTH; i = i + 1)
        begin
            int_rs_r_addr = i;
            #(CYCLE_TIME);
        end
        cdb_w_en = 1;
        cdb_w_addr = 47;
        cdb_din = 11111;
        #(CYCLE_TIME)
        int_rs_r_en = 0;
        cdb_w_en = 0;

        #(3 * CYCLE_TIME)
        int_rt_r_en = 1;
        for(i = 0; i < PRF_DEPTH; i = i + 1)
        begin
            int_rt_r_addr = i;
            #(CYCLE_TIME);
        end
        cdb_w_en = 1;
        cdb_w_addr = 47;
        cdb_din = 22222;
        #(CYCLE_TIME)
        int_rt_r_en = 0;
        cdb_w_en = 0;

        #(3 * CYCLE_TIME)
        mult_rs_r_en = 1;
        for(i = 0; i < PRF_DEPTH; i = i + 1)
        begin
            mult_rs_r_addr = i;
            #(CYCLE_TIME);
        end
        cdb_w_en = 1;
        cdb_w_addr = 47;
        cdb_din = 33333;
        #(CYCLE_TIME)
        mult_rs_r_en = 0;
        cdb_w_en = 0;

        #(3 * CYCLE_TIME)
        mult_rt_r_en = 1;
        for(i = 0; i < PRF_DEPTH; i = i + 1)
        begin
            mult_rt_r_addr = i;
            #(CYCLE_TIME);
        end
        cdb_w_en = 1;
        cdb_w_addr = 47;
        cdb_din = 44444;
        #(CYCLE_TIME)
        mult_rt_r_en = 0;
        cdb_w_en = 0;

        #(3 * CYCLE_TIME)
        div_rs_r_en = 1;
        for(i = 0; i < PRF_DEPTH; i = i + 1)
        begin
            div_rs_r_addr = i;
            #(CYCLE_TIME);
        end
        cdb_w_en = 1;
        cdb_w_addr = 47;
        cdb_din = 55555;
        #(CYCLE_TIME)
        div_rs_r_en = 0;
        cdb_w_en = 0;

        #(3 * CYCLE_TIME)
        div_rt_r_en = 1;
        for(i = 0; i < PRF_DEPTH; i = i + 1)
        begin
            div_rt_r_addr = i;
            #(CYCLE_TIME);
        end
        cdb_w_en = 1;
        cdb_w_addr = 47;
        cdb_din = 66666;
        #(CYCLE_TIME)
        div_rt_r_en = 0;
        cdb_w_en = 0;

        #(3 * CYCLE_TIME)
        lsq_r_en = 1;
        for(i = 0; i < PRF_DEPTH; i = i + 1)
        begin
            lsq_r_addr = i;
            #(CYCLE_TIME);
        end
        cdb_w_en = 1;
        cdb_w_addr = 47;
        cdb_din = 77777;
        #(CYCLE_TIME)
        lsq_r_en = 0;
        cdb_w_en = 0;

        #(3 * CYCLE_TIME)
        sb_r_en = 1;
        for(i = 0; i < PRF_DEPTH; i = i + 1)
        begin
            sb_r_addr = i;
            #(CYCLE_TIME);
        end
        cdb_w_en = 1;
        cdb_w_addr = 47;
        cdb_din = 88888;
        #(CYCLE_TIME)
        sb_r_en = 0;
        cdb_w_en = 0;

        #(10 * CYCLE_TIME)
        $finish;
    end

endmodule