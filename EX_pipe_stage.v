`timescale 1ns / 1ps

module EX_pipe_stage(
    input [31:0] id_ex_instr,
    input [31:0] reg1, reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
    );
    
    wire [3:0] ALU_Control; 
    wire zero;
    wire [31:0] alu_a;
    wire [31:0] alu_b;
    
    
    
    // Write your code here
    
//    assign alu_in2_out = (Forward_A == 2'b10) ? ex_mem_alu_result : (Forward_A == 2'b01) ? mem_wb_write_back_result : reg1;
//    assign alu_a = (Forward_B == 2'b10) ? ex_mem_alu_result : (Forward_B == 2'b01) ? mem_wb_write_back_result : reg2;
    mux4 #(.mux_width(32)) first_mux
        (
            .a(reg1),
            .b(mem_wb_write_back_result),
            .c(ex_mem_alu_result),
            .d(32'd0),
            .sel(Forward_A),
            .y(alu_a)
        );
    mux4 #(.mux_width(32)) second_mux
        (
            .a(reg2),
            .b(mem_wb_write_back_result),
            .c(ex_mem_alu_result),
            .d(32'd0),
            .sel(Forward_B),
            .y(alu_in2_out)
        );
    mux2 #(.mux_width(32)) INST_MUX
                (
                    .a(alu_in2_out),
                    .b(id_ex_imm_value),
                    .sel(id_ex_alu_src),
                    .y(alu_b)
                );
                
    ALUControl INST_ALU_CONTROL
        (
            .ALUOp(id_ex_alu_op),
            .Function(id_ex_instr[5:0]),
            .ALU_Control(ALU_Control)
        );
    ALU INST_ALU
        (
            .a(alu_a),
            .b(alu_b),
            .alu_control(ALU_Control),
            .zero(zero),
            .alu_result(alu_result)
        );
    
endmodule
