/*
 * @Author: Yihao Wang
 * @Date: 2020-04-27 00:16:40
 * @LastEditTime: 2020-04-28 00:58:37
 * @LastEditors: Please set LastEditors
 * @Description: 
 *      a. A configuerable synchronous FIFO 
 *      b. Reading is asynchronous, writing is synchronous
 *      c. Supporting pointer changing, pointer changing has higher priority than read and write operation
 * @FilePath: /Tomasulo_3/Tomasulo_3_test1/projects/design/sync_fifo.v
 */
`timescale 1ns/1ps
module sync_fifo #(
    parameter DEPTH = 32, // the depth must be a power of 2
    parameter WIDTH = 32, // data width
    parameter PTR_WIDTH = 6 // width or read and write pointer (using (n+1)-bit pointer)
)
(
    clk, reset, 
    r_en, dout, r_ptr, 
    w_en, din, w_ptr, 
    full, empty, 
    w_fail, r_fail,
    change_r_ptr_en, change_r_ptr_value,
    change_w_ptr_en, change_w_ptr_value
);

//// Port Definition ///////////////////////////////////////////////////////////////

    input clk, reset; // positive edge triggering and synchronous reset
    
    // For read port:
    input r_en; // read enable 
    output [0:WIDTH - 1] dout; // read data out (synchronous read)
    output [0:PTR_WIDTH - 1] r_ptr; // the value of read pointer

    // For write port:
    input w_en; // write enable
    input [0:WIDTH - 1] din; // write data in
    output [0:PTR_WIDTH - 1] w_ptr; // the value of wirte pointer

    // Flow control signal
    output full, empty;

    // Fail signal
    output w_fail, r_fail; // failure of read or write due to ilegal read or write

    // Pointer changing control signals
    input change_r_ptr_en; // enable signal for read pointer changing
    input [0:PTR_WIDTH - 1] change_r_ptr_value; // change value of read pointer, note that (n+1)-bit change value is used
    input change_w_ptr_en; // enable signal for write pointer changing
    input [0:PTR_WIDTH - 1] change_w_ptr_value; // change value of write pointer, note that (n+1)-bit change value is used
    
////////////////////////////////////////////////////////////////////////////////////

//// Memory array instantiation
    reg [0:WIDTH - 1] mem [0:DEPTH - 1];

//// Generates full & empty signal
    wire empty_i, full_i; // internal empty and internal full signals
    assign {full, empty} = {full_i, empty_i};


//// Data Reading and read pointer changing
    wire r_en_q; // qualified read enable to avoid ilegal reading
    assign r_en_q = (!empty_i) && r_en;

    reg [0:PTR_WIDTH - 1] r_ptr_r; // read pointer (register)
    always @(posedge clk)
    begin
        if(reset) r_ptr_r <= 0;
        else 
            // Change value of r_ptr_r synchronously
            if(change_r_ptr_en) r_ptr_r <= change_r_ptr_value;
            else
                // if r_en is inactive, output register 
                if(r_en_q) r_ptr_r <= r_ptr_r + 1;
    end

    assign dout = mem[r_ptr_r[1:PTR_WIDTH - 1]];


//// Data Writing
    wire w_en_q; // qualified write enable to avoid ilegal writing
    assign w_en_q = (!full_i) && w_en;

    reg [0:PTR_WIDTH - 1] w_ptr_r; // read pointer (register)
    always @(posedge clk)
    begin
        if(reset) w_ptr_r <= 0;
        else  
            // Change value of r_ptr_r synchronously
            if(change_w_ptr_en) w_ptr_r <= change_w_ptr_value; 
            else
                if(w_en_q)
                begin
                    mem[w_ptr_r[1:PTR_WIDTH - 1]] <= din;
                    w_ptr_r <= w_ptr_r + 1;
                end
    end

//// Generates full_i & empty_i signals
    wire [0:PTR_WIDTH - 1] diff; // the difference of w_ptr_r and r_ptr_r
    assign diff = w_ptr_r - r_ptr_r;
    assign empty_i = (diff == 0);
    assign full_i = (diff == DEPTH);


//// Generates w_fail & r_fail signals
    assign w_fail = ((!change_w_ptr_en) && (w_en != w_en_q)) || ((change_w_ptr_en) && (w_en));
    assign r_fail = ((!change_r_ptr_en) && (r_en != r_en_q)) || ((change_r_ptr_en) && (r_en));

//// Generates w_ptr & r_ptr
    assign w_ptr = w_ptr_r;
    assign r_ptr = r_ptr_r;


endmodule    