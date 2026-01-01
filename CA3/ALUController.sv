module AluController (ALUop, func, ALUopc, nop, writeSrc);
    input [2:0] ALUop; input [8:0] func;
    output logic [2:0] aluOpc;
    output logic nop, writeSrc;

    always @(ALUop, func) begin
        aluOpc = 3'b000;
        {nop, writeSrc} = 2'b00;

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
                    9'b000000100: aluOpc = 3'b000; // Add
                    9'b000001000: aluOpc = 3'b001; // Sub
                    9'b000010000: aluOpc = 3'b010; // And
                    9'b000100000: aluOpc = 3'b011; // Or
                    9'b001000000: aluOpc = 3'b100; // Not
                    9'b000000001: begin aluOpc = 3'b101; writeSrc = 1'b1; end // MoveTo
                    9'b000000010: aluOpc = 3'b110; // MoveFrom
                    9'b010000000: begin aluOpc = 3'b111; nop = 1'b1; end // Nop
                    default: aluOpc = 3'b000;
                endcase
            default: aluOpc = 3'b000;
        endcase
    end
endmodule
