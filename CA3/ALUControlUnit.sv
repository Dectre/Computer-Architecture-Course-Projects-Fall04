`define ADD 3'b000
`define SUB 3'b001
`define AND 3'b010
`define OR 3'b011
`define NOT 3'b100
`define SELA 3'b101
`define SELB 3'b110
`define NOP 3'b111

module AluControlUnit (ALUop, func, ALUopc, nop);
    input [2:0] ALUop; input [8:0] func;
    output logic [2:0] aluOpc;
    output logic nop;

    always @(ALUop, func) begin
        aluOpc = 3'b000;
        nop = 1'b0;

        case (ALUop)
            3'b000:
                aluOpc = 3'b000;
            3'b001:
                aluOpc = 3'b001;
            3'b010:
                aluOpc = 3'b010;
            3'b011:
                aluOpc = 3'b011;
            3'b100:
                case (func)
                    9'b000000100: aluOpc = ADD; // Add
                    9'b000001000: aluOpc = SUB; // Sub
                    9'b000010000: aluOpc = AND; // And
                    9'b000100000: aluOpc = OR; // Or
                    9'b001000000: aluOpc = NOT; // Not
                    9'b000000001: begin aluOpc = SELA; end // MoveTo
                    9'b000000010: aluOpc = SELB; // MoveFrom
                    9'b010000000: begin aluOpc = NOP; nop = 1'b1; end // Nop
                    default: aluOpc = 3'b000;
                endcase
            default: aluOpc = 3'b000;
        endcase
    end
endmodule
