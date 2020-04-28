/*
 * @Author: Yihao Wang
 * @Date: 2020-04-27 16:34:18
 * @LastEditTime: 2020-04-27 20:13:50
 * @LastEditors: Please set LastEditors
 * @Description: Testbench for module sync_fifo
 * @FilePath: /Tomasulo_3/Tomasulo_3_test1/projects/tb/tb_sync_fifo.v
 */
`timescale 1ns/1ps
module tb_sync_fifo;

    parameter CYCLE_TIME = 5; // clock cycle time
    parameter LOG_PATH = "./test_logs/sync_fifo/signal_time.log";
    
    localparam DEPTH = 8;
    localparam WIDTH = 8;

    reg clk, reset;
    reg r_en, w_en;
    reg [0:WIDTH - 1] din;

    wire [0:WIDTH - 1] dout;
    wire full, empty;
    wire [0:$clog2(DEPTH)] r_ptr, w_ptr;
    wire r_fail, w_fail;

    always #(0.5 * CYCLE_TIME) clk = ~ clk;

    // DUT
    sync_fifo #(
        .DEPTH(DEPTH),
        .WIDTH(WIDTH)
    )
    sync_fifo_dut
    (
        .clk(clk), .reset(reset),

        .r_en(r_en), .dout(dout), .r_ptr(r_ptr),

        .w_en(w_en), .din(din), .w_ptr(w_ptr),

        .full(full), .empty(empty),

        .r_fail(r_fail), .w_fail(w_fail)
    );

    integer signal_time_log;
    initial 
    begin
        signal_time_log = $fopen(LOG_PATH, "w");
        $fmonitor(signal_time_log, 
            "time = %1d ns, clk = %1b, reset = %1b, r_en = %1b, dout = %1d, r_ptr = %1d, w_en = %1d, din = %1d, w_ptr = %1d, full = %1b, empty = %1b, w_fail = %1b, r_fail = %1b",
            $time, clk, reset, r_en, dout, r_ptr, w_en, din, w_ptr, full, empty, w_fail, r_fail);
    end

    initial 
    begin : test
        integer i;

        clk = 1;
        reset = 1;
        r_en = 0;
        w_en = 0;

        #(3.5 * CYCLE_TIME) 
        reset = 0;

        // writing without enabling w_en
        #(CYCLE_TIME)
        for(i = 0; i < 16; i = i + 1)
        begin
            din = i;
            #(CYCLE_TIME);
        end

        // test legal writing and ilegal writing
        #(CYCLE_TIME)
        w_en = 1;
        for(i = 16;i < 32; i = i + 1)
        begin
            din = i;
            #(CYCLE_TIME);
        end
        
        // Test legal reading and ilegal reading
        #(CYCLE_TIME)
        w_en = 0;
        r_en = 1;

        #(32 * CYCLE_TIME)
        $fclose(signal_time_log);
        $finish;
    end

endmodule