module CPU_tb;
    logic clk;
    logic reset;
    logic [18:0] alu_result;
    
    CPU uut (.*);  // Direct port connection
    
    initial begin
        clk = 0;
        forever #5ns clk = ~clk;
    end
    
    initial begin
        reset = 1'b1;
        #10ns reset = 1'b0;
        #1000ns $finish;
    end
    
    initial begin
        $timeformat(-9, 0, "ns", 3);
        $monitor("At %t: reset=%b, alu_result=%h", $time, reset, alu_result);
    end
endmodule
