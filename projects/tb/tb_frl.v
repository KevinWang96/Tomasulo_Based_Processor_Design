/*
 * @Author: Yihao Wang
 * @Date: 2020-04-28 17:57:15
 * @LastEditTime: 2020-04-28 19:44:42
 * @LastEditors: Please set LastEditors
 * @Description: Testbench for frl.v
 * @FilePath: /Tomasulo_3_test1/projects/tb/tb_frl.v
 */
 `timescale 1ns/1ps
 module tb_frl;
    
    parameter CYCLE_TIME = 10;
    parameter FRL_WIDTH = 7;
    parameter FRL_DEPTH = 128;
    parameter FRL_PTR_WIDTH = FRL_WIDTH + 1;

    reg clk, reset;
    reg dispatch_pid;
    wire [0:FRL_WIDTH - 1] pid_out;
    wire frl_empty;

    reg return_pid;
    reg [0:FRL_WIDTH - 1] pid_in;
    reg flush_frl;
    reg [0:FRL_PTR_WIDTH - 1] flush_value;

    always #(0.5 * CYCLE_TIME) clk = ~ clk;

    // DUT
    frl frl_dut (
        .clk(clk),
        .reset(reset),
        .du_dispatch_pid(dispatch_pid),
        .frl_pid_out(pid_out),
        .frl_empty(frl_empty),
        .rob_return_pid(return_pid),
        .rob_pid_in(pid_in),
        .cfc_flush_frl(flush_frl),
        .cfc_flush_frl_value(flush_value)
    );

    initial 
    begin : test 
        integer i;

        clk = 1;
        reset = 1;
        dispatch_pid = 0;
        return_pid = 0;
        flush_frl = 0;

        #(3.5 * CYCLE_TIME)
        reset = 0;
        dispatch_pid = 1;

        #( (FRL_DEPTH + 5) * CYCLE_TIME)
        dispatch_pid = 0;
        return_pid = 1;
        for(i = 0; i < FRL_DEPTH; i = i + 1)
        begin    
            pid_in = i;
            #(CYCLE_TIME);
        end

        #(3 * CYCLE_TIME)
        return_pid = 0;
        flush_frl = 1;
        for(i = 0; i < 2 ** FRL_PTR_WIDTH; i = i + 1)
        begin
            flush_value = i;
            #(CYCLE_TIME);
        end

        #(10 * CYCLE_TIME)
        $finish;

    end

 endmodule