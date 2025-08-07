module systolic_4x4 (
    input clk,
    input reset,
    input [3:0] data_in,
    input load_weights,
    input load_inputs,
    output reg [7:0] results[3:0],
    output reg valid_out
);

    // Memory elements
    reg [3:0] weights[0:3][0:3];
    reg [3:0] inputs[0:3];
    reg [7:0] accum[0:3][0:3];
    
    // Control signals
    reg [3:0] load_counter;
    reg compute_en;
    reg [1:0] compute_phase;

    // Initialize all registers
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Clear all arrays
            for (int i=0; i<4; i++) begin
                inputs[i] <= 0;
                results[i] <= 0;
                for (int j=0; j<4; j++) begin
                    weights[i][j] <= 0;
                    accum[i][j] <= 0;
                end
            end
            load_counter <= 0;
            compute_en <= 0;
            compute_phase <= 0;
            valid_out <= 0;
        end
        else begin
            valid_out <= 0;
            
            // Weight loading
            if (load_weights) begin
                weights[load_counter[3:2]][load_counter[1:0]] <= data_in;
                load_counter <= load_counter + 1;
            end
            // Input loading
            else if (load_inputs) begin
                inputs[load_counter[1:0]] <= data_in;
                load_counter <= load_counter + 1;
                
                // Start computation after last input
                if (load_counter == 3) begin
                    compute_en <= 1;
                    load_counter <= 0;
                end
            end
            // Computation
            else if (compute_en) begin
                case (compute_phase)
                    0: begin
                        // Initial multiplication only
                        for (int i=0; i<4; i++) begin
                            for (int j=0; j<4; j++) begin
                                accum[i][j] <= inputs[j] * weights[i][j];
                            end
                        end
                        compute_phase <= 1;
                    end
                    1: begin
                        // Diagonal propagation
                        for (int i=0; i<4; i++) begin
                            for (int j=0; j<4; j++) begin
                                if (i > 0 && j > 0) begin
                                    accum[i][j] <= accum[i][j] + accum[i-1][j] + accum[i][j-1] - accum[i-1][j-1];
                                end
                                else if (i > 0) begin
                                    accum[i][j] <= accum[i][j] + accum[i-1][j];
                                end
                                else if (j > 0) begin
                                    accum[i][j] <= accum[i][j] + accum[i][j-1];
                                end
                            end
                        end
                        compute_phase <= 2;
                    end
                    2: begin
                        // Capture results
                        for (int i=0; i<4; i++) begin
                            results[i] <= accum[i][3];
                        end
                        valid_out <= 1;
                        compute_en <= 0;
                    end
                endcase
            end
        end
    end
endmodule