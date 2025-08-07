module systolic_4x4 (
    input clk,
    input reset,
    input [3:0] data_in,       // 4 parallel bits (complete 4-bit value)
    input load_weights,        // High during weight loading
    input load_inputs,         // High during input loading
    output [7:0] results[3:0], // 4 output channels
    output valid_out           // High when results are valid
);

// ==============================================
// Weight and Input Storage
// ==============================================
reg [3:0] weights[3:0][3:0];  // 4x4 weight matrix
reg [3:0] inputs[3:0];        // Current input vector
reg [1:0] load_counter;       // Tracks loading progress

// ==============================================
// Processing Elements
// ==============================================
reg [7:0] pe_results[3:0][3:0]; // PE computation results

// ==============================================
// Control Logic
// ==============================================
always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Clear all weights and inputs
        for (int i=0; i<4; i++) begin
            inputs[i] <= 0;
            for (int j=0; j<4; j++) begin
                weights[i][j] <= 0;
                pe_results[i][j] <= 0;
            end
        end
        load_counter <= 0;
    end
    else begin
        // Weight Loading (row-major order)
        if (load_weights) begin
            case (load_counter)
                2'd0: weights[0][0] <= data_in;
                2'd1: weights[0][1] <= data_in;
                2'd2: weights[0][2] <= data_in;
                2'd3: weights[0][3] <= data_in;
            endcase
            load_counter <= load_counter + 1;
        end
        // Input Loading
        else if (load_inputs) begin
            inputs[load_counter] <= data_in;
            load_counter <= load_counter + 1;
        end
        // Computation
        else begin
            for (int i=0; i<4; i++) begin
                for (int j=0; j<4; j++) begin
                    pe_results[i][j] <= pe_results[i][j] + (inputs[j] * weights[i][j]);
                end
            end
        end
    end
end

// ==============================================
// Output Logic
// ==============================================
assign results[0] = pe_results[0][3];
assign results[1] = pe_results[1][3];
assign results[2] = pe_results[2][3];
assign results[3] = pe_results[3][3];

// Valid output appears after computation completes
reg [2:0] compute_cycles;
always @(posedge clk or posedge reset) begin
    if (reset) compute_cycles <= 0;
    else if (load_inputs && load_counter == 3) compute_cycles <= 1;
    else if (compute_cycles > 0) compute_cycles <= compute_cycles + 1;
end

assign valid_out = (compute_cycles == 4);

endmodule