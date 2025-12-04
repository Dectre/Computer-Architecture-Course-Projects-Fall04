module Adder_32(A, B, Sum);
    input signed [31:0] A, B;
    output logic [31:0] Sum;

    assign Sum = A + B;
endmodule
