// $Id: $
// File name:   fir_filter.sv
// Created:     3/4/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: FIR Filter
module fir_filter
(
	input wire clk,
	input wire n_reset,
	input wire [15:0] sample_data,
	input wire [15:0] fir_coefficient,
	input wire load_coeff,
	input wire data_ready,
	output reg one_k_samples,
	output reg modwait,
	output reg [15:0] fir_out,
	output reg err
);

reg lc;
reg dr;
reg cnt;
reg clear;
reg [2:0] op;
reg [3:0] src1;
reg [3:0] src2;
reg [3:0] dest;
reg [16:0] in;
reg overflow;



controller
 CON(
	.clk(clk),
	.n_rst(n_reset),
	.dr(data_ready),
	.lc(load_coeff),
	.overflow(overflow),
	.cnt_up(cnt),
	.clear(clear),
	.modwait(modwait),
	.op(op),
	.src1(src1),
	.src2(src2),
	.dest(dest),
	.err(err)
 );

counter
 CNT(
	.clk(clk),
	.n_rst(n_reset),
	.cnt_up(cnt),
	.clear(clear),
	.one_k_samples(one_k_samples)
 );

magnitude
 MAG(
	.in(in),
	.out(fir_out)
 );

datapath
 DATA(
	.clk(clk),
	.n_reset(n_reset),
	.op(op),
	.src1(src1),
	.src2(src2),
	.dest(dest),
	.ext_data1(sample_data),
	.ext_data2(fir_coefficient),
	.outreg_data(in),
	.overflow(overflow)
 );

endmodule

