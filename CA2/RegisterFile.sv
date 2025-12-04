module RegisterFile(A1, A2, A3, WD3, WE3, RD1, RD2)
    input clk, rst;
    input [4:0] A1, A2, A3;
    input [31:0] WD3;
    input WE3;
    output logic [31:0] RD1, RD2;
    logic [31:0] registers [31:0];
    integer i;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                register[i] <= 32'b0; 
        end
        else if (WE3 && (A3 != 5'd0)) // this 5'd0 is for zero register (x0)
            register[A3] <= WD3;
    end
    assign RD1 = registers[A1];
    assign RD2 = registers[A2];
endmodule