module ALU (reg_one, reg_two, opcode, out);
    input wire [18:0] reg_one, reg_two;
    input wire [1:0] opcode;
    output reg [18:0] out;

	always @(*)
		begin
		case(opcode)
			2'b00: out = reg_one + reg_two;
			2'b01: out = reg_one - reg_two;
			2'b10: out = reg_one & reg_two;
			2'b11: out = reg_one | reg_two;
			default: out = 0;
		endcase
    end
endmodule
