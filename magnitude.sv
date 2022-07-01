// $Id: $
// File name:   magnitude.sv
// Created:     3/4/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Magnitude
module magnitude
(
	input wire [16:0] in,
	output reg [15:0] out
);

reg [16:0] invert_in;
reg [16:0] add;
	
always_comb
begin
	if (in[16] == 0) begin
		out[15:0] = in[15:0];
	end else begin
		invert_in = ~in;
		add = invert_in + 1'b1;
		out[15:0] = add[15:0];
	end
end

endmodule

