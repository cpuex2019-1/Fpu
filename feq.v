module feq(
  input wire [31:0] s,
  input wire [31:0] t,
  output wire b
);

assign b = (s == t);

endmodule