module Mux_4to1_32(A, B, C, D, Sel, Y);
    input [31:0] A, B, C, D;
    input [1:0] Sel;
    output logic [31:0] Y;

    always @(Sel, A, B, C, D) begin
        case (Sel)
            2'b00: Y = A;
            2'b01: Y = B;
            2'b10: Y = C;
            2'b11: Y = D;
            default: Y = 32'b0;
        endcase
    end
endmodule

module Mux_2to1_32(A, B, Sel, Y);
    input [31:0] A, B;
    input Sel;
    output logic [31:0] Y;

    always @(Sel, A, B) begin
        case (Sel)
            1'b0: Y = A;
            1'b1: Y = B;
            default: Y = 32'b0;
        endcase
    end
endmodule