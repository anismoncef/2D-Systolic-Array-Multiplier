module systolic_4x4 (
    input clk,
    input reset,
    input [3:0] bit_inputs,  // 4x 1-bit inputs (parallel)
    input start,             // Pulse to begin loading
    output [7:0] results[3:0], // 4x 8-bit outputs
    output valid_out         // High when results are valid
);

// ==============================================
// Parallel Serial Input Processing (4 channels)
// ==============================================
reg [3:0] input_shift_reg[3:0];  // 4x 4-bit shift registers
reg [1:0] bit_counter;           // Tracks 4-cycle sequences

always @(posedge clk or posedge reset) begin
    if (reset) begin
        bit_counter <= 0;
        for (int i=0; i<4; i++) input_shift_reg[i] <= 0;
    end else begin
        if (bit_counter < 3) begin
            // Shift in new bits (LSB first) for all 4 channels
            for (int i=0; i<4; i++) begin
                input_shift_reg[i] <= {bit_inputs[i], input_shift_reg[i][3:1]};
            end
            bit_counter <= bit_counter + 1;
        end else begin
            bit_counter <= 0;
        end
    end
end

// Full 4-bit values available after 4 cycles
wire [3:0] parallel_data[3:0];
assign parallel_data[0] = input_shift_reg[0];
assign parallel_data[1] = input_shift_reg[1];
assign parallel_data[2] = input_shift_reg[2];
assign parallel_data[3] = input_shift_reg[3];

// ==============================================
// Control FSM
// ==============================================
typedef enum {IDLE, LOAD_WEIGHTS, LOAD_INPUTS, COMPUTE} state_t;
state_t current_state, next_state;

reg [3:0] load_counter;  // Tracks loading progress
reg compute_en;          // Computation enable
reg array_reset;
wire pe_valid[3:0][3:0]; // Individual PE valid signals

// FSM transitions
always @(posedge clk or posedge reset) begin
    if (reset) current_state <= IDLE;
    else current_state <= next_state;
end

// FSM logic
always_comb begin
    next_state = current_state;
    case (current_state)
        IDLE: if (start) next_state = LOAD_WEIGHTS;
        LOAD_WEIGHTS: 
            if (load_counter == 3) next_state = LOAD_INPUTS; // 4 cycles per weight set
        LOAD_INPUTS:
            if (load_counter == 3) next_state = COMPUTE;
        COMPUTE:
            if (load_counter == 3) next_state = IDLE;
    endcase
end

// Control signals
always @(posedge clk or posedge reset) begin
    if (reset) begin
        load_counter <= 0;
        compute_en <= 0;
        array_reset <= 1;
    end else begin
        array_reset <= (current_state == IDLE);
        
        if (bit_counter == 3) begin
            load_counter <= load_counter + 1;
        end
        
        compute_en <= (current_state == COMPUTE);
    end
end

// ==============================================
// 4x4 Processing Array
// ==============================================
wire gated_clk = clk & compute_en;

// Processing Element definition
genvar i, j;
generate
    for (i=0; i<4; i++) begin : row
        for (j=0; j<4; j++) begin : col
            pe #(.ID((i*4)+j)) processing_element (
                .clk(gated_clk),
                .reset(array_reset),
                .in_data(parallel_data[j]),  // Direct channel mapping
                .in_valid((current_state == LOAD_WEIGHTS) && (bit_counter == 3) && (load_counter == i)),
                .in_weight(current_state == LOAD_WEIGHTS),
                .out_result(results[i]),
                .out_valid(pe_valid[i][j])
            );
        end
    end
endgenerate

// Combine valid signals from last column
assign valid_out = pe_valid[0][3] | pe_valid[1][3] | pe_valid[2][3] | pe_valid[3][3];

endmodule

// ==============================================
// Processing Element
// ==============================================
module pe #(parameter ID = 0) (
    input clk,
    input reset,
    input [3:0] in_data,
    input in_valid,
    input in_weight,
    output reg [7:0] out_result,
    output reg out_valid
);

reg [3:0] weight;       // 4-bit weight storage
reg [7:0] accumulator;  // 8-bit accumulator

always @(posedge clk or posedge reset) begin
    if (reset) begin
        weight <= 0;
        accumulator <= 0;
        out_valid <= 0;
    end else begin
        // Weight loading (on 4th cycle of each set)
        if (in_valid && in_weight) begin
            weight <= in_data;
        end
        
        // Data processing
        if (in_valid && !in_weight) begin
            accumulator <= accumulator + (in_data * weight);
            out_valid <= 1'b1;
            out_result <= accumulator;
        end else begin
            out_valid <= 1'b0;
        end
    end
end

endmodule