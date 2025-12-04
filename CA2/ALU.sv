module ALU(A, B, select, result, zero);
    input signed [31:0] A, B;
    input [2:0] select;
    output logic signed [31:0] result;
    output logic zero;
    parameter ADD = 3'b000,
              SUB = 3'b001,
              AND = 3'b010,
              OR  = 3'b011,
              XOR = 3'b100,
              SLT = 3'b101;
    always @(select, A, B) begin
        case (select)
            ADD: result = A + B;
            SUB: result = A - B; 
            AND: result = A & B;
            OR: result = A | B;
            XOR: result = A ^ B;
            SLT: result = A < B ? 32'b1 : 32'b0;
            default: result = 32'b0;
        endcase
    end

    assign zero = (result == 0); 
endmodule