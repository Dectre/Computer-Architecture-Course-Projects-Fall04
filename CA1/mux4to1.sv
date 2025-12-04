module mux4to1(a, b, c, d, sel, y);
    input signed [11:0] a, b, c, d;
    input [1:0] sel;
    output logic signed [11:0] y;
    
    always @(a or b or c or d or sel) begin
        case (sel)
            2'b00: y = a;
            2'b01: y = b;
            2'b10: y = c;
            2'b11: y = d;
            default: y = 12'b0;
        endcase
    end
endmodule