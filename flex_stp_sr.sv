// $Id: $
// File name:   flex_stp_sr.sv
// Created:     2/14/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Serial-to-Parallel Shift Register
module flex_stp_sr
#(
	parameter NUM_BITS = 4,
	parameter SHIFT_MSB = 1
)
(
	input wire clk,
	input wire n_rst,
	input wire shift_enable,
	input wire serial_in,
	output reg [NUM_BITS-1:0]parallel_out
);

reg [NUM_BITS-1:0] next_in;

always_comb
begin 
	if (shift_enable == 1'b1 && SHIFT_MSB)
		next_in = {parallel_out[NUM_BITS-2:0], serial_in};
	else if (shift_enable == 1'b1 && !SHIFT_MSB)
		next_in = {serial_in, parallel_out[NUM_BITS-1:1]};
	else
		next_in = parallel_out;
end

always_ff @ (posedge clk, negedge n_rst)
begin
	if (1'b0 == n_rst)
		parallel_out <= '1;
	else
		parallel_out <= next_in;
end
endmodule

