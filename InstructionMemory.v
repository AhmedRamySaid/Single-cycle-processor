module Instructions(
	input [4:0] address, // 5-bit instruction address
	output reg [18:0] instruction // Instruction outputted
);
	
	// 31 registers of 19 bits each containing an instruction
	reg [18:0] instructionMemory [0:31];

	initial begin
		instructionMemory[0] = 19'b0; //Empty instruction used for initialization
		instructionMemory[1] = 19'b0100_000_001_111_111_111;
		instructionMemory[2] = 19'b0100_000_010_000_000_111;
		instructionMemory[3] = 19'b0000_001_010_011_000_010;
	end
	
	// Return instruction
	always @(*) begin
		instruction <= instructionMemory[address];
	end

endmodule
