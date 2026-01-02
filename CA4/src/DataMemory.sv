module DataMemory(A, WD, WE, clk, rst, RD);
    input [31:0] A;
    input signed [31:0] WD;
    input WE, clk, rst;
    output logic signed [31:0] RD;

    logic signed [31:0] memory [0:8191];
    always @(posedge clk or posedge rst) begin
        if (rst)
            $readmemh("data.mem", memory);
		else if (WE) 
            memory[A[31:2]] <= WD;
	end
    assign RD = memory[A[31:2]];

endmodule
    