// $Id: $
// File name:   timer.sv
// Created:     4/23/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Timer
module timer
(
	input wire clk,
	input wire n_rst,
	input wire d_edge,
	input wire rcving,
	output reg shift_enable,
	output reg byte_received
);

reg [3:0] shift_count;

assign shift_enable = (shift_count == 4'd2) ? 1 : 0;

flex_counter
  SHIFT(
    .clk(clk),
    .n_rst(n_rst),
    .clear(d_edge || !rcving),
    .count_enable(rcving),
    .rollover_val(4'd8),
    .count_out(shift_count),
    .rollover_flag()
  );

flex_counter
  BYTE(
    .clk(clk),
    .n_rst(n_rst),
    .clear(!rcving),
    .count_enable(shift_enable),
    .rollover_val(4'd8),
    .count_out(),
    .rollover_flag(byte_received)
  );
	

endmodule
