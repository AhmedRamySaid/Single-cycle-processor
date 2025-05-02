module Registers(
	input clk,               // Clock input
	input reset, // Active high reset
	input w_enable,          // Write enable
	input [2:0] add1,        // Read address 1
	input [2:0] add2,        // Read address 2
	input [2:0] add3,        // Write address
	input [18:0] data_in,    // Data input
	output reg [18:0] reg1,  // Output register 1
	output reg [18:0] reg2   // Output register 2
);

	// 8 registers of 19 bits each
	reg [18:0] registers [0:7];
	integer i;
	
	// Read operation
	always @(*) begin
		// If one of the addresses are 0 return 0
		reg1 <= (add1 == 0) ? 19'b0 : registers[add1];
		reg2 <= (add2 == 0) ? 19'b0 : registers[add2];
	end

	// Write operation
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			for (i = 0; i < 8; i = i + 1) begin
				registers[i] <= 19'b0;
			end
			i <= 0;
		end

		else begin
			if (w_enable && (add3 != 0)) begin  // Prevent writing to register 0
				registers[add3] <= data_in;
			end
		end
	end

endmodule
