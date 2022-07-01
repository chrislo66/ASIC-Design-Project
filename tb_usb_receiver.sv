// $Id: $
// File name:   tb_usb_receiver.sv
// Created:     4/24/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: TestBench for USB Receiver

`timescale 1ns / 100ps
module tb_usb_receiver();

	localparam CLK_PERIOD=10;
	reg tb_clk;

	
	//CLOCK DIVIDER
	always
	begin
		tb_clk=1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk=1'b1;
		#(CLK_PERIOD/2.0);
	end

	//Test Bench Signals
	reg tb_n_rst,tb_d_plus,tb_d_minus,tb_r_enable,tb_empty,tb_full,tb_rcving,tb_r_error;
	reg [7:0] tb_r_data;
	//reg [7:0] test_data;

	//DUT PORT MAP

	usb_receiver DUT(.clk(tb_clk), .n_rst(tb_n_rst), .d_plus(tb_d_plus), .d_minus(tb_d_minus), .r_enable(tb_r_enable), .empty(tb_empty), .full(tb_full), .rcving(tb_rcving), .r_error(tb_r_error), .r_data(tb_r_data));

	//Declare variable testcase counter
	//Reset Receiver
	task reset_dut;
	begin
		// Activate the design's reset (does not need to be synchronize with clock)
		tb_n_rst = 1'b0;
		
		// Wait for a couple clock cycles
		@(posedge tb_clk);
		@(posedge tb_clk);
		
		// Release the reset
		@(negedge tb_clk);
		tb_n_rst = 1;
		
		// Wait for a while before activating the design
		@(posedge tb_clk);
		@(posedge tb_clk);
	end
	endtask

	//Task send SYNC BYTE

	task send_bit(input logic bit_val);
		integer i;
	begin
		@(negedge tb_clk)
		if(bit_val == 1'b0)
		begin
			tb_d_plus=~tb_d_plus;
			tb_d_minus=~tb_d_minus;
		end
		else if(bit_val == 1'b1)
		begin
			tb_d_plus=tb_d_plus;
			tb_d_minus=tb_d_minus;
		end
		#(CLK_PERIOD*8);
	end
	endtask


	task send_byte(input logic[7:0] byte_val);
		integer i;
	begin
		@(negedge tb_clk);
		for (i=0; i<8; i=i+1)
		begin
			if(byte_val[i] == 1'b0)
			begin
				tb_d_plus=~tb_d_plus;
				tb_d_minus=~tb_d_minus;
			end
			else if(byte_val[i] == 1'b1)
			begin
				tb_d_plus=tb_d_plus;
				tb_d_minus=tb_d_minus;
			end
			#(CLK_PERIOD*8);
		end

	end
	endtask



	task send_eop;
	begin
		tb_d_plus='0;
		tb_d_minus='0;
		#(CLK_PERIOD*16);
	end
	endtask
		
	task send_early_eop(input logic[7:0] byte_val);
		integer i;
	begin
		@(negedge tb_clk);
		for(i=0; i<5; i=i+1)
		begin
			if(byte_val[i] == 1'b0)
			begin
				tb_d_plus=~tb_d_plus;
				tb_d_minus=~tb_d_minus;
			end
			else if(byte_val[i] == 1'b1)
			begin
				tb_d_plus=~tb_d_plus;
				tb_d_minus=~tb_d_minus;
			end
			#(CLK_PERIOD*8);
		end
		send_eop;
	end
	endtask

	integer testcase;

	initial
	begin
		tb_d_plus='1;
		tb_d_minus='0;

		tb_n_rst='0;
		#(CLK_PERIOD*8);
		tb_n_rst='1;
		#(CLK_PERIOD*8);
		testcase=1;
		@(negedge tb_clk);
		send_byte(8'b10000000);
		//#(CLK_PERIOD);
		@(negedge tb_clk);
		send_byte(8'b00000001);
		#(CLK_PERIOD);

		send_eop;
		//#(CLK_PERIOD);
		@(negedge tb_clk);
		tb_d_plus=1'b1;
		tb_r_enable=1'b1;
		@(negedge tb_clk);
		//#(CLK_PERIOD);
		assert(tb_r_data == 8'b00000001)
			$info("Testcase %d passed",testcase);
		else
			$error("Testcase %d failed",testcase);

		assert(tb_empty == 1'b0)
			$info("Testcase %d passed",testcase);
		else
			$error("Testcase %d failed",testcase);

		assert(tb_empty == 1'b1)
			$info("Testcase %d passed",testcase);
		else
			$error("Testcase %d failed",testcase);
		@(negedge tb_clk);
		//#(CLK_PERIOD);
		tb_r_enable=1'b0;

		testcase=2;
		tb_n_rst='0;
		#(CLK_PERIOD);
		tb_n_rst='1;
		@(negedge tb_clk);
		send_byte(8'b10000000);
		#(CLK_PERIOD);
		send_byte(8'b00000000);
		#(CLK_PERIOD);
		send_byte(8'b00000001);
		#(CLK_PERIOD);
		send_byte(8'b00000010);
		#(CLK_PERIOD);
		send_byte(8'b00000011);
		#(CLK_PERIOD);
		send_byte(8'b00000100);
		#(CLK_PERIOD);
		send_byte(8'b00000101);
		#(CLK_PERIOD);
		send_byte(8'b00000110);
		#(CLK_PERIOD);
		send_byte(8'b00000111);
		#(CLK_PERIOD);
		send_eop;
		tb_r_enable=1'b1;
		assert(tb_r_data==8'b00000001)
			$display("Testcase %d passed",testcase);
		else
			$error("Testcase %d failed", testcase);
		#(CLK_PERIOD);
		tb_r_enable=1'b0;
		

		/*tb_r_enable=1'b1;
		send_byte(8'b00000010);
		#(CLK_PERIOD);
		tb_r_enable=1'b0;
		assert(tb_r_data == 8'b00000010)
			$info("Testcase %d passed",testcase);
		else
			$error("Testcase %d failed",testcase);
		assert(tb_empty == 1'b0)
			$info("Testcase %d passed",testcase);
		else
			$error("Testcase %d failed",testcase);
		//send_byte(8'b10000011);
		//#(CLK_PERIOD);
		send_eop;
		@(negedge tb_clk);
		tb_d_plus='1;
		tb_n_rst=1'b0;
		@(negedge tb_clk);
		tb_n_rst=1'b1;
		@(negedge tb_clk);
		send_byte(8'b10000000);
		#(CLK_PERIOD);
		send_early_eop(8'b00000010);
		#(CLK_PERIOD);
		tb_d_plus=1'b1;
		#(CLK_PERIOD);
		tb_d_plus=1'b0;
		#(CLK_PERIOD);
		tb_d_plus=1'b1;*/
	end

endmodule
		
