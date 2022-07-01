// $Id: $
// File name:   rcu.sv
// Created:     4/23/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Receiver Control Unit Block
module rcu
(
	input wire clk,
	input wire n_rst,
	input wire d_edge,
	input wire eop,
	input wire shift_enable,
	input wire [7:0] rcv_data,
	input wire byte_received,
	output reg rcving,
	output reg w_enable,
	output reg r_error,
	output reg [3:0] pid
);

typedef enum logic [3:0] {IDLE, GET_BYTE, CHECK_BYTE, WAIT_NBYTE, PID, MATCH_RCVING, STORE, CHECK_EOP, PRE_DONE, DONE, NO_MATCH, DELAY, EIDLE} state_type;
state_type state, next_state;

always_ff @ (posedge clk, negedge n_rst)
begin
	if(1'b0 == n_rst)
		state <= IDLE;
	else
		state <= next_state;
end

reg [3:0] pid1;

always_comb
begin
	next_state = state;
	w_enable = 0;
	r_error = 0;
	rcving = 0;
	pid = 1;

	case(state)
	  IDLE:begin
		if(d_edge) next_state = GET_BYTE;
	  end
	  GET_BYTE:begin
		rcving = 1;
		if(byte_received) next_state = CHECK_BYTE;
	  end
	  CHECK_BYTE: begin
		rcving = 1;
		pid = 1;
		if(rcv_data == 8'b10000000) next_state = WAIT_NBYTE;
		else next_state = NO_MATCH;
	  end
	  WAIT_NBYTE: begin
		rcving = 1;
		pid = 1;
		if(byte_received) next_state = PID;
		//if(!byte_received) next_state = MATCH_RCVING;		

	  PID: begin
		rcving = 1;
		pid = rcv_data[4:7]; 
		if(!byte_received) next_state = MATCH_RCVING;
	  end
	  MATCH_RCVING:begin
		rcving = 1;
		if(byte_received) next_state = STORE;
		else if (shift_enable && eop) next_state = DELAY;
	  end
	  STORE:begin
		rcving = 1;
		w_enable = 1;	
		next_state = CHECK_EOP;
	  end
	  CHECK_EOP:begin
		rcving = 1;
		if(shift_enable && !eop) next_state = MATCH_RCVING;
		else if (shift_enable && eop) next_state = PRE_DONE;
	  end
	  PRE_DONE:begin
		rcving = 1;
		if (shift_enable && eop) next_state = DONE;
		else if(shift_enable && !eop) next_state = EIDLE;
	  end
	  DONE:begin
		rcving = 0;
		if (d_edge) next_state = IDLE;
	  end
	  NO_MATCH:begin 
		rcving = 1;
		r_error = 1;
		if(shift_enable && eop) next_state = DELAY;
	  end
	  DELAY:begin
		rcving = 1;
		r_error = 1;
		if(d_edge) next_state = EIDLE;
	  end
	  EIDLE:begin
		r_error = 1;
		if(d_edge) next_state = GET_BYTE;
	  end
	endcase
end
endmodule

		
		
