// $Id: $
// File name:   shift_register.sv
// Created:     4/23/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Shift Register
module shift_register
(
	input wire clk,
	input wire n_rst,
	input wire shift_enable,
	input wire d_orig,
	output reg [7:0] rcv_data
);

flex_stp_sr  #(
    .SHIFT_MSB(0),
    .NUM_BITS(8)
    )
  STP(
    .clk(clk),
    .n_rst(n_rst),
    .serial_in(d_orig),
    .shift_enable(shift_enable),
    .parallel_out(rcv_data)
  );

endmodule
