module dff(d, ld, clk, rst, q);
    input d, clk, rst, ld;
    output logic q;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            q <= 1'b0;
        end else if (ld) begin
            q <= d;
        end
    end
endmodule
