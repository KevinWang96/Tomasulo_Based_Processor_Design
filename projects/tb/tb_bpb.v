/*
 * @Author: Yihao Wang
 * @Date: 2020-05-01 20:27:30
 * @LastEditTime: 2020-05-01 21:19:32
 * @LastEditors: Please set LastEditors
 * @Description: Testbench for bpb.v
 * @FilePath: /Tomasulo_3_test1/projects/tb/tb_bpb.v
 */
 `timescale 1ns/1ps
 module tb_bpb;

    parameter   CYCLE_TIME  =   5;

    parameter   DEPTH   =   8;
    parameter   WIDTH   =   2;
    parameter   ADDR    =   $clog2(DEPTH);

    reg                     clk;
    reg                     reset;

    reg                     du_branch;
    reg     [0:ADDR - 1]    du_bpb_addr;
    wire                    bpb_branch_prediction_du;

    reg                     cdb_branch;
    reg                     cdb_branch_res;
    reg     [0:ADDR - 1]    cdb_bpb_addr;
    wire                    bpb_branch_prediction_cdb;

    // dut
    bpb bpb_dut (
        .clk                        (clk),
        .reset                      (reset),

        .du_branch                  (du_branch),
        .du_bpb_addr                (du_bpb_addr),
        .bpb_branch_prediction_du   (bpb_branch_prediction_du),

        .cdb_branch                 (cdb_branch),
        .cdb_branch_res             (cdb_branch_res),
        .cdb_bpb_addr               (cdb_bpb_addr),
        .bpb_branch_prediction_cdb  (bpb_branch_prediction_cdb)
    );

    always #(0.5 * CYCLE_TIME) clk = ~ clk;

    initial begin : test
        integer i;

        clk = 1;
        reset = 1;
        du_branch = 0;
        cdb_branch = 0;

        #(3.5 * CYCLE_TIME)
        reset = 0;
        // tests resetting
        du_branch = 1;
        for(i = 0; i < DEPTH; i = i + 1) begin
            du_bpb_addr = i;
            #(CYCLE_TIME);
        end

        #(2 * CYCLE_TIME)
        cdb_branch = 1;
        for(i = 0; i < DEPTH; i = i + 1) begin
            du_bpb_addr = i; // tests internally forwarding
            
            // tests saturate counter of each BPB locations
            cdb_bpb_addr = i;
            cdb_branch_res = 1;
            #(4 * CYCLE_TIME)
            cdb_branch_res = 0;
            #(6 * CYCLE_TIME);
        end

        $finish;
    end

 endmodule