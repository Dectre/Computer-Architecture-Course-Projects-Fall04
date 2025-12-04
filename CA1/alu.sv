module alu12(a, b, sel, result);
    input signed [11:0] a, b;
    input[1:0] sel;
    output logic signed [11:0] result;

    always @(a, b, sel) begin
        case (sel)
            2'b00: result = a + b;
            2'b01: result = a - b;
            2'b10: result = a >>> 2;
            2'b11: result = (a >= b) ? 12'b1 : 12'b0;
            default: result = 12'b0;
        endcase
    end
endmodule