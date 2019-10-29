module shift_with_round(
    input wire [63:0] s,
    input wire [7:0] shift,
    output wire [63:0] d
);

// NOTE: できるだけ誤差が少なくなるようにshiftする
wire [63:0] t;
assign t = s >> shift;

wire ulp, guard, round, sticky, flag;
wire [63:0] for_ulp, for_guard, for_round;
assign for_ulp = s >> shift;
assign for_guard = s >> (shift - 8'b1);
assign for_round = s >> (shift - 8'b10);
// FIXME: とりあえず面倒なのでstickyは0としておく
assign ulp = for_ulp[0:0];
assign guard = for_guard[0:0];
assign round = for_round[0:0];
assign sticky = 1'b0;
assign flag = 
    (ulp && guard && (~round) && (~sticky)) ||
    (guard && (~round) && sticky) ||
    (guard && round);

assign d = {t[63:1], flag};

endmodule


// NOTE: FSqrt
module fsqrt(
    input wire [31:0] s,
    output wire [31:0] d,
    output wire overflow,
    output wire underflow,
    output wire [63:0] a1,
    output wire [63:0] b1,
    output wire [63:0] c1,
    output wire [63:0] a2,
    output wire [63:0] b2,
    output wire [63:0] c2,
    output wire [31:0] iter0,
    output wire [31:0] iter1,
    output wire [31:0] iter2
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
assign sign_d = 1'b0;

// 指数を決める
wire [8:0] tmp1, tmp2, tmp3;
assign tmp1 = {1'b0, exponent_s} - 9'd127;
assign tmp2 = tmp1 >> 1'b1;
assign tmp3 = tmp2 + 9'd127;
assign exponent_d = tmp3[7:0];

// 仮数を決める
// NOTE: 64bitで計算していく！
wire [6:0] upper7;
wire [15:0] lower16;
wire [63:0] x0, x1, x2;
// wire [63:0] a1, a2, a3;
// wire [63:0] b1, b2, b3;
// wire [63:0] c1, c2, c3;
// wire [63:0] d1, d2, d3;

// FIXME: Newton法を回す x_{n+1} = 1/2 (x_n + a / x_n)
wire [63:0] om;
assign om = 
  exponent_s[0:0] == 1'b0 ? {32'b0, one_mantissa_s, 8'b0} : {31'b0, one_mantissa_s, 9'b0};

assign x0 = {33'b1, upper7, lower16, 8'b0};
assign a1 = om << 8'd32;
assign b1 = a1 / x0;
// shift_with_round u11(b1,8'd31,c1);
assign c1 = x0 + b1;
// shift_with_round u12(d1,8'd32,e1);
assign x1 = c1 >> 1'b1;
// DEBUG:
assign iter0 = {sign_d, exponent_d, x0[30:8]};
assign iter1 = {sign_d, exponent_d, x1[30:8]};
assign iter2 = {sign_d, exponent_d, x2[30:8]};

assign a2 = om << 8'd32;
assign b2 = a2 / x1;
// shift_with_round u11(b1,8'd31,c1);
assign c2 = x1 + b2;
// shift_with_round u12(d1,8'd32,e1);
assign x2 = c2 >> 1'b1;

// 仮数を決める
wire ulp, guard, round, sticky, flag;
assign ulp = x2[8:8];
assign guard = x2[7:7];
assign round = x2[6:6];
assign sticky = |(x2[5:0]);
assign flag = 
    (ulp && guard && (~round) && (~sticky)) ||
    (guard && (~round) && sticky) ||
    (guard && round);

assign mantissa_d = x2[30:8] + {22'b0, flag};

// 初期値の下位bitはとりあえず0で
assign lower16 = 16'b0;

// NOTE: 初期値の上位7桁を決める
assign upper7 =
exponent_s[0:0] == 1'b0 ? (
mantissa_s[22:16] == 7'b0000000 ? 7'b0110101 :
mantissa_s[22:16] == 7'b0000001 ? 7'b0110101 :
mantissa_s[22:16] == 7'b0000010 ? 7'b0110110 :
mantissa_s[22:16] == 7'b0000011 ? 7'b0110111 :
mantissa_s[22:16] == 7'b0000100 ? 7'b0110111 :
mantissa_s[22:16] == 7'b0000101 ? 7'b0111000 :
mantissa_s[22:16] == 7'b0000110 ? 7'b0111001 :
mantissa_s[22:16] == 7'b0000111 ? 7'b0111001 :
mantissa_s[22:16] == 7'b0001000 ? 7'b0111010 :
mantissa_s[22:16] == 7'b0001001 ? 7'b0111011 :
mantissa_s[22:16] == 7'b0001010 ? 7'b0111011 :
mantissa_s[22:16] == 7'b0001011 ? 7'b0111100 :
mantissa_s[22:16] == 7'b0001100 ? 7'b0111101 :
mantissa_s[22:16] == 7'b0001101 ? 7'b0111101 :
mantissa_s[22:16] == 7'b0001110 ? 7'b0111110 :
mantissa_s[22:16] == 7'b0001111 ? 7'b0111111 :
mantissa_s[22:16] == 7'b0010000 ? 7'b1000000 :
mantissa_s[22:16] == 7'b0010001 ? 7'b1000000 :
mantissa_s[22:16] == 7'b0010010 ? 7'b1000001 :
mantissa_s[22:16] == 7'b0010011 ? 7'b1000001 :
mantissa_s[22:16] == 7'b0010100 ? 7'b1000010 :
mantissa_s[22:16] == 7'b0010101 ? 7'b1000011 :
mantissa_s[22:16] == 7'b0010110 ? 7'b1000011 :
mantissa_s[22:16] == 7'b0010111 ? 7'b1000100 :
mantissa_s[22:16] == 7'b0011000 ? 7'b1000101 :
mantissa_s[22:16] == 7'b0011001 ? 7'b1000101 :
mantissa_s[22:16] == 7'b0011010 ? 7'b1000110 :
mantissa_s[22:16] == 7'b0011011 ? 7'b1000111 :
mantissa_s[22:16] == 7'b0011100 ? 7'b1000111 :
mantissa_s[22:16] == 7'b0011101 ? 7'b1001000 :
mantissa_s[22:16] == 7'b0011110 ? 7'b1001001 :
mantissa_s[22:16] == 7'b0011111 ? 7'b1001001 :
mantissa_s[22:16] == 7'b0100000 ? 7'b1001010 :
mantissa_s[22:16] == 7'b0100001 ? 7'b1001011 :
mantissa_s[22:16] == 7'b0100010 ? 7'b1001011 :
mantissa_s[22:16] == 7'b0100011 ? 7'b1001100 :
mantissa_s[22:16] == 7'b0100100 ? 7'b1001100 :
mantissa_s[22:16] == 7'b0100101 ? 7'b1001101 :
mantissa_s[22:16] == 7'b0100110 ? 7'b1001110 :
mantissa_s[22:16] == 7'b0100111 ? 7'b1001110 :
mantissa_s[22:16] == 7'b0101000 ? 7'b1001111 :
mantissa_s[22:16] == 7'b0101001 ? 7'b1010000 :
mantissa_s[22:16] == 7'b0101010 ? 7'b1010000 :
mantissa_s[22:16] == 7'b0101011 ? 7'b1010001 :
mantissa_s[22:16] == 7'b0101100 ? 7'b1010001 :
mantissa_s[22:16] == 7'b0101101 ? 7'b1010010 :
mantissa_s[22:16] == 7'b0101110 ? 7'b1010011 :
mantissa_s[22:16] == 7'b0101111 ? 7'b1010011 :
mantissa_s[22:16] == 7'b0110000 ? 7'b1010100 :
mantissa_s[22:16] == 7'b0110001 ? 7'b1010100 :
mantissa_s[22:16] == 7'b0110010 ? 7'b1010101 :
mantissa_s[22:16] == 7'b0110011 ? 7'b1010110 :
mantissa_s[22:16] == 7'b0110100 ? 7'b1010110 :
mantissa_s[22:16] == 7'b0110101 ? 7'b1010111 :
mantissa_s[22:16] == 7'b0110110 ? 7'b1010111 :
mantissa_s[22:16] == 7'b0110111 ? 7'b1011000 :
mantissa_s[22:16] == 7'b0111000 ? 7'b1011001 :
mantissa_s[22:16] == 7'b0111001 ? 7'b1011001 :
mantissa_s[22:16] == 7'b0111010 ? 7'b1011010 :
mantissa_s[22:16] == 7'b0111011 ? 7'b1011010 :
mantissa_s[22:16] == 7'b0111100 ? 7'b1011011 :
mantissa_s[22:16] == 7'b0111101 ? 7'b1011011 :
mantissa_s[22:16] == 7'b0111110 ? 7'b1011100 :
mantissa_s[22:16] == 7'b0111111 ? 7'b1011101 :
mantissa_s[22:16] == 7'b1000000 ? 7'b1011101 :
mantissa_s[22:16] == 7'b1000001 ? 7'b1011110 :
mantissa_s[22:16] == 7'b1000010 ? 7'b1011110 :
mantissa_s[22:16] == 7'b1000011 ? 7'b1011111 :
mantissa_s[22:16] == 7'b1000100 ? 7'b1100000 :
mantissa_s[22:16] == 7'b1000101 ? 7'b1100000 :
mantissa_s[22:16] == 7'b1000110 ? 7'b1100001 :
mantissa_s[22:16] == 7'b1000111 ? 7'b1100001 :
mantissa_s[22:16] == 7'b1001000 ? 7'b1100010 :
mantissa_s[22:16] == 7'b1001001 ? 7'b1100010 :
mantissa_s[22:16] == 7'b1001010 ? 7'b1100011 :
mantissa_s[22:16] == 7'b1001011 ? 7'b1100011 :
mantissa_s[22:16] == 7'b1001100 ? 7'b1100100 :
mantissa_s[22:16] == 7'b1001101 ? 7'b1100101 :
mantissa_s[22:16] == 7'b1001110 ? 7'b1100101 :
mantissa_s[22:16] == 7'b1001111 ? 7'b1100110 :
mantissa_s[22:16] == 7'b1010000 ? 7'b1100110 :
mantissa_s[22:16] == 7'b1010001 ? 7'b1100111 :
mantissa_s[22:16] == 7'b1010010 ? 7'b1100111 :
mantissa_s[22:16] == 7'b1010011 ? 7'b1101000 :
mantissa_s[22:16] == 7'b1010100 ? 7'b1101000 :
mantissa_s[22:16] == 7'b1010101 ? 7'b1101001 :
mantissa_s[22:16] == 7'b1010110 ? 7'b1101010 :
mantissa_s[22:16] == 7'b1010111 ? 7'b1101010 :
mantissa_s[22:16] == 7'b1011000 ? 7'b1101011 :
mantissa_s[22:16] == 7'b1011001 ? 7'b1101011 :
mantissa_s[22:16] == 7'b1011010 ? 7'b1101100 :
mantissa_s[22:16] == 7'b1011011 ? 7'b1101100 :
mantissa_s[22:16] == 7'b1011100 ? 7'b1101101 :
mantissa_s[22:16] == 7'b1011101 ? 7'b1101101 :
mantissa_s[22:16] == 7'b1011110 ? 7'b1101110 :
mantissa_s[22:16] == 7'b1011111 ? 7'b1101110 :
mantissa_s[22:16] == 7'b1100000 ? 7'b1101111 :
mantissa_s[22:16] == 7'b1100001 ? 7'b1110000 :
mantissa_s[22:16] == 7'b1100010 ? 7'b1110000 :
mantissa_s[22:16] == 7'b1100011 ? 7'b1110001 :
mantissa_s[22:16] == 7'b1100100 ? 7'b1110001 :
mantissa_s[22:16] == 7'b1100101 ? 7'b1110010 :
mantissa_s[22:16] == 7'b1100110 ? 7'b1110010 :
mantissa_s[22:16] == 7'b1100111 ? 7'b1110011 :
mantissa_s[22:16] == 7'b1101000 ? 7'b1110011 :
mantissa_s[22:16] == 7'b1101001 ? 7'b1110100 :
mantissa_s[22:16] == 7'b1101010 ? 7'b1110100 :
mantissa_s[22:16] == 7'b1101011 ? 7'b1110101 :
mantissa_s[22:16] == 7'b1101100 ? 7'b1110101 :
mantissa_s[22:16] == 7'b1101101 ? 7'b1110110 :
mantissa_s[22:16] == 7'b1101110 ? 7'b1110110 :
mantissa_s[22:16] == 7'b1101111 ? 7'b1110111 :
mantissa_s[22:16] == 7'b1110000 ? 7'b1110111 :
mantissa_s[22:16] == 7'b1110001 ? 7'b1111000 :
mantissa_s[22:16] == 7'b1110010 ? 7'b1111000 :
mantissa_s[22:16] == 7'b1110011 ? 7'b1111001 :
mantissa_s[22:16] == 7'b1110100 ? 7'b1111001 :
mantissa_s[22:16] == 7'b1110101 ? 7'b1111010 :
mantissa_s[22:16] == 7'b1110110 ? 7'b1111010 :
mantissa_s[22:16] == 7'b1110111 ? 7'b1111011 :
mantissa_s[22:16] == 7'b1111000 ? 7'b1111011 :
mantissa_s[22:16] == 7'b1111001 ? 7'b1111100 :
mantissa_s[22:16] == 7'b1111010 ? 7'b1111100 :
mantissa_s[22:16] == 7'b1111011 ? 7'b1111101 :
mantissa_s[22:16] == 7'b1111100 ? 7'b1111101 :
mantissa_s[22:16] == 7'b1111101 ? 7'b1111110 :
mantissa_s[22:16] == 7'b1111110 ? 7'b1111110 : 7'b1111111
) : (
mantissa_s[22:16] == 7'b0000000 ? 7'b0000000 :
mantissa_s[22:16] == 7'b0000001 ? 7'b0000000 :
mantissa_s[22:16] == 7'b0000010 ? 7'b0000000 :
mantissa_s[22:16] == 7'b0000011 ? 7'b0000001 :
mantissa_s[22:16] == 7'b0000100 ? 7'b0000001 :
mantissa_s[22:16] == 7'b0000101 ? 7'b0000010 :
mantissa_s[22:16] == 7'b0000110 ? 7'b0000010 :
mantissa_s[22:16] == 7'b0000111 ? 7'b0000011 :
mantissa_s[22:16] == 7'b0001000 ? 7'b0000011 :
mantissa_s[22:16] == 7'b0001001 ? 7'b0000100 :
mantissa_s[22:16] == 7'b0001010 ? 7'b0000100 :
mantissa_s[22:16] == 7'b0001011 ? 7'b0000101 :
mantissa_s[22:16] == 7'b0001100 ? 7'b0000101 :
mantissa_s[22:16] == 7'b0001101 ? 7'b0000110 :
mantissa_s[22:16] == 7'b0001110 ? 7'b0000110 :
mantissa_s[22:16] == 7'b0001111 ? 7'b0000111 :
mantissa_s[22:16] == 7'b0010000 ? 7'b0000111 :
mantissa_s[22:16] == 7'b0010001 ? 7'b0001000 :
mantissa_s[22:16] == 7'b0010010 ? 7'b0001000 :
mantissa_s[22:16] == 7'b0010011 ? 7'b0001001 :
mantissa_s[22:16] == 7'b0010100 ? 7'b0001001 :
mantissa_s[22:16] == 7'b0010101 ? 7'b0001010 :
mantissa_s[22:16] == 7'b0010110 ? 7'b0001010 :
mantissa_s[22:16] == 7'b0010111 ? 7'b0001011 :
mantissa_s[22:16] == 7'b0011000 ? 7'b0001011 :
mantissa_s[22:16] == 7'b0011001 ? 7'b0001011 :
mantissa_s[22:16] == 7'b0011010 ? 7'b0001100 :
mantissa_s[22:16] == 7'b0011011 ? 7'b0001100 :
mantissa_s[22:16] == 7'b0011100 ? 7'b0001101 :
mantissa_s[22:16] == 7'b0011101 ? 7'b0001101 :
mantissa_s[22:16] == 7'b0011110 ? 7'b0001110 :
mantissa_s[22:16] == 7'b0011111 ? 7'b0001110 :
mantissa_s[22:16] == 7'b0100000 ? 7'b0001111 :
mantissa_s[22:16] == 7'b0100001 ? 7'b0001111 :
mantissa_s[22:16] == 7'b0100010 ? 7'b0010000 :
mantissa_s[22:16] == 7'b0100011 ? 7'b0010000 :
mantissa_s[22:16] == 7'b0100100 ? 7'b0010000 :
mantissa_s[22:16] == 7'b0100101 ? 7'b0010001 :
mantissa_s[22:16] == 7'b0100110 ? 7'b0010001 :
mantissa_s[22:16] == 7'b0100111 ? 7'b0010010 :
mantissa_s[22:16] == 7'b0101000 ? 7'b0010010 :
mantissa_s[22:16] == 7'b0101001 ? 7'b0010011 :
mantissa_s[22:16] == 7'b0101010 ? 7'b0010011 :
mantissa_s[22:16] == 7'b0101011 ? 7'b0010011 :
mantissa_s[22:16] == 7'b0101100 ? 7'b0010100 :
mantissa_s[22:16] == 7'b0101101 ? 7'b0010100 :
mantissa_s[22:16] == 7'b0101110 ? 7'b0010101 :
mantissa_s[22:16] == 7'b0101111 ? 7'b0010101 :
mantissa_s[22:16] == 7'b0110000 ? 7'b0010110 :
mantissa_s[22:16] == 7'b0110001 ? 7'b0010110 :
mantissa_s[22:16] == 7'b0110010 ? 7'b0010110 :
mantissa_s[22:16] == 7'b0110011 ? 7'b0010111 :
mantissa_s[22:16] == 7'b0110100 ? 7'b0010111 :
mantissa_s[22:16] == 7'b0110101 ? 7'b0011000 :
mantissa_s[22:16] == 7'b0110110 ? 7'b0011000 :
mantissa_s[22:16] == 7'b0110111 ? 7'b0011001 :
mantissa_s[22:16] == 7'b0111000 ? 7'b0011001 :
mantissa_s[22:16] == 7'b0111001 ? 7'b0011001 :
mantissa_s[22:16] == 7'b0111010 ? 7'b0011010 :
mantissa_s[22:16] == 7'b0111011 ? 7'b0011010 :
mantissa_s[22:16] == 7'b0111100 ? 7'b0011011 :
mantissa_s[22:16] == 7'b0111101 ? 7'b0011011 :
mantissa_s[22:16] == 7'b0111110 ? 7'b0011011 :
mantissa_s[22:16] == 7'b0111111 ? 7'b0011100 :
mantissa_s[22:16] == 7'b1000000 ? 7'b0011100 :
mantissa_s[22:16] == 7'b1000001 ? 7'b0011101 :
mantissa_s[22:16] == 7'b1000010 ? 7'b0011101 :
mantissa_s[22:16] == 7'b1000011 ? 7'b0011101 :
mantissa_s[22:16] == 7'b1000100 ? 7'b0011110 :
mantissa_s[22:16] == 7'b1000101 ? 7'b0011110 :
mantissa_s[22:16] == 7'b1000110 ? 7'b0011111 :
mantissa_s[22:16] == 7'b1000111 ? 7'b0011111 :
mantissa_s[22:16] == 7'b1001000 ? 7'b0100000 :
mantissa_s[22:16] == 7'b1001001 ? 7'b0100000 :
mantissa_s[22:16] == 7'b1001010 ? 7'b0100000 :
mantissa_s[22:16] == 7'b1001011 ? 7'b0100001 :
mantissa_s[22:16] == 7'b1001100 ? 7'b0100001 :
mantissa_s[22:16] == 7'b1001101 ? 7'b0100001 :
mantissa_s[22:16] == 7'b1001110 ? 7'b0100010 :
mantissa_s[22:16] == 7'b1001111 ? 7'b0100010 :
mantissa_s[22:16] == 7'b1010000 ? 7'b0100011 :
mantissa_s[22:16] == 7'b1010001 ? 7'b0100011 :
mantissa_s[22:16] == 7'b1010010 ? 7'b0100011 :
mantissa_s[22:16] == 7'b1010011 ? 7'b0100100 :
mantissa_s[22:16] == 7'b1010100 ? 7'b0100100 :
mantissa_s[22:16] == 7'b1010101 ? 7'b0100101 :
mantissa_s[22:16] == 7'b1010110 ? 7'b0100101 :
mantissa_s[22:16] == 7'b1010111 ? 7'b0100101 :
mantissa_s[22:16] == 7'b1011000 ? 7'b0100110 :
mantissa_s[22:16] == 7'b1011001 ? 7'b0100110 :
mantissa_s[22:16] == 7'b1011010 ? 7'b0100111 :
mantissa_s[22:16] == 7'b1011011 ? 7'b0100111 :
mantissa_s[22:16] == 7'b1011100 ? 7'b0100111 :
mantissa_s[22:16] == 7'b1011101 ? 7'b0101000 :
mantissa_s[22:16] == 7'b1011110 ? 7'b0101000 :
mantissa_s[22:16] == 7'b1011111 ? 7'b0101000 :
mantissa_s[22:16] == 7'b1100000 ? 7'b0101001 :
mantissa_s[22:16] == 7'b1100001 ? 7'b0101001 :
mantissa_s[22:16] == 7'b1100010 ? 7'b0101010 :
mantissa_s[22:16] == 7'b1100011 ? 7'b0101010 :
mantissa_s[22:16] == 7'b1100100 ? 7'b0101010 :
mantissa_s[22:16] == 7'b1100101 ? 7'b0101011 :
mantissa_s[22:16] == 7'b1100110 ? 7'b0101011 :
mantissa_s[22:16] == 7'b1100111 ? 7'b0101011 :
mantissa_s[22:16] == 7'b1101000 ? 7'b0101100 :
mantissa_s[22:16] == 7'b1101001 ? 7'b0101100 :
mantissa_s[22:16] == 7'b1101010 ? 7'b0101101 :
mantissa_s[22:16] == 7'b1101011 ? 7'b0101101 :
mantissa_s[22:16] == 7'b1101100 ? 7'b0101101 :
mantissa_s[22:16] == 7'b1101101 ? 7'b0101110 :
mantissa_s[22:16] == 7'b1101110 ? 7'b0101110 :
mantissa_s[22:16] == 7'b1101111 ? 7'b0101110 :
mantissa_s[22:16] == 7'b1110000 ? 7'b0101111 :
mantissa_s[22:16] == 7'b1110001 ? 7'b0101111 :
mantissa_s[22:16] == 7'b1110010 ? 7'b0110000 :
mantissa_s[22:16] == 7'b1110011 ? 7'b0110000 :
mantissa_s[22:16] == 7'b1110100 ? 7'b0110000 :
mantissa_s[22:16] == 7'b1110101 ? 7'b0110001 :
mantissa_s[22:16] == 7'b1110110 ? 7'b0110001 :
mantissa_s[22:16] == 7'b1110111 ? 7'b0110001 :
mantissa_s[22:16] == 7'b1111000 ? 7'b0110010 :
mantissa_s[22:16] == 7'b1111001 ? 7'b0110010 :
mantissa_s[22:16] == 7'b1111010 ? 7'b0110010 :
mantissa_s[22:16] == 7'b1111011 ? 7'b0110011 :
mantissa_s[22:16] == 7'b1111100 ? 7'b0110011 :
mantissa_s[22:16] == 7'b1111101 ? 7'b0110011 :
mantissa_s[22:16] == 7'b1111110 ? 7'b0110100 : 7'b0110100
);

// 出力する

assign d = {sign_d, exponent_d, mantissa_d}; 
assign overflow = 1'b0;
assign underflow = 1'b0;

endmodule