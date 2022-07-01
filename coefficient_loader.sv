// $Id: $
// File name:   coefficient_loader.sv
// Created:     4/4/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Coefficient Loader Module
module coefficient_loader
(
	input wire clk,
	input wire n_reset,
	input wire new_coefficient_set,
	input wire modwait,
	output reg load_coeff,
	output reg [1:0] coefficient_num
);

typedef enum logic [3:0] {IDLE, LOAD1, WAIT1, LOAD2, WAIT2, LOAD3, WAIT3, LOAD4} state_type;
state_type state, next_state;

always_comb
begin
	next_state = state;
	load_coeff = 0;
	coefficient_num = '0;

	case(state)
	 IDLE:begin
		load_coeff = 0;
		if (new_coefficient_set && !modwait) next_state = LOAD1;
	 end
	 LOAD1:begin
		coefficient_num = 2'd0; 
		load_coeff = 1;
		next_state = WAIT1;
	 end
	 WAIT1:begin
		coefficient_num = 2'd0; 
		load_coeff = 0;
		if (!modwait) next_state = LOAD2;
	 end
	 LOAD2:begin
		coefficient_num = 2'd1; 
		load_coeff = 1;
		next_state = WAIT2;
	 end
	 WAIT2:begin
		load_coeff = 0;
		coefficient_num = 2'd1; 
		if (!modwait) next_state = LOAD3;
	 end
	 LOAD3:begin
		coefficient_num = 2'd2; 
		load_coeff = 1;
		next_state = WAIT3;
	 end	 
	 WAIT3:begin
		load_coeff = 0;
		coefficient_num = 2'd2; 
		if (!modwait) next_state = LOAD4;
	 end
	 LOAD4:begin
		coefficient_num = 2'd3; 
		load_coeff = 1;
		next_state = IDLE;
	 end	
	 endcase
end

always_ff @ (posedge clk, negedge n_reset)
begin
	if(1'b0 == n_reset) begin
		state <= IDLE;
	end else begin
		state <= next_state;
	end
end
endmodule	
