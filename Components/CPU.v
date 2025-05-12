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
	wire [2:0] ALU_Code;
	wire reg_write;
	wire mem_write;
	wire I_Flag, J_Flag, branch_flag,
		reg_mem_flag, zero_flag, lea_flag, mvz_flag, pcm_flag;

	// I/R type flags and immediate value and jump value
	wire [1:0] flags;
	wire signed [8:0]  immediate_9bit = instruction[8:0]; // Original 9-bit value
	wire signed [18:0] immediate_19bit; // Sign-extended to 19 bits
	wire [11:0]  jump_address = instruction[11:0];
	
	// Address of registers to read and write to
	wire [2:0] add1 = instruction[14:12]; //rs
	wire [2:0] add2 = instruction[11:9]; //rt
	wire [2:0] add3; // Destination (rt/rd)
	assign add3 = I_Flag ? add2 : instruction[8:6];

	// Addresses of memory to read and write to
	wire [4:0] read_add;
	wire [4:0] write_add = alu_result[4:0];
	assign read_add = pcm_flag ? add2 : alu_result[4:0];

	// Data read from register memory
	wire [18:0] reg_data1; //rs
	wire [18:0] reg_data2; //rt
	
	// ALU inputs
	reg [18:0] alu_input1;
	reg [18:0] alu_input2;

	// Data read from memory and written to memory
	wire [18:0] mem_data;
	wire [18:0] mem_data_in;
	/* 
		If pcm_flag then data written to memory is 
			the next instruction address
		Else write rt 
	*/
	assign mem_data_in = pcm_flag ? 
		instructionAddress : reg_data2;

	// Data written to registers
	wire [18:0] reg_write_data;
	/*
		If mvz_flag and zero_flag then write back rs
		else if reg_mem_flag then write back mem_data
		else write back alu_result
	*/
	assign reg_write_data = 
		(mvz_flag && zero_flag) ? reg_data1 :
		reg_mem_flag ? mem_data : alu_result;

	// Next PC
	wire [4:0] pc_plus_1 = newInstructionAddress + 1;
	/*
		if pcm_flag then IA = mem_data
		else if J_Flag then IA = j_add
		else if b_flag && z_flag then IA = i
		else IA = IA + 1
	*/
	assign instructionAddress = 
		pcm_flag ? mem_data :
		J_Flag ? jump_address :
		(branch_flag && zero_flag) ? immediate_9bit :
		pc_plus_1;

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
		.mem_write(mem_write),
		.reg_mem_flag(reg_mem_flag),
		.branch_flag(branch_flag),
		.lea_flag(lea_flag),
		.mvz_flag(mvz_flag),
		.pcm_flag(pcm_flag),
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
		.data_in(reg_write_data),
		.reg1(reg_data1),
		.reg2(reg_data2)
	);

	// RAM
	RAM ram (
		.clk(clk),
		.reset(reset),
		.address_write(write_add),
		.data_write(mem_data_in),
		.write_enable(mem_write),
		.address_read(read_add),
		.data_read(mem_data)
	);

	// ALU
	ALU alu (
		.reg_one(alu_input1),
		.reg_two(alu_input2),
		.opcode(ALU_Code),
		.zero_flag(zero_flag),
		.out(alu_result)
	);
	
	assign flags = {I_Flag, J_Flag};
	// Sign-extend by replicating the MSB (bit 8) 10 times (19-9=10)
	assign immediate_19bit = {{10{immediate_9bit[8]}}, immediate_9bit};
	
	// Always block to update ALU inputs based on flags (synchronized to the clock)
	always @(*) begin
		case(flags)
			2'b00: begin // R-type instruction
				alu_input1 <= mvz_flag ? 0 : reg_data1;
				alu_input2 <= reg_data2;
			end
			
			2'b10: begin // I-type instruction
				alu_input1 <= reg_data1;
				alu_input2 <= lea_flag ? 
					(reg_data2 * immediate_9bit) : immediate_19bit;
			end
			
			default: ; // Currently nothing
		endcase
	end
	
endmodule
