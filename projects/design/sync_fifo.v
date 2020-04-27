/*
 * @Author: Yihao Wang
 * @Date: 2020-04-27 00:16:40
 * @LastEditTime: 2020-04-27 01:09:41
 * @LastEditors: Please set LastEditors
 * @Description: A configuerable synchronous FIFO 
 *               Reading is asynchronous, writing is synchronous
 * @FilePath: /Tomasulo_3/Tomasulo_3_test1/projects/design/sync_fifo.v
 */
module sync_fifo #(
    parameter DEPTH = 32, // the depth must be a power of 2
    parameter WIDTH = 32,
)
(
    clk, reset, r_en, dout, r_ptr, w_en, din, w_ptr, full, empty
);
    localparam ADDR = $clog2(DEPTH); // address
    localparam PTR_WIDTH = ADDR + 1; // using (n + 1)-bit write and read pointers

//// Port Definition ///////////////////////////////////////////////////////////////

     input clk, reset; // positive edge triggering and synchronous reset
    
    // For read port:
    input r_en; // read enable 
    output [0:WIDTH - 1] dout; // read data out (synchronous read)
    output [0:PTR_WIDTH - 1] r_ptr; // the value of read pointer

    // For write port:
    input w_en; // write enable
    input din; // write data in
    output [0:PTR_WIDTH - 1] w_ptr; // the value of wirte pointer

    // Flow control signal
    output full, empty;

////////////////////////////////////////////////////////////////////////////////////

//// Memory array instantiation
    reg [0:WIDTH - 1] mem [0:DEPTH - 1];

//// Generates full & empty signal
    wire empty_i, full_i; // internal empty and internal full signals
    assign {full, empty} = {full_i, empty_i};


//// Data Reading
    wire r_en_q; // qualified read enable to avoid ilegal reading
    assign r_en_q = (!empty_i) && r_en;

    reg [0:PTR_WIDTH - 1] r_ptr_r; // read pointer (register)
    always @(posedge clk)
    begin
        if(reset) r_ptr_r <= 0;
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


endmodule    