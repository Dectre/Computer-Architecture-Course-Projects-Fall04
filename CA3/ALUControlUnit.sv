`define ADD 3'b000
`define SUB 3'b001
`define AND 3'b010
`define OR 3'b011
`define NOT 3'b100
`define SELA 3'b101
`define SELB 3'b110
`define NOP 3'b111

module AluControlUnit (AluOp, func, AluOpc, nop);
    input [2:0] AluOp; input [8:0] func;
    output logic [2:0] AluOpc;
    output logic nop;

    always @(AluOp, func) begin
        AluOpc = 3'b000;
        nop = 1'b0;

        case (AluOp)
            3'b000: AluOpc = 3'b000;
            3'b001: AluOpc = 3'b001;
            3'b010: AluOpc = 3'b010;
            3'b011: AluOpc = 3'b011;
            3'b100:
                case (func)
                    9'b000000100: AluOpc = `ADD;
                    9'b000001000: AluOpc = `SUB;
                    9'b000010000: AluOpc = `AND;
                    9'b000100000: AluOpc = `OR;
                    9'b001000000: AluOpc = `NOT;
                    9'b000000001: AluOpc = `SELB;
                    9'b000000010: AluOpc = `SELA;
                    9'b010000000: begin AluOpc = `NOP; nop = 1'b1; end
                    default: AluOpc = 3'b000;
                endcase
            default: AluOpc = 3'b000;
        endcase
    end
endmodule