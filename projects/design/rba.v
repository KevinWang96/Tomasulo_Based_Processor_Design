/*
 * @Author: Yihao Wang
 * @Date: 2020-04-28 22:53:18
 * @LastEditTime: 2020-04-28 23:34:06
 * @LastEditors: Please set LastEditors
 * @Description: 
 *      a. 48 X 1 Ready Bit Array attached to PRF
 *      b. Support 2 read-only ports and 2 write-only ports
 *      c. DU read ready bit of Rs and Rt, reset (write) ready bit of Rd to 0
 *      d. CDB set ready bit of Rd to 1 if Rd finished computation
 *      e. All bits are reset to 0 during sync resetting
 *      f. Supporting internally forwarding between CDB write port and 2 DU read ports
 * @FilePath: /Tomasulo_3_test1/projects/design/rba.v
 */
 `define RBA_DEPTH 48
 `define RBA_ADDR_WIDTH 6
 module rba (
     clk, reset,
     du_rs_r_en, du_rs_r_addr, du_rs_dout,
     du_rt_r_en, du_rt_r_addr, du_rt_dout,
     du_rd_w_en, du_rd_w_addr, du_rd_din,
     cdb_rd_w_en, cdb_rd_w_addr, cdb_rd_din
 );
    
    input clk, reset; // // positive edge triggering and synchronous reset

    input du_rs_r_en, du_rt_r_en, du_rd_w_en, cdb_rd_w_en; // read enable and write enable of each port
    input [0:`RBA_ADDR_WIDTH - 1] du_rs_r_addr, du_rt_r_addr, du_rd_w_addr, cdb_rd_w_addr; // write or read address of each port
    input cdb_rd_din, du_rd_din; // write data of 2 write ports
    output du_rs_dout, du_rt_dout; // read data of 2 read ports

    // Memory array definition
    reg mem [0:`RBA_DEPTH - 1];

//// 2 write ports:
    always @(posedge clk)
    begin
        if(reset) 
        begin : reset_loop
            integer i;
            for(i = 0; i < `RBA_DEPTH; i = i + 1) mem[i] <= 0;
        end
        else // It is impossible that du_rd_w_addr == cdb_rd_w_addr
             // because they have distinct PID (address)
        begin
            if(du_rd_w_en) mem[du_rd_w_addr] <= du_rd_din;
            if(cdb_rd_w_en) mem[cdb_rd_w_addr] <= cdb_rd_din;
        end
    end

//// Read port #0 (read ready bit of Rs by DU):
    assign du_rs_dout = (cdb_rd_w_en && (cdb_rd_w_addr == du_rs_r_addr)) ? cdb_rd_din : mem[du_rs_r_addr];

//// Read port #0 (read ready bit of Rt by DU):
    assign du_rt_dout = (cdb_rd_w_en && (cdb_rd_w_addr == du_rt_r_addr)) ? cdb_rd_din : mem[du_rt_r_addr];

 endmodule
 `undef RBA_DEPTH
 `undef RBA_ADDR_WIDTH