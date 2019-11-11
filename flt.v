module flt(
  input wire [31:0] s,
  input wire [31:0] t,
  output wire b
);

assign b =
  (s[31:31] == t[31:31]) ? (s[30:0] < t[30:0]) :
  (s[31:31] > t[31:31]) ? 1'b1 :
  1'b0;

endmodule