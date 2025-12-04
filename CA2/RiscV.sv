`timescale 1ns/1ns

module RiscV(clk, rst);
    input clk, rst;
    wire MemWrite, ALUSrc, RegWrite, Zero;
    wire [1:0] PCSrc, ResultSrc;
    wire [2:0] ALUControl, ImmSrc;
    wire [6:0] op, funct7_5;
    wire [2:0] funct3;
    
    Datapath DP(.clk(clk), .rst(rst), 
    .PCSrc(PCSrc), .ResultSrc(ResultSrc), .MemWrite(MemWrite), 
    .ALUControl(ALUControl), .ALUSrc(ALUSrc), .ImmSrc(ImmSrc), 
    .RegWrite(RegWrite), 
    .op(op), .funct3(funct3), .funct7_5(funct7_5), .Zero(Zero));
    ControlUnit CU(.op(op), .funct3(funct3), .funct7_5(funct7_5), .Zero(Zero), 
    .PCSrc(PCSrc), .ResultSrc(ResultSrc), .MemWrite(MemWrite), 
    .ALUControl(ALUControl), .ALUSrc(ALUSrc), 
    .ImmSrc(ImmSrc), .RegWrite(RegWrite));

endmodule