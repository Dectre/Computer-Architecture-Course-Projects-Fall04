module SignExtend(input [11:0] in, output logic [15:0] out);
    assign out = {{4{in[11]}}, in};
endmodule