/*
 * @Author: Yihao Wang
 * @Date: 2020-05-05 20:12:57
 * @LastEditTime: 2020-05-06 01:06:52
 * @LastEditors: Please set LastEditors
 * @Description: Parameters used by four issue queues
 * @FilePath: /Tomasulo_3_test1/projects/design/params/iq_params.v
 */
 
//// Integer Issue Queue
`define IQ_INT_DEPTH 8
    // width of each subfields:
`define IQ_INT_ROB_TAG_WIDTH 5
`define IQ_INT_RS_WIDTH 6
`define IQ_INT_RS_RDY_WIDTH 1
`define IQ_INT_RT_WIDTH 6
`define IQ_INT_RT_RDY_WIDTH 1
`define IQ_INT_OPCODE_WIDTH 3
`define IQ_INT_RD_WIDTH 6
`define IQ_INT_INSTR_VALID_WIDTH 1
`define IQ_INT_REG_WR_WIDTH 1
`define IQ_INT_IMM_WIDTH 16 // immediate addend of addi
`define IQ_INT_BR_WIDTH 1
`define IQ_INT_BR_PREDICT_WIDTH 1
`define IQ_INT_BR_ADDR_WIDTH 32
`define IQ_INT_BR_PC_WIDTH 3
`define IQ_INT_JR_VALID_WIDTH 1
`define IQ_INT_JR_31_VALID_WIDTH 1
`define IQ_INT_JAL_VALID_WIDTH 1

`define IQ_INT_WIDTH 86

`define IQ_INT_RS_RDY_START_LOC 11
`define IQ_INT_RT_RDY_START_LOC 18
`define IQ_INT_INSTR_VALID_START_LOC 28
`define IQ_INT_RS_START_LOC 5
`define IQ_INT_RT_START_LOC 12
`define IQ_INT_INSTR_VALID_START_LOC 28
`define IQ_INT_JR_VALID_START_LOC 83
`define IQ_INT_ROB_TAG_START_LOC 0


