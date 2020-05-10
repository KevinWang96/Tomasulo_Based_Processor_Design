/*
 * @Author: Yihao Wang
 * @Date: 2020-05-08 07:20:19
 * @LastEditTime: 2020-05-08 07:27:25
 * @LastEditors: Please set LastEditors
 * @Description: MIPS Full Branch Address Generator 
 * @FilePath: /Tomasulo_3/Tomasulo_3_test1/projects/design/br_addr_gen.v
 */
`include "./design/arithmetic/add_sub.v"
`timescale 1ns/1ps
`define PC_WIDTH 32
`define BR_ADDR_WIDTH 16
module br_addr_gen (
    pc,
    br_addr,
    addr_out
);

    input   [0:PC_WIDTH - 1]        pc;
    input   [0:BR_ADDR_WIDTH - 1]   br_addr;
    output  [0:PC_WIDTH - 1]        addr_out;

    wire    [0:PC_WIDTH - 1]        br_addr_full;

    assign  br_addr_full    =   {14{br_addr[0]}, br_addr, 2'b00}};

    add_sub #(
        .WIDTH(PC_WIDTH)
    )
    adder_inst
    (
        .A(pc),
        .B(br_addr_full),
        .add_b_sub(0),
        .S(addr_out),
        .Co()
    );

endmodule