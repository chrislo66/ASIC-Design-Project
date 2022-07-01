// $Id: $
// File name:   eop_detect.sv
// Created:     4/22/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: EOP Detector
module eop_detect
(
	input wire d_plus,
	input wire d_minus,
	output reg eop
);

always_comb
begin
	if (!d_plus && !d_minus)
		eop = 1;
	else
		eop = 0;
end
endmodule

