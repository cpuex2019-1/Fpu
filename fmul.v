module fmul(
    input wire [31:0] s,
    input wire [31:0] t,
    output wire [31:0] d,
    output wire overflow
);

// 符号1bit、指数8bit、仮数23bitを読み出す
wire [0:0] sign_s, sign_t, sign_d;
wire [7:0] exponent_s, exponent_t, exponent_d;
wire [22:0] mantissa_s, mantissa_t, mantissa_d;

assign sign_s = s[31:31];
assign sign_t = t[31:31];
assign exponent_s = s[30:23];
assign exponent_t = t[30:23];
assign mantissa_s = s[22:0];
assign mantissa_t = t[22:0];

// 省略されている1を元に戻す
wire [23:0] one_mantissa_s, one_mantissa_t;
assign one_mantissa_s = {1'b1, mantissa_s};
assign one_mantissa_t = {1'b1, mantissa_t};

// 符号を決める
assign sign_d = (sign_s == sign_t) ? 0 : 1;

// 指数を決める
// TODO: overflowに対処する
// assign exponent_d = exponent_s + exponent_t - 8'b11111111;

// 仮数を決める

// 24bitのone_mantissaどうしでMulを行う(とC1.22UG22(R)の48bitになる)
wire [47:0] one_mantissa_d_48bit;
wire carry;

assign one_mantissa_d_48bit = mantissa_s * mantissa_t;
assign carry = one_mantissa_d_48bit[47:47];

// 正規化する
// 繰り上がりの有無で場合分けする
wire [23:0] one_mantissa_d_24bit;
assign one_mantissa_d_24bit[23:1] = (carry == 1) ? one_mantissa_48bit[47:25] : one_mantissa_48bit[46:24];

// 丸める
wire ulp, guard, round;
assign ulp = (carry == 1) ? one_mantissa_d_48bit[24:24] : one_mantissa_d_48bit[23:23];
assign guard = (carry == 1) ? one_mantissa_d_48bit[23:23] : one_mantissa_d_48bit[22:22];
assign round = (carry == 1) ? |(one_mantissa_d_48bit[22:0]) : |(one_mantissa_d_48bit[21:0]);
assign one_mantissa_d_24bit[0:0] = ulp | (guard & round);

// 指数と仮数を決定する
assign exponent_d = (carry == 1) ? exponent_s + exponent_t - 8'b11111111 : exponent_s + exponent_t - 8'b11111110 ;
assign mantissa_d = one_mantissa_24bit[22:0];

endmodule