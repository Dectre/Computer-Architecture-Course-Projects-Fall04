`timescale 1ns/1ns

module LIF_tb;
  logic clk = 0;
  logic rst = 1;
  logic start = 0;
  logic [7:0] input_spikes;
  logic Vth_en, Vrest_en;
  logic signed [11:0] Vth, Vrest;
  logic spike_out, valid;
  integer vfile, sfile;
  always #5 clk = ~clk;
  LIF dut(
    .clk(clk),
    .rst(rst),
    .start(start),
    .input_spikes(input_spikes),
    .Vth_en(Vth_en),
    .Vth(Vth),
    .Vrest_en(Vrest_en),
    .Vrest(Vrest),
    .spike_out(spike_out),
    .valid(valid)
  );
  initial begin
    vfile = $fopen("v_n_log.txt","w");
    sfile = $fopen("spike_log.txt","w");
    rst = 1'b0; #10 rst = 1'b1; #10 rst = 1'b0;
    Vth = 12'b000100000000;
    Vrest = 12'b111111100110;
    Vth_en = 1'b1;
    Vrest_en = 1'b1;
    input_spikes = 8'b00000000; #400
    input_spikes = 8'b11111011; @(negedge clk); start = 1; #30 start = 0; #400
    input_spikes = 8'b00011010; @(negedge clk); start = 1; #30 start = 0; #400
    input_spikes = 8'b00010001; @(negedge clk); start = 1; #30 start = 0; #400
    input_spikes = 8'b00000010; @(negedge clk); start = 1; #30 start = 0; #400
    input_spikes = 8'b01010111; @(negedge clk); start = 1; #30 start = 0; #400
    input_spikes = 8'b00111101; @(negedge clk); start = 1; #30 start = 0; #400
    input_spikes = 8'b10011100; @(negedge clk); start = 1; #30 start = 0; #400
    input_spikes = 8'b01011110; @(negedge clk); start = 1; #30 start = 0; #400
    input_spikes = 8'b01110000; @(negedge clk); start = 1; #30 start = 0; #400
    input_spikes = 8'b10101010; @(negedge clk); start = 1; #30 start = 0; #400
    input_spikes = 8'b10101110; @(negedge clk); start = 1; #30 start = 0; #400
    input_spikes = 8'b00000101; @(negedge clk); start = 1; #30 start = 0; #400
    input_spikes = 8'b11110111; @(negedge clk); start = 1; #30 start = 0; #400
    input_spikes = 8'b10100111; @(negedge clk); start = 1; #30 start = 0; #400
    input_spikes = 8'b11110000; @(negedge clk); start = 1; #30 start = 0; #400
    input_spikes = 8'b10100010; @(negedge clk); start = 1; #30 start = 0; #400
    input_spikes = 8'b10101010; @(negedge clk); start = 1; #30 start = 0; #400
    input_spikes = 8'b10110110; @(negedge clk); start = 1; #30 start = 0; #400
    input_spikes = 8'b00010000; @(negedge clk); start = 1; #30 start = 0; #400
    input_spikes = 8'b00001100; @(negedge clk); start = 1; #30 start = 0; #400
    $fclose(vfile);
    $stop;
  end
  always @(posedge dut.ctrl.ps) if (dut.ctrl.ps == 5'd17) $fwrite(vfile, "%0t %012b\n", $time, dut.dp.v_n);
  always @(posedge valid) $fwrite(sfile, "%0t %012b\n", $time, spike_out);
endmodule
