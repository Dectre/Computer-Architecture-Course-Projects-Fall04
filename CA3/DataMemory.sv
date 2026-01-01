module DataMemory(A, WD, WE, clk, rst, RD);
    input [11:0] A;
    input [15:0] WD;
    input WE, clk, rst;
    output logic [15:0] RD;

    logic [35:0] memory [8191:0];
    always @(posedge clk or posedge rst) begin
        if (rst)
            $readmemh("data.mem", memory);
		else if (WE) 
            memory[A] <= WD;
	end
    assign RD = memory[A];
endmodule
    