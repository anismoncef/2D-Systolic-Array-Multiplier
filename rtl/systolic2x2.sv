module systolic_array_2x2 #(
  parameter BITWIDTH = 4,
  parameter N = 4,
  parameter OUTWIDTH = 8
  )
(
    input  wire                     clk,
    input  wire                     reset,
    input  wire                     preload_en,       // 1=preload weights, 0=compute
    input  wire  [BITWIDTH-1:0]     din0, din1, // 2x 4-bit inputs
    output logic [OUTWIDTH-1:0]     dout0, dout1, // 2x 8-bit outputs
    output logic                    valid_out         // Output valid flag
);

// Weight storage (4x 4-bit registers)
reg [BITWIDTH-1:0] w00, w01, w10, w11;

// Pipeline registers (4x 8-bit)
reg [OUTWIDTH-1:0] p00, p01, p10, p11;

// Input shift register (2x 4-bit)
reg [BITWIDTH-1:0] in0, in1;

// Single-bit state machine
reg state;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        {w00, w01, w10, w11} <= 0;
        {p00, p01, p10, p11} <= 0;
        {in0, in1} <= 0;
        {dout0, dout1} <= 0;
        valid_out <= 0;
        state <= 0;
    end else begin
        valid_out <= ~preload_en; // Output valid during compute phase

        if (preload_en) begin
            // Weight loading (2 cycles)
            if (~state) {w00, w01} <= {din0, din1};
            else {w10, w11} <= {din0, din1};
            state <= ~state;
        end else begin
            // Computation phase
            in0 <= din0;      // New input
            in1 <= in0;       // Shift previous input
            
            // First column processing
            p00 <= $signed(in0) * $signed(w00);
            p10 <= $signed(in0) * $signed(w10) + p00;
            
            // Second column processing
            p01 <= $signed(in1) * $signed(w01) + p00;
            p11 <= $signed(in1) * $signed(w11) + p01 + p10 - p00;
            
            // Outputs
            dout0 <= p01;
            dout1 <= p11;
        end
    end
end

endmodule