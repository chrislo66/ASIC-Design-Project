// $Id: $
// File name:   apb_slave.sv
// Created:     3/30/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: APB-slave Interface
module apb_slave
(
	input wire clk,
	input wire n_rst,
	input wire [7:0] rx_data,
	input wire data_ready,
	input wire overrun_error,
	input wire framing_error,
	input wire psel,
	input wire penable,
	input wire [2:0] paddr,
	input wire pwrite,
	input wire [7:0] pwdata,
	output reg [7:0] prdata,
	output reg data_read,
	output reg [3:0] data_size,
	output reg [13:0] bit_period,
	output reg pslverr
);
typedef enum logic [2:0] {IDLE, WRITE, READ, ERROR} state_type;
state_type state, next_state;

reg [7:0] next_prdata;
reg next_pslverr;
reg [6:0][7:0] address_mapping;
reg [6:0][7:0] next_address_mapping;

always_comb
begin
	next_state = state;
	case(state)
	 IDLE:begin
		if((psel) && (((pwrite) && !((paddr == 3'd2)|(paddr == 3'd3)|(paddr == 3'd4))) | ((!pwrite) && !((paddr == 3'd0)|(paddr == 3'd1)|(paddr == 3'd2)|(paddr == 3'd3)|(paddr == 3'd4)|(paddr == 3'd6))))) begin
			next_state = ERROR;
		end else if(psel && pwrite) begin
			next_state = WRITE;
		end else if (psel && (!pwrite))begin
			next_state = READ;
		end else begin 
			next_state = IDLE;
		end
	 end
	 WRITE: begin
		next_state = IDLE;
	 end 
	 READ: begin
		next_state = IDLE;
	 end
	 ERROR: begin
		next_state = IDLE;
	 end
	endcase
end


always_comb
begin
	next_address_mapping = address_mapping;
	next_prdata = '0;
	next_pslverr = '0;
	data_read = 0;
	data_size = address_mapping[4];
	bit_period = {address_mapping[3], address_mapping[2]};
	
	next_address_mapping[0] = data_ready;
	next_address_mapping[5] = '0;
	next_address_mapping[6] = rx_data;
		
	if(framing_error) next_address_mapping[1] = 1;
	else if (overrun_error) next_address_mapping[1] = 2;
	else  next_address_mapping[1] = 0;

	if (state == WRITE) next_address_mapping[paddr] = pwdata;
	if (next_state == READ) begin
		next_prdata = address_mapping[paddr];
		if (paddr == 3'd6) data_read = 1;
	end else if (next_state == ERROR) begin
		next_pslverr = 1;
	end
end

always_ff @ (posedge clk, negedge n_rst) 
begin
	if (1'b0 == n_rst) begin
		state <= IDLE;
		address_mapping <= '0;
		pslverr <= '0;
		prdata <= '0;
	end else begin
		state <= next_state;
		address_mapping <= next_address_mapping;
		pslverr <= next_pslverr;
		prdata <= next_prdata;
	end
end 
		
endmodule




  
		
