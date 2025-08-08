// SPDX-FileCopyrightText: © 2025 XXX Authors
// SPDX-License-Identifier: Apache-2.0

// Adapted from the Tiny Tapeout template
`include "./heichips25_systolicArray.sv"
`default_nettype none

module heichips25_template (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // List all unused inputs to prevent warnings
    wire    _unused         = &{ena, ui_in[7:5], uio_in[7:0]};
w   ire     load_weights    ; 
    wire    load_inputs     ; 
    wire    store_outputs   ; 
    wire    valid_out       ; 
heichips25_systolicArray #(
    .BITWIDTH(4),
    .OUTWIDTH(8)
)mydesign(
    .clk(clk),
    .reset(!rst_n),
    .data_in(ui_in[3:0]),
    .load_weights(load_weights),
    .load_inputs(load_inputs),
    .store_outputs(store_outputs),
    .results(uo_out),
    .valid_out(valid_out)
);

    logic [ 9:0] sram_addr;
    logic [31:0] sram_bm;
    logic [31:0] sram_din;
    logic        sram_wen;
    logic        sram_men;
    logic        sram_ren;
    logic [31:0] sram_dout;
    
    IHP_SRAM_1024x32_wrapper IHP_SRAM_1024x32_wrapper (
        .ADDR  (sram_addr),
        .BM    (4'b0011),
        .DIN   (sram_din),
        .WEN   (sram_wen),
        .MEN   (sram_men),
        .REN   (sram_ren),
        .DOUT  (sram_dout)
    );
    
    fsm #(
    .ADDR_W(10)
    ) (
    .clk(clk),
    .start(ui_in[4]),
    .reset(!rst_n),
    .load_weights(load_weights),   
    .load_inputs(load_inputs), 
    .store_outputs(store_outputs), 
    .ren(uio_out[0]),
    .wen(uio_out[1]),
    .address_o(sram_addr), 
    .valid_out(valid_out) 
);
//SRAM ASSIGNS
    assign sram_din     = uo_out    ;
    assign sram_wen     = uio_out[1];
    assign sram_ren     = uio_out[0];
    assign sram_men     = 1'b1;
    assign ui_in[3:0]   = sram_dout ;
//DESIGN UNUSED ASSIGNS
    assign uio_out[7:2] = '0        ;
    assign uio_oe       = '1        ;

endmodule