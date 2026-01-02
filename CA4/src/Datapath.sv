module Datapath(clk, rst,
                ImmSrc, ALUSrc, ALUControl, Branch, Jump, MemWrite, ResultSrc, RegWrite, JumpSel,
                StallF, StallD, FlushD, FlushE, ForwardAE, ForwardBE,
                op, funct3, funct7_5,
                Rs1D, Rs2D, Rs1E, Rs2E, RdE, PCSrcE, ResultSrcE0, RdM, RdW, RegWriteM, RegWriteW);
    
    input clk, rst;
    input MemWrite, ALUSrc, RegWrite, Jump, JumpSel;
    input StallF, StallD, FlushD, FlushE;
    input [1:0] ForwardAE, ForwardBE;
    input [1:0] ResultSrc, Branch;
    input [2:0] ALUControl, ImmSrc;
    output [6:0] op;
    output [2:0] funct3;
    output [6:0] funct7_5;
    output [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW;
    output PCSrcE, ResultSrcE0, RegWriteM, RegWriteW;

    import PipeDefinitions::*;

    logic [31:0] PCF_next, PCF_current, PCPlus4F, InstrF;
    logic [1:0] PCSelect;

    IF_ID IF_ID_next, IF_ID_current;
    logic [31:0] InstrD, PCD, PCPlus4D;
    logic [31:0] RD1D, RD2D, ExtImmD;
    logic [4:0] RdD;
    logic [24:0] ImmD;
    logic MemWriteD, ALUSrcD, RegWriteD, JumpD, JumpSelD;
    logic [1:0] ResultSrcD, BranchD;
    logic [2:0] ALUControlD, ImmSrcD;

    ID_EX ID_EX_next, ID_EX_current;
    logic [31:0] RD1E, RD2E, PCE, ExtImmE, PCPlus4E;
    logic [31:0] SrcAE, SrcBE, WriteDataE, ALUResultE;
    logic [31:0] PCTargetE;
    logic MemWriteE, ALUSrcE, JumpE, JumpSelE;
    logic [1:0] ResultSrcE, BranchE;
    logic [2:0] ALUControlE;
    logic ZeroE;

    EX_MEM EX_MEM_next, EX_MEM_current;
    logic [31:0] ALUResultM, WriteDataM, PCM, PCPlus4M;
    logic [31:0] ReadDataM;
    logic MemWriteM;
    logic [1:0] ResultSrcM;

    MEM_WB MEM_WB_next, MEM_WB_current;
    logic [31:0] ALUResultW, ReadDataW, PCW, PCPlus4W, ResultW;
    logic RegWriteW;
    logic [1:0] ResultSrcW;

    // Instruction Fetch Stage
    assign PCSelect = {PCSrcE, JumpSelE};
    Mux_4to1 #(.N(32)) PCMUX (.A(PCPlus4F), .B(PCPlus4F), .C(PCTargetE), .D(ALUResultE), .Sel(PCSelect), .Y(PCF_next));
    Register #(32) PC_Register(.d(PCF_next), .en(~StallF), .clr(1'b0), .clk(clk), .rst(rst), .q(PCF_current));
    InstructionMemory IM(.A(PCF_current), .RD(InstrF));
    assign PCPlus4F = PCF_current + 32'd4;

    assign IF_ID_next = '{PC: PCF_current, Instr: InstrF, PCPlus4: PCPlus4F};
    Register #(.N($bits(IF_ID))) IF_ID_Register(.d(IF_ID_next), .en(~StallD), .clr(FlushD), .clk(clk), .rst(rst), .q(IF_ID_current));

    // Instruction Decode Stage
    assign InstrD = IF_ID_current.Instr;
    assign PCD = IF_ID_current.PC;
    assign PCPlus4D = IF_ID_current.PCPlus4;

    assign op = InstrD[6:0];
    assign funct3 = InstrD[14:12];
    assign funct7_5 = InstrD[31:25];
    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];
    assign RdD = InstrD[11:7];
    assign ImmD = InstrD[31:7];

    assign JumpSelD = JumpSel;
    assign RegWriteD = RegWrite;
    assign ResultSrcD = ResultSrc;
    assign MemWriteD = MemWrite;
    assign JumpD = Jump;
    assign BranchD = Branch;
    assign ALUControlD = ALUControl;
    assign ALUSrcD = ALUSrc;
    assign ImmSrcD = ImmSrc;

    RegisterFile RF(.clk(clk), .rst(rst), .WE3(RegWriteW), .A1(Rs1D), .A2(Rs2D), .A3(RdW), .WD3(ResultW), .RD1(RD1D), .RD2(RD2D));
    ImmediateExtend ImmExt(.immediate(ImmD), .select(ImmSrcD), .extended(ExtImmD));

    assign ID_EX_next = '{RegWrite: RegWriteD, ResultSrc: ResultSrcD, MemWrite: MemWriteD, Jump: JumpD, Branch: BranchD,
                          ALUControl: ALUControlD, ALUSrc: ALUSrcD, JumpSel: JumpSelD,
                          RD1: RD1D, RD2: RD2D, PC: PCD, Rs1: Rs1D, Rs2: Rs2D, Rd: RdD,
                          ExtImm: ExtImmD, PCPlus4: PCPlus4D};
    Register #(.N($bits(ID_EX))) ID_EX_Register(.d(ID_EX_next), .en(1'b1), .clr(FlushE), .clk(clk), .rst(rst), .q(ID_EX_current));

    // Execute Stage
    assign JumpSelE = ID_EX_current.JumpSel;
    assign RegWriteE = ID_EX_current.RegWrite;
    assign ResultSrcE = ID_EX_current.ResultSrc;
    assign MemWriteE = ID_EX_current.MemWrite;
    assign JumpE = ID_EX_current.Jump;
    assign BranchE = ID_EX_current.Branch;
    assign ALUControlE = ID_EX_current.ALUControl;
    assign ALUSrcE = ID_EX_current.ALUSrc;
    assign RD1E = ID_EX_current.RD1;
    assign RD2E = ID_EX_current.RD2;
    assign PCE = ID_EX_current.PC;
    assign Rs1E = ID_EX_current.Rs1;
    assign Rs2E = ID_EX_current.Rs2;
    assign RdE = ID_EX_current.Rd;
    assign ExtImmE = ID_EX_current.ExtImm;
    assign PCPlus4E = ID_EX_current.PCPlus4;

    assign PCSrcE = (BranchE[0] & (ZeroE ^ BranchE[1])) | JumpE;
    assign PCTargetE = PCE + ExtImmE;
    assign ResultSrcE0 = ResultSrcE[0];
    Mux_4to1 #(.N(32)) ForwardA_Mux(.A(RD1E), .B(ResultW), .C(ALUResultM), .D(32'b0), .Sel(ForwardAE), .Y(SrcAE));
    Mux_4to1 #(.N(32)) ForwardB_Mux(.A(RD2E), .B(ResultW), .C(ALUResultM), .D(32'b0), .Sel(ForwardBE), .Y(WriteDataE));
    Mux_2to1 #(.N(32)) ALUSrc_Mux(.A(WriteDataE), .B(ExtImmE), .Sel(ALUSrcE), .Y(SrcBE));
    ALU ALU_Unit(.A(SrcAE), .B(SrcBE), .select(ALUControlE), .result(ALUResultE), .zero(ZeroE));

    assign EX_MEM_next = '{RegWrite: RegWriteE, ResultSrc: ResultSrcE, MemWrite: MemWriteE,
                          ALUResult: ALUResultE, WriteData: WriteDataE, PC: PCE,
                          Rd: RdE, PCPlus4: PCPlus4E};
    Register #(.N($bits(EX_MEM))) EX_MEM_Register(.d(EX_MEM_next), .en(1'b1), .clr(1'b0), .clk(clk), .rst(rst), .q(EX_MEM_current));

    // Memory Stage
    assign RegWriteM = EX_MEM_current.RegWrite;
    assign ResultSrcM = EX_MEM_current.ResultSrc;
    assign MemWriteM = EX_MEM_current.MemWrite;
    assign ALUResultM = EX_MEM_current.ALUResult;
    assign WriteDataM = EX_MEM_current.WriteData;
    assign PCM = EX_MEM_current.PC;
    assign RdM = EX_MEM_current.Rd;
    assign PCPlus4M = EX_MEM_current.PCPlus4;

    DataMemory DM(.clk(clk), .A(ALUResultM), .WD(WriteDataM), .WE(MemWriteM), .RD(ReadDataM), .rst(rst));
    assign MEM_WB_next = '{RegWrite: RegWriteM, ResultSrc: ResultSrcM,
                          ALUResult: ALUResultM, ReadData: ReadDataM, PC: PCM,
                          Rd: RdM, PCPlus4: PCPlus4M};
    Register #(.N($bits(MEM_WB))) MEM_WB_Register(.d(MEM_WB_next), .en(1'b1), .clr(1'b0), .clk(clk), .rst(rst), .q(MEM_WB_current));

    // Write Back Stage
    assign RegWriteW = MEM_WB_current.RegWrite;
    assign ResultSrcW = MEM_WB_current.ResultSrc;
    assign ALUResultW = MEM_WB_current.ALUResult;
    assign ReadDataW = MEM_WB_current.ReadData;
    assign PCW = MEM_WB_current.PC;
    assign RdW = MEM_WB_current.Rd;
    assign PCPlus4W = MEM_WB_current.PCPlus4;

    Mux_4to1 #(.N(32)) Result_Mux(.A(ALUResultW), .B(ReadDataW), .C(PCPlus4W), .D(PCW), .Sel(ResultSrcW), .Y(ResultW));

endmodule