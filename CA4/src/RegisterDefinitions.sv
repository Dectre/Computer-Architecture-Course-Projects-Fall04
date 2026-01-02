package PipeDefinitions;

    typedef struct packed {
        logic [31:0] PC;
        logic [31:0] Instr;
        logic [31:0] PCPlus4;
    } IF_ID;

    typedef struct packed {
        logic JumpSel;
        logic RegWrite;
        logic [1:0] ResultSrc;
        logic MemWrite;
        logic Jump;
        logic [1:0] Branch;
        logic [2:0] ALUControl;
        logic ALUSrc;
        logic [31:0] RD1;
        logic [31:0] RD2;
        logic [31:0] PC;
        logic [4:0] Rs1;
        logic [4:0] Rs2;
        logic [4:0] Rd;
        logic [31:0] ExtImm;
        logic [31:0] PCPlus4;
    } ID_EX;

    typedef struct packed {
        logic RegWrite;
        logic [1:0] ResultSrc;
        logic MemWrite;
        logic [31:0] ALUResult;
        logic [31:0] WriteData;
        logic [31:0] PC;
        logic [4:0] Rd;
        logic [31:0] PCPlus4;
    } EX_MEM;

    typedef struct packed {
        logic RegWrite;
        logic [1:0] ResultSrc;
        logic [31:0] ALUResult;
        logic [31:0] ReadData;
        logic [31:0] PC;
        logic [4:0] Rd;
        logic [31:0] PCPlus4;
    } MEM_WB;

endpackage