module datapath(clk , rst, inc, init_counter, 
    ld_v_in, v_rest_in, ld_v_rest, v_th_in, ld_v_th, ld_i_in, init_i, spike_in, ld_spike_in, ld_aluOut,
    sel_mux1, sel_mux2, sel_mux3,
    sel_alu,
    ld_spike_out, s, out, spike_out, co, compare_result);

    input clk, rst, inc, init_counter, ld_v_in, ld_v_rest, ld_v_th, ld_i_in, init_i, ld_spike_in, ld_spike_out, ld_aluOut;
    input [1:0] sel_mux1, sel_mux2, sel_mux3, sel_alu;

    input logic signed [11:0] v_rest_in, v_th_in;
    input logic [7:0] spike_in;
    output logic out, spike_out, s, co, compare_result;

    wire signed [11:0] v_n, v_rest, v_th, i_n, w, mux1_out, mux2_out, mux_v_n_out, aluOutput, aluOut;
    wire [7:0] spike;
    wire [2:0] i;

    
    register_12 v_n_reg (.clk(clk), .rst(rst), .d(mux_v_n_out), .q(v_n), .ld(ld_v_in), .init(1'b0));
    register_12 v_rest_reg (.clk(clk), .rst(rst), .d(v_rest_in), .q(v_rest), .ld(ld_v_rest), .init(1'b0));
    register_12 v_th_reg (.clk(clk), .rst(rst), .d(v_th_in), .q(v_th), .ld(ld_v_th), .init(1'b0));
    register_12 i_n_reg (.clk(clk), .rst(rst), .d(aluOut), .q(i_n), .ld(ld_i_in), .init(init_i));
    register_12 aluOut_reg (.clk(clk), .rst(rst), .d(aluOutput), .q(aluOut), .ld(ld_aluOut), .init(1'b0));
    register_8 spike_reg(.clk(clk), .rst(rst), .d(spike_in), .q(spike), .ld(ld_spike_in));
    dff spike_out_reg(.clk(clk), .rst(rst), .d(~aluOut[0]), .q(out), .ld(ld_spike_out));
    counter_3 i_counter(.clk(clk), .rst(rst), .inc(inc), .init(init_counter), .count_out(i), .carry_out(co));
    rom weights_rom(.clk(clk), .rst(rst), .index(i), .data(w));

    alu12 alu(.a(mux1_out), .b(mux2_out), .sel(sel_alu), .result(aluOutput));
    mux4to1 mux4_1(.a(v_n), .b(v_rest), .c(w), .d(aluOut), .sel(sel_mux1), .y(mux1_out));
    mux4to1 mux4_2(.a(v_n), .b(v_th), .c(i_n), .d(aluOut), .sel(sel_mux2), .y(mux2_out));
    mux4to1 mux4_3(.a(v_n), .b(v_rest), .c(aluOut), .d(12'b0), .sel(sel_mux3), .y(mux_v_n_out));

    assign compare_result = aluOut[0];
    assign s = spike[i];
    assign spike_out = ~out;
    

endmodule