`timescale 1ns/1ps

module systolic_4x4_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // 10ns = 100MHz clock
    
    // Signals
    reg clk;
    reg reset;
    reg [3:0] data_in;
    reg [3:0] outsignal;
    reg load_weights;
    reg load_inputs;
    reg store_outputs;
    wire [7:0] results ;
    wire valid_out;
    
    // Test matrices (initialized separately)
    reg [3:0] weight_matrix_1 [0:3][0:3];
    reg [3:0] input_matrix_1 [0:3][0:3];
    reg [3:0] weight_matrix_2 [0:3][0:3];
    reg [3:0] input_matrix_2 [0:3][0:3];
    
    // Expected results
    reg [7:0] expected_result_1 [0:3];
    reg [7:0] expected_result_2 [0:3];
    
    // Instantiate DUT
    systolic_4x4 dut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .load_weights(load_weights),
        .load_inputs(load_inputs),
        .store_outputs(store_outputs),
        .results(results),
        .valid_out(valid_out)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Initialize test matrices
    initial begin
        // Initialize weight_matrix_1
        weight_matrix_1[0][0] = 1; weight_matrix_1[0][1] = 1; weight_matrix_1[0][2] = 1; weight_matrix_1[0][3] = 1;
        weight_matrix_1[1][0] = 1; weight_matrix_1[1][1] = 1; weight_matrix_1[1][2] = 1; weight_matrix_1[1][3] = 1;
        weight_matrix_1[2][0] = 1; weight_matrix_1[2][1] = 1; weight_matrix_1[2][2] = 1; weight_matrix_1[2][3] = 1;
        weight_matrix_1[3][0] = 1; weight_matrix_1[3][1] = 1; weight_matrix_1[3][2] = 1; weight_matrix_1[3][3] = 1;
        
        // Initialize input_matrix_1
        input_matrix_1[0][0] = 1; input_matrix_1[0][1] = 0; input_matrix_1[0][2] = 0; input_matrix_1[0][3] = 0;
        input_matrix_1[1][0] = 0; input_matrix_1[1][1] = 1; input_matrix_1[1][2] = 0; input_matrix_1[1][3] = 0;
        input_matrix_1[2][0] = 0; input_matrix_1[2][1] = 0; input_matrix_1[2][2] = 1; input_matrix_1[2][3] = 0;
        input_matrix_1[3][0] = 0; input_matrix_1[3][1] = 0; input_matrix_1[3][2] = 0; input_matrix_1[3][3] = 1;
        
        
        // Initialize expected results
        expected_result_1[0] = 1;
        expected_result_1[1] = 6;
        expected_result_1[2] = 11;
        expected_result_1[3] = 1;
        
        expected_result_2[0] = 1;
        expected_result_2[1] = 6;
        expected_result_2[2] = 11;
        expected_result_2[3] = 1;
    end
    
    // Test procedure
    initial begin
        // Initialize
        reset = 1;
        data_in = 0;
        load_weights = 0;
        load_inputs = 0;
        store_outputs = 0;
        
        // Reset the system
        #20;
        reset = 0;
        #10;
        
        ///////////////////////////////////////
        // First Test Case: Matrix Multiplication 1
        ///////////////////////////////////////
        $display("\nStarting Test Case 1...");
        
        // Load weights
        $display("Loading weights for test case 1...");
        load_weights = 1;
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                data_in = weight_matrix_1[i][j];
                #10;
            end
        end
        load_weights = 0;
        #10;
        
        // Load inputs
        $display("Loading inputs for test case 1...");
        load_inputs = 1;
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                data_in = input_matrix_1[i][j];
                #10;
            end
        end
        load_inputs = 0;
        #10;
        
        // Wait for computation to complete
        $display("Waiting for computation to complete...");
        wait(valid_out);
        #10;
        store_outputs = 1 ;
        #10;
        $display("Results for test case 1:");
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                $display("  Result[%0d][%0d] = %0d", i, j, results);
                #10;
            end
        end
        store_outputs = 0 ;
        $display("finished the testbench...");
        $finish;
    end
    
    // VCD dump for waveform viewing
    initial begin
        $dumpfile("systolic_array.vcd");
        $dumpvars(0, systolic_4x4_tb);
    end

endmodule