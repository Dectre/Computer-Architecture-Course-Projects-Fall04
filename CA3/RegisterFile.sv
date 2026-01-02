module RegisterFile(A1, A2, A3, WD3, WE3, clk, rst, RD1, RD2);
    input clk, rst;
    input [2:0] A1, A2, A3;
    input [15:0] WD3;
    input WE3;
    output logic [15:0] RD1, RD2;
    logic [15:0] registers [7:0];
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1)
                registers[i] <= 16'b0; 
        end
        else if (WE3)
            registers[A3] <= WD3;
    end
    assign RD1 = registers[A1];
    assign RD2 = registers[A2];
endmodule