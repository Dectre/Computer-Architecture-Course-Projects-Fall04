module RegisterFile(A1, A2, A3, WD3, WE3, clk, rst, RD1, RD2)
    input clk, rst;
    input [4:0] A1, A2, A3;
    input [31:0] WD3;
    input WE3;
    output logic signed [31:0] RD1, RD2;
    logic signed [31:0] registers [31:0];
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0; 
        end
        else if (WE3 && (A3 != 5'd0)) // this 5'd0 is for zero register (x0)
            registers[A3] <= WD3;
    end
    assign RD1 = registers[A1];
    assign RD2 = registers[A2];
endmodule