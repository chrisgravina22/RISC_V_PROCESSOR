`timescale 1ns / 1ps
module IF_pipe_stage(
    input clk, reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
    );
    reg [9:0]pc;
    
    
    wire [9:0] a_jump_mux;
    wire [9:0] copy_pc;
// write your code here

    always @(posedge clk or posedge reset)  
    begin   
        if(reset)   
           pc <= 10'b0000000000; 
        else if (en)
           pc <= copy_pc;
    end  
 
    assign pc_plus4 = pc + 10'd4;
    
    
    mux2 #(.mux_width(10)) branch_mux
        (
            .a(pc_plus4),
            .b(branch_address),
            .sel(branch_taken),
            .y(a_jump_mux)
        );
    mux2 #(.mux_width(10)) jump_mux
        (
            .a(a_jump_mux),
            .b(jump_address),
            .sel(jump),
            .y(copy_pc)
        );      
    
    instruction_mem inst_mem (
        .read_addr(pc),
        .data(instr));             
           
endmodule
