module fneg(
  input wire [31:0] s,
  output wire [31:0] d
)

wire sign_d;
assign sign_d = s[31:31] ? 1'b0 : 1'b1;
assign d = {sign_d, s[30:30]};

endmodule