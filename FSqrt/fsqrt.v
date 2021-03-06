// NOTE: stage1
module fsqrt_stage1(
    input wire [31:0] s,
    output wire [63:0] target,
    output wire [63:0] b1,
    output wire [63:0] c1,
    output wire [63:0] d1
);

// 符号1bit、指数8bit、仮数23bitを読み出す
wire [0:0] sign_s;
wire [7:0] exponent_s;
wire [22:0] mantissa_s;

assign sign_s = s[31:31];
assign exponent_s = s[30:23];
assign mantissa_s = s[22:0];

// 省略されている1を元に戻す
wire [23:0] one_mantissa_s;
assign one_mantissa_s = {1'b1, mantissa_s};

// Newton法で求めたい値を決める
assign target = 
  exponent_s[0:0] == 1'b0 ? {31'b0, one_mantissa_s, 9'b0} : {32'b0, one_mantissa_s, 8'b0};

// Newton法の初期値を設定する
wire [6:0] upper7;
wire [15:0] lower16;
// 初期値の下位bitはとりあえず0で
assign lower16 = 16'b0;
// NOTE: 初期値の上位7桁を決める
assign upper7 =
exponent_s[0:0] == 1'b1 ? (
mantissa_s[22:16] == 7'b0000000 ? 7'b1111111 :
mantissa_s[22:16] == 7'b0000001 ? 7'b1111111 :
mantissa_s[22:16] == 7'b0000010 ? 7'b1111111 :
mantissa_s[22:16] == 7'b0000011 ? 7'b1111110 :
mantissa_s[22:16] == 7'b0000100 ? 7'b1111110 :
mantissa_s[22:16] == 7'b0000101 ? 7'b1111101 :
mantissa_s[22:16] == 7'b0000110 ? 7'b1111101 :
mantissa_s[22:16] == 7'b0000111 ? 7'b1111100 :
mantissa_s[22:16] == 7'b0001000 ? 7'b1111100 :
mantissa_s[22:16] == 7'b0001001 ? 7'b1111011 :
mantissa_s[22:16] == 7'b0001010 ? 7'b1111011 :
mantissa_s[22:16] == 7'b0001011 ? 7'b1111010 :
mantissa_s[22:16] == 7'b0001100 ? 7'b1111010 :
mantissa_s[22:16] == 7'b0001101 ? 7'b1111001 :
mantissa_s[22:16] == 7'b0001110 ? 7'b1111001 :
mantissa_s[22:16] == 7'b0001111 ? 7'b1111001 :
mantissa_s[22:16] == 7'b0010000 ? 7'b1111000 :
mantissa_s[22:16] == 7'b0010001 ? 7'b1111000 :
mantissa_s[22:16] == 7'b0010010 ? 7'b1110111 :
mantissa_s[22:16] == 7'b0010011 ? 7'b1110111 :
mantissa_s[22:16] == 7'b0010100 ? 7'b1110111 :
mantissa_s[22:16] == 7'b0010101 ? 7'b1110110 :
mantissa_s[22:16] == 7'b0010110 ? 7'b1110110 :
mantissa_s[22:16] == 7'b0010111 ? 7'b1110101 :
mantissa_s[22:16] == 7'b0011000 ? 7'b1110101 :
mantissa_s[22:16] == 7'b0011001 ? 7'b1110101 :
mantissa_s[22:16] == 7'b0011010 ? 7'b1110100 :
mantissa_s[22:16] == 7'b0011011 ? 7'b1110100 :
mantissa_s[22:16] == 7'b0011100 ? 7'b1110011 :
mantissa_s[22:16] == 7'b0011101 ? 7'b1110011 :
mantissa_s[22:16] == 7'b0011110 ? 7'b1110011 :
mantissa_s[22:16] == 7'b0011111 ? 7'b1110010 :
mantissa_s[22:16] == 7'b0100000 ? 7'b1110010 :
mantissa_s[22:16] == 7'b0100001 ? 7'b1110010 :
mantissa_s[22:16] == 7'b0100010 ? 7'b1110001 :
mantissa_s[22:16] == 7'b0100011 ? 7'b1110001 :
mantissa_s[22:16] == 7'b0100100 ? 7'b1110001 :
mantissa_s[22:16] == 7'b0100101 ? 7'b1110000 :
mantissa_s[22:16] == 7'b0100110 ? 7'b1110000 :
mantissa_s[22:16] == 7'b0100111 ? 7'b1110000 :
mantissa_s[22:16] == 7'b0101000 ? 7'b1101111 :
mantissa_s[22:16] == 7'b0101001 ? 7'b1101111 :
mantissa_s[22:16] == 7'b0101010 ? 7'b1101111 :
mantissa_s[22:16] == 7'b0101011 ? 7'b1101110 :
mantissa_s[22:16] == 7'b0101100 ? 7'b1101110 :
mantissa_s[22:16] == 7'b0101101 ? 7'b1101110 :
mantissa_s[22:16] == 7'b0101110 ? 7'b1101101 :
mantissa_s[22:16] == 7'b0101111 ? 7'b1101101 :
mantissa_s[22:16] == 7'b0110000 ? 7'b1101101 :
mantissa_s[22:16] == 7'b0110001 ? 7'b1101100 :
mantissa_s[22:16] == 7'b0110010 ? 7'b1101100 :
mantissa_s[22:16] == 7'b0110011 ? 7'b1101100 :
mantissa_s[22:16] == 7'b0110100 ? 7'b1101011 :
mantissa_s[22:16] == 7'b0110101 ? 7'b1101011 :
mantissa_s[22:16] == 7'b0110110 ? 7'b1101011 :
mantissa_s[22:16] == 7'b0110111 ? 7'b1101011 :
mantissa_s[22:16] == 7'b0111000 ? 7'b1101010 :
mantissa_s[22:16] == 7'b0111001 ? 7'b1101010 :
mantissa_s[22:16] == 7'b0111010 ? 7'b1101010 :
mantissa_s[22:16] == 7'b0111011 ? 7'b1101001 :
mantissa_s[22:16] == 7'b0111100 ? 7'b1101001 :
mantissa_s[22:16] == 7'b0111101 ? 7'b1101001 :
mantissa_s[22:16] == 7'b0111110 ? 7'b1101001 :
mantissa_s[22:16] == 7'b0111111 ? 7'b1101000 :
mantissa_s[22:16] == 7'b1000000 ? 7'b1101000 :
mantissa_s[22:16] == 7'b1000001 ? 7'b1101000 :
mantissa_s[22:16] == 7'b1000010 ? 7'b1100111 :
mantissa_s[22:16] == 7'b1000011 ? 7'b1100111 :
mantissa_s[22:16] == 7'b1000100 ? 7'b1100111 :
mantissa_s[22:16] == 7'b1000101 ? 7'b1100111 :
mantissa_s[22:16] == 7'b1000110 ? 7'b1100110 :
mantissa_s[22:16] == 7'b1000111 ? 7'b1100110 :
mantissa_s[22:16] == 7'b1001000 ? 7'b1100110 :
mantissa_s[22:16] == 7'b1001001 ? 7'b1100110 :
mantissa_s[22:16] == 7'b1001010 ? 7'b1100101 :
mantissa_s[22:16] == 7'b1001011 ? 7'b1100101 :
mantissa_s[22:16] == 7'b1001100 ? 7'b1100101 :
mantissa_s[22:16] == 7'b1001101 ? 7'b1100101 :
mantissa_s[22:16] == 7'b1001110 ? 7'b1100100 :
mantissa_s[22:16] == 7'b1001111 ? 7'b1100100 :
mantissa_s[22:16] == 7'b1010000 ? 7'b1100100 :
mantissa_s[22:16] == 7'b1010001 ? 7'b1100100 :
mantissa_s[22:16] == 7'b1010010 ? 7'b1100011 :
mantissa_s[22:16] == 7'b1010011 ? 7'b1100011 :
mantissa_s[22:16] == 7'b1010100 ? 7'b1100011 :
mantissa_s[22:16] == 7'b1010101 ? 7'b1100011 :
mantissa_s[22:16] == 7'b1010110 ? 7'b1100010 :
mantissa_s[22:16] == 7'b1010111 ? 7'b1100010 :
mantissa_s[22:16] == 7'b1011000 ? 7'b1100010 :
mantissa_s[22:16] == 7'b1011001 ? 7'b1100010 :
mantissa_s[22:16] == 7'b1011010 ? 7'b1100010 :
mantissa_s[22:16] == 7'b1011011 ? 7'b1100001 :
mantissa_s[22:16] == 7'b1011100 ? 7'b1100001 :
mantissa_s[22:16] == 7'b1011101 ? 7'b1100001 :
mantissa_s[22:16] == 7'b1011110 ? 7'b1100001 :
mantissa_s[22:16] == 7'b1011111 ? 7'b1100000 :
mantissa_s[22:16] == 7'b1100000 ? 7'b1100000 :
mantissa_s[22:16] == 7'b1100001 ? 7'b1100000 :
mantissa_s[22:16] == 7'b1100010 ? 7'b1100000 :
mantissa_s[22:16] == 7'b1100011 ? 7'b1100000 :
mantissa_s[22:16] == 7'b1100100 ? 7'b1011111 :
mantissa_s[22:16] == 7'b1100101 ? 7'b1011111 :
mantissa_s[22:16] == 7'b1100110 ? 7'b1011111 :
mantissa_s[22:16] == 7'b1100111 ? 7'b1011111 :
mantissa_s[22:16] == 7'b1101000 ? 7'b1011111 :
mantissa_s[22:16] == 7'b1101001 ? 7'b1011110 :
mantissa_s[22:16] == 7'b1101010 ? 7'b1011110 :
mantissa_s[22:16] == 7'b1101011 ? 7'b1011110 :
mantissa_s[22:16] == 7'b1101100 ? 7'b1011110 :
mantissa_s[22:16] == 7'b1101101 ? 7'b1011110 :
mantissa_s[22:16] == 7'b1101110 ? 7'b1011101 :
mantissa_s[22:16] == 7'b1101111 ? 7'b1011101 :
mantissa_s[22:16] == 7'b1110000 ? 7'b1011101 :
mantissa_s[22:16] == 7'b1110001 ? 7'b1011101 :
mantissa_s[22:16] == 7'b1110010 ? 7'b1011101 :
mantissa_s[22:16] == 7'b1110011 ? 7'b1011100 :
mantissa_s[22:16] == 7'b1110100 ? 7'b1011100 :
mantissa_s[22:16] == 7'b1110101 ? 7'b1011100 :
mantissa_s[22:16] == 7'b1110110 ? 7'b1011100 :
mantissa_s[22:16] == 7'b1110111 ? 7'b1011100 :
mantissa_s[22:16] == 7'b1111000 ? 7'b1011011 :
mantissa_s[22:16] == 7'b1111001 ? 7'b1011011 :
mantissa_s[22:16] == 7'b1111010 ? 7'b1011011 :
mantissa_s[22:16] == 7'b1111011 ? 7'b1011011 :
mantissa_s[22:16] == 7'b1111100 ? 7'b1011011 :
mantissa_s[22:16] == 7'b1111101 ? 7'b1011011 :
mantissa_s[22:16] == 7'b1111110 ? 7'b1011010 : 7'b1011010
) : (
mantissa_s[22:16] == 7'b0000000 ? 7'b1011010 :
mantissa_s[22:16] == 7'b0000001 ? 7'b1011010 :
mantissa_s[22:16] == 7'b0000010 ? 7'b1011001 :
mantissa_s[22:16] == 7'b0000011 ? 7'b1011001 :
mantissa_s[22:16] == 7'b0000100 ? 7'b1011001 :
mantissa_s[22:16] == 7'b0000101 ? 7'b1011000 :
mantissa_s[22:16] == 7'b0000110 ? 7'b1011000 :
mantissa_s[22:16] == 7'b0000111 ? 7'b1011000 :
mantissa_s[22:16] == 7'b0001000 ? 7'b1010111 :
mantissa_s[22:16] == 7'b0001001 ? 7'b1010111 :
mantissa_s[22:16] == 7'b0001010 ? 7'b1010111 :
mantissa_s[22:16] == 7'b0001011 ? 7'b1010110 :
mantissa_s[22:16] == 7'b0001100 ? 7'b1010110 :
mantissa_s[22:16] == 7'b0001101 ? 7'b1010110 :
mantissa_s[22:16] == 7'b0001110 ? 7'b1010101 :
mantissa_s[22:16] == 7'b0001111 ? 7'b1010101 :
mantissa_s[22:16] == 7'b0010000 ? 7'b1010101 :
mantissa_s[22:16] == 7'b0010001 ? 7'b1010101 :
mantissa_s[22:16] == 7'b0010010 ? 7'b1010100 :
mantissa_s[22:16] == 7'b0010011 ? 7'b1010100 :
mantissa_s[22:16] == 7'b0010100 ? 7'b1010100 :
mantissa_s[22:16] == 7'b0010101 ? 7'b1010011 :
mantissa_s[22:16] == 7'b0010110 ? 7'b1010011 :
mantissa_s[22:16] == 7'b0010111 ? 7'b1010011 :
mantissa_s[22:16] == 7'b0011000 ? 7'b1010011 :
mantissa_s[22:16] == 7'b0011001 ? 7'b1010010 :
mantissa_s[22:16] == 7'b0011010 ? 7'b1010010 :
mantissa_s[22:16] == 7'b0011011 ? 7'b1010010 :
mantissa_s[22:16] == 7'b0011100 ? 7'b1010001 :
mantissa_s[22:16] == 7'b0011101 ? 7'b1010001 :
mantissa_s[22:16] == 7'b0011110 ? 7'b1010001 :
mantissa_s[22:16] == 7'b0011111 ? 7'b1010001 :
mantissa_s[22:16] == 7'b0100000 ? 7'b1010000 :
mantissa_s[22:16] == 7'b0100001 ? 7'b1010000 :
mantissa_s[22:16] == 7'b0100010 ? 7'b1010000 :
mantissa_s[22:16] == 7'b0100011 ? 7'b1010000 :
mantissa_s[22:16] == 7'b0100100 ? 7'b1001111 :
mantissa_s[22:16] == 7'b0100101 ? 7'b1001111 :
mantissa_s[22:16] == 7'b0100110 ? 7'b1001111 :
mantissa_s[22:16] == 7'b0100111 ? 7'b1001111 :
mantissa_s[22:16] == 7'b0101000 ? 7'b1001111 :
mantissa_s[22:16] == 7'b0101001 ? 7'b1001110 :
mantissa_s[22:16] == 7'b0101010 ? 7'b1001110 :
mantissa_s[22:16] == 7'b0101011 ? 7'b1001110 :
mantissa_s[22:16] == 7'b0101100 ? 7'b1001110 :
mantissa_s[22:16] == 7'b0101101 ? 7'b1001101 :
mantissa_s[22:16] == 7'b0101110 ? 7'b1001101 :
mantissa_s[22:16] == 7'b0101111 ? 7'b1001101 :
mantissa_s[22:16] == 7'b0110000 ? 7'b1001101 :
mantissa_s[22:16] == 7'b0110001 ? 7'b1001100 :
mantissa_s[22:16] == 7'b0110010 ? 7'b1001100 :
mantissa_s[22:16] == 7'b0110011 ? 7'b1001100 :
mantissa_s[22:16] == 7'b0110100 ? 7'b1001100 :
mantissa_s[22:16] == 7'b0110101 ? 7'b1001100 :
mantissa_s[22:16] == 7'b0110110 ? 7'b1001011 :
mantissa_s[22:16] == 7'b0110111 ? 7'b1001011 :
mantissa_s[22:16] == 7'b0111000 ? 7'b1001011 :
mantissa_s[22:16] == 7'b0111001 ? 7'b1001011 :
mantissa_s[22:16] == 7'b0111010 ? 7'b1001011 :
mantissa_s[22:16] == 7'b0111011 ? 7'b1001010 :
mantissa_s[22:16] == 7'b0111100 ? 7'b1001010 :
mantissa_s[22:16] == 7'b0111101 ? 7'b1001010 :
mantissa_s[22:16] == 7'b0111110 ? 7'b1001010 :
mantissa_s[22:16] == 7'b0111111 ? 7'b1001010 :
mantissa_s[22:16] == 7'b1000000 ? 7'b1001001 :
mantissa_s[22:16] == 7'b1000001 ? 7'b1001001 :
mantissa_s[22:16] == 7'b1000010 ? 7'b1001001 :
mantissa_s[22:16] == 7'b1000011 ? 7'b1001001 :
mantissa_s[22:16] == 7'b1000100 ? 7'b1001001 :
mantissa_s[22:16] == 7'b1000101 ? 7'b1001000 :
mantissa_s[22:16] == 7'b1000110 ? 7'b1001000 :
mantissa_s[22:16] == 7'b1000111 ? 7'b1001000 :
mantissa_s[22:16] == 7'b1001000 ? 7'b1001000 :
mantissa_s[22:16] == 7'b1001001 ? 7'b1001000 :
mantissa_s[22:16] == 7'b1001010 ? 7'b1001000 :
mantissa_s[22:16] == 7'b1001011 ? 7'b1000111 :
mantissa_s[22:16] == 7'b1001100 ? 7'b1000111 :
mantissa_s[22:16] == 7'b1001101 ? 7'b1000111 :
mantissa_s[22:16] == 7'b1001110 ? 7'b1000111 :
mantissa_s[22:16] == 7'b1001111 ? 7'b1000111 :
mantissa_s[22:16] == 7'b1010000 ? 7'b1000111 :
mantissa_s[22:16] == 7'b1010001 ? 7'b1000110 :
mantissa_s[22:16] == 7'b1010010 ? 7'b1000110 :
mantissa_s[22:16] == 7'b1010011 ? 7'b1000110 :
mantissa_s[22:16] == 7'b1010100 ? 7'b1000110 :
mantissa_s[22:16] == 7'b1010101 ? 7'b1000110 :
mantissa_s[22:16] == 7'b1010110 ? 7'b1000101 :
mantissa_s[22:16] == 7'b1010111 ? 7'b1000101 :
mantissa_s[22:16] == 7'b1011000 ? 7'b1000101 :
mantissa_s[22:16] == 7'b1011001 ? 7'b1000101 :
mantissa_s[22:16] == 7'b1011010 ? 7'b1000101 :
mantissa_s[22:16] == 7'b1011011 ? 7'b1000101 :
mantissa_s[22:16] == 7'b1011100 ? 7'b1000101 :
mantissa_s[22:16] == 7'b1011101 ? 7'b1000100 :
mantissa_s[22:16] == 7'b1011110 ? 7'b1000100 :
mantissa_s[22:16] == 7'b1011111 ? 7'b1000100 :
mantissa_s[22:16] == 7'b1100000 ? 7'b1000100 :
mantissa_s[22:16] == 7'b1100001 ? 7'b1000100 :
mantissa_s[22:16] == 7'b1100010 ? 7'b1000100 :
mantissa_s[22:16] == 7'b1100011 ? 7'b1000011 :
mantissa_s[22:16] == 7'b1100100 ? 7'b1000011 :
mantissa_s[22:16] == 7'b1100101 ? 7'b1000011 :
mantissa_s[22:16] == 7'b1100110 ? 7'b1000011 :
mantissa_s[22:16] == 7'b1100111 ? 7'b1000011 :
mantissa_s[22:16] == 7'b1101000 ? 7'b1000011 :
mantissa_s[22:16] == 7'b1101001 ? 7'b1000011 :
mantissa_s[22:16] == 7'b1101010 ? 7'b1000010 :
mantissa_s[22:16] == 7'b1101011 ? 7'b1000010 :
mantissa_s[22:16] == 7'b1101100 ? 7'b1000010 :
mantissa_s[22:16] == 7'b1101101 ? 7'b1000010 :
mantissa_s[22:16] == 7'b1101110 ? 7'b1000010 :
mantissa_s[22:16] == 7'b1101111 ? 7'b1000010 :
mantissa_s[22:16] == 7'b1110000 ? 7'b1000010 :
mantissa_s[22:16] == 7'b1110001 ? 7'b1000001 :
mantissa_s[22:16] == 7'b1110010 ? 7'b1000001 :
mantissa_s[22:16] == 7'b1110011 ? 7'b1000001 :
mantissa_s[22:16] == 7'b1110100 ? 7'b1000001 :
mantissa_s[22:16] == 7'b1110101 ? 7'b1000001 :
mantissa_s[22:16] == 7'b1110110 ? 7'b1000001 :
mantissa_s[22:16] == 7'b1110111 ? 7'b1000001 :
mantissa_s[22:16] == 7'b1111000 ? 7'b1000001 :
mantissa_s[22:16] == 7'b1111001 ? 7'b1000000 :
mantissa_s[22:16] == 7'b1111010 ? 7'b1000000 :
mantissa_s[22:16] == 7'b1111011 ? 7'b1000000 :
mantissa_s[22:16] == 7'b1111100 ? 7'b1000000 :
mantissa_s[22:16] == 7'b1111101 ? 7'b1000000 :
mantissa_s[22:16] == 7'b1111110 ? 7'b1000000 : 7'b1000000
);

// NOTE: Newton法を回す x_{n+1} = 1/2 (3 x_n + a / x_n)
wire [63:0] x0, a1;
assign x0 = {33'b0, upper7, lower16, 8'b0};
assign a1 = x0 >> 8'd1; // a = x/2
assign b1 = a1 + x0; // b = 3x/2
assign c1 = (target * x0) >> 8'd31; // c = ax
assign d1 = (x0 * x0) >> 8'd31; // d = x^2/2

endmodule


// NOTE: stage2
module fsqrt_stage2(
    input wire [63:0] c1,
    input wire [63:0] d1,
    output wire [63:0] e1
);

assign e1 = (c1 * d1) >> 8'd32; // e = ax^3/2

endmodule

// NOTE: stage3
module fsqrt_stage3(
    input wire [63:0] b1,
    input wire [63:0] e1,
    output wire [63:0] x1
);

assign x1 = b1 - e1;   // x' = (3x-ax^3)/2

endmodule


// NOTE: stage4
module fsqrt_stage4(
    input wire [63:0] target,
    input wire [63:0] x1,
    output wire [63:0] b2,
    output wire [63:0] c2,
    output wire [63:0] d2
);

// NOTE: Newton法を回す x_{n+1} = 1/2 (3 x_n + a / x_n)
wire [63:0] a2;
assign a2 = x1 >> 8'd1; // a = x/2
assign b2 = a2 + x1; // b = 3x/2
assign c2 = (target * x1) >> 8'd31; // c = ax
assign d2 = (x1 * x1) >> 8'd31; // d = x^2/2

endmodule


// NOTE: stage5
module fsqrt_stage5(
    input wire [63:0] c2,
    input wire [63:0] d2,
    output wire [63:0] e2
);

assign e2 = (c2 * d2) >> 8'd32; // e = ax^3/2

endmodule


// NOTE: stage6
module fsqrt_stage6(
    input wire [63:0] b2,
    input wire [63:0] e2,
    output wire [63:0] x2
);

assign x2 = b2 - e2;   // x' = (3x-ax^3)/2

endmodule

// NOTE: stage7
module fsqrt_stage7(
    input wire [31:0] s,
    input wire [63:0] target,
    input wire [63:0] x2,
    output wire [31:0] d
);

// 符号1bit、指数8bit、仮数23bitを読み出す
wire [0:0] sign_s, sign_d;
wire [7:0] exponent_s, exponent_d;
wire [22:0] mantissa_s, mantissa_d;

assign sign_s = s[31:31];
assign exponent_s = s[30:23];
assign mantissa_s = s[22:0];

wire [63:0] y2;
assign y2 = (x2 * target) >> 8'd31;

// 符号を決める
assign sign_d = 1'b0;

// 指数を決める
wire [8:0] tmp1, tmp2, tmp3;
assign tmp1 = {1'b0, exponent_s} - 9'd127;
assign tmp2 = tmp1 >> 1'b1;
assign tmp3 = tmp2 + 9'd127;
assign exponent_d = tmp3[7:0];

// 仮数を決める
wire ulp, guard, round, sticky, flag;
assign ulp = y2[8:8];
assign guard = y2[7:7];
assign round = y2[6:6];
assign sticky = |(y2[5:0]);
assign flag = 
    (ulp && guard && (~round) && (~sticky)) ||
    (guard && (~round) && sticky) ||
    (guard && round);
assign mantissa_d = y2[30:8] + {22'b0, flag};

// 出力する
assign d = 
  sign_s == 1'b0 ? {sign_d, exponent_d, mantissa_d}
  : {1'b0, 8'd0, 23'd0};

endmodule


// NOTE: fsqrt
module fsqrt(
  input wire clk,
  input wire [31:0] s,
  output wire [31:0] d
);

wire [31:0] wire_s1, wire_s2, wire_s3, wire_s4, wire_s5, wire_s6, wire_s7;
wire [63:0] wire_target1, wire_target2, wire_target3, wire_target4, wire_target5, wire_target6, wire_target7;
wire [63:0] wire_b1, wire_b2, wire_b3, wire_b4, wire_b5, wire_b6;
wire [63:0] wire_c1, wire_c2, wire_c4, wire_c5;
wire [63:0] wire_d1, wire_d2, wire_d4, wire_d5;
wire [63:0] wire_e2, wire_e3, wire_e5, wire_e6;
wire [63:0] wire_x3, wire_x4, wire_x5, wire_x6, wire_x7;
reg [31:0] reg_s1, reg_s2, reg_s3, reg_s4, reg_s5, reg_s6, reg_s7;
reg [63:0] reg_target1, reg_target2, reg_target3, reg_target4, reg_target5, reg_target6, reg_target7;
reg [63:0] reg_b1, reg_b2, reg_b3, reg_b4, reg_b5, reg_b6;
reg [63:0] reg_c2, reg_c5;
reg [63:0] reg_d2, reg_d5;
reg [63:0] reg_e2, reg_e3, reg_e5, reg_e6;
reg [63:0] reg_x4, reg_x5, reg_x7;

/*
NOTE: Signature
module fsqrt_stage1(
    input wire [31:0] s,
    output wire [63:0] target,
    output reg [63:0] b1,
    output reg [63:0] c1,
    output reg [63:0] d1
);
module fsqrt_stage2(
    input wire [63:0] c1,
    input wire [63:0] d1,
    output wire [63:0] e1
);

module fsqrt_stage3(
    input wire [63:0] b1,
    input wire [63:0] e1,
    output wire [63:0] x1
);

module fsqrt_stage4(
    input wire [63:0] target,
    input wire [63:0] x1,
    output wire [63:0] b2,
    output wire [63:0] c2,
    output wire [63:0] d2
);

module fsqrt_stage5(
    input wire [63:0] c2,
    input wire [63:0] d2,
    output wire [63:0] e2
);

module fsqrt_stage6(
    input wire [63:0] b2,
    input wire [63:0] e2,
    output wire [63:0] x2
);

module fsqrt_stage7(
    input wire [31:0] s,
    input wire [63:0] target,
    input wire [63:0] x2,
    output wire [31:0] d
);
*/


fsqrt_stage1 u1(wire_s1,wire_target1,wire_b1,wire_c1,wire_d1);
fsqrt_stage2 u2(wire_c2,wire_d2,wire_e2);
fsqrt_stage3 u3(wire_b3,wire_e3,wire_x3);
fsqrt_stage4 u4(wire_target4,wire_x4,wire_b4,wire_c4,wire_d4);
fsqrt_stage5 u5(wire_c5,wire_d5,wire_e5);
fsqrt_stage6 u6(wire_b6,wire_e6,wire_x6);
fsqrt_stage7 u7(wire_s7,wire_target7,wire_x7,d);

assign wire_s1 = s;
assign wire_s2 = reg_s2;
assign wire_s3 = reg_s3;
assign wire_s4 = reg_s4;
assign wire_s5 = reg_s5;
assign wire_s6 = reg_s6;
assign wire_s7 = reg_s7;
assign wire_target2 = reg_target2;
assign wire_target3 = reg_target3;
assign wire_target4 = reg_target4;
assign wire_target5 = reg_target5;
assign wire_target6 = reg_target6;
assign wire_target7 = reg_target7;
assign wire_b2 = reg_b2;
assign wire_b3 = reg_b3;
assign wire_b5 = reg_b5;
assign wire_b6 = reg_b6;
assign wire_c2 = reg_c2;
assign wire_c5 = reg_c5;
assign wire_d2 = reg_d2;
assign wire_d5 = reg_d5;
assign wire_e3 = reg_e3;
assign wire_e6 = reg_e6;
assign wire_x4 = reg_x4;
assign wire_x5 = reg_x5;
assign wire_x7 = reg_x7;

always @(posedge clk) begin
  reg_s2 <= wire_s1;
  reg_s3 <= wire_s2;
  reg_s4 <= wire_s3;
  reg_s5 <= wire_s4;
  reg_s6 <= wire_s5;
  reg_s7 <= wire_s6;
  reg_target2 <= wire_target1;
  reg_target3 <= wire_target2;
  reg_target4 <= wire_target3;
  reg_target5 <= wire_target4;
  reg_target6 <= wire_target5;
  reg_target7 <= wire_target6;
  reg_b2 <= wire_b1;
  reg_b3 <= wire_b2;
  reg_b5 <= wire_b4;
  reg_b6 <= wire_b5;
  reg_c2 <= wire_c1;
  reg_c5 <= wire_c4;
  reg_d2 <= wire_d1;
  reg_d5 <= wire_d4;
  reg_e3 <= wire_e2;
  reg_e6 <= wire_e5;
  reg_x4 <= wire_x3;
  reg_x5 <= wire_x4;
  reg_x7 <= wire_x6;
end

endmodule