module ControlUnit(
	input [18:0] instruction,
	output reg [1:0] ALU_Code,
	output reg reg_write,
	output reg I_Flag,
	output reg J_Flag
);
    // Extract relevant fields from the instruction
	wire [1:0] type = instruction[18:17]; // Optimisation to make a smaller mux
	wire [1:0] code = instruction[16:15];  
	wire [2:0] funct  = instruction[2:0];

    // Control signals
    always @(*) begin
		case(type)
			2'b00: begin //R-type instruction
				reg_write = 1'b1;
				I_Flag = 1'b0;
				J_Flag = 1'b0;
				case(funct) 
					3'b000: ALU_Code = 2'b00; // Add
					3'b010: ALU_Code = 2'b01; // Sub
					3'b100: ALU_Code = 2'b10; // And
					3'b101: ALU_Code = 2'b11; // Or
					3'b111: ; // Slt
					3'b001: ; // Mvz
					default: ALU_Code = 2'b00;
				endcase
			end

			2'b01: begin // I-type instruction that writes to a register
				reg_write = 1'b1;
				I_Flag = 1'b1;
				J_Flag = 1'b0;
				case(code)
					2'b00: ALU_Code = 2'b00; // Addi
					2'b01: ALU_Code = 2'b10; // Andi
					2'b10: ; // Lw
					2'b11: ; // Lea
				endcase
			end
			
			2'b10: begin // I-type instruction that does not write to a register
				reg_write = 1'b0;
				I_Flag = 1'b1;
				J_Flag = 1'b0;
				case(code)
					2'b00: ; // Sw
					2'b01: ; // Pcm
					2'b10: ; // Beq
					default: ;
				endcase
			end

			2'b11: begin // Jump
				reg_write = 1'b1;
				I_Flag = 1'b0;
				J_Flag = 1'b1;
			end
 
		endcase
    end

endmodule
