module CPU(
	input clk,
	input reset,
	output [18:0] alu_result
);
	
    // Instruction and its address
	wire [18:0] instruction;
	wire [4:0] instructionAddress;
	wire [4:0] newInstructionAddress;
	
	// Control signals
	wire [1:0] ALU_Code;
	wire reg_write;
	wire I_Flag, J_Flag;

	// Next PC
	wire [4:0] pc_plus_1 = newInstructionAddress + 1;
	assign instructionAddress = J_Flag ? 0 : pc_plus_1;
	
	// Address of registers to read and write to
	wire [2:0] add1 = instruction[14:12]; //rs
	wire [2:0] add2 = instruction[11:9]; //rt
	wire [2:0] add3; // Destination (rt/rd)
	assign add3 = I_Flag ? add2 : instruction[8:6];

	// Registers read from register memory
	wire [18:0] reg_data1;
	wire [18:0] reg_data2;
	
	// ALU inputs
	reg [18:0] alu_input1;
	reg [18:0] alu_input2;

	// Program counter
	PC pc (
		.clk(clk),
		.reset(reset),
		.address(instructionAddress),
		.newAddress(newInstructionAddress)
	);

	// Instruction memory
	Instructions rom (
		.address(newInstructionAddress),
		.instruction(instruction)
	);

	// Control unit
	ControlUnit cu (
		.instruction(instruction),
		.ALU_Code(ALU_Code),
		.reg_write(reg_write),
		.I_Flag(I_Flag),
		.J_Flag(J_Flag)
	);

	// Registers
	Registers regs (
		.clk(clk),
		.reset(reset),
		.w_enable(reg_write),
		.add1(add1),
		.add2(add2),
		.add3(add3),
		.data_in(alu_result),  // ALU result is written to registers
		.reg1(reg_data1),
		.reg2(reg_data2)
	);

	// ALU: Execute ALU operations based on inputs and ALU_Code
	ALU alu (
		.reg_one(alu_input1),
		.reg_two(alu_input2),
		.opcode(ALU_Code),
		.out(alu_result)
	);
	
	wire [1:0] flags;
	wire [8:0]  immediate_9bit = instruction[8:0]; // Original 9-bit value
	wire [18:0] immediate_19bit; // Sign-extended to 19 bits
	
	assign flags = {I_Flag, J_Flag};
	// Sign-extend by replicating the MSB (bit 8) 10 times (19-9=10)
	assign immediate_19bit = {{10{immediate_9bit[8]}}, immediate_9bit};
	
	// Always block to update ALU inputs based on flags (synchronized to the clock)
	always @(*) begin
		case(flags)
			2'b00: begin // R-type instruction
				alu_input1 <= reg_data1;
				alu_input2 <= reg_data2;
			end
			
			2'b10: begin // I-type instruction
				alu_input1 <= reg_data1;
				alu_input2 <= immediate_19bit;
			end
			
			default: ; // Currently nothing
		endcase
	end
	
endmodule
