`timescale 1ns / 1ps


module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write,
    input  [4:0] mem_wb_write_reg_addr,
    input  [31:0] mem_wb_write_back_data,
    input  Data_Hazard,
    input  Control_Hazard,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
    wire [31:0] temp;
    wire reg_dst;
    wire equal;
    wire hazard;
    wire copy_mem_to_reg;
    wire [1:0]copy_alu_op;
    wire copy_mem_read;
    wire copy_mem_write;
    wire copy_alu_src;
    wire copy_reg_write;
    wire branch;
    
    assign equal = (( reg1 ^ reg2 )==32'd0 ) ? 1'b1 : 1'b0;
    assign hazard = (~(Data_Hazard) | Control_Hazard);
    
    //outputs
    assign mem_to_reg = (hazard == 1) ? 1'b0 : copy_mem_to_reg;
    assign alu_op = (hazard == 1) ? 2'b0: copy_alu_op;
    assign mem_read = (hazard == 1) ? 1'b0 : copy_mem_read;
    assign mem_write = (hazard == 1) ? 1'b0 : copy_mem_write;
    assign alu_src = (hazard == 1) ? 1'b0 : copy_alu_src;
    assign reg_write = (hazard == 1) ? 1'b0: copy_reg_write;
    
    assign jump_address = instr[25:0] << 2;
    assign branch_address = pc_plus4 + (temp << 2);
    assign branch_taken = (branch & equal)? 1'b1: 1'b0;
    assign imm_value = temp;
    
 
    //jump, reg1, reg2, destination reg are all outputs from the components
    
    // Remember that we test if the branch is taken or not in the decode stage. 	
    register_file INST_REG_FILE(
        .clk(clk), .reset(reset),  
        .reg_write_en(mem_wb_reg_write),
        .reg_write_dest(mem_wb_write_reg_addr),  
        .reg_write_data(mem_wb_write_back_data),
        .reg_read_addr_1(instr[25:21]), 
        .reg_read_addr_2(instr[20:16]),  
        .reg_read_data_1(reg1),
        .reg_read_data_2(reg2) 
        );
    mux2 #(.mux_width(5)) MUX_REG_DEST(
            .a(instr[20:16]),
            .b(instr[15:11]),
            .sel(reg_dst),
            .y(destination_reg)
            );
   control INST_CONTROL(
           .reset(reset),
           .opcode(instr[31:26]),
           .reg_dst(reg_dst),
           .mem_to_reg(copy_mem_to_reg),
           .alu_op(copy_alu_op),
           .mem_read(copy_mem_read),
           .mem_write(copy_mem_write),
           .alu_src(copy_alu_src),
           .reg_write(copy_reg_write),
           .branch(branch), 
           .jump(jump)
           );
   sign_extend INST_SIGN_EXTEND
            (
                .sign_ex_in(instr[15:0]),
                .sign_ex_out(temp)
            );
    
    
endmodule
