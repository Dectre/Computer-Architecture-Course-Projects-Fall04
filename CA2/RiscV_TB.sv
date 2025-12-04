`timescale 1ns/1ns

module RiscV_TB();
    logic clk = 1'b0, rst = 1'b1;
    wire Ready;

    RiscV UUT(clk, rst, Ready);

    always #20 clk = ~clk;

    always @(posedge Ready) #10 $stop;
    initial #10 rst = 1'b0;
endmodule