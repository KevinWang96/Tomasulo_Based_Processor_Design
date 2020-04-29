/*
 * @Author: Yihao Wang
 * @Date: 2020-04-28 00:39:38
 * @LastEditTime: 2020-04-28 21:38:58
 * @LastEditors: Please set LastEditors
 * @Description: 
 *       a. Free Register List implemented using a sync 128 X 7 FIFO (7-bit PID)
 *       b. Contact with DU: offering unused PID to DU during instruction dispatching
 *       c. Contact with CFC: also offering same unused PID to CFC during instruction dispatching
 *           and changing read pointer during flushing due miss branch prediction
 *       d. Contact with ROB: If an intruction graduated from ROB, it should return its old PID for Rd 
 *           back to FRL to ensure recycling of PID
 * @FilePath: /Tomasulo_3/Tomasulo_3_test1/projects/design/frl.v
 */
 `define FRL_DEPTH 16 // 16 PIDs are needed (PID 32 - PID 47), PID 0 - PID 31 are preinitialized in RAT
 `define FRL_WIDTH 6 // since there are 48 locations in PRF (physical register file)
 `define FRL_PTR_WIDTH 5 // (n + 1)-bit pointer
 `timescale 1ns/1ps
 module frl (
     clk, reset,
     du_dispatch_pid, frl_pid_out, frl_empty,
     rob_return_pid, rob_pid_in,
     cfc_flush_frl, cfc_flush_frl_value
 );

    input clk, reset; // positive edge triggering and synchronous reset
    input du_dispatch_pid; // 1-bit dispath control signal and generated by DU
    output [0:`FRL_WIDTH - 1] frl_pid_out; // PID dispatched from FRL
    output frl_empty; // no PID in frl, DU must stall dispatching

    input rob_return_pid; // 1-bit return control signal and generated by ROB
    input [0:`FRL_WIDTH - 1] rob_pid_in; // PID returned by ROB

    input cfc_flush_frl; // 1-bit flush control signal and generated by CFC
    input [0:`FRL_PTR_WIDTH - 1] cfc_flush_frl_value; // flush value given by CFC

    // Instantiates a sync FIFO
    sync_fifo #(
        .DEPTH(`FRL_DEPTH),
        .WIDTH(`FRL_WIDTH),
        .RESET_MODE(3) // using reset mode 3, reset FRL with PID #32 to PID #47
    )
    sync_fifo_inst
    (
        .clk(clk), .reset(reset),
        .r_en(du_dispatch_pid), .dout(frl_pid_out), .empty(frl_empty),
        .w_en(rob_return_pid), .din(rob_pid_in), .full(),
        .w_fail(), .r_fail(),
        .change_r_ptr_en(cfc_flush_frl), .change_r_ptr_value(cfc_flush_frl_value),
        .change_w_ptr_en(1'b0), .change_w_ptr_value({`FRL_PTR_WIDTH{1'b0}}) // don't need to flush write pointer
    );

 endmodule
 `undef FRL_WIDTH
 `undef FRL_DEPTH
 `undef FRL_PTR_WIDTH