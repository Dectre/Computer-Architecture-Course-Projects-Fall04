module ImmediateExtend(immediate, select, extended);
    input signed [31:7] immediate;
    input [2:0] select;
    output logic signed [31:0] extended;
    always @(immediate, select) begin
        case (select)
            3'b000: extended = {{20{immediate[31]}}, immediate[31:20]}; // I-type
            3'b001: extended = {{20{immediate[31]}}, immediate[31:25], immediate[11:7]}; //S-type
            3'b010: extended = {{20{immediate[31]}}, immediate[7], immediate[30:25], immediate[11:8], 1'b0}; // B-type
            3'b011: extended = {immediate[31:12], 12'b00}; // U-type
            3'b101: extended = {{12{immediate[31]}}, immediate[19:12], immediate[20], immediate[30:21], 1'b0}; // J-type
            default: extended = 32'b0;
        endcase
    end
endmodule