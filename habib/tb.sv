module tb_systolic_4x4();
    reg clk = 0;
    reg reset;
    reg [3:0] data_in;
    reg load_weights;
    reg load_inputs;
    wire [7:0] results[3:0];
    wire valid_out;
    
    // Instantiate DUT
    systolic_4x4 dut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .load_weights(load_weights),
        .load_inputs(load_inputs),
        .results(results),
        .valid_out(valid_out)
    );
    
    // Clock generation (100MHz)
    always #5 clk = ~clk;
    
    // Initialize waveform dumping
    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, tb_systolic_4x4);
    end
    
    // Test sequence
    initial begin
        // Reset
        reset = 1;
        data_in = 0;
        load_weights = 0;
        load_inputs = 0;
        #20 reset = 0;
        
        // Load weights (1-16 in row-major order)
        $display("[%0t] Loading weights...", $time);
        load_weights = 1;
        for (int i=0; i<4; i++) begin
            for (int j=0; j<4; j++) begin
                data_in = i*4 + j + 1;  // Values 1-16
                #10;
            end
        end
        load_weights = 0;
        
        // Load inputs (1,2,3,4)
        $display("[%0t] Loading inputs...", $time);
        load_inputs = 1;
        data_in = 1; #10;
        data_in = 2; #10;
        data_in = 3; #10;
        data_in = 4; #10;
        load_inputs = 0;
        
        // Wait for results
        $display("[%0t] Computing...", $time);
        wait(valid_out);
        $display("[%0t] Results: %0d, %0d, %0d, %0d", 
                $time, results[0], results[1], results[2], results[3]);
        
        // Verify results
        if (results[0] != 30 || results[1] != 70 || 
            results[2] != 110 || results[3] != 150) begin
            $display("ERROR: Incorrect results!");
        end
        
        #100 $display("[%0t] Simulation complete", $time);
        $finish;
    end
    
    // Monitor signals
    always @(posedge clk) begin
        if (valid_out) begin
            $display("[%0t] Output valid: %0d, %0d, %0d, %0d",
                    $time, results[0], results[1], results[2], results[3]);
        end
    end
endmodule