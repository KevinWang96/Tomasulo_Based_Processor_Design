/*
 * @Author: Yihao Wang
 * @Date: 2020-04-29 17:47:51
 * @LastEditTime: 2020-04-29 17:58:13
 * @LastEditors: Please set LastEditors
 * @Description: Testbench for ras.v
 * @FilePath: /Tomasulo_3_test1/projects/tb/tb_ras.tb
 */
 `timescale 1ns/1ps
 module tb_ras;
    
    parameter CYCLE_TIME = 5;
    parameter RAS_WIDTH = 32;
    parameter RAS_DEPTH = 4;

    reg clk, reset;
    reg du_jal_push, du_jr31_pop;
    reg [0:RAS_WIDTH - 1] du_jal_push_din;
    wire [0:RAS_WIDTH - 1] du_jr31_pop_dout;
    
    wire [0:$clog2(RAS_DEPTH) - 1] TOSP, TOSP_p1;
    wire [0:RAS_WIDTH - 1] latest_poped_addr;
    wire [0:$clog2(RAS_DEPTH)] depth_counter;
    assign TOSP = ras_dut.TOSP;
    assign TOSP_p1 = ras_dut.TOSP_p1;
    assign latest_poped_addr = ras_dut.latest_poped_addr;
    assign depth_counter = ras_dut.depth_counter;
    
    wire [0:RAS_WIDTH - 1] mem [0:RAS_DEPTH - 1];
    genvar i;
    generate
        for(i = 0; i < RAS_DEPTH; i = i + 1)
            assign mem[i] = ras_dut.mem[i];
    endgenerate
    
    

    always #(0.5 * CYCLE_TIME) clk = ~ clk;

    //dut
    ras ras_dut (
        .clk(clk), 
        .reset(reset),
        .du_jal_push(du_jal_push),
        .du_jal_push_din(du_jal_push_din),
        .du_jr31_pop(du_jr31_pop),
        .du_jr31_pop_dout(du_jr31_pop_dout)
    );

    initial
    begin : Test
        integer i;

        clk = 1;
        reset = 1;
        du_jal_push = 0;
        du_jr31_pop = 0;

        #(3.5 * CYCLE_TIME)
        reset = 0;
        du_jal_push = 1;
        for(i = 0; i < 10; i = i + 1)
        begin
            du_jal_push_din = i;
            #(CYCLE_TIME);
        end
        du_jal_push = 0;

        #(3 * CYCLE_TIME)
        du_jr31_pop = 1;
        
        #(10 * CYCLE_TIME)
        $finish;

    end

 endmodule