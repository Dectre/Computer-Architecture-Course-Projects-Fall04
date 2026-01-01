module Mux_4to1 #(parameter N  = 16)(A, B, C, D, Sel, Y);
    input [N-1:0] A, B, C, D;
    input [1:0] Sel;
    output logic [N-1:0] Y;

    always @(Sel, A, B, C, D) begin
        case (Sel)
            2'b00: Y = A;
            2'b01: Y = B;
            2'b10: Y = C;
            2'b11: Y = D;
            default: Y = (N-1)'b0;
        endcase
    end
endmodule

module Mux_2to1 #(parameter N  = 16)(A, B, Sel, Y);
    input [N-1:0] A, B;
    input Sel;
    output logic [N-1:0] Y;

    always @(Sel, A, B) begin
        case (Sel)
            1'b0: Y = A;
            1'b1: Y = B;
            default: Y = (N-1)'b0;
        endcase
    end
endmodule