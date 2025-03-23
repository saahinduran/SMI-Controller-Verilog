`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.11.2024 17:43:08
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top (
    input wire clk,
    input wire rst_n,
    input wire sw,
		input wire [4 : 0] reg_addr,
		input wire d0,
		input wire d1,
		input wire dv,
    output wire phy_reset,
    output reg led,
    output wire eth_int,
    output reg clk_out,
    output reg mdio_clk,
    inout reg mdio_data,
		output reg [15 : 0]data_read		
);

typedef enum logic [2:0]{
        IDLE,   
        READ,   
        WRITE
} state_t;

typedef enum logic [2:0]{
        INITIAL,  
				SFD,
        CALC,   
        DONE
} crc_state_t;

 (* KEEP = "TRUE" *) crc_state_t crc_state;

reg clk100Mhz;
reg locked;
reg start_counting;
reg [1 :0 ] eth_pkt_ctr;


reg [15 : 0] leds;
reg [4  : 0] reg_addr_reg;
(* KEEP = "TRUE" *) reg [7  : 0] valid_data_reg;
(* KEEP = "TRUE" *) reg [7  : 0] data_reg;
(* KEEP = "TRUE" *) reg data_valid;
		
(* KEEP = "TRUE" *) state_t state;

(* KEEP = "TRUE" *) state_t state_packets;

    reg [4 : 0] phy_addr;
(* KEEP = "TRUE" *)  reg start;
    
    
(* KEEP = "TRUE" *)  reg busy;

		
 (* KEEP = "TRUE" *)   reg [15 : 0]write_data; 
 
 (* KEEP = "TRUE" *) reg [31:0] crcIn;
 (* KEEP = "TRUE" *) reg [7:0] data;
 (* KEEP = "TRUE" *) reg [31:0] crcOut;
 (* KEEP = "TRUE" *) reg [20:0] crc_counter;
   
		reg write_n_in;	
    smi 
    #(
        .FPGA_CLK_FREQ(200_000_000),
        .SMI_CLK(2_500_000)
     ) my_smi (
     .clk(clk100Mhz),
     .rst_n(rst_n),
     .write_n(write_n_in),
     .phy_addr(phy_addr),
     .reg_addr(reg_addr_reg),
     .write_data(write_data),
     .start(start),
    
     .mdio_clk(mdio_clk),
     .mdio_data(mdio_data),
    
     .busy(busy),
     .data_read(leds)
);

 clk_wiz_0 myClockGenerator
 (
 // Clock in ports
  .clk_in1(clk),
  // Clock out ports
  .clk_out1(clk100Mhz),
  .clk_out2(clk_out),
  // Status and control signals
   .locked(locked)
 );

crc myCrc(.crcIn(crcIn), .data(data), .crcOut(crcOut) );


assign reg_addr_reg = (state == IDLE) ? 0 : reg_addr;

always @(posedge clk100Mhz or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE; 

    end 
		else begin
			case (state)
	
			IDLE       : begin
				phy_addr <= 1;
				write_n_in <= 0; // read operation
				start <= 1;
				write_data <= 16'h1000;
				if(busy == 1) begin
					state <= WRITE;
					start <= 0;
				end

			end
			
			READ   : begin
				
				if(busy == 0) begin
					start <= 1;
					write_n_in <= 1;
					data_read <= leds;
				
				end

			end
			
			WRITE  : begin
				if(busy == 0) begin
					start <= 1;
					write_n_in <= 1;
					state <= READ;
				
				end
			end

			default    : begin
			end
			endcase
		end


end

assign phy_reset = sw;
assign eth_int = 1;


always @(posedge clk_out) begin
	if(dv ) begin
		data_reg = { d1, d0, data_reg[7 : 2] };
	end
	
	data_valid <= dv;
end


always @(posedge clk_out or negedge rst_n) begin
	
	if (!rst_n) begin
			crc_state <= INITIAL;
			crcIn <= 32'hffffffff;
			crc_counter <= 0;
  end 

		else begin
			case (crc_state)
			
			INITIAL    : begin
			
				if(crc_counter == 23) begin
					crc_state <= CALC;
					crc_counter <= 0;
				end
				
				if(valid_data_reg == 8'h55) begin
					crc_counter++;
				end
				else crc_counter <= 0;
			
			
			end
	
			SFD       : begin
			
				if(crc_counter == 3 ) begin
					if(valid_data_reg == 8'hd5) crc_state <= CALC;
					else crc_state <= INITIAL;
				end
				
				if(valid_data_reg == 8'h55) begin
					crc_counter++;
				end
			
			end
			
			
			CALC     : begin
			
				if(crc_counter == 3 ) begin
					data = valid_data_reg;
					crcIn = crcOut;
				end
				
				else begin
					crc_counter++;
				end
				
				if(!dv) crc_state <= DONE;
			
			end
			
			DONE     : begin
				//crcOut <= ~crcOut;
				
			
			end
			
			
			
			
		
		endcase

		
end

end







always @(posedge clk_out or negedge rst_n) begin
	
	if (!rst_n) begin
			state_packets <= IDLE;
			start_counting <= 0;
			eth_pkt_ctr <= 0;
  end 

		else begin
			case (state_packets)
	
			IDLE       : begin
			
				if(data_reg == 8'h55 && dv) begin
					state_packets <= READ;
					eth_pkt_ctr <= 0;
				end
			
			end
			
			
			READ       : begin
				if(eth_pkt_ctr == 3 && dv) begin
					eth_pkt_ctr <= 0;
					valid_data_reg <= data_reg;
				end
				else if(eth_pkt_ctr != 3 && dv) begin
					eth_pkt_ctr++;
				end
				else begin
					state_packets <= IDLE;
					valid_data_reg <= data_reg;
				end
			
			end
		endcase
		
		if(valid_data_reg == 8'h55) begin
			led = 0;
		end
		else begin
			led = 1;
		end
		
		
end

end




endmodule

