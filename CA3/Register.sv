module Register_12(d, load, clk, rst, q);
    input [11:0] d;
    input load, clk, rst;
    output logic [11:0] q;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 12'b0;
        end else if (load) begin
            q <= d;
        end
    end
endmodule