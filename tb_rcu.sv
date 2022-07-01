// $Id: $
// File name:   tb_rcu.sv
// Created:     4/24/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: TestBench RCU
// 

`timescale 1ns / 10ps


module tb_rcu();

	// Define local parameters used by the test bench
	localparam	CLK_PERIOD		= 2;
	localparam  FF_SETUP_TIME = 0.190;
  	localparam  FF_HOLD_TIME  = 0.100;
  	localparam  CHECK_DELAY   = (CLK_PERIOD - FF_SETUP_TIME); // Check right before the setup time starts
  
  	localparam  INACTIVE_VALUE     = 1'b0;
  	localparam  RESET_OUTPUT_VALUE = INACTIVE_VALUE;
	
	
	// Declare DUT portmap signals
	reg tb_clk;
	reg tb_n_rst;
	reg tb_d_edge;
	reg tb_eop;
	reg tb_shift_enable;
	reg [7:0] tb_rcv_data;
	reg tb_byte_received;
	reg tb_rcving;
	reg tb_w_enable;
	reg tb_r_error;
	
	// Declare test bench signals
	integer tb_test_num;
	string tb_test_case;
	integer tb_stream_test_num;
	string tb_stream_check_tag;
	
	// DUT Port map
	rcu DUT
	(
		.clk(tb_clk),
		.n_rst(tb_n_rst),
		.d_edge(tb_d_edge),
		.eop(tb_eop),
		.shift_enable(tb_shift_enable),
		.rcv_data(tb_rcv_data),
		.byte_received(tb_byte_received),
		.rcving(tb_rcving),
		.w_enable(tb_w_enable),
		.r_error(tb_r_error)
	);


endmodule
	

