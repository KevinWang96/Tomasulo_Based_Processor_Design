/*
 * @Author: Yihao Wang
 * @Date: 2020-04-29 23:03:47
 * @LastEditTime: 2020-04-30 01:27:26
 * @LastEditors: Please set LastEditors
 * @Description: 
 *      a. 16 X 32 Instruction Fetch Queue located between I-cache and DU
 *      b. Supporting variabe-width reading and writing
 *      c. Writing domain: 4 X 128 (An entire cache line will be stored into IFQ)
 *      d. Reading domain: 16 X 32 (DU only fetch a word of intruction every clock)
 * @FilePath: /Tomasulo_3_test1/projects/design/ifg.v
 */
 `define IFQ_DEPTH 16 // from read domain
 `define IFQ_WDITH 32 // from read domain
 module ifq (
     clk, reset,
     if_w_en, if_w_din,
     du_r_en, du_r_dout,
     ifq_full, ifq_empty
 );
    
    input clk, reset; // positive edge triggering and synchronous reset
                      // note that synchronous reset is also used for flushing IFQ by CDB
    input if_w_en, du_r_en; // write enable of IF unit and read enable of DU
    input [0:4 * `IFQ_WDITH - 1] if_w_din; // 128-bit write data (entire cache line)
    output [0:`IFQ_WDITH - 1] du_r_dout;

    output ifq_empty, ifq_full; // flow control signals 

    // Memory array
    reg [0:`IFQ_WDITH - 1] mem [0:`IFQ_DEPTH - 1];

//// Data reading: reading one word instruction by DU
    reg [0:$clog2(`IFQ_DEPTH)] r_ptr; // (n+1)-bit read ptr

    assign du_r_dout = (du_r_en) ? mem[r_ptr[1:$clog2(`IFQ_DEPTH)]] : 0;

    always @(posedge clk)
    begin
        if(reset) r_ptr <= 0;
        else
            if(du_r_en) r_ptr <= r_ptr + 1;
    end

//// Data writing: I-Cache write entire cache line (128 bits) into IFQ
    reg [0:$clog2(`IFQ_DEPTH)] w_ptr; // (n+1)-bit write ptr

    always @(posedge clk)
    begin
        if(reset) w_ptr <= 0;
        else
            if(if_w_en)
            begin
                // write four words (one cache line) in one stroke
                mem[{w_ptr[1:$clog2(`IFQ_DEPTH) - 2], 2'b00}] <= if_w_din[(0 * `IFQ_WDITH)+:`IFQ_WDITH];
                mem[{w_ptr[1:$clog2(`IFQ_DEPTH) - 2], 2'b01}] <= if_w_din[(1 * `IFQ_WDITH)+:`IFQ_WDITH];
                mem[{w_ptr[1:$clog2(`IFQ_DEPTH) - 2], 2'b10}] <= if_w_din[(2 * `IFQ_WDITH)+:`IFQ_WDITH];
                mem[{w_ptr[1:$clog2(`IFQ_DEPTH) - 2], 2'b11}] <= if_w_din[(3 * `IFQ_WDITH)+:`IFQ_WDITH];
                // change w_ptr (the least significant 2 bits are alwasy 2'b00)
                w_ptr[0:$clog2(`IFQ_DEPTH) - 2] <= w_ptr[0:$clog2(`IFQ_DEPTH) - 2] + 1;
            end
    end

//// Generates full & empty signals:
    wire [0:$clog2(`IFQ_DEPTH)] diff; // (w_ptr - r_ptr) mod (2 * IFQ_DEPTH)
    assign diff = w_ptr - r_ptr;

    assign ifq_empty = (diff == 0);
    assign ifq_full = (diff == `IFQ_DEPTH);

 endmodule
 `undef IFQ_DEPTH
 `undef IFQ_WDITH