// $Id: $
// File name:   edge_detect.sv
// Created:     4/22/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Edge Detector Block
module edge_detect
(
	input wire clk,
	input wire n_rst,
	input wire d_plus,
	output reg d_edge
);

reg e1;
reg e2;

always_ff @ (posedge clk, negedge n_rst)
begin
	if(1'b0 == n_rst) begin
		e1 <= '1;
		e2 <= '1;
	end else begin
		e1 <= d_plus;
		e2 <= e1;
	end
end

always_comb 
begin
	d_edge = (e1 ^ e2);
end
endmodule

