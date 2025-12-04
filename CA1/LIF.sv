module LIF(clk, rst, start, input_spikes, Vth_en, Vth, Vrest_en, Vrest, spike_out, valid);
    input clk, rst, start;
    input logic [7:0] input_spikes;
    input Vth_en, Vrest_en;
    input logic signed [11:0] Vth, Vrest;
    output logic spike_out, valid;

    logic inc, init_counter, init_i;
    logic ld_v_in, ld_v_rest, ld_v_th, ld_i_in, ld_spike_in, ld_spike_out;
    logic [1:0] sel_mux1, sel_mux2, sel_mux3, sel_alu;
    logic s, out, co, compare_result;


    datapath dp(
    .clk(clk), .rst(rst),
    .inc(inc), .init_counter(init_counter),
    .ld_v_in(ld_v_in),
    .v_rest_in(Vrest), .ld_v_rest(ld_v_rest),
    .v_th_in(Vth), .ld_v_th(ld_v_th),
    .ld_i_in(ld_i_in), .init_i(init_i),
    .spike_in(input_spikes), .ld_spike_in(ld_spike_in),
    .sel_mux1(sel_mux1), .sel_mux2(sel_mux2), .sel_mux3(sel_mux3), .sel_alu(sel_alu),
    .ld_spike_out(ld_spike_out), .ld_aluOut(ld_aluOut),
    .s(s), .out(out), .spike_out(spike_out), .co(co), .compare_result(compare_result)
);

    controller ctrl(
    .clk(clk), .rst(rst), .start(start), .valid(valid), .Vth_en(Vth_en), .Vrest_en(Vrest_en),
    .inc(inc), .init_counter(init_counter), .init_i(init_i),
    .ld_v_in(ld_v_in), .ld_v_rest(ld_v_rest), .ld_v_th(ld_v_th),
    .ld_i_in(ld_i_in), .ld_spike_in(ld_spike_in), .ld_spike_out(ld_spike_out), .ld_aluOut(ld_aluOut),
    .sel_mux1(sel_mux1), .sel_mux2(sel_mux2), .sel_mux3(sel_mux3), .sel_alu(sel_alu),
    .s(s), .out(out), .co(co), .compare_result(compare_result)
    );
endmodule
