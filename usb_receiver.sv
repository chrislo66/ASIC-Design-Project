// $Id: $
// File name:   usb_receiver.sv
// Created:     4/24/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: USB Receiver 
module usb_receiver
(
	input wire clk,
	input wire n_rst,
	input wire d_plus,
	input wire d_minus,
	input wire r_enable,
	output reg [7:0] r_data,
	output reg empty,
	output reg full,
	output reg rcving,
	output reg r_error
	output logic [3:0] pid;
);

reg d_minus_sync;
reg d_plus_sync;
reg shift_enable;
reg eop;
reg d_orig;
reg d_edge;
reg byte_received;
reg [7:0] rcv_data;
reg w_enable;

always_comb
begin
	
	
	


sync_low
 LOW(
	.clk(clk),
	.n_rst(n_rst),
	.async_in(d_minus),
	.sync_out(d_minus_sync)
);

sync_high
 HIGH(
	.clk(clk),
	.n_rst(n_rst),
	.async_in(d_plus),
	.sync_out(d_plus_sync)
);

decode 
 DC(
	.clk(clk),
	.n_rst(n_rst),
	.d_plus(d_plus_sync),
	.shift_enable(shift_enable),
	.eop(eop),
	.d_orig(d_orig)
);

edge_detect
 EDGE(
	.clk(clk),
	.n_rst(n_rst),
	.d_plus(d_plus_sync),
	.d_edge(d_edge)
);

eop_detect
 EOP(
	.d_plus(d_plus_sync),
	.d_minus(d_minus_sync),
	.eop(eop)
);

timer
 TIME(
	.clk(clk),
	.n_rst(n_rst),
	.d_edge(d_edge),
	.rcving(rcving),
	.shift_enable(shift_enable),
	.byte_received(byte_received)
);

shift_register
 SR(
	.clk(clk),
	.n_rst(n_rst),
	.shift_enable(shift_enable),
	.d_orig(d_orig),
	.rcv_data(rcv_data)
);

rx_fifo
 RX(
	.clk(clk),
	.n_rst(n_rst),
	.r_enable(r_enable),
	.w_enable(w_enable),
	.w_data(rcv_data),
	.r_data(r_data),
	.empty(empty),
	.full(full)
);

rcu
 RCU(
	.clk(clk),
	.n_rst(n_rst),
	.d_edge(d_edge),
	.eop(eop),
	.shift_enable(shift_enable),
	.rcv_data(rcv_data),
	.byte_received(byte_received),
	.rcving(rcving),
	.w_enable(w_enable),
	.r_error(r_error)
);
endmodule


