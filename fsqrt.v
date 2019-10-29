module shift_with_round(
    input wire [47:0] s,
    input wire [7:0] shift,
    output wire [47:0] d
);

// NOTE: できるだけ誤差が少なくなるようにshiftする
wire [47:0] t;
assign t = s >> shift;

wire ulp, guard, round, sticky, flag;
wire [47:0] for_ulp, for_guard, for_round;
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

assign d = {t[47:1], flag};

endmodule


// NOTE: FSqrt
module fsqrt(
    input wire [31:0] s,
    output wire [31:0] d,
    output wire overflow,
    output wire underflow,
    output wire [6:0] up
    // output wire [7:0] be,
    // output wire [7:0] af,
    // output wire [47:0] a1,
    // output wire [47:0] b1,
    // output wire [47:0] c1,
    // output wire [47:0] a2,
    // output wire [47:0] b2,
    // output wire [47:0] c2
    // output wire [31:0] x1,
    // output wire [31:0] x2,
    // output wire [31:0] x3,
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
assign exponent_d = exponent_s >> 1;

// 仮数を決める
wire [6:0] upper7;
wire [15:0] lower16;
wire [47:0] x0, x1, x2;
wire [47:0] a1, a2, a3;
wire [47:0] b1, b2, b3;
wire [47:0] c1, c2, c3;
wire [47:0] d1, d2, d3;
wire [47:0] e1, e2, e3;

// DEBUG:
assign up = upper7;

// FIXME: Newton法を回す
wire [47:0] om;
assign om = {24'b0, one_mantissa_s};

assign x0 = {25'b1, mantissa_s[22:16], lower16};
assign a1 = x0 << 1;
assign b1 = (om * x0);
shift_with_round u11(b1,8'd23,c1);
assign d1 = (c1 * x0);
shift_with_round u12(d1,8'd24,e1);
assign x1 = a1 - e1;

assign a2 = x1 << 1;
assign b2 = (om * x1);
shift_with_round u21(b2,8'd23,c2);
assign d2 = (c2 * x1);
shift_with_round u22(d2,8'd24,e2);
assign x2 = a2 - e2;

// 仮数を決める
assign mantissa_d = x0[22:0];

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