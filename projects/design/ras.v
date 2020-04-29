/*
 * @Author: Yihao Wang
 * @Date: 2020-04-29 03:32:09
 * @LastEditTime: 2020-04-29 04:14:26
 * @LastEditors: Please set LastEditors
 * @Description: 
 *      a. Return Address Stack used to predict return address of (JR $31)
 *      b. 4 X 32 stack is used to offer accurate prediction for latest 4 (JR $31)
 *      c. If subsequent (JR $31) requests an empty RAS, it returns the latest poped return address
 * @FilePath: /Tomasulo_3_test1/projects/design/ras.v
 */
 `define RAS_WIDTH 32 // 32-bit PC (address) is used 
 `define RAS_DEPTH 4 // the depth of stack
 module ras (
     clk, reset,
     du_jal_push, du_jal_push_din,
     du_jr31_pop, du_jr31_pop_dout
 );

    input clk, reset; // positive edge triggering and synchronous reset
    
    input du_jal_push; // 1-bit push enable, JAL instruction will push PC + 4 into RAS during dispatching
    input [0:`RAS_WIDTH - 1] du_jal_push_din;

    input du_jr31_pop; // 1-bit pop enable, JR $31 will pop predicted return address during dispatching
    output [0:`RAS_WIDTH - 1] du_jr31_pop_dout;

    // Memory Array
    reg [0:`RAS_WIDTH - 1] mem [0:`RAS_DEPTH - 1]; 

    // Register used to store latest poped return address
    reg [0:`RAS_WIDTH - 1] latest_poped_addr;

    // TOSP and (TOSP + 1) 
    // TOSP means Top of Stack Pointer
    // TOSP used for popping, (TOSP + 1) used for pushing
    reg [0:$clog2(`RAS_DEPTH) - 1] TOSP, TOSP_p1;

    // (n + 1)-bit depth counter used track the current depth 
    reg [0:$clog2(`RAS_DEPTH)] depth_counter;

//// All sequential actions :
    always @(posedge clk)
    begin
        if(reset)
        begin
            TOSP_p1 <= 0;
            TOSP <= 3;
            depth_counter <= 0;
            latest_poped_addr <= 0;
        end
        else
        begin

            // Note that du_jal_push and du_jr31_pop are mutual exclusive
            if(du_jal_push) // DU pushing RAS
            begin
                mem[TOSP_p1] <= du_jal_push_din;
                TOSP_p1 <= TOSP_p1 + 1;
                TOSP <= TOSP + 1;
                if(depth_counter != `RAS_DEPTH) 
                    depth_counter <= depth_counter + 1;
            end

            if(du_jr31_pop) // DU popping RAS
                if(depth_counter != 0) // only if RAS is not empty
                begin
                    TOSP_p1 <= TOSP_p1 - 1;
                    TOSP <= TOSP - 1;
                    depth_counter <= depth_counter - 1;
                    latest_poped_addr <= mem[TOSP];
                end

        end
    end

//// Combination logic 
    assign du_jr31_pop_dout = (du_jr31_pop) ? 
        ( (depth_counter == 0) ? latest_poped_addr : mem[TOSP] ) : 0;

 endmodule
`undef RAS_DEPTH
`undef RAS_WIDTH