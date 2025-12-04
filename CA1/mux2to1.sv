module mux2to1(a, b, sel, y);
    input signed [11:0] a, b;
    input sel;
    output logic signed [11:0] y;

    always @(a or b or sel) begin
        case (sel)
            1'b0: y = a;
            1'b1: y = b;
            default: y = 12'b0;
        endcase
    end
endmodule