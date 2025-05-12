/* 
 * Random Access Memory (RAM) with
 * 1 read port and 1 write port
 */
module RAM (clk, reset, address_write, data_write, 
write_enable, address_read, data_read);
  
	/* 
	D_WIDTH is the word size 
	A_WIDTH is the address size
	A_MAX is the number of words
	*/
	parameter D_WIDTH = 19;
	parameter A_WIDTH = 5;
	parameter A_MAX = 32; // 2^A_WIDTH

	// Write port
	input clk;
	input reset;
	input [A_WIDTH-1:0] address_write;
	input [D_WIDTH-1:0] data_write;
	input write_enable;

	// Read port
	input [A_WIDTH-1:0] address_read;
	output reg [D_WIDTH-1:0] data_read;
  
   // Memory as multi-dimensional array
	reg [D_WIDTH-1:0] memory [A_MAX-1:0];
	
	integer i;
   // Write data to memory
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			for (i = 0; i < A_MAX; i = i + 1) begin
				memory[i] <= 19'b0;
			end
			i <= 0;
		end

		else if (write_enable) begin
			memory[address_write] <= data_write;
		end
	end

	// Read data from memory
	always @(*) begin
		data_read <= memory[address_read];
	end

endmodule