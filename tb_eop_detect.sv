// $Id: $
// File name:   tb_eop_detect.sv
// Created:     4/24/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: TestBench for EOP Detect
`timescale 1ns / 10ps


module tb_eop_detect();

	// Define local parameters used by the test bench
	localparam	CLK_PERIOD		= 2;
	localparam  FF_SETUP_TIME = 0.190;
  	localparam  FF_HOLD_TIME  = 0.100;
  	localparam  CHECK_DELAY   = (CLK_PERIOD - FF_SETUP_TIME); // Check right before the setup time starts
  
  	localparam  INACTIVE_VALUE     = 1'b0;
  	localparam  RESET_OUTPUT_VALUE = INACTIVE_VALUE;
	
	
	// Declare DUT portmap signals
	reg tb_d_plus;
	reg tb_d_minus;
	reg tb_eop;
	
	// Declare test bench signals
	integer tb_test_num;
	string tb_test_case;
	integer tb_stream_test_num;
	string tb_stream_check_tag;
	
	// DUT Port map
	eop_detect DUT
	(
		.d_plus(tb_d_plus),	
		.d_minus(tb_d_minus),
		.eop(tb_eop)
	);


	// Test bench main process
	initial
	begin
		tb_test_num = 0;
		// Test Case 1: !D+ && !D-
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "!D+ && !D-";
		tb_d_minus = 1'b0;
		tb_d_plus = 1'b0;
		#(CLK_PERIOD);
		// Check output
		if(1'b1 == tb_eop)
			$info("Testcase %d: PASSED", tb_test_num);
		else
			$error("Testcase %d: FAILED", tb_test_num);


		// Test Case 2: D+ && D-
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "D+ && D-";
		tb_d_minus = 1'b1;
		tb_d_plus = 1'b1;
		#(CLK_PERIOD);
		// Check output
		if(1'b0 == tb_eop)
			$info("Testcase %d: PASSED", tb_test_num);
		else
			$error("Testcase %d: FAILED", tb_test_num);

		// Test Case 3: D+ && !D-
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "D+ && !D-";
		tb_d_minus = 1'b0;
		tb_d_plus = 1'b1;
		#(CLK_PERIOD);
		// Check output
		if(1'b0 == tb_eop)
			$info("Testcase %d: PASSED", tb_test_num);
		else
			$error("Testcase %d: FAILED", tb_test_num);

		
		// Test Case 4: !D+ && D-
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "!D+ && D-";
		tb_d_minus = 1'b1;
		tb_d_plus = 1'b0;
		#(CLK_PERIOD);
		// Check output
		if(1'b0 == tb_eop)
			$info("Testcase %d: PASSED", tb_test_num);
		else
			$error("Testcase %d: FAILED", tb_test_num);


	end

endmodule
	
