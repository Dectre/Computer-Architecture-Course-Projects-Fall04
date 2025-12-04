module InstructionMemory(A, RD)
    input [31:0] A;
    output logic [31:0] RD;
    logic [31:0] memory [8191:0];
    initial begin
        $readmemh("instructions.mem", memory);
    end
    assign RD = memory[{A[31:2], 2'b00}];
endmodule