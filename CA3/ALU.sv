module ALU(A, B, select, result, zero);
    parameter N = 16;
    input [N-1:0] A, B;
    input [2:0] select;
    output logic [N-1:0] result;
    output logic zero;
    parameter ADD = 3'b000,
              SUB = 3'b001,
              AND = 3'b010,
              OR  = 3'b011,
              NOT = 3'b100,
              IN1 = 3'b101,
              IN2 = 3'b110;
    always @(select, A, B) begin
        case (select)
            ADD: result = A + B;
            SUB: result = A - B; 
            AND: result = A & B;
            OR: result = A | B;
            NOT: result = ~A;
            IN1: result = A;
            IN2: result = B;
            default: result = {N{1'b0}};
        endcase
    end

    assign zero = (result == 0); 
endmodule