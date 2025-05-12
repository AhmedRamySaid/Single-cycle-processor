module ALU (reg_one, reg_two, opcode, zero_flag, out);
	input wire [18:0] reg_one, reg_two; // rs, rt
	input wire [2:0] opcode;
	output reg zero_flag;
	output reg [18:0] out;

	always @(*)
		begin
		case(opcode)
			3'b000: out = reg_one + reg_two;
			3'b001: out = reg_one - reg_two;
			3'b010: out = reg_one & reg_two;
			3'b011: out = reg_one | reg_two;
			3'b100: out = ($signed(reg_one) < $signed(reg_two)) 
								? 1 : 0;
			default: out = 0;
		endcase
		zero_flag = (out == 0) ? 1'b1 : 1'b0;
	end

endmodule
