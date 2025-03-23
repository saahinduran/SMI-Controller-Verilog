`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.11.2024 09:33:34
// Design Name: 
// Module Name: smi
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


module smi
#( 
    parameter FPGA_CLK_FREQ = 27_000_000,   // Default 27 MHz FPGA clock
    parameter SMI_CLK = 2_500_000           // Default 100 kHz SMI frequency
)
(
	input wire clk,
	input wire rst_n,
	input wire write_n,
	input wire [4 : 0] phy_addr,
	input wire [4 : 0] reg_addr,
	input wire [15: 0] write_data,
	input wire start,

	output reg mdio_clk,
	inout reg mdio_data,
	
	output reg busy,
	output reg [15 : 0]data_read
);


/* calculate the frequency */
localparam COUNT_LIMIT = FPGA_CLK_FREQ / SMI_CLK /2; 


/* one hot encoding */



localparam PREAMBLE_BIT_CNT = 32;
localparam PHY_REG_ADDR_BIT_CNT = 5;
localparam DATA_LEN = 16;
	
reg smi_clk;
reg smi_clk_half;
reg smi_clk_half_n;
reg [7:0] clk_counter = 8'b0;
reg [4:0] bit_counter = 8'b0;
reg mdio_data_reg;

assign mdio_data = mdio_data_reg;


reg [PHY_REG_ADDR_BIT_CNT -1 : 0] saved_phy_addr;
reg [PHY_REG_ADDR_BIT_CNT -1 : 0] saved_reg_addr;
reg [DATA_LEN -1 : 0] saved_write_data;	


typedef enum logic [7:0]{
        IDLE,   
        PREAMBLE,   
        SOF, 
        OPCODE,   
				PHY_ADDR,
				REG_ADDR,
				TURNAROUND,
				DATA
    } state_t;
		
state_t state;




reg data_ready_tick_reg;
wire data_ready_tick;

assign data_ready_tick = ((bit_counter == DATA_LEN -1) && (state == DATA) && write_n == 1) ? 1 : 0;
assign mdio_clk = smi_clk;
/* Clock and clock enable signal generation unit */
always @(posedge clk or negedge rst_n) begin
		smi_clk_half <= 0;
		smi_clk_half_n <= 0;
		if (!rst_n) begin
				// Reset the counter and enable signal
				clk_counter <= 0;
				smi_clk <= 0;
		end 
		else if (clk_counter == COUNT_LIMIT - 1) begin
				// Reset the counter and toggle the enable signal
				clk_counter <= 0;
				smi_clk <= ~smi_clk;

		end
		else if (clk_counter == COUNT_LIMIT - 1 -1) begin
				smi_clk_half <= ~smi_clk;
				smi_clk_half_n <= smi_clk;
				clk_counter <= clk_counter + 1;
		end
		else begin
				// Increment the counter
				clk_counter <= clk_counter + 1;
		end
end


always @(posedge clk or negedge rst_n) begin

if (!rst_n) begin
		state <= IDLE;
		bit_counter <= 0;
		busy <= 0;
end 
		
else begin
if(smi_clk_half_n) begin

	data_ready_tick_reg <= data_ready_tick;
	
	case (state)
	
		IDLE       : begin
			if(start)  begin
				state <= PREAMBLE;
				mdio_data_reg <= 1'b1; // TODO: this might be 1'bz as well.
				bit_counter <= 0;
				busy <= 1;
				saved_phy_addr <= phy_addr;
				saved_reg_addr  <= reg_addr;
				saved_write_data <= write_data;
			end
			else begin
				busy <= 0;
				mdio_data_reg <= 1'bz;
			end
			
 		
		end
		
		PREAMBLE   : begin
		 
		 if(bit_counter == PREAMBLE_BIT_CNT -1) begin
			bit_counter <= 0;
			mdio_data_reg <= 0; /* sof bits */
			state <= SOF;
		 end
		 
		 else begin
			bit_counter <= bit_counter + 1;
			
		 end
		
		end
		
		SOF        : begin
			state <= OPCODE;
			mdio_data_reg <= 1; /* sof bits */
			
		
		end
		
		OPCODE     : begin
			if(bit_counter == 0) begin
				mdio_data_reg <= write_n; /* if write process, write 1 to mdio */
				bit_counter <= bit_counter + 1;
			end
			
			else if(bit_counter == 1) begin
				mdio_data_reg <= ~write_n; /* if write process, write 1 to mdio */
				state <= PHY_ADDR;
				bit_counter <= 0;
			end
			
		end
		
		PHY_ADDR   : begin
			if(bit_counter == PHY_REG_ADDR_BIT_CNT -1) begin
				state <= REG_ADDR;
				mdio_data_reg <= saved_phy_addr[PHY_REG_ADDR_BIT_CNT -1];
				bit_counter <= 0;
			end
			else begin
				bit_counter <= bit_counter + 1;
				mdio_data_reg <= saved_phy_addr[PHY_REG_ADDR_BIT_CNT -1];
				saved_phy_addr <= {saved_phy_addr[PHY_REG_ADDR_BIT_CNT-2:0], 1'b0}; // Shift left, fill LSB with 0
			end
			
		
		end
		
		REG_ADDR   : begin
			if(bit_counter == PHY_REG_ADDR_BIT_CNT -1) begin
				state <= TURNAROUND;
				mdio_data_reg <= saved_reg_addr[PHY_REG_ADDR_BIT_CNT -1];
				bit_counter <= 0;
			end
			else begin
				bit_counter <= bit_counter + 1;
				mdio_data_reg <= saved_reg_addr[PHY_REG_ADDR_BIT_CNT -1];
				saved_reg_addr <= {saved_reg_addr[PHY_REG_ADDR_BIT_CNT-2:0], 1'b0}; // Shift left, fill LSB with 0
			end
		
		end
		
		TURNAROUND : begin
			if(bit_counter == 0) begin
				if(write_n == 1) begin
					mdio_data_reg <= 1'bz;	
					bit_counter <= bit_counter + 1;
				end
				
				else begin
					mdio_data_reg <= 1'b1;
					bit_counter <= bit_counter + 1;
				end
			end
			else if (bit_counter == 1) begin
				if(write_n == 1) begin
					mdio_data_reg <= 1'bz;	
					bit_counter <= bit_counter + 1;
					bit_counter <= 0;
					state <= DATA;
				end
				
				else begin
					mdio_data_reg <= 1'b0;
					bit_counter <= bit_counter + 1;
					bit_counter <= 0;
					state <= DATA;
				end
			
			end
		end
		
		DATA       : begin
			if(write_n == 0) begin /* write operation */
				if(bit_counter == DATA_LEN -1) begin 
					state <= IDLE;
					busy <= 0;
					mdio_data_reg <= saved_write_data[DATA_LEN -1];
					bit_counter <= 0;
				end
				else begin
					mdio_data_reg <= saved_write_data[DATA_LEN -1];
					saved_write_data <= {saved_write_data[DATA_LEN-2:0], 1'b0}; // Shift left, fill LSB with 0
					bit_counter <= bit_counter + 1;
				end 
			
			end
			
			else begin /* read operation */
				if(bit_counter == DATA_LEN -1) begin 
					state <= IDLE;
					busy <= 0;
					bit_counter <= 0;
					data_read <= {data_read[DATA_LEN-2:0], mdio_data_reg};
				end
				else begin
					bit_counter <= bit_counter + 1;
					data_read <= {data_read[DATA_LEN-2:0], mdio_data_reg};
				end 
			
			end
			
			
			
		end
		
		default    : begin
		
		end
		
endcase

end


end

end



/*
always @(posedge clk) begin
		
if(smi_clk_half) begin

	data_read <= {data_read[DATA_LEN-2:0], mdio_data_reg};


end

end
*/
endmodule

