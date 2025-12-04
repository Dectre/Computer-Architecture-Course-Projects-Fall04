module register_12(d, ld, init, clk, rst, q);
    input signed [11:0] d;
    input clk, rst, ld, init;
    output logic signed [11:0] q;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            q <= 12'b0;
        end else if (init) begin
            q <= 12'b0;
        end else if (ld) begin
            q <= d;
        end
    end
endmodule