module ALU(SrcA, SrcB, ALUControl, ALUResult, zero);
    input signed [31:0] SrcA, SrcB;
    input [2:0] ALUControl;
    output logic signed [31:0] ALUResult;
    output logic zero;
    parameter ADD = 3'b000,
              SUB = 3'b001,
              AND = 3'b010,
              OR  = 3'b011,
              XOR = 3'b100,
              SLT = 3'b101;
    always @(ALUControl, SrcA, SrcB) begin
        case (ALUControl)
            ADD: ALUResult = SrcA + SrcB;
            SUB: ALUResult = SrcA - SrcB; 
            AND: ALUResult = SrcA & SrcB;
            OR: ALUResult = SrcA | SrcB;
            XOR: ALUResult = SrcA ^ SrcB;
            SLT: ALUResult = SrcA < SrcB;
            default: ALUResult = 32'b0;
        endcase
    end

    assign zero = (ALUResult == 0); 
endmodule