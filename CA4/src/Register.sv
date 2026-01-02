module Register #(parameter N = 32)(
    input clk, rst, clr, en,
    input [N-1:0] d,
    output logic [N-1:0] q
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            q <= {N{1'b0}};
        else if (clr)
            q <= {N{1'b0}};
        else if (en)
            q <= d;
    end

endmodule