// $Id: $
// File name:   ahb_lite_slave.sv
// Created:     4/4/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: AHB-Lite Slave Interface.
module ahb_lite_slave(
	input wire clk,
	input wire n_rst,
	output reg [15:0] sample_data,
	output reg data_ready,
	output reg new_coefficient_set,
	input wire [1:0] coefficient_num,
	output reg [15:0] fir_coefficient,
	input wire modwait,
	input wire [15:0] fir_out,
	input wire err,
	input wire hsel,
	input wire [3:0] haddr,
	input wire hsize,
	input wire [1:0] htrans,
	input wire hwrite,
	input wire [15:0] hwdata,
	output reg [15:0] hrdata,
	output reg hresp
);

typedef enum logic [1:0]  {IDLE, READ, WRITE, ERROR} state_type;
state_type state, next_state;

reg [15:0] [7:0] address_mapping;
reg [15:0] [7:0] next_address_mapping;
reg next_data_ready;
reg next_hsize;
reg [3:0] next_haddr;


always_comb 
begin
	next_state = state;
	case(state)
	IDLE: begin
		
		if ((hsel) && ((hwrite) && ((haddr == 4'd0) | (haddr == 4'd1) | (haddr == 4'd2) | (haddr == 4'd3) | (haddr == 4'd15))) | ((!hwrite) && (haddr == 4'd15))) 
			next_state = ERROR;
		else if ((hsel) && (htrans != 0) && (!hwrite)) 
			next_state = READ;
		else if ((hsel) && (htrans != 0) && (hwrite)) 
			next_state = WRITE;
		else 
			next_state = IDLE;
	end
	READ: begin
		if ((hsel) && ((hwrite) && ((haddr == 4'd0) | (haddr == 4'd1) | (haddr == 4'd2) | (haddr == 4'd3) | (haddr == 4'd15))) | ((!hwrite) && (haddr == 4'd15))) 
			next_state = ERROR;
		else if ((hsel) && (htrans != 0) && (!hwrite)) 
			next_state = READ;
		else if ((hsel) && (htrans != 0) && (hwrite)) 
			next_state = WRITE;
		else 
			next_state = IDLE;
	end
	WRITE: begin
		if ((hsel) && ((hwrite) && ((haddr == 4'd0) | (haddr == 4'd1) | (haddr == 4'd2) | (haddr == 4'd3) | (haddr == 4'd15))) | ((!hwrite) && (haddr == 4'd15))) 
			next_state = ERROR;
		else if ((hsel) && (htrans != 0) && (!hwrite)) 
			next_state = READ;
		else if ((hsel) && (htrans != 0) && (hwrite)) 
			next_state = WRITE;
		else 
			next_state = IDLE;
	end
	ERROR: begin
		if ((hsel) && ((hwrite) && ((haddr == 4'd0) | (haddr == 4'd1) | (haddr == 4'd2) | (haddr == 4'd3) | (haddr == 4'd15))) | ((!hwrite) && (haddr == 4'd15))) 
			next_state = ERROR;
		else if ((hsel) && (htrans != 0) && (!hwrite)) 
			next_state = READ;
		else if ((hsel) && (htrans != 0) && (hwrite)) 
			next_state = WRITE;
		else 
			next_state = IDLE;
	end
	endcase
end

always_comb 
begin
	next_address_mapping = address_mapping;
	next_address_mapping[15] = '0;
	new_coefficient_set = address_mapping[14];
	sample_data = {address_mapping[5], address_mapping[4]};
	next_data_ready = data_ready;
	hrdata = '0;

	if (coefficient_num == 0) begin
		fir_coefficient = {address_mapping[7], address_mapping[6]};
	end else if (coefficient_num == 1) begin
		fir_coefficient = {address_mapping[9], address_mapping[8]};
	end else if (coefficient_num == 2) begin
		fir_coefficient = {address_mapping[11], address_mapping[10]};
	end else if (coefficient_num == 3) begin
		fir_coefficient = {address_mapping[13], address_mapping[12]};
		next_address_mapping[14] = 0;
	end

	if (new_coefficient_set == 1 | modwait == 1) begin
		next_address_mapping[1] = 0;
		next_address_mapping[0] = 1;
	end else if (err == 1) begin
		next_address_mapping[1] = 1;
		next_address_mapping[0] = 0;
	end else begin
		next_address_mapping[1] = 0;
		next_address_mapping[0] = 0;
	end

	
	next_address_mapping[3] = fir_out[15:8];
	next_address_mapping[2] = fir_out[7:0];

	
	if(state == READ) begin	
		if(next_hsize == 1) begin
			if((next_haddr % 2 == 0) && (next_haddr != 4'd14))
				hrdata = {address_mapping[next_haddr + 1], address_mapping[next_haddr]};
			else if((next_haddr % 2 == 1) && (next_haddr != 4'd15))
				hrdata = {address_mapping[next_haddr], address_mapping[next_haddr - 1]};
			else if((next_haddr == 4'd14) | (next_haddr == 4'd15)) 
				hrdata = {8'b0, address_mapping[14]};
		end else if(next_hsize == 0) begin
			if(next_haddr % 2 == 0)
				hrdata = {8'b0, address_mapping[next_haddr]};
			else if(next_haddr % 2 == 1)
				hrdata = {address_mapping[next_haddr], 8'b0};
		end		
	end

	if(modwait) next_data_ready = 0;
	if (state == WRITE) begin
		if((next_haddr == 4'd4) | (next_haddr == 4'd5)) next_data_ready = 1;
		if(next_hsize == 1) begin
			if((next_haddr % 2 == 0) && (next_haddr != 4'd14)) begin							
				next_address_mapping[next_haddr + 1] = hwdata[15:8];
				next_address_mapping[next_haddr] = hwdata[7:0];
			end else if((next_haddr % 2 == 0) && (next_haddr != 4'd14)) begin
				next_address_mapping[next_haddr] = hwdata[15:8];
				next_address_mapping[next_haddr - 1] = hwdata[7:0];
			end else if((next_haddr == 4'd14) | (next_haddr == 4'd15)) begin						
				next_address_mapping[14] = hwdata[7:0];
			end	
		end else if(next_hsize == 0) begin
			if(next_haddr % 2 == 0) begin
				next_address_mapping[next_haddr] = hwdata[7:0];
			end else if(next_haddr % 2 == 1) begin
				next_address_mapping[next_haddr] = hwdata[15:8];
			end
		end
		
	end	
		
end
always_comb 
begin
	hresp = 0;
	if ((hsel) && ((hwrite) && ((haddr == 4'd0) | (haddr == 4'd1) | (haddr == 4'd2) | (haddr == 4'd3) | (haddr == 4'd15))) | ((!hwrite) && (haddr == 4'd15)))
		hresp = 1;
end

always_ff @ (negedge n_rst, posedge clk) 
begin
	if(1'b0 == n_rst) begin
		state <= IDLE;
		address_mapping <= '0;
		data_ready <= 0;
		next_hsize <= '0;
		next_haddr <= '0;
	end else begin
		state <= next_state;
		address_mapping <= next_address_mapping;
		data_ready <= next_data_ready;
		next_haddr <= haddr;
		next_hsize <= hsize;
	end
end

endmodule
