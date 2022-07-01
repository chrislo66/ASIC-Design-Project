// $Id: $
// File name:   apb_uart_rx.sv
// Created:     3/30/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: APB-UART Receiver Peripheral
module apb_uart_rx 
(
	input wire clk,
	input wire n_rst,
	input wire serial_in,
	input wire psel,
	input wire [2:0] paddr,
	input wire penable,
	input wire pwrite,
	input wire [7:0] pwdata,
	output reg [7:0] prdata,
	output reg pslverr
);


reg read;
reg [13:0] period;
reg [3:0] size;
reg [7:0] data;
reg ready;
reg overrun;
reg framing;



rcv_block
  UART(
	.clk(clk),
	.n_rst(n_rst),
	.serial_in(serial_in),
	.data_read(read),
	.bit_period(period),
	.data_size(size),
	.rx_data(data),
	.data_ready(ready),
	.overrun_error(overrun),
	.framing_error(framing)
  );

apb_slave
  SLAVE(
	.clk(clk),
	.n_rst(n_rst),
	.rx_data(data),
	.data_ready(ready),
	.overrun_error(overrun),
	.framing_error(framing),
	.psel(psel),
	.penable(penable),
	.paddr(paddr),
	.pwrite(pwrite),
	.pwdata(pwdata),
	.prdata(prdata),
	.data_read(read),
	.data_size(size),
	.bit_period(period),
	.pslverr(pslverr)
  );

endmodule	
