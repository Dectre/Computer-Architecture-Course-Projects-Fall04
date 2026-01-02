module InstructionMemory(A, RD);
    input [31:0] A;
    output logic [31:0] RD;
    logic [31:0] memory [0:8191];

    initial begin
        $readmemh("src/instructions.mem", memory);
    end
    assign RD = memory[A[31:2]];
endmodule