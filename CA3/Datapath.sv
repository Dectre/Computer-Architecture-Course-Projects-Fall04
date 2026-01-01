module Datapath(clk, rst, PCLoad, AdrSrc, MemWrite, IRWrite, WriteTo, RFWrite, WriteSrc, SrcA, SrcB, AluOP, PCSrc, op, func, Zero, nop);
    input clk, rst;
    input PCLoad, AdrSrc, MemWrite, IRWrite , WriteTo, RFWrite, WriteSrc, SrcA;
    input [1:0] SrcB, PCSrc;
    input [2:0] AluOP;
    output [3:0] op;
    output [8:0] func;
    output Zero;
    
    assign op = Instr[15:12];
    assign Ri = Instr[11:9];
    assign func = Instr[8:0];
    assign Imm = Instr[11:0];

    wire [11:0] Imm;
    wire [2:0] Ri, AluControl;
    wire [11:0] PC_current, PC_next, MemAddr;
    wire [15:0] ReadData, Instr, MDR_out, WriteReg, ImmExt, A_in, A_out, B_in, B_out, AluIn1, AluIn2 ,AluOutNext, AluOutCurrent;

    Register #(12) PC(.d(PC_next), .load(PCLoad), .clk(clk), .rst(rst), .q(PC_current));
    Mux_2to1 #(12) MemoryMux(.A(PC_current), .B(Imm), .Sel(AdrSrc), .Y(MemAddr)); 
    DataMemory DM(.clk(clk), .rst(rst), .A(MemAddr), .WD(A_out), .WE(MemWrite), .RD(ReadData));
    Register #(16) IR(.d(ReadData), .load(IRWrite), .clk(clk), .rst(rst), .q(Instr));
    Register #(16) MDR(.d(ReadData), .load(1'b1), .clk(clk), .rst(rst), .q(MDR_out));
    Mux_2to1 #(16) WriteRegMux(.A(12'b0), .B(Ri), .Sel(WriteSrc), .Y(WriteReg));
    Mux_2to1 #(16) WriteDataMux(.A(MDR_out), .B(AluOutCurrent), .Sel(WriteTo), .Y(WriteData));
    RegisterFile RF(.A1(Ri), .A3(Ri), .WD3(AluOutCurrent), .WE3(RFWrite), .clk(clk), .rst(rst), .RD1(A_in), .RD2(B_in));
    SignExtend SE(.in(Imm), .out(ImmExt));
    Register #(16) A(.d(A_in), .load(1'b1), .clk(clk), .rst(rst), .q(A_out));
    Register #(16) B(.d(B_in), .load(1'b1), .clk(clk), .rst(rst), .q(B_out));
    Mux_2to1 #(16) SrcAMux(.A(A_out), .B(PC_current), .Sel(SrcA), .Y(AluIn1));
    Mux_4to1 #(16) SrcBMux(.A(B_out), .B(16'b1), .C(ImmExt), .D(16'b0), .Sel(SrcB), .Y(AluIn2));
    ALU ALU_Unit(.A(AluIn1), .B(AluIn2), .select(ALUControl), .result(AluOutNext), .zero(Zero));
    AluControlUnit ALUControl(.ALUop(AluOP), .func(func), .ALUopc(AluControl), .nop(nop));
    Register #(16) ALUOut(.d(AluOutNext), .load(1'b1), .clk(clk), .rst(rst), .q(AluOutCurrent));
    Mux_4to1 #(12) PCMux(.A(AluOutNext[11:0]), .B(Imm), .C(func), .D(32'b0), .Sel(PCSrc), .Y(PC_next));
endmodule