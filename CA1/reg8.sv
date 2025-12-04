module register_8(d, ld, clk, rst, q);
    input[7:0] d;
    input clk, rst, ld;
    output logic [7:0] q;

    always @(posedge clk, posedge rst) begin
        if (rst) q <= 8'b0;
        else if (ld)
            q <= d;
    end
endmodule