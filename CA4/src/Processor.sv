module RISCV_Top(clk, rst
);

    input clk, rst;
    
    wire [6:0] op;
    wire [2:0] funct3;
    wire [6:0] funct7_5;
    wire MemWrite, ALUSrc, RegWrite, Jump, JumpSel;
    wire [1:0] ResultSrc, Branch;
    wire [2:0] ALUControl, ImmSrc;

    // Hazard Unit -> Datapath & Control
    wire StallF, StallD, FlushD, FlushE;
    wire [1:0] ForwardAE, ForwardBE;

    // Datapath -> Hazard Unit
    wire [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW;
    wire PCSrcE, ResultSrcE0;
    wire RegWriteM, RegWriteW; 
    
    // --- Module Instantiations ---

    ControlUnit Controller (
        .op(op),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .ALUControl(ALUControl),
        .Branch(Branch),
        .Jump(Jump),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .RegWrite(RegWrite),
        .JumpSel(JumpSel)
    );

    Datapath DP (
        .clk(clk),
        .rst(rst),
        // Inputs from Controller
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .ALUControl(ALUControl),
        .Branch(Branch),
        .Jump(Jump),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .RegWrite(RegWrite),
        .JumpSel(JumpSel),
        // Inputs from Hazard Unit
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        // Outputs to Controller
        .op(op),
        .funct3(funct3),
        .funct7_5(funct7_5),
        // Outputs to Hazard Unit
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdE(RdE),
        .RdM(RdM),
        .RdW(RdW),
        .PCSrcE(PCSrcE),
        .ResultSrcE0(ResultSrcE0),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW)
    );

    // 3. Hazard Unit
    HazardUnit Hazard (
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdE(RdE),
        .RdM(RdM),
        .RdW(RdW),
        .ResultSrcE0(ResultSrcE0),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .PCSrcE(PCSrcE),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE)
    );

endmodule