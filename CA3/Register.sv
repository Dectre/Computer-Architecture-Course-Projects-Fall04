module Register #(parameter N = 16)(d, load, clk, rst, q);
    input [N-1:0] d;
    input load, clk, rst;
    output logic [N-1:0] q;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= N'b0;
        end else if (load) begin
            q <= d;
        end
    end
endmodule