// $Id: $
// File name:   decode.sv
// Created:     4/22/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Decode Block
module decode
(
	input wire clk,
	input wire n_rst,
	input wire d_plus,
	input wire shift_enable,
	input wire eop,
	output reg d_orig
);

reg pre_d_orig;
reg d_current;
reg d_stored;

always_ff @ (posedge clk, negedge n_rst)
begin
	if(1'b0 == n_rst) begin
		d_stored <= '1;
	end else begin
		d_stored <= d_current;
	end
end

always_comb 
begin
	if(shift_enable && !eop)
		d_current = d_plus;
	else if (shift_enable && eop)
		d_current = 1;
	else 
		d_current = d_stored;
	
	d_orig = ~(d_stored ^ d_plus); 
end



endmodule

