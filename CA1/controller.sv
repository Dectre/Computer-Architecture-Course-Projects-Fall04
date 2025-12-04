`define S0 5'b00000
`define S1 5'b00001
`define S2 5'b00010
`define S3 5'b00011
`define S4 5'b00100
`define S5 5'b00101
`define S6 5'b00110
`define S7 5'b00111
`define S8 5'b01000
`define S9 5'b01001
`define S10 5'b01010
`define S11 5'b01011
`define S12 5'b01100
`define S13 5'b01101
`define S14 5'b01110
`define S15 5'b01111
`define S16 5'b10000
`define S17 5'b10001
`define S18 5'b10010


module controller(clk, rst, start, valid, Vth_en, Vrest_en,
    inc, init_counter, init_i,
    ld_v_in, ld_v_rest, ld_v_th, ld_i_in, ld_spike_in, ld_spike_out, ld_aluOut,
    sel_mux1, sel_mux2, sel_mux3, sel_alu,
    s, co, out, compare_result);
    input clk, rst, start, s, co, out, compare_result, Vth_en, Vrest_en;
    output logic inc, init_counter, init_i,
        ld_v_in, ld_v_rest, ld_v_th, ld_i_in, ld_spike_in, ld_spike_out, ld_aluOut, valid;
    output logic [1:0] sel_mux1, sel_mux2, sel_mux3, sel_alu;
    logic [4:0] ps, ns;

    parameter[1:0] sel_v_n_1 = 2'b00,
        sel_v_rest = 2'b01,
        sel_w = 2'b10,
        sel_aluOut_1 = 2'b11;
    parameter[1:0] sel_v_n_2 = 2'b00,
        sel_v_th = 2'b01,
        sel_i_n = 2'b10,
        sel_aluOut_2 = 2'b11;
    parameter[1:0] sel_v_n_3 = 2'b00,
        sel_v_rest_3 = 2'b01,
        sel_aluOut_3 = 2'b10,
        sel_zero = 2'b11;

    parameter[1:0] add = 2'b00,
        sub = 2'b01,
        shift = 2'b10,
        compare = 2'b11;
    
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            ps <= 4'b0000;
        end else begin
            ps <= ns;
        end
    end

    always @(ps or start or co or compare_result) begin
        case (ps)
            `S0: ns = start ? `S1 : `S0;
            `S1: ns = start ? `S1 : `S2;
            `S2: ns = `S3;
            `S3: ns = `S4;
            `S4: ns = `S5;
            `S5: ns = `S6;
            `S6: ns = `S7;
            `S7: ns = `S8;
            `S8: ns = `S9;
            `S9: ns = `S18;
            `S18: ns = `S10;
            `S10: ns = co ? `S12 : `S11;
            `S11: ns = `S18;
            `S12: ns = `S13;
            `S13: ns = `S14;
            `S14: ns = `S15;
            `S15: ns = `S16;
            `S16: ns = `S17;
            `S17: ns = `S0;
        endcase
    end

    always @(ps) begin
        {inc, init_counter, init_i, valid,
        ld_v_in, ld_v_rest, ld_v_th, ld_i_in, ld_spike_in, ld_spike_out, ld_aluOut,
        sel_mux1, sel_mux2, sel_mux3, sel_alu, valid} = 23'b0;

        case (ps)
            `S0: valid = 1'b1;
            `S1: {ld_v_rest, ld_v_th, ld_spike_in} = {Vrest_en, Vth_en, 1'b1};
            `S2: {ld_v_in, sel_mux3} = {1'b1, out ? sel_v_n_3 : sel_v_rest_3};
            `S3: {sel_mux1, sel_alu, ld_aluOut} = {sel_v_n_1, shift, 1'b1};
            `S4: {sel_mux1, sel_mux2, sel_alu, ld_aluOut} = {sel_v_n_1, sel_aluOut_2, sub, 1'b1};
            `S5: {sel_mux3, ld_v_in} = {sel_aluOut_3, 1'b1};
            `S6: {sel_mux1, sel_alu, ld_aluOut} = {sel_v_rest, shift, 1'b1};
            `S7: {sel_mux1, sel_mux2, sel_alu, ld_aluOut} = {sel_v_n_1, sel_aluOut_2, add, 1'b1};
            `S8: {sel_mux3, ld_v_in} = {sel_aluOut_3, 1'b1};
            `S9: {init_counter, init_i} = {1'b1, 1'b1};
            `S10: {sel_mux1, sel_mux2, sel_alu, ld_aluOut} = {sel_i_n, sel_w, add, 1'b1};
            `S11: {ld_i_in, inc} = {s, 1'b1};
            `S12: {sel_mux1, sel_mux2, sel_alu, ld_aluOut} = {sel_v_n_1, sel_i_n, add, 1'b1};
            `S13: {sel_mux3, ld_v_in} = {sel_aluOut_3, 1'b1};
            `S14: {sel_mux1, sel_mux2, sel_alu, ld_aluOut} = {sel_v_n_1, sel_v_th, compare, 1'b1};
            `S16: ld_spike_out = 1'b1;
            `S17: {ld_v_in, sel_mux3} = {1'b1, out ? sel_v_n_3 : sel_v_rest_3};
        endcase
    end


endmodule