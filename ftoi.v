module ftoi(
  input wire [31:0] s,
  output wire [31:0] d
)

wire sign_s;
wire [7:0] exponent_s;
wire [22:0] mantissa_s;
wire [23:0] one_mantissa_s;

assign sign_s = s[31:31];
assign exponent_s = s[30:23];
assign mantissa_s = s[22:0];
assign one_mantissa_s = {1'b1, mantissa_s};


// FIXME: 非正規化数には対応していない
// とりあえず31bitくらい確保した
wire [54:0] tmp1, tmp2;
wire [31:0] tmp3, tmp4;
assign tmp1 = {32'b0, mantissa_s};
assign tmp2 = tmp1 << exponent_s;
assign tmp3 = {1'b0, tmp2[54:24]};
assign tmp4 =
    sign_s ? ~tmp3 + 32'b1 : tmp3;

// FIXME:
wire d_is_inf, d_is_zero;
assign d_is_inf = |(exponent_s[7:5]);
assign d_is_zero = ~(|(exponent_s) || |(mantissa_s));

assign d =
    d_is_inf ? tmp4 :
    d_is_zero ? 32'd0 :
    tmp4;

endmodule