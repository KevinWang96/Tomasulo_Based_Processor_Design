/*
 * @Author: Yihao Wang
 * @Date: 2020-05-08 07:05:11
 * @LastEditTime: 2020-05-08 07:19:56
 * @LastEditors: Please set LastEditors
 * @Description: Configurable Adder and Subtractor
 * @FilePath: /Tomasulo_3/Tomasulo_3_test1/projects/design/arithmetic/add_sub.v
 */
 `include "./design/arithmetic/1bit_full_adder.v"
 `timescale 1ns/1ps
 module add_sub #(
     parameter WIDTH    =   8
 )
 (
     A,
     B, 
     add_b_sub, // 0: add; 1: sub;
     S,
     Co
 );

    input   [0:WIDTH - 1]   A;
    input   [0:WIDTH - 1]   B;
    input                   add_b_sub;
    output  [0:WIDTH - 1]   S;
    output                  Co;

    wire    [0:WIDTH - 1]   B_temp;
    wire    [0:WIDTH]       C_wire;

    assign  B_temp      =   B ^ {WIDTH{add_b_sub}};
    assign  C_wire[0]   =   add_b_sub;
    assign  Co          =   C_wire[WIDTH];

    genvar i;
    generate begin
        for(i = 0; i < WIDTH; i = i + 1) begin : add_loop

            1bit_full_adder (
                .A(A[i]),
                .B(B[i]),
                .Ci(C_wire[i]),
                .S(S[i]),
                .Co(C_wire[i + 1])
            );
        end
    end
    endgenerate

 endmodule

