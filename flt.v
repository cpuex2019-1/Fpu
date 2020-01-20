module flt(
  input wire [31:0] s,
  input wire [31:0] t,
  output wire b
);

wire ss, tt;
assign ss = (s == {1'b1, 31'b0}) ? 32'b0 : s;
assign tt = (t == {1'b1, 31'b0}) ? 32'b0 : t;

assign b =
  (ss[31:31] == tt[31:31]) ? (ss[30:0] < tt[30:0]) :
  (ss[31:31] > tt[31:31]) ? 1'b1 :
  1'b0;

endmodule