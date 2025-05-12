module Instructions(
	input [4:0] address, // 5-bit instruction address
	output reg [18:0] instruction // Instruction outputted
);
	
	// 31 registers of 19 bits each containing an instruction
	reg [18:0] instructionMemory [0:31];


	initial begin
		$readmemb("output.mem", instructionMemory); 
	end
	
	// Return instruction
	always @(*) begin
		instruction <= instructionMemory[address];
	end

endmodule
