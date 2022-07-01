// $Id: $
// File name:   flex_counter.sv
// Created:     2/12/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Flexible Counter

module flex_counter
#(
	parameter NUM_CNT_BITS = 4
)	
(
	input wire clk,
	input wire n_rst,
	input wire clear,
	input wire count_enable,
	input wire [NUM_CNT_BITS-1:0] rollover_val,
	output reg [NUM_CNT_BITS-1:0] count_out,
	output reg rollover_flag
);

reg [NUM_CNT_BITS-1:0] next_count;
reg next_flag;

always_comb
begin
	next_flag = rollover_flag;
	next_count = count_out;
	if (clear == 1'b1) begin
		next_count = 1'b0;
	end else if (count_enable == 1'b1 && count_out != rollover_val)begin
		next_count = count_out + 1;
	end else if (count_enable == 1'b1 && count_out == rollover_val)begin
		next_count = 1;
	end
	if (next_count == rollover_val)begin
		next_flag = 1;
	end else begin
		next_flag = 0;
	end
end

always_ff @ (posedge clk, negedge n_rst) 
begin
	if (!n_rst) begin
		count_out <= 1'b0;
		rollover_flag <= 1'b0;
	end else begin
		count_out <= next_count;
		rollover_flag <= next_flag;
	end
end
endmodule		
