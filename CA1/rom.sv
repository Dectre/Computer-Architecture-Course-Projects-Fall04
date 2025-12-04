module rom(clk, rst, index, data);
    input clk, rst;
    input[2:0] index;
    output logic signed [11:0] data;
    logic signed [11:0] rom [0:7];
    initial begin
        $readmemb("Weights.mif", rom);
    end
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            data <= 12'b0;
        end else begin
            data <= rom[index];
        end
    end
endmodule