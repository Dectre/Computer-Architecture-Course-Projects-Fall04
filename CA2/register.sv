module register_32(d, clk, rst, q);
    input [31:0] d;
    input clk, rst;
    output logic [31:0] q;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            q <= 32'b0;
        end else begin
            q <= d;
        end
    end
endmodule