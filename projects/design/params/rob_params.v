/*
 * @Author: Yihao Wang
 * @Date: 2020-05-01 02:05:34
 * @LastEditTime: 2020-05-01 03:00:04
 * @LastEditors: Please set LastEditors
 * @Description: Parameters used by rob.v
 * @FilePath: /undefined/Users/yihaowang/Desktop/Tomasulo_3/Tomasulo_3_test1/projects/design/params/rob_params.v
 */

 `define ROB_DEPTH 32
 `define LOG2_ROB_DEPTH 5 // $clog2(ROB_DEPTH)
 `define ROB_PTR_WIDTH `LOG2_ROB_DEPTH + 1 // width of write and read pointer
 `define ROB_WIDTH 41 // width of ROB entry
 `define ROB_ROB_TAG_WIDTH  `LOG2_ROB_DEPTH // width of ROB tag
 `define ROB_SW_ADDR_WIDTH 32 // memory address of SW 

 // width of sub-field
 `define ROB_CUR_RD_PID_WIDTH 6
 `define ROB_PRE_RD_PID_WIDTH 6
 `define ROB_RD_AID_WIDTH 5
 `define ROB_RS_PID_WIDTH 6
 `define ROB_SW_ADDR_PART0_WIDTH 11
 `define ROB_SW_ADDR_PART1_WIDTH 21

 `define ROB_COMP_START_LOC 19 // the start bit of complete bit in ROB entry
 `define ROB_SW_ADDR_PART0_START_LOC 6
 `define ROB_SW_ADDR_PART1_START_LOC 20
