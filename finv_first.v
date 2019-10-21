module finv(
    input wire [31:0] s,
    output wire [31:0] d,
    output wire overflow,
    output wire underflow
    // output wire [31:0] x1,
    // output wire [31:0] x2,
    // output wire [31:0] x3,
    // output wire [31:0] x4,
    // output wire [31:0] x5,
    // output wire [31:0] x6
);

// 符号1bit、指数8bit、仮数23bitを読み出す
wire [0:0] sign_s, sign_d;
wire [7:0] exponent_s, exponent_d;
wire [22:0] mantissa_s, mantissa_d;

assign sign_s = s[31:31];
assign exponent_s = s[30:23];
assign mantissa_s = s[22:0];

// 省略されている1を元に戻す
wire [23:0] one_mantissa_s;
assign one_mantissa_s = {1'b1, mantissa_s};

// 符号を決める
assign sign_d = sign_s;

// 指数を決める
assign exponent_d = 8'd253 - exponent_s;

// 仮数を決める
// wire [31:0] oms;
wire [31:0] x0, x1, x2, x3, x4, x5, x6;
// wire [31:0] x0;
wire [31:0] a0, a1, a2, a3, a4, a5, a6;
wire [31:0] b0, b1, b2, b3, b4, b5, b6;
wire [31:0] c0, c1, c2, c3, c4, c5, c6;
wire [31:0] const2;

// FIXME: Newton法を回す
assign x0 = {sign_d, exponent_d, 23'b0};
assign const2 = {1'b0, 8'd128, 23'b0};

// step1
fmul u11(s, x0, a1);
assign b1 = {1'b1 - a1[31:31], a1[30:0]};
fadd u12(const2, b1, c1);
fmul u13(c1, x0, x1);

//step2
fmul u21(s, x1, a2);
assign b2 = {1'b1 - a2[31:31], a2[30:0]};
fadd u22(const2, b2, c2);
fmul u23(c2, x1, x2);

// step3
fmul u31(s, x2, a3);
assign b3 = {1'b1 - a3[31:31], a3[30:0]};
fadd u32(const2, b3, c3);
fmul u33(c3, x2, x3);

// step4
fmul u41(s, x3, a4);
assign b4 = {1'b1 - a4[31:31], a4[30:0]};
fadd u42(const2, b4, c4);
fmul u43(c4, x3, x4);

// step5
fmul u51(s, x4, a5);
assign b5 = {1'b1 - a5[31:31], a5[30:0]};
fadd u52(const2, b5, c5);
fmul u53(c5, x4, x5);

// step6
fmul u61(s, x5, a6);
assign b6 = {1'b1 - a6[31:31], a6[30:0]};
fadd u62(const2, b6, c6);
fmul u63(c6, x5, x6);

assign mantissa_d = x6[22:0];

// 出力する
// assign d = {sign_d, exponent_d, mantissa_d}; 
assign d = x6;
assign ovf = 1'b0;

endmodule