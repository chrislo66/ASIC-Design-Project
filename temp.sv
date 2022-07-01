// $Id: $
// File name:   temp.sv
// Created:     3/30/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: temp
rcv_block.sv apb_slave.sv timer.sv start_bit_det.sv sr_9bit.sv rcu.sv stop_bit_chk.sv rx_data_buff.sv flex_counter.sv flex_stp_sr.sv stp_sr_4_msb.sv

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
reg [3:0] ndata_size;
reg [13:0]nbit_period;

always_comb
begin
	next_state = state;
	ndata_size = data_size;
	nbit_period = bit_period;
	prdata = '0;
	data_read = '0;
	pslverr = '0;
	case (state)
	 IDLE:begin
		if(psel && !penable) begin
		  if(pwrite) begin
			next_state = WRITE;
		  end else begin
			next_state = READ;
		  end
		end else begin 
			next_state = IDLE;
		end
	 end
	 WRITE:begin
		if(psel && penable && pwrite) begin
		  if(paddr == 3'd2) begin
			nbit_period = {bit_period[13:8], pwdata};
			next_state = IDLE;
		  end else if(paddr == 3'd3) begin
			nbit_period = {pwdata, bit_period[7:0]};
			next_state = IDLE;
		  end else if(paddr == 3'd4) begin
			ndata_size = pwdata[3:0];
			next_state = IDLE; 
		  end else begin
			next_state = ERROR;
		  end
		end
	 end
	 READ:begin
		if(psel && penable && !pwrite) begin
		  if(paddr == 3'd0) begin
			prdata = {7'b0, data_ready};
			next_state = IDLE;
		  end else if(paddr == 3'd1) begin
			prdata = {6'b0, overrun_error, framing_error};
			next_state = IDLE;
		  end else if(paddr == 3'd2) begin
			prdata = bit_period[7:0];
			next_state = IDLE;
		  end else if(paddr == 3'd3) begin
			prdata = {2'b0, bit_period[13:8]};
			next_state = IDLE;
		  end else if(paddr == 3'd4) begin
			prdata = {4'b0, ndata_size};
			next_state = IDLE;
		  end else if(paddr == 3'd6) begin
			if(data_size == 4'd5)			
				prdata = {3'b0,rx_data[7:3]};
			else if(data_size == 4'd7)
				prdata = {1'b0,rx_data[7:1]};
			else if(data_size == 4'd8)
				prdata = rx_data;
			data_read = 1;
			next_state = IDLE;
		  end
		end
	 end
	 ERROR:begin
		pslverr = 1'b1;
		next_state = IDLE;
	 end
	endcase
end

always_ff @ (posedge clk, negedge n_rst) 
begin
	if (1'b0 == n_rst) begin
		state <= IDLE;
		data_size <= '0;
		bit_period <= '0;
	end else begin
		state <= next_state;
		data_size <= ndata_size;
		bit_period <= nbit_period;
	end
end 
		
endmodule

// $Id: $
// File name:   ahb_lite_slave.sv
// Created:     4/4/2020
// Author:      Wang-Ning Lo
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: AHB-Lite Slave Interface.
module ahb_lite_slave
(
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
typedef enum logic [2:0] {IDLE, READ, WRITE, ERROR} state_type;
state_type state, next_state;
reg [15:0] [7:0] next_address_mapping;
reg [15:0] [7:0] address_mapping;
reg next_data_ready;
reg [3:0] next_haddr;
reg next_hsize;

always_comb
begin
	next_state = state;
	case(state)
	 IDLE:begin
		if((hsel && (!hwrite) && (haddr == 4'd15)) | (hsel && (hwrite) && ((haddr == 4'd0) | (haddr == 4'd1) | (haddr == 4'd2) | (haddr == 4'd3) | (haddr == 4'd15)))) 
			next_state = ERROR;
		else if(hsel && (htrans != 0) && (!hwrite))
			next_state = READ;
		else if(hsel && (htrans != 0) && (hwrite))
			next_state = WRITE;
		else
			next_state = IDLE;
	 end
	 READ:begin
		if((hsel && (!hwrite) && (haddr == 4'd15)) | (hsel && (hwrite) && ((haddr == 4'd0) | (haddr == 4'd1) | (haddr == 4'd2) | (haddr == 4'd3) | (haddr == 4'd15))))
			next_state = ERROR;
		else if(hsel && (htrans != 0) && (!hwrite))
			next_state = READ;
		else if(hsel && (htrans != 0) && (hwrite))
			next_state = WRITE;
		else
			next_state = IDLE;
	 end
	 WRITE:begin
		if((hsel && (!hwrite) && (haddr == 4'd15)) | (hsel && (hwrite) && ((haddr == 4'd0) | (haddr == 4'd1) | (haddr == 4'd2) | (haddr == 4'd3) | (haddr == 4'd15))))
			next_state = ERROR;
		else if(hsel && (htrans != 0) && (!hwrite))
			next_state = READ;
		else if(hsel && (htrans != 0) && (hwrite))
			next_state = WRITE;
		else
			next_state = IDLE;
	 end
	 ERROR:begin		
		//hresp = 1;
		if((hsel && (!hwrite) && (haddr == 4'd15)) | (hsel && (hwrite) && ((haddr == 4'd0) | (haddr == 4'd1) | (haddr == 4'd2) | (haddr == 4'd3) | (haddr == 4'd15)))) begin
			next_state = ERROR;
		end else if(hsel && (htrans != 0) && (!hwrite)) begin
			next_state = READ;
		end else if(hsel && (htrans != 0) && (hwrite)) begin
			next_state = WRITE;
		end else begin
			next_state = IDLE;
		end
	 end
	endcase
end

always_comb
begin
	hresp = 0;
	if((hsel && (!hwrite) && (haddr == 4'd15)) | (hsel && (hwrite) && ((haddr == 4'd0) | (haddr == 4'd1) | (haddr == 4'd2) | (haddr == 4'd3) | (haddr == 4'd15))))  
		hresp = 1;
end
	

always_comb
begin
	next_address_mapping = address_mapping;
	next_data_ready = data_ready;
	sample_data = {address_mapping[5], address_mapping[4]};
	new_coefficient_set = address_mapping[14];
	next_address_mapping[15] = 0;
	hrdata = '0;
	
	
	if (modwait | new_coefficient_set) begin
		next_address_mapping[1] = 0;
		next_address_mapping[0] = 1;
	end else if (err) begin
		next_address_mapping[1] = 1;
		next_address_mapping[0] = 0;
	end else begin
		next_address_mapping[1] = 0;
		next_address_mapping[0] = 0;
	end
	
	next_address_mapping[3] = fir_out[15:8];
	next_address_mapping[2] = fir_out[7:0];

	if (coefficient_num == 0)
		fir_coefficient = {address_mapping[7],address_mapping[6]};
	else if (coefficient_num == 1)
		fir_coefficient = {address_mapping[9],address_mapping[8]};
	else if (coefficient_num == 2)
		fir_coefficient = {address_mapping[11],address_mapping[10]};
	else if (coefficient_num == 3)
		fir_coefficient = {address_mapping[13],address_mapping[12]};
		next_address_mapping[14] = 0;
	
	if (modwait) next_data_ready = 0;
	
	if (state == WRITE) begin
		if ((next_haddr == 4'd4) | (next_haddr == 4'd5)) begin
				next_data_ready = 1;
		end
		if (next_hsize == 1) begin
			if((next_haddr == 4'd4) | (next_haddr == 4'd6) | (next_haddr == 4'd8) | (next_haddr == 4'd10) | (next_haddr == 4'd12)) begin
				next_address_mapping[next_haddr + 4'b1] = hwdata[15:8];
				next_address_mapping[next_haddr] = hwdata[7:0];			
			end else if ((next_haddr == 4'd5) | (next_haddr == 4'd7) | (next_haddr == 4'd9) | (next_haddr == 4'd11) | (next_haddr == 4'd13)) begin
				next_address_mapping[next_haddr - 4'b1] = hwdata[7:0];
				next_address_mapping[next_haddr] = hwdata[15:8];
			end else if ((next_haddr == 4'd14) | (next_haddr == 4'd15)) begin
				next_address_mapping[14] = hwdata[7:0];
			end
		end else if (next_hsize == 0) begin
			if((next_haddr == 4'd4) | (next_haddr == 4'd6) | (next_haddr == 4'd8) | (next_haddr == 4'd10) | (next_haddr == 4'd12) | (next_haddr == 4'd14)) begin 					
				next_address_mapping[next_haddr] = hwdata[7:0];			
			end else if ((next_haddr == 4'd5) | (next_haddr == 4'd7) | (next_haddr == 4'd9) | (next_haddr == 4'd11) | (next_haddr == 4'd13) | (next_haddr == 4'd15)) begin
				next_address_mapping[next_haddr] = hwdata[15:8];
			end
		end
	end
	
	if (state == READ) begin	
		if (next_hsize == 1)begin
			if((next_haddr == 4'd0) | (next_haddr == 4'd2) | (next_haddr == 4'd4) | (next_haddr == 4'd6) | (next_haddr == 4'd8) | (next_haddr == 4'd10) | (next_haddr == 4'd12)) begin
				hrdata = {address_mapping[next_haddr+4'd1], address_mapping[next_haddr]};
			end else if((next_haddr == 4'd1) | (next_haddr == 4'd3) | (next_haddr == 4'd5) | (next_haddr == 4'd7) | (next_haddr == 4'd9) | (next_haddr == 4'd11) | (next_haddr == 4'd13)) begin
				hrdata = {address_mapping[next_haddr], address_mapping[next_haddr-4'd1]};
			end else if((next_haddr == 4'd14) | (next_haddr == 4'd15)) begin
				hrdata = {8'b0, address_mapping[14]};
			end
		end else if (next_hsize == 0) begin
			if((next_haddr == 4'd0) | (next_haddr == 4'd2) | (next_haddr == 4'd4) | (next_haddr == 4'd6) | (next_haddr == 4'd8) | (next_haddr == 4'd10) | (next_haddr == 4'd12) | (next_haddr == 4'd14)) begin
				hrdata = {8'b0, address_mapping[next_haddr]};
			end else if((next_haddr == 4'd1) | (next_haddr == 4'd3) | (next_haddr == 4'd5) | (next_haddr == 4'd7) | (next_haddr == 4'd9) | (next_haddr == 4'd11) | (next_haddr == 4'd13) | (next_haddr == 4'd15)) begin
				hrdata = {address_mapping[next_haddr], 8'b0};
			end
		end
	end
end

always_ff @ (posedge clk, negedge n_rst)
begin
	if (1'b0 == n_rst) begin
		state <= IDLE;
		data_ready <= '0;
		address_mapping <='0;
		next_hsize <= '0;
		next_haddr <= '0;
	end else begin
		state <= next_state;
		data_ready <= next_data_ready;
		address_mapping <= next_address_mapping;
		next_hsize <= hsize;
		next_haddr <= haddr;
	end
end
	
endmodule
			
ahb_lite_slave.sv coefficient_loader.sv controller.sv counter.sv fir_filter.sv flex_counter.sv magnitude.sv sync_low.sv

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




  
			
	
	
	
		
	

	
	
	
	
	

	
		
		
	

	 


	


  
		
