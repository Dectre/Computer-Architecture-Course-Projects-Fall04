module Datapath(clk, rst, PCSrc, ResultSrc, MemWrite, ALUControl, ALUSrc, ImmSrc, RegWrite, op, funct3, funct7_5, Zero);
    input clk, rst;
    input MemWrite, ALUSrc, RegWrite;
    input [1:0] PCSrc, ResultSrc;
    input [2:0] ALUControl, ImmSrc;
    output [6:0] op;
    output [2:0] funct3;
    output [6:0] funct7_5;
    output Zero;

    wire [31:0] PC_next, PC_current, Instr, PCPlus4, ImmExt, SrcA, SrcB, WriteData, ALUResult, PCTarget, ReadData, Result;
    wire [24:0] Imm;
    wire [4:0] rs1, rs2, rd;
    
    assign rs1 = Instr[19:15];
    assign rs2 = Instr[24:20];
    assign rd = Instr[11:7];
    assign Imm = Instr[31:7];

    assign op = Instr[6:0];
    assign funct3 = Instr[14:12];
    assign funct7_5 = Instr[31:25];

    Mux_4to1_32 PCMux(.A(PCPlus4), .B(PCTarget), .C(ALUResult), .D(32'b0), .Sel(PCSrc), .Y(PC_next));
    Register_32 PC(.d(PC_next), .clk(clk), .rst(rst), .q(PC_current));
    InstructionMemory IM(.A(PC_current), .RD(Instr));
    Adder_32 PCAdder(.A(PC_current), .B(32'd4), .Sum(PCPlus4));
    RegisterFile RF(.A1(rs1), .A2(rs2), .A3(rd), .WD3(Result), .WE3(RegWrite), .clk(clk), .rst(rst), .RD1(SrcA), .RD2(WriteData));
    ImmediateExtend immExt(.immediate(Imm), .select(ImmSrc), .extended(ImmExt));
    Mux_2to1_32 ALUSrcMux(.A(WriteData), .B(ImmExt), .Sel(ALUSrc), .Y(SrcB));
    ALU ALU_Unit(.A(SrcA), .B(SrcB), .select(ALUControl), .result(ALUResult), .zero(Zero));
    Adder_32 PCTargetAdder(.A(PC_current), .B(ImmExt), .Sum(PCTarget));
    DataMemory DM(.clk(clk), .rst(rst), .A(ALUResult), .WD(WriteData), .WE(MemWrite), .RD(ReadData));
    Mux_4to1_32 resultMux(.A(ALUResult), .B(ReadData), .C(PCPlus4), .D(PC_current), .Sel(ResultSrc), .Y(Result));
endmodule