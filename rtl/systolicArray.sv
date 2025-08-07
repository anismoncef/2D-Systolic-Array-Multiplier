// This module interconnects the PEs to form a systolic array. Below, is an
// example of how PEs in a 4x4 systolic array are interconnected. The horizontal
// lines represent row interconnects, and the vertical lines represent column
// interconnects. The arrows indicate the direction of data flow.

// PE[0][0] --> PE[0][1] --> PE[0][2] --> PE[0][3]
//   |            |            |            |
//   v            v            v            v
// PE[1][0] --> PE[1][1] --> PE[1][2] --> PE[1][3]
//   |            |            |            |
//   v            v            v            v
// PE[2][0] --> PE[2][1] --> PE[2][2] --> PE[2][3]
//   |            |            |            |
//   v            v            v            v
// PE[3][0] --> PE[3][1] --> PE[3][2] --> PE[3][3]

`default_nettype none
`include "./pe.sv"

module systolicArray#(
  parameter BITWIDTH = 4,
  parameter N = 4,
  parameter OUTWIDTH = 8
  )
  ( input  var logic                         i_clk
  , input  var logic                         i_arst

  , input  var logic                         i_doProcess

  , input  var logic [N-1:0][BITWIDTH -1:0] i_row
  , input  var logic [N-1:0][BITWIDTH -1:0] i_col

  , output var logic [N-1:0][N-1:0][OUTWIDTH -1:0]    o_c
  );

  /* verilator lint_off UNUSED */
  // Variable used to pass data horizontally between PEs in the same row. The
  // output o_a of one PE is connected to the input i_a of the PE to its right.
  wire [N-1:0][N:0][BITWIDTH -1:0] rowInterConnect;
  wire [N:0][N-1:0][BITWIDTH -1:0] colInterConnect;
  /* verilator lint_off UNUSED */

  for (genvar i = 0; i < N; i++) begin: PerDummyRowColInterconnect

    always_comb
      rowInterConnect[i][0] = i_row[i][0];

    always_comb
      colInterConnect[0][i] = i_col[i][0];

  end: PerDummyRowColInterconnect

  for (genvar i = 0; i < N; i++) begin: PerRow
    for (genvar j = 0; j < N; j++) begin: PerCol

      pe u_pe
      ( .i_clk
      , .i_arst

      , .i_doProcess

      , .i_a (rowInterConnect[i][j])
      , .i_b (colInterConnect[i][j])

      , .o_a (rowInterConnect[i][j+1])
      , .o_b (colInterConnect[i+1][j])
      , .o_y (o_c[i][j])
      );

    end: PerCol
  end: PerRow

endmodule

`resetall
