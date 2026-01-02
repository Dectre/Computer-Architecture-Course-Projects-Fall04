`timescale 1ns/1ns

module MultiCycle_TB();
    logic clk = 1'b0, rst = 1'b1;

    MultiCycle UUT(clk, rst);
    always #10 clk = ~clk;

    initial begin
        rst = 1'b1;
        #20 rst = 1'b0;
        #20000; 
        $display("Sum : %d", UUT.DP.DM.memory[4000]);
        $stop;
    end
endmodule