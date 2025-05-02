module PC(
	input clk, // Clock
	input reset, // Active high reset
	input [4:0] address, // Instruction address. Reg to allow initialization
	output reg [4:0] newAddress // Instruction address outputted
);
	
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            newAddress <= 5'b0;
        end
        else begin
            newAddress <= address;
        end
    end

endmodule
