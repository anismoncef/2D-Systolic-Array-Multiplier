module tb_systolic_4x4();
    reg clk = 0;
    reg reset;
    reg [3:0] data_in;
    reg load_weights;
    reg load_inputs;
    wire [7:0] results[3:0];
    wire valid_out;
    
    always #5 clk = ~clk;
    
    systolic_4x4 dut (.*);
    
    initial begin
        // Initialize
        reset = 1;
        data_in = 0;
        load_weights = 0;
        load_inputs = 0;
        #20 reset = 0;
        
        // Load weights (16 cycles)
        $display("Loading weights...");
        load_weights = 1;
        for (int i=0; i<16; i++) begin
            data_in = i+1; // Weights 1-16
            #10;
        end
        load_weights = 0;
        
        // Load inputs (4 cycles)
        $display("Loading inputs...");
        load_inputs = 1;
        data_in = 1; #10;
        data_in = 2; #10;
        data_in = 3; #10;
        data_in = 4; #10;
        load_inputs = 0;
        
        // Wait for results
        $display("Computing...");
        wait(valid_out);
        $display("Results: %0d, %0d, %0d, %0d", 
                results[0], results[1], results[2], results[3]);
        
        #100 $finish;
    end
endmodule