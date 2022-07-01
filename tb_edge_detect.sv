// $Id: $
// File name:   tb_edge_detect.sv
// Created:     4/22/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Teshbench for decode.sv
`timescale 1ns / 10ps


module tb_edge_detect();

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
	reg tb_d_plus;
	reg tb_shift_enable;
	reg tb_eop;
	reg tb_d_orig;
	
	// Declare test bench signals
	integer tb_test_num;
	string tb_test_case;
	integer tb_stream_test_num;
	string tb_stream_check_tag;
	
	// Clock generation block
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end

	// Task for standard DUT reset procedure
  	task reset_dut;
  	begin
    	// Activate the reset
    	tb_n_rst = 1'b0;

    	// Maintain the reset for more than one cycle
    	@(posedge tb_clk);
    	@(posedge tb_clk);

    	// Wait until safely away from rising edge of the clock before releasing
    	@(negedge tb_clk);
    	tb_n_rst = 1'b1;

    	// Leave out of reset for a couple cycles before allowing other stimulus
    	// Wait for negative clock edges, 
    	// since inputs to DUT should normally be applied away from rising clock edges
    	@(negedge tb_clk);
    	@(negedge tb_clk);
  	end
  	endtask
	
	// DUT Port map
	edge_detect DUT
	(
		.clk(tb_clk), 
		.n_rst(tb_n_rst), 
		.d_plus(tb_d_plus),	
		.d_edge(tb_d_edge)
	);


	// Test bench main process
	initial
	begin
		tb_test_num = 0;
		// Test Case 1: Power-on Reset of the DUT
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "Power-on Reset";
		reset_dut();
		tb_n_rst = 1'b0;
		tb_d_plus = 1'b1;
		@(posedge tb_clk);
		#(CLK_PERIOD);
		// Check that internal state was correctly reset
		if(1'b0 == tb_d_edge)
			$info("Testcase %d: PASSED", tb_test_num);
		else
			$error("Testcase %d: FAILED", tb_test_num);


		// Test Case 2: d_plus 1->0 Falling edge 
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "d_plus 1->0 Falling edge";
		tb_n_rst = 1'b1;
		tb_d_plus = 1'b0;
		@(posedge tb_clk);
		#(CLK_PERIOD);
		// Check output
		if(1'b1 == tb_d_edge)
			$info("Testcase %d: PASSED", tb_test_num);
		else
			$error("Testcase %d: FAILED", tb_test_num);


		// Test Case 3: d_plus 0->1 Rising Edge
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "d_plus 0->1 Rising Edge";
		tb_n_rst = 1'b1;
		tb_d_plus = 1'b1;
		@(posedge tb_clk);
		#(CLK_PERIOD);
		// Check output
		if(1'b1 == tb_d_edge)
			$info("Testcase %d: PASSED", tb_test_num);
		else
			$error("Testcase %d: FAILED", tb_test_num);

		// Test Case 4: No Change
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "No Change";
		tb_n_rst = 1'b1;
		tb_d_plus = 1'b1;
		@(posedge tb_clk);
		#(CLK_PERIOD);
		// Check output
		if(1'b0 == tb_d_edge)
			$info("Testcase %d: PASSED", tb_test_num);
		else
			$error("Testcase %d: FAILED", tb_test_num);

		
		// Test Case 5:  Falling edge with reset
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "Falling edge with reset";
		tb_n_rst = 1'b0;
		tb_d_plus = 1'b0;
		@(posedge tb_clk);
		#(CLK_PERIOD);
		// Check output
		if(1'b0 == tb_d_edge)
			$info("Testcase %d: PASSED", tb_test_num);
		else
			$error("Testcase %d: FAILED", tb_test_num);


	end

endmodule
	
