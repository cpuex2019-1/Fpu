module fabs(
  input wire [31:0] s,
  output wire [31:0] d
)

assign d = {1'b0, s[30:0]};

endmodule