/*
 * @Author: Yihao Wang
 * @Date: 2020-04-28 20:43:47
 * @LastEditTime: 2020-04-28 21:21:56
 * @LastEditors: Please set LastEditors
 * @Description: 
 *      a. 48 X 32 Physical Register File
 *      b. Supporting 4 read-only ports and 1 write-only port
 *      c. Supporting data internally forwarding
 *      d. $0 is hardwired tom GND
 *      e. All bits are synchronously reset to 0 
 * @FilePath: /Tomasulo_3_test1/projects/design/prf.v
 */
 `define PRF_DEPTH 48
 `define PRF_ADDR_WIDTH 6 
 `define PRF_WIDTH 32 // 32-bit data
 module prf (
     clk, reset,
     r_en_p0, r_addr_p0, dout_p0,
     r_en_p1, r_addr_p1, dout_p1,
     r_en_p2, r_addr_p2, dout_p2,
     r_en_p3, r_addr_p3, dout_p3,
     w_en, w_addr, din
 );

    input clk, reset; // positive edge triggering and synchronous reset

    input r_en_p0, r_en_p1, r_en_p2, r_en_p3; // read enable for 4 read ports
    input [0:`PRF_ADDR_WIDTH - 1] r_addr_p0, r_addr_p1, r_addr_p2, r_addr_p3; // read address of 4 read ports
    output reg [0:`PRF_WIDTH - 1] dout_p0, dout_p1, dout_p2, dout_p3; // read data out of 4 read ports

    input w_en; // write enbale of write port
    input [0:`PRF_ADDR_WIDTH - 1] w_addr; // write address for write port
    input [0:`PRF_WIDTH - 1] din; // write data in of write port

    // Memory array definition
    reg [0:`PRF_WIDTH - 1] mem [1:`PRF_DEPTH - 1]; // PRF_DEPTH - 1 locations ($0 is hardwired to GND)

//// Write Port:
    always @(posedge clk)
    begin
        if(reset) 
        begin : reset_loop
            integer i;
            for(i = 1; i < `PRF_DEPTH; i = i + 1)
                mem[i] <= 0;
        end
        else
            if(w_en && (w_addr != 0)) mem[w_addr] <= din;
    end

//// Read Port #0:
    always @(*)
    begin
        dout_p0 = {`PRF_WIDTH{1'bx}};
        if((!r_en_p0) || (r_addr_p0 == 0)) dout_p0 = 0;
        else    
        begin
            if(w_en && (w_addr == r_addr_p0)) dout_p0 = din;
            else dout_p0 = mem[r_addr_p0];
        end
    end

//// Read Port #1:
    always @(*)
    begin
        dout_p1 = {`PRF_WIDTH{1'bx}};
        if((!r_en_p1) || (r_addr_p1 == 0)) dout_p1 = 0;
        else    
        begin
            if(w_en && (w_addr == r_addr_p1)) dout_p1 = din;
            else dout_p1 = mem[r_addr_p1];
        end
    end

//// Read Port #2:
    always @(*)
    begin
        dout_p2 = {`PRF_WIDTH{1'bx}};
        if((!r_en_p2) || (r_addr_p2 == 0)) dout_p2 = 0;
        else    
        begin
            if(w_en && (w_addr == r_addr_p2)) dout_p2 = din;
            else dout_p2 = mem[r_addr_p2];
        end
    end

//// Read Port #3:
    always @(*)
    begin
        dout_p3 = {`PRF_WIDTH{1'bx}};
        if((!r_en_p3) || (r_addr_p3 == 0)) dout_p3 = 0;
        else    
        begin
            if(w_en && (w_addr == r_addr_p3)) dout_p3 = din;
            else dout_p3 = mem[r_addr_p3];
        end
    end

 endmodule
 `undef PRF_DEPTH
 `undef PRF_WIDTH
 `undef PRF_ADDR_WIDTH