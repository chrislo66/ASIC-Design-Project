// $Id: $
// File name:   controller.sv
// Created:     3/4/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Controller
module controller
(
	input wire clk,
	input wire n_rst,
	input wire dr,
	input wire lc,
	input wire overflow,
	output reg cnt_up,
	output reg clear,
	output reg modwait,
	output reg [2:0] op,
	output reg [3:0] src1,
	output reg [3:0] src2,
	output reg [3:0] dest,
	output reg err
);

typedef enum logic [4:0] {IDLE, STORE, ZERO, SORT1, SORT2, SORT3, SORT4, MUL1, ADD1, MUL2, SUB1, MUL3, ADD2, MUL4, SUB2, EIDLE, LOAD1, WAIT1, LOAD2, WAIT2, LOAD3, WAIT3, LOAD4} state_type;
state_type state, next_state;
reg next_modwait;

always_comb 
begin
	cnt_up = 0;
	err = 0;
	clear = 0;
	src1 = 4'd0;
	src2 = 4'd0;
	dest = 4'd0;
	op = '0;
	next_state = state;
	next_modwait = modwait;
	case(state)
	 IDLE:begin
		if (dr) next_state = STORE;
		if (lc) next_state = LOAD1;
		if (!dr && !lc) next_state = IDLE;
		next_modwait = 0;
	 end
	 STORE:begin
		dest = 4'd5;
		op = 3'b010;
		err = 0;
		next_modwait = 1;
		if (!dr) 
			next_state = EIDLE;
		else 
			next_state = ZERO;
		
	 end
	 ZERO:begin
		src1 = 4'd0;
		src2 = 4'd0;
		dest = 4'd0;
		op = 3'b101;
		cnt_up = 1;
		next_modwait = 1;
		next_state = SORT1;
	 end
	 SORT1:begin
		src1 = 4'd2;
		dest = 4'd1;
		op = 3'b001;
		cnt_up = 0;
		next_modwait = 1;
		next_state = SORT2;
	 end
	 SORT2:begin
		src1 = 4'd3;
		dest = 4'd2;
		op = 3'b001;
		next_modwait = 1;
		next_state = SORT3;
	 end
	 SORT3:begin
		src1 = 4'd4;
		dest = 4'd3;
		op = 3'b001;
		next_modwait = 1;
		next_state = SORT4;
	 end
	 SORT4:begin
		src1 = 4'd5;
		dest = 4'd4;
		op = 3'b001;
		next_modwait = 1;
		next_state = MUL1;
	 end
	 MUL1:begin
		src1 = 4'd1;
		src2 = 4'd6;
		dest = 4'd10;
		op = 3'b110;
		next_modwait = 1;
		if(overflow) 
			next_state = EIDLE;
		else
			next_state = ADD1;
	 end
	 ADD1:begin
		src1 = 4'd0;
		src2 = 4'd10;
		dest = 4'd0;
		op = 3'b100;
		next_modwait = 1;
		if(overflow)
			next_state = EIDLE;
		else		
			next_state = MUL2;
	 end
	 MUL2:begin
		src1 = 4'd2;
		src2 = 4'd7;
		dest = 4'd10;
		op = 3'b110;
		next_modwait = 1;
		if(overflow) 
			next_state = EIDLE;
		else
			next_state = SUB1;
	 end
	 SUB1:begin
		src1 = 4'd0;
		src2 = 4'd10;
		dest = 4'd0;
		op = 3'b101;
		next_modwait = 1;
		if(overflow)
			next_state = EIDLE;
		else		
			next_state = MUL3;
	 end
	 MUL3:begin
		src1 = 4'd3;
		src2 = 4'd8;
		dest = 4'd10;
		op = 3'b110;
		next_modwait = 1;
		if(overflow) 
			next_state = EIDLE;
		else
			next_state = ADD2;
	 end
	 ADD2:begin
		src1 = 4'd0;
		src2 = 4'd10;
		dest = 4'd0;
		op = 3'b100;
		next_modwait = 1;
		if(overflow)
			next_state = EIDLE;
		else		
			next_state = MUL4;
	 end
	 MUL4:begin
		src1 = 4'd4;
		src2 = 4'd9;
		dest = 4'd10;
		op = 3'b110;
		next_modwait = 1;
		if(overflow) 
			next_state = EIDLE;
		else
			next_state = SUB2;
	 end
	 SUB2:begin
		src1 = 4'd0;
		src2 = 4'd10;
		dest = 4'd0;
		op = 3'b101;
		next_modwait = 1;
		if(overflow)
			next_state = EIDLE;
		else
			next_state = IDLE;
	 end
	 EIDLE:begin
		err = 1;
		next_modwait = 0;
		if(dr)	next_state = STORE;
		if(lc) next_state = LOAD1;
	 end 
	 LOAD1:begin
		dest = 4'd6;
		op = 3'b011;
		clear = 1;
		next_modwait = 1;
		next_state = WAIT1;
	 end
	 WAIT1:begin
		clear = 1;
		next_modwait = 0;
		if(lc) next_state = LOAD2;
	 end
	 LOAD2:begin
		dest = 4'd7;
		op = 3'b011;
		clear = 1;
		next_modwait = 1;
		next_state = WAIT2;
	 end
	 WAIT2:begin
		clear = 1;
		next_modwait = 0;
		if(lc) next_state = LOAD3;
	 end
	 LOAD3:begin
		dest = 4'd8;
		op = 3'b011;
		clear = 1;
		next_modwait = 1;
		next_state = WAIT3;
	 end	 
	 WAIT3:begin
		clear = 1;
		next_modwait = 0;
		if(lc) next_state = LOAD4;
	 end
	 LOAD4:begin
		dest = 4'd9;
		op = 3'b011;
		clear = 1;
		next_modwait = 1;
		next_state = IDLE;
	 end	
	 endcase
end

always_ff @ (posedge clk, negedge n_rst)
begin
	if(1'b0 == n_rst) begin
		state <= IDLE;
		modwait <= 0;
	end else begin
		state <= next_state;
		modwait <= next_modwait;
	end
end
endmodule

