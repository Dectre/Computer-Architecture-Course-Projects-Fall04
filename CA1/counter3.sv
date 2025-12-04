module counter_3(clk, rst, inc, init, count_out, carry_out);
    input clk, rst, inc, init;
    output carry_out;
    logic carry_out;
    output logic [2:0] count_out;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            {carry_out, count_out} <= 4'b0;
        end else if (init) begin
            {carry_out, count_out} <= 4'b0;
        end else if (inc) begin
            {carry_out, count_out} <= count_out + 3'b001;
        end
    end
endmodule