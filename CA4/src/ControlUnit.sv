`define OP_R 7'b0110011 // add, sub, and, or, slt
`define OP_I_AR 7'b0010011 // addi, xori, ori, slti
`define OP_LOAD 7'b0000011 // lw
`define OP_JALR 7'b1100111 // jalr
`define OP_STORE 7'b0100011 // sw
`define OP_BRANCH 7'b1100011 // beq, bne
`define OP_JAL 7'b1101111 // jal
`define OP_LUI 7'b0110111 // lui

`define IMM_I 3'b000 // I-type
`define IMM_S 3'b001 // S-type
`define IMM_B 3'b010 // B-type
`define IMM_J 3'b011 // J-type
`define IMM_U 3'b100 // U-type

`define ALU_ADD 3'b000
`define ALU_SUB 3'b001
`define ALU_AND 3'b010
`define ALU_OR 3'b011
`define ALU_XOR 3'b100
`define ALU_SLT 3'b101
`define ALU_SELA 3'b110
`define ALU_SELB 3'b111

module ControlUnit(op, funct3, funct7_5,
                   ImmSrc, ALUSrc, ALUControl, Branch, Jump, MemWrite, ResultSrc, RegWrite, JumpSel);
    input [6:0] op;
    input [2:0] funct3;
    input [6:0] funct7_5;

    output logic MemWrite, ALUSrc, RegWrite, Jump, JumpSel;
    output logic [1:0] ResultSrc, Branch;
    output logic [2:0] ALUControl, ImmSrc;

    always @(op, funct3, funct7_5) begin
        {ImmSrc, ALUSrc, ALUControl, Branch, Jump, MemWrite, ResultSrc, RegWrite, JumpSel} = 15'b0;
        case (op)
            `OP_R: begin
                RegWrite = 1'b1;
                case (funct3)
                    3'b000: ALUControl = funct7_5 == 7'b0000000 ? `ALU_ADD : `ALU_SUB;   
                    3'b111: ALUControl = `ALU_AND;
                    3'b110: ALUControl = `ALU_OR;
                    3'b010: ALUControl = `ALU_SLT;
                    default: ALUControl = `ALU_ADD;
                endcase
            end

            `OP_I_AR: begin
                ImmSrc = `IMM_I;
                ALUSrc = 1'b1;
                RegWrite = 1'b1;
                case (funct3)
                    3'b000: ALUControl = `ALU_ADD;
                    3'b100: ALUControl = `ALU_XOR;
                    3'b110: ALUControl = `ALU_OR;
                    3'b010: ALUControl = `ALU_SLT;
                endcase
            end

            `OP_LOAD: begin
                ImmSrc = `IMM_I;
                ALUSrc = 1'b1;
                ResultSrc = 2'b01;
                RegWrite = 1'b1;
            end
            
            `OP_STORE: begin
                ImmSrc = `IMM_S;
                ALUSrc = 1'b1;
                MemWrite = 1'b1;
            end

            `OP_BRANCH: begin
                ImmSrc = `IMM_B;
                ALUControl= `ALU_SUB;
                case (funct3)
                    3'b000: Branch = 2'b01; 
                    3'b001: Branch = 2'b11; 
                    default: Branch = 2'b00;
                endcase
            end

            `OP_JAL: begin
                ImmSrc = `IMM_J;
                Jump = 1'b1;
                ResultSrc = 2'b10;
                RegWrite = 1'b1;
                JumpSel = 1'b0;
            end

            `OP_JALR: begin
                ImmSrc = `IMM_I;
                ALUSrc = 1'b1;
                Jump = 1'b1;
                ResultSrc = 2'b10;
                RegWrite = 1'b1;
                JumpSel = 1'b1;
            end

            `OP_LUI: begin
                ImmSrc = `IMM_U;
                ALUSrc = 1'b1;
                ALUControl = `ALU_SELB;
                RegWrite = 1'b1;
            end

        endcase
    end

endmodule
