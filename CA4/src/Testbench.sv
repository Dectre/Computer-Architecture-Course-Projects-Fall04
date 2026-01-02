`timescale 1ns/1ns

module RiscV_TB();
    logic clk = 1'b0, rst = 1'b1;

    RISCV_Top UUT(clk, rst);

    always #20 clk = ~clk;

    initial begin 
        #10 rst = 1'b0;
        #10000 $stop;
    end
endmodule

`timescale 1ns/1ns