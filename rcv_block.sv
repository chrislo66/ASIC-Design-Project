// $Id: $
// File name:   rcv_block.sv
// Created:     2/25/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Receiver Block
module rcv_block
(
	input wire clk,
	input wire n_rst,
	input wire serial_in,
	input wire data_read,
	input wire [13:0] bit_period,
	input wire [3:0] data_size,
	output reg [7:0] rx_data,
	output reg data_ready,
	output reg overrun_error,
	output reg framing_error
);

reg new_packet;
reg shift;
reg [7:0] packet_data;
reg stop;
reg packet_done;
reg clear;
reg sbc_enable;
reg timer_en;
reg load;

start_bit_det
 START(
   .clk(clk),
   .n_rst(n_rst),
   .serial_in(serial_in),
   .start_bit_detected(),
   .new_package_detected(new_packet)
 );

sr_9bit
 SHIFT(
   .clk(clk),
   .n_rst(n_rst),
   .shift_strobe(shift),
   .serial_in(serial_in),
   .packet_data(packet_data),
   .stop_bit(stop)
 );

timer
 TIMER(
   .clk(clk),
   .n_rst(n_rst),
   .enable_timer(timer_en),
   .bit_period(bit_period),
   .data_size(data_size),
   .shift_enable(shift),
   .packet_done(packet_done)
 );

rcu
 RECEIVER(
   .clk(clk),
   .n_rst(n_rst),
   .new_packet_detected(new_packet),
   .packet_done(packet_done),
   .framing_error(framing_error),
   .sbc_clear(clear),
   .sbc_enable(sbc_enable),
   .load_buffer(load),
   .enable_timer(timer_en)
 );

stop_bit_chk
 STOP(
   .clk(clk),
   .n_rst(n_rst),
   .sbc_clear(clear),
   .sbc_enable(sbc_enable),
   .stop_bit(stop),
   .framing_error(framing_error)
 );

rx_data_buff
 BUFF(
   .clk(clk),
   .n_rst(n_rst),
   .load_buffer(load),
   .packet_data(packet_data),
   .data_read(data_read),
   .rx_data(rx_data),
   .data_ready(data_ready),
   .overrun_error(overrun_error)
 );

endmodule


	
