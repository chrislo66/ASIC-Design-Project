// $Id: $
// File name:   counter.sv
// Created:     3/4/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Counter Unit
module counter
(
	input wire clk,
	input wire n_rst,
	input wire cnt_up,
	input wire clear,
	output reg one_k_samples
);

flex_counter #(
	.NUM_CNT_BITS(10)
	)
  CT(
    .clk(clk),
    .n_rst(n_rst),
    .clear(clear),
    .count_enable(cnt_up),
    .rollover_val(10'd1000),
    .count_out(),
    .rollover_flag(one_k_samples)
  );
endmodule


