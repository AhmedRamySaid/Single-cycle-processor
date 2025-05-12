module ControlUnit(
	input [18:0] instruction,
	output reg [2:0] ALU_Code,
	output reg reg_write,
	output reg mem_write,
	output reg reg_mem_flag,
	output reg branch_flag,
	output reg lea_flag,
	output reg mvz_flag,
	output reg pcm_flag,
	output reg I_Flag,
	output reg J_Flag
);
	// Extract relevant fields from the instruction
	wire [1:0] type = instruction[18:17]; // Optimisation to make a smaller mux
	wire [1:0] code = instruction[16:15];  
	wire [2:0] funct  = instruction[2:0];

	// Control signals
	always @(*) begin
	// Predict the default for the flags is zero
	mem_write = 1'b0;
	lea_flag = 1'b0;
	mvz_flag = 1'b0;
	pcm_flag = 1'b0;
	branch_flag = 1'b0;
	reg_mem_flag = 1'b0;
		case(type)
			2'b00: begin //R-type instruction
				reg_write = 1'b1;
				I_Flag = 1'b0;
				J_Flag = 1'b0;
				case(funct) 
					3'b000: ALU_Code = 3'b000; // Add
					3'b010: ALU_Code = 3'b001; // Sub
					3'b100: ALU_Code = 3'b010; // And
					3'b101: ALU_Code = 3'b011; // Or
					3'b111: ALU_Code = 3'b100; // Slt
					3'b001: begin // Mvz
							ALU_Code = 3'b000;
							mvz_flag = 1'b1;
						end
					default: ALU_Code = 3'b000;
				endcase
			end

			2'b01: begin // I-type instruction that writes to a register
				reg_write = 1'b1;
				I_Flag = 1'b1;
				J_Flag = 1'b0;
				case(code)
					2'b00: ALU_Code = 3'b000; // Addi
					2'b01: ALU_Code = 3'b010; // Andi
					2'b10: begin // Lw
							ALU_Code = 3'b000;
							reg_mem_flag = 1'b1;
						end
					2'b11: begin // Lea
						ALU_Code = 3'b000;
						lea_flag = 1'b1;
					end
				endcase
			end
			
			2'b10: begin // I-type instruction that does not write to a register
				reg_write = 1'b0;
				I_Flag = 1'b1;
				J_Flag = 1'b0;
				case(code)
					2'b00: begin // Sw
							ALU_Code = 3'b000;
							mem_write = 1'b1;
						end
					2'b01: begin // Pcm
							ALU_Code = 3'b000;
							mem_write = 1'b1;
							pcm_flag = 1'b1;
						end
					2'b10: begin // Beq
							ALU_Code = 3'b001;
							branch_flag = 1'b1;
						end
					default: ;
				endcase
			end

			2'b11: begin // Jump
				reg_write = 1'b0;
				I_Flag = 1'b0;
				J_Flag = 1'b1;
			end
 
		endcase
    end

endmodule
