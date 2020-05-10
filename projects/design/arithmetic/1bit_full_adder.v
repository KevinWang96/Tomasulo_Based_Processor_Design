/*
 * @Author: Yihao Wang
 * @Date: 2020-05-08 07:01:48
 * @LastEditTime: 2020-05-08 07:04:45
 * @LastEditors: Please set LastEditors
 * @Description: 1-bit full adder
 * @FilePath: /Tomasulo_3/Tomasulo_3_test1/projects/design/arithmetic/1bit_full_adder.v
 */
 module 1bit_full_adder (
     A, 
     B,
     Ci,
     S,
     Co
 );
    input   A;
    input   B;
    input   Ci;
    output  S;
    output  Co;

    assign  S   =   A ^ B ^ Ci;
    assign  Co  =   A & B | A & Ci | B & Ci;

 endmodule

