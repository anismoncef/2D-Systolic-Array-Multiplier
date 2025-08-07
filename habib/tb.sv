module tb_systolic_4x4();
    reg clk = 0;
    reg reset;
    reg [3:0] bit_inputs;
    reg start;
    wire [7:0] results[3:0];
    wire valid_out;
    
    // Clock generation (100MHz)
    always #5 clk = ~clk;
    
    // Instantiate DUT
    systolic_4x4 dut (
        .clk(clk),
        .reset(reset),
        .bit_inputs(bit_inputs),
        .start(start),
        .results(results),
        .valid_out(valid_out)
    );
    
    // Test procedure
    initial begin
        // Initialize
        reset = 1;
        bit_inputs = 0;
        start = 0;
        #20 reset = 0;
        
        // Load weights (4 sets of 4 weights)
        $display("[%0t] Starting weight loading", $time);
        #10 start = 1;
        #10 start = 0;
        
        // Set 0: weights [1,2,3,4] (LSB first)
        bit_inputs = 4'b0001; // Cycle 1: LSB of [1,2,3,4]
        #10;
        bit_inputs = 4'b0010; // Cycle 2
        #10;
        bit_inputs = 4'b0011; // Cycle 3
        #10;
        bit_inputs = 4'b0000; // Cycle 4: MSB of [1,2,3,4]
        #10;
        
        // Set 1: weights [5,6,7,8]
        bit_inputs = 4'b0001; // Cycle 1: LSB of [5,6,7,8]
        #10;
        bit_inputs = 4'b0010; // Cycle 2
        #10;
        bit_inputs = 4'b0011; // Cycle 3
        #10;
        bit_inputs = 4'b0000; // Cycle 4: MSB of [5,6,7,8]
        #10;
        
        // Set 2: weights [9,10,11,12]
        bit_inputs = 4'b0001; // Cycle 1: LSB of [9,10,11,12]
        #10;
        bit_inputs = 4'b0010; // Cycle 2
        #10;
        bit_inputs = 4'b0011; // Cycle 3
        #10;
        bit_inputs = 4'b0000; // Cycle 4: MSB of [9,10,11,12]
        #10;
        
        // Set 3: weights [13,14,15,16]
        bit_inputs = 4'b0001; // Cycle 1: LSB of [13,14,15,16]
        #10;
        bit_inputs = 4'b0010; // Cycle 2
        #10;
        bit_inputs = 4'b0011; // Cycle 3
        #10;
        bit_inputs = 4'b0000; // Cycle 4: MSB of [13,14,15,16]
        #10;
        
        // Load inputs (4 sets of 4 inputs)
        $display("[%0t] Starting input loading", $time);
        // Set 0: inputs [1,1,1,1]
        bit_inputs = 4'b0001; // Cycle 1: LSB
        #10;
        bit_inputs = 4'b0000; // Cycle 2
        #10;
        bit_inputs = 4'b0000; // Cycle 3
        #10;
        bit_inputs = 4'b0000; // Cycle 4: MSB
        #10;
        
        // Set 1: inputs [2,2,2,2]
        bit_inputs = 4'b0010; // Cycle 1: LSB
        #10;
        bit_inputs = 4'b0000; // Cycle 2
        #10;
        bit_inputs = 4'b0000; // Cycle 3
        #10;
        bit_inputs = 4'b0000; // Cycle 4: MSB
        #10;
        
        // Set 2: inputs [3,3,3,3]
        bit_inputs = 4'b0011; // Cycle 1: LSB
        #10;
        bit_inputs = 4'b0000; // Cycle 2
        #10;
        bit_inputs = 4'b0000; // Cycle 3
        #10;
        bit_inputs = 4'b0000; // Cycle 4: MSB
        #10;
        
        // Set 3: inputs [4,4,4,4]
        bit_inputs = 4'b0000; // Cycle 1: LSB
        #10;
        bit_inputs = 4'b0001; // Cycle 2
        #10;
        bit_inputs = 4'b0000; // Cycle 3
        #10;
        bit_inputs = 4'b0000; // Cycle 4: MSB
        #10;
        
        $display("[%0t] Waiting for computation results...", $time);
        
        // Wait for computation to complete
        #500; // Wait for 50 additional cycles
        
        $display("[%0t] Simulation complete", $time);
        $finish;
    end
    
    // Monitor results
    always @(posedge clk) begin
        if (valid_out) begin
            $display("[%0t] RESULTS: Row0=%0d, Row1=%0d, Row2=%0d, Row3=%0d", 
                    $time, results[0], results[1], results[2], results[3]);
        end
    end
endmodule