/*
 * @Author: Yihao Wang
 * @Date: 2020-04-28 20:43:47
 * @LastEditTime: 2020-04-28 23:29:10
 * @LastEditors: Please set LastEditors
 * @Description: 
 *      a. 48 X 32 Physical Register File
 *      b. Supporting 8 read-only ports and 1 write-only port
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
    // two read ports of integer queue
     int_rs_r_en, int_rs_r_addr, int_rs_dout,
     int_rt_r_en, int_rt_r_addr, int_rt_dout,
    // two read ports of multiplication queue
     mult_rs_r_en, mult_rs_r_addr, mult_rs_dout,
     mult_rt_r_en, mult_rt_r_addr, mult_rt_dout,
    // two read ports of division queue
     div_rs_r_en, div_rs_r_addr, div_rs_dout,
     div_rt_r_en, div_rt_r_addr, div_rt_dout,
    // 1 read port for load store queue
     lsq_r_en, lsq_r_addr, lsq_dout,
    // 1 read port for store buffer
     sb_r_en, sb_r_addr, sb_dout,
    // 1 write port for cdb
     cdb_w_en, cdb_w_addr, cdb_din
 );

    input clk, reset; // positive edge triggering and synchronous reset

    // Read enable for 8 read ports
    input int_rs_r_en, int_rt_r_en, mult_rs_r_en, mult_rt_r_en, div_rs_r_en, div_rt_r_en, lsq_r_en, sb_r_en; 
    // Read address for 8 read ports
    input [0:`PRF_ADDR_WIDTH - 1] int_rs_r_addr, int_rt_r_addr, mult_rs_r_addr, mult_rt_r_addr, div_rs_r_addr, div_rt_r_addr, lsq_r_addr, sb_r_addr; 
    // Read data out for 8 read ports
    output reg [0:`PRF_WIDTH - 1] int_rs_dout, int_rt_dout, mult_rs_dout, mult_rt_dout, div_rs_dout, div_rt_dout, lsq_dout, sb_dout; 

    input cdb_w_en; // write enbale of write port
    input [0:`PRF_ADDR_WIDTH - 1] cdb_w_addr; // write address for write port
    input [0:`PRF_WIDTH - 1] cdb_din; // write data in of write port

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
            if(cdb_w_en && (cdb_w_addr != 0)) mem[cdb_w_addr] <= cdb_din;
    end

//// Read Port #0 (Rs in Integer Quene):
    always @(*)
    begin
        int_rs_dout = {`PRF_WIDTH{1'bx}};
        if((!int_rs_r_en) || (int_rs_r_addr == 0)) int_rs_dout = 0;
        else    
            if(cdb_w_en && (cdb_w_addr == int_rs_r_addr)) int_rs_dout = cdb_din;
            else int_rs_dout = mem[int_rs_r_addr];
    end

//// Read Port #1 (Rt in Integer Quene):
    always @(*)
    begin
        int_rt_dout = {`PRF_WIDTH{1'bx}};
        if((!int_rt_r_en) || (int_rt_r_addr == 0)) int_rt_dout = 0;
        else    
            if(cdb_w_en && (cdb_w_addr == int_rt_r_addr)) int_rt_dout = cdb_din;
            else int_rt_dout = mem[int_rt_r_addr];
    end

//// Read Port #2 (Rs in Multiplication Quene):
    always @(*)
    begin
        mult_rs_dout = {`PRF_WIDTH{1'bx}};
        if((!mult_rs_r_en) || (mult_rs_r_addr == 0)) mult_rs_dout = 0;
        else    
            if(cdb_w_en && (cdb_w_addr == mult_rs_r_addr)) mult_rs_dout = cdb_din;
            else mult_rs_dout = mem[mult_rs_r_addr];
    end

//// Read Port #3 (Rt in Multiplication Quene):
    always @(*)
    begin
        mult_rt_dout = {`PRF_WIDTH{1'bx}};
        if((!mult_rt_r_en) || (mult_rt_r_addr == 0)) mult_rt_dout = 0;
        else    
            if(cdb_w_en && (cdb_w_addr == mult_rt_r_addr)) mult_rt_dout = cdb_din;
            else mult_rt_dout = mem[mult_rt_r_addr];
    end

//// Read Port #4 (Rs in Division Quene):
    always @(*)
    begin
        div_rs_dout = {`PRF_WIDTH{1'bx}};
        if((!div_rs_r_en) || (div_rs_r_addr == 0)) div_rs_dout = 0;
        else    
            if(cdb_w_en && (cdb_w_addr == div_rs_r_addr)) div_rs_dout = cdb_din;
            else div_rs_dout = mem[div_rs_r_addr];
    end

//// Read Port #5 (Rt in Division Quene):
    always @(*)
    begin
        div_rt_dout = {`PRF_WIDTH{1'bx}};
        if((!div_rt_r_en) || (div_rt_r_addr == 0)) div_rt_dout = 0;
        else    
            if(cdb_w_en && (cdb_w_addr == div_rt_r_addr)) div_rt_dout = cdb_din;
            else div_rt_dout = mem[div_rt_r_addr];
    end

//// Read Port #6 (Rs in Load Store Quene):
    always @(*)
    begin
        lsq_dout = {`PRF_WIDTH{1'bx}};
        if((!lsq_r_en) || (lsq_r_addr == 0)) lsq_dout = 0;
        else    
            if(cdb_w_en && (cdb_w_addr == lsq_r_addr)) lsq_dout = cdb_din;
            else lsq_dout = mem[lsq_r_addr];
    end

//// Read Port #7 (Rs in Store Buffer):
    always @(*)
    begin
        sb_dout = {`PRF_WIDTH{1'bx}};
        if((!sb_r_en) || (sb_r_addr == 0)) sb_dout = 0;
        else    
            if(cdb_w_en && (cdb_w_addr == sb_r_addr)) sb_dout = cdb_din;
            else sb_dout = mem[sb_r_addr];
    end

 endmodule
 `undef PRF_DEPTH
 `undef PRF_WIDTH
 `undef PRF_ADDR_WIDTH