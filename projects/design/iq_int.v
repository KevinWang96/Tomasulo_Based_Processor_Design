/*
 * @Author: Yihao Wang
 * @Date: 2020-05-05 20:27:20
 * @LastEditTime: 2020-05-06 00:51:58
 * @LastEditors: Please set LastEditors
 * @Description: Integer Issue Queue
 * @FilePath: /Tomasulo_3_test1/projects/design/iq_int.v
 */

 `include "./params/rob_params.v"
 `include "./params/iq_params.v"
 module iq_int (

     clk,
     reset,

     du_w_en,
     du_w_din,
     iq_int_full,

     cdb_flush,
     rob_r_ptr,
     cdb_rob_tag,

     cdb_reg_wr,
     cdb_rd_pid,

     iq_int_rdy,
     iq_int_r_dout,
     iu_r_en

 );

    input                               clk;    // posedge triggerring
    input                               reset;    // sync reset
    
    input                               du_w_en;    // write enable of DU
    input   [0:`IQ_INT_WIDTH - 1]       du_w_din;  // write data in of DU
    output                              iq_int_full;    // integer issue queue full signal

    input                               cdb_flush;  // cdb flush signal
    input   [0:`ROB_PTR_WIDTH - 2]      rob_r_ptr;  // the current read pointer of ROB used to do selective flushing
    input   [0:`ROB_ROB_TAG_WIDTH - 1]  cdb_rob_tag; // the rob tag of senior on CDB 

    input                               cdb_reg_wr; // register write bit of senior on CDB
    input   [0:`IQ_INT_RD_WIDTH - 1]    cdb_rd_pid; // the pid of rd of senior on CDB

    output                              iq_int_rdy; // ready signal of integer issue queue
    output  [0:`IQ_INT_WIDTH - 1]       iq_int_r_dout;  // read data out of integer issue queue
    input                               iu_r_en;    // read enable of issue unit, means gets permission of issue unit

    
    reg     [0:`IQ_INT_WIDTH - 1]   mem                 [0:`IQ_INT_DEPTH - 1]; // register array definition

    reg                             reg_update          [0:`IQ_INT_DEPTH - 1]; // register update control bits array
    reg     [0:`IQ_INT_WIDTH - 1]   reg_update_value    [0:`IQ_INT_DEPTH - 1]; // register update value array
    wire                            rdy_bit             [0:`IQ_INT_DEPTH - 1]; // ready bit array
    
    reg     [0:$clog2(`IQ_INT_DEPTH) - 1]   out_mux_sel;    // select signal of output MUX

    // Update ready bit array
    genvar i;
    generate begin
        for(i = 0; i < `IQ_INT_DEPTH; i = i + 1) begin : rdy_bit_update
            // we assume DU will set rdy bit of unused source register to 1 !!!
            assign rdy_bit[i] = mem[i][`IQ_INT_RS_RDY_START_LOC] & mem[i][`IQ_INT_RT_RDY_START_LOC]
                                    & mem[i][`IQ_INT_INSTR_VALID_START_LOC];
        end
    end
    endgenerate

    // Update reg_update_value
    always @(*) begin : reg_update_value_update
        integer j;
        for(j = 0; j < `IQ_INT_DEPTH; j = j + 1) begin
            reg_update_value[j] = mem[j];

            if(cdb_flush) begin
                if((mem[j][`IQ_INT_ROB_TAG_START_LOC+:`IQ_INT_ROB_TAG_WIDTH] - rob_r_ptr) >=
                    (cdb_rob_tag - rob_r_ptr))
                    reg_update_value[j] = 0;
            end
            else begin
                if(cdb_reg_wr) begin
                    if(cdb_rd_pid == mem[j][`IQ_INT_RS_START_LOC+:`IQ_INT_RS_WIDTH])
                        reg_update_value[j][`IQ_INT_RS_RDY_START_LOC] = 1;
                    if(cdb_rd_pid == mem[j][`IQ_INT_RT_START_LOC+:`IQ_INT_RT_WIDTH])
                        reg_update_value[j][`IQ_INT_RT_RDY_START_LOC] = 1;
                end

                if(iu_r_en && (j == out_mux_sel)) reg_update_value[j] = 0;
            end
        end
    end

    // Generates reg_update array
    reg     shift_loc   [0:`IQ_INT_DEPTH - 1];
    always @(*) begin : shift_loc_update
        integer j;

        for(j = 0; j < `IQ_INT_DEPTH; j = j + 1) 
            shift_loc[j] = 0;

        if(!mem[0][`IQ_INT_INSTR_VALID_START_LOC]) shift_loc[0] = 1;
        else if(!mem[1][`IQ_INT_INSTR_VALID_START_LOC]) shift_loc[1] = 1;
        else if(!mem[2][`IQ_INT_INSTR_VALID_START_LOC]) shift_loc[2] = 1;
        else if(!mem[3][`IQ_INT_INSTR_VALID_START_LOC]) shift_loc[3] = 1;
        else if(!mem[4][`IQ_INT_INSTR_VALID_START_LOC]) shift_loc[4] = 1;
        else if(!mem[5][`IQ_INT_INSTR_VALID_START_LOC]) shift_loc[5] = 1;
        else if(!mem[6][`IQ_INT_INSTR_VALID_START_LOC]) shift_loc[6] = 1;
        else if(!mem[7][`IQ_INT_INSTR_VALID_START_LOC]) shift_loc[7] = 0;

    end

    always @(*) begin : reg_update_update 
        integer j;
        for(j = 0; j < `IQ_INT_DEPTH; j = j + 1) begin
            if(shift_loc[j]) reg_update[j] = 1;
            else if(j == 0) reg_update[j] = 0;
            else reg_update[j] = reg_update[j - 1];
        end
    end

    // Update each line of registers based on reg_update array
    always @(posedge clk) begin : sequential_block
        integer j;
        if(reset) 
            for(j = 0; j < `IQ_INT_DEPTH; j = j + 1) 
                mem[j] <= 0;
        else
            for(j = 0; j < `IQ_INT_DEPTH; j = j + 1) begin
                if(j != `IQ_INT_DEPTH - 1) begin
                    if(reg_update[j]) mem[j] <= reg_update_value[j + 1];
                    else mem[j] <= reg_update_value[j];
                end
                else begin
                    if(reg_update[j]) begin
                        if(du_w_en) mem[j] <= du_w_din;
                        else mem[j] <= 0;
                    end
                    else
                        mem[j] <= reg_update_value[j];
                end
            end
    end

    // if the top of queue plan to be updated,
    // it means we can load new data into the top location at next postive edge
    assign  iq_int_full =   (~reg_update[`IQ_INT_DEPTH - 1]); 

    // Outputs instruction who has been ready based on priority
    // JR has the highest priority 
    always @(*) begin
        out_mux_sel = 0;
        if(rdy_bit[0] & mem[0][`IQ_INT_JR_VALID_START_LOC]) out_mux_sel = 0;
        else if(rdy_bit[1] & mem[1][`IQ_INT_JR_VALID_START_LOC]) out_mux_sel = 1;
        else if(rdy_bit[2] & mem[2][`IQ_INT_JR_VALID_START_LOC]) out_mux_sel = 2;
        else if(rdy_bit[3] & mem[3][`IQ_INT_JR_VALID_START_LOC]) out_mux_sel = 3;
        else if(rdy_bit[4] & mem[4][`IQ_INT_JR_VALID_START_LOC]) out_mux_sel = 4;
        else if(rdy_bit[5] & mem[5][`IQ_INT_JR_VALID_START_LOC]) out_mux_sel = 5;
        else if(rdy_bit[6] & mem[6][`IQ_INT_JR_VALID_START_LOC]) out_mux_sel = 6;
        else if(rdy_bit[7] & mem[7][`IQ_INT_JR_VALID_START_LOC]) out_mux_sel = 7;
        else if(rdy_bit[0]) out_mux_sel = 0;
        else if(rdy_bit[1]) out_mux_sel = 1;
        else if(rdy_bit[2]) out_mux_sel = 2;
        else if(rdy_bit[3]) out_mux_sel = 3;
        else if(rdy_bit[4]) out_mux_sel = 4;
        else if(rdy_bit[5]) out_mux_sel = 5;
        else if(rdy_bit[6]) out_mux_sel = 6;
        else if(rdy_bit[7]) out_mux_sel = 7;
    end

    assign  iq_int_r_dout   =   mem[out_mux_sel];   // read data out
    assign  iq_int_rdy      =   rdy_bit[0] | rdy_bit[1] | rdy_bit[2] | rdy_bit[3] | rdy_bit[4] |
                                rdy_bit[5] | rdy_bit[6] | rdy_bit[7];
    
 endmodule