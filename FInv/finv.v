// NOTE: stage1
module finv_stage1(
  input wire [31:0] s,
  output wire [63:0] target,
  output wire [63:0] a1,
  output wire [63:0] b1,
  output wire [63:0] x0
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

// 仮数を決める
wire [7:0] upper8;
wire [14:0] lower15;

assign target = {32'b0, one_mantissa_s, 8'b0};

// Newton法の初期値を決める
// 初期値の下位bitはとりあえず0で
assign lower15 = 15'b0;
// NOTE: 初期値の上位8桁を決める
assign upper8 =
mantissa_s[22:15] == 8'b00000000 ? 8'b11111111 :
mantissa_s[22:15] == 8'b00000001 ? 8'b11111110 :
mantissa_s[22:15] == 8'b00000010 ? 8'b11111100 :
mantissa_s[22:15] == 8'b00000011 ? 8'b11111010 :
mantissa_s[22:15] == 8'b00000100 ? 8'b11111000 :
mantissa_s[22:15] == 8'b00000101 ? 8'b11110110 :
mantissa_s[22:15] == 8'b00000110 ? 8'b11110100 :
mantissa_s[22:15] == 8'b00000111 ? 8'b11110010 :
mantissa_s[22:15] == 8'b00001000 ? 8'b11110000 :
mantissa_s[22:15] == 8'b00001001 ? 8'b11101110 :
mantissa_s[22:15] == 8'b00001010 ? 8'b11101100 :
mantissa_s[22:15] == 8'b00001011 ? 8'b11101010 :
mantissa_s[22:15] == 8'b00001100 ? 8'b11101001 :
mantissa_s[22:15] == 8'b00001101 ? 8'b11100111 :
mantissa_s[22:15] == 8'b00001110 ? 8'b11100101 :
mantissa_s[22:15] == 8'b00001111 ? 8'b11100011 :
mantissa_s[22:15] == 8'b00010000 ? 8'b11100001 :
mantissa_s[22:15] == 8'b00010001 ? 8'b11100000 :
mantissa_s[22:15] == 8'b00010010 ? 8'b11011110 :
mantissa_s[22:15] == 8'b00010011 ? 8'b11011100 :
mantissa_s[22:15] == 8'b00010100 ? 8'b11011010 :
mantissa_s[22:15] == 8'b00010101 ? 8'b11011001 :
mantissa_s[22:15] == 8'b00010110 ? 8'b11010111 :
mantissa_s[22:15] == 8'b00010111 ? 8'b11010101 :
mantissa_s[22:15] == 8'b00011000 ? 8'b11010100 :
mantissa_s[22:15] == 8'b00011001 ? 8'b11010010 :
mantissa_s[22:15] == 8'b00011010 ? 8'b11010000 :
mantissa_s[22:15] == 8'b00011011 ? 8'b11001111 :
mantissa_s[22:15] == 8'b00011100 ? 8'b11001101 :
mantissa_s[22:15] == 8'b00011101 ? 8'b11001011 :
mantissa_s[22:15] == 8'b00011110 ? 8'b11001010 :
mantissa_s[22:15] == 8'b00011111 ? 8'b11001000 :
mantissa_s[22:15] == 8'b00100000 ? 8'b11000111 :
mantissa_s[22:15] == 8'b00100001 ? 8'b11000101 :
mantissa_s[22:15] == 8'b00100010 ? 8'b11000011 :
mantissa_s[22:15] == 8'b00100011 ? 8'b11000010 :
mantissa_s[22:15] == 8'b00100100 ? 8'b11000000 :
mantissa_s[22:15] == 8'b00100101 ? 8'b10111111 :
mantissa_s[22:15] == 8'b00100110 ? 8'b10111101 :
mantissa_s[22:15] == 8'b00100111 ? 8'b10111100 :
mantissa_s[22:15] == 8'b00101000 ? 8'b10111010 :
mantissa_s[22:15] == 8'b00101001 ? 8'b10111001 :
mantissa_s[22:15] == 8'b00101010 ? 8'b10110111 :
mantissa_s[22:15] == 8'b00101011 ? 8'b10110110 :
mantissa_s[22:15] == 8'b00101100 ? 8'b10110100 :
mantissa_s[22:15] == 8'b00101101 ? 8'b10110011 :
mantissa_s[22:15] == 8'b00101110 ? 8'b10110010 :
mantissa_s[22:15] == 8'b00101111 ? 8'b10110000 :
mantissa_s[22:15] == 8'b00110000 ? 8'b10101111 :
mantissa_s[22:15] == 8'b00110001 ? 8'b10101101 :
mantissa_s[22:15] == 8'b00110010 ? 8'b10101100 :
mantissa_s[22:15] == 8'b00110011 ? 8'b10101010 :
mantissa_s[22:15] == 8'b00110100 ? 8'b10101001 :
mantissa_s[22:15] == 8'b00110101 ? 8'b10101000 :
mantissa_s[22:15] == 8'b00110110 ? 8'b10100110 :
mantissa_s[22:15] == 8'b00110111 ? 8'b10100101 :
mantissa_s[22:15] == 8'b00111000 ? 8'b10100100 :
mantissa_s[22:15] == 8'b00111001 ? 8'b10100010 :
mantissa_s[22:15] == 8'b00111010 ? 8'b10100001 :
mantissa_s[22:15] == 8'b00111011 ? 8'b10100000 :
mantissa_s[22:15] == 8'b00111100 ? 8'b10011110 :
mantissa_s[22:15] == 8'b00111101 ? 8'b10011101 :
mantissa_s[22:15] == 8'b00111110 ? 8'b10011100 :
mantissa_s[22:15] == 8'b00111111 ? 8'b10011010 :
mantissa_s[22:15] == 8'b01000000 ? 8'b10011001 :
mantissa_s[22:15] == 8'b01000001 ? 8'b10011000 :
mantissa_s[22:15] == 8'b01000010 ? 8'b10010111 :
mantissa_s[22:15] == 8'b01000011 ? 8'b10010101 :
mantissa_s[22:15] == 8'b01000100 ? 8'b10010100 :
mantissa_s[22:15] == 8'b01000101 ? 8'b10010011 :
mantissa_s[22:15] == 8'b01000110 ? 8'b10010010 :
mantissa_s[22:15] == 8'b01000111 ? 8'b10010000 :
mantissa_s[22:15] == 8'b01001000 ? 8'b10001111 :
mantissa_s[22:15] == 8'b01001001 ? 8'b10001110 :
mantissa_s[22:15] == 8'b01001010 ? 8'b10001101 :
mantissa_s[22:15] == 8'b01001011 ? 8'b10001011 :
mantissa_s[22:15] == 8'b01001100 ? 8'b10001010 :
mantissa_s[22:15] == 8'b01001101 ? 8'b10001001 :
mantissa_s[22:15] == 8'b01001110 ? 8'b10001000 :
mantissa_s[22:15] == 8'b01001111 ? 8'b10000111 :
mantissa_s[22:15] == 8'b01010000 ? 8'b10000110 :
mantissa_s[22:15] == 8'b01010001 ? 8'b10000100 :
mantissa_s[22:15] == 8'b01010010 ? 8'b10000011 :
mantissa_s[22:15] == 8'b01010011 ? 8'b10000010 :
mantissa_s[22:15] == 8'b01010100 ? 8'b10000001 :
mantissa_s[22:15] == 8'b01010101 ? 8'b10000000 :
mantissa_s[22:15] == 8'b01010110 ? 8'b01111111 :
mantissa_s[22:15] == 8'b01010111 ? 8'b01111110 :
mantissa_s[22:15] == 8'b01011000 ? 8'b01111101 :
mantissa_s[22:15] == 8'b01011001 ? 8'b01111011 :
mantissa_s[22:15] == 8'b01011010 ? 8'b01111010 :
mantissa_s[22:15] == 8'b01011011 ? 8'b01111001 :
mantissa_s[22:15] == 8'b01011100 ? 8'b01111000 :
mantissa_s[22:15] == 8'b01011101 ? 8'b01110111 :
mantissa_s[22:15] == 8'b01011110 ? 8'b01110110 :
mantissa_s[22:15] == 8'b01011111 ? 8'b01110101 :
mantissa_s[22:15] == 8'b01100000 ? 8'b01110100 :
mantissa_s[22:15] == 8'b01100001 ? 8'b01110011 :
mantissa_s[22:15] == 8'b01100010 ? 8'b01110010 :
mantissa_s[22:15] == 8'b01100011 ? 8'b01110001 :
mantissa_s[22:15] == 8'b01100100 ? 8'b01110000 :
mantissa_s[22:15] == 8'b01100101 ? 8'b01101111 :
mantissa_s[22:15] == 8'b01100110 ? 8'b01101110 :
mantissa_s[22:15] == 8'b01100111 ? 8'b01101101 :
mantissa_s[22:15] == 8'b01101000 ? 8'b01101100 :
mantissa_s[22:15] == 8'b01101001 ? 8'b01101011 :
mantissa_s[22:15] == 8'b01101010 ? 8'b01101010 :
mantissa_s[22:15] == 8'b01101011 ? 8'b01101001 :
mantissa_s[22:15] == 8'b01101100 ? 8'b01101000 :
mantissa_s[22:15] == 8'b01101101 ? 8'b01100111 :
mantissa_s[22:15] == 8'b01101110 ? 8'b01100110 :
mantissa_s[22:15] == 8'b01101111 ? 8'b01100101 :
mantissa_s[22:15] == 8'b01110000 ? 8'b01100100 :
mantissa_s[22:15] == 8'b01110001 ? 8'b01100011 :
mantissa_s[22:15] == 8'b01110010 ? 8'b01100010 :
mantissa_s[22:15] == 8'b01110011 ? 8'b01100001 :
mantissa_s[22:15] == 8'b01110100 ? 8'b01100000 :
mantissa_s[22:15] == 8'b01110101 ? 8'b01011111 :
mantissa_s[22:15] == 8'b01110110 ? 8'b01011110 :
mantissa_s[22:15] == 8'b01110111 ? 8'b01011101 :
mantissa_s[22:15] == 8'b01111000 ? 8'b01011100 :
mantissa_s[22:15] == 8'b01111001 ? 8'b01011011 :
mantissa_s[22:15] == 8'b01111010 ? 8'b01011010 :
mantissa_s[22:15] == 8'b01111011 ? 8'b01011001 :
mantissa_s[22:15] == 8'b01111100 ? 8'b01011000 :
mantissa_s[22:15] == 8'b01111101 ? 8'b01011000 :
mantissa_s[22:15] == 8'b01111110 ? 8'b01010111 :
mantissa_s[22:15] == 8'b01111111 ? 8'b01010110 :
mantissa_s[22:15] == 8'b10000000 ? 8'b01010101 :
mantissa_s[22:15] == 8'b10000001 ? 8'b01010100 :
mantissa_s[22:15] == 8'b10000010 ? 8'b01010011 :
mantissa_s[22:15] == 8'b10000011 ? 8'b01010010 :
mantissa_s[22:15] == 8'b10000100 ? 8'b01010001 :
mantissa_s[22:15] == 8'b10000101 ? 8'b01010000 :
mantissa_s[22:15] == 8'b10000110 ? 8'b01010000 :
mantissa_s[22:15] == 8'b10000111 ? 8'b01001111 :
mantissa_s[22:15] == 8'b10001000 ? 8'b01001110 :
mantissa_s[22:15] == 8'b10001001 ? 8'b01001101 :
mantissa_s[22:15] == 8'b10001010 ? 8'b01001100 :
mantissa_s[22:15] == 8'b10001011 ? 8'b01001011 :
mantissa_s[22:15] == 8'b10001100 ? 8'b01001010 :
mantissa_s[22:15] == 8'b10001101 ? 8'b01001010 :
mantissa_s[22:15] == 8'b10001110 ? 8'b01001001 :
mantissa_s[22:15] == 8'b10001111 ? 8'b01001000 :
mantissa_s[22:15] == 8'b10010000 ? 8'b01000111 :
mantissa_s[22:15] == 8'b10010001 ? 8'b01000110 :
mantissa_s[22:15] == 8'b10010010 ? 8'b01000110 :
mantissa_s[22:15] == 8'b10010011 ? 8'b01000101 :
mantissa_s[22:15] == 8'b10010100 ? 8'b01000100 :
mantissa_s[22:15] == 8'b10010101 ? 8'b01000011 :
mantissa_s[22:15] == 8'b10010110 ? 8'b01000010 :
mantissa_s[22:15] == 8'b10010111 ? 8'b01000010 :
mantissa_s[22:15] == 8'b10011000 ? 8'b01000001 :
mantissa_s[22:15] == 8'b10011001 ? 8'b01000000 :
mantissa_s[22:15] == 8'b10011010 ? 8'b00111111 :
mantissa_s[22:15] == 8'b10011011 ? 8'b00111110 :
mantissa_s[22:15] == 8'b10011100 ? 8'b00111110 :
mantissa_s[22:15] == 8'b10011101 ? 8'b00111101 :
mantissa_s[22:15] == 8'b10011110 ? 8'b00111100 :
mantissa_s[22:15] == 8'b10011111 ? 8'b00111011 :
mantissa_s[22:15] == 8'b10100000 ? 8'b00111011 :
mantissa_s[22:15] == 8'b10100001 ? 8'b00111010 :
mantissa_s[22:15] == 8'b10100010 ? 8'b00111001 :
mantissa_s[22:15] == 8'b10100011 ? 8'b00111000 :
mantissa_s[22:15] == 8'b10100100 ? 8'b00111000 :
mantissa_s[22:15] == 8'b10100101 ? 8'b00110111 :
mantissa_s[22:15] == 8'b10100110 ? 8'b00110110 :
mantissa_s[22:15] == 8'b10100111 ? 8'b00110101 :
mantissa_s[22:15] == 8'b10101000 ? 8'b00110101 :
mantissa_s[22:15] == 8'b10101001 ? 8'b00110100 :
mantissa_s[22:15] == 8'b10101010 ? 8'b00110011 :
mantissa_s[22:15] == 8'b10101011 ? 8'b00110010 :
mantissa_s[22:15] == 8'b10101100 ? 8'b00110010 :
mantissa_s[22:15] == 8'b10101101 ? 8'b00110001 :
mantissa_s[22:15] == 8'b10101110 ? 8'b00110000 :
mantissa_s[22:15] == 8'b10101111 ? 8'b00110000 :
mantissa_s[22:15] == 8'b10110000 ? 8'b00101111 :
mantissa_s[22:15] == 8'b10110001 ? 8'b00101110 :
mantissa_s[22:15] == 8'b10110010 ? 8'b00101110 :
mantissa_s[22:15] == 8'b10110011 ? 8'b00101101 :
mantissa_s[22:15] == 8'b10110100 ? 8'b00101100 :
mantissa_s[22:15] == 8'b10110101 ? 8'b00101011 :
mantissa_s[22:15] == 8'b10110110 ? 8'b00101011 :
mantissa_s[22:15] == 8'b10110111 ? 8'b00101010 :
mantissa_s[22:15] == 8'b10111000 ? 8'b00101001 :
mantissa_s[22:15] == 8'b10111001 ? 8'b00101001 :
mantissa_s[22:15] == 8'b10111010 ? 8'b00101000 :
mantissa_s[22:15] == 8'b10111011 ? 8'b00100111 :
mantissa_s[22:15] == 8'b10111100 ? 8'b00100111 :
mantissa_s[22:15] == 8'b10111101 ? 8'b00100110 :
mantissa_s[22:15] == 8'b10111110 ? 8'b00100101 :
mantissa_s[22:15] == 8'b10111111 ? 8'b00100101 :
mantissa_s[22:15] == 8'b11000000 ? 8'b00100100 :
mantissa_s[22:15] == 8'b11000001 ? 8'b00100011 :
mantissa_s[22:15] == 8'b11000010 ? 8'b00100011 :
mantissa_s[22:15] == 8'b11000011 ? 8'b00100010 :
mantissa_s[22:15] == 8'b11000100 ? 8'b00100001 :
mantissa_s[22:15] == 8'b11000101 ? 8'b00100001 :
mantissa_s[22:15] == 8'b11000110 ? 8'b00100000 :
mantissa_s[22:15] == 8'b11000111 ? 8'b00100000 :
mantissa_s[22:15] == 8'b11001000 ? 8'b00011111 :
mantissa_s[22:15] == 8'b11001001 ? 8'b00011110 :
mantissa_s[22:15] == 8'b11001010 ? 8'b00011110 :
mantissa_s[22:15] == 8'b11001011 ? 8'b00011101 :
mantissa_s[22:15] == 8'b11001100 ? 8'b00011100 :
mantissa_s[22:15] == 8'b11001101 ? 8'b00011100 :
mantissa_s[22:15] == 8'b11001110 ? 8'b00011011 :
mantissa_s[22:15] == 8'b11001111 ? 8'b00011011 :
mantissa_s[22:15] == 8'b11010000 ? 8'b00011010 :
mantissa_s[22:15] == 8'b11010001 ? 8'b00011001 :
mantissa_s[22:15] == 8'b11010010 ? 8'b00011001 :
mantissa_s[22:15] == 8'b11010011 ? 8'b00011000 :
mantissa_s[22:15] == 8'b11010100 ? 8'b00011000 :
mantissa_s[22:15] == 8'b11010101 ? 8'b00010111 :
mantissa_s[22:15] == 8'b11010110 ? 8'b00010110 :
mantissa_s[22:15] == 8'b11010111 ? 8'b00010110 :
mantissa_s[22:15] == 8'b11011000 ? 8'b00010101 :
mantissa_s[22:15] == 8'b11011001 ? 8'b00010101 :
mantissa_s[22:15] == 8'b11011010 ? 8'b00010100 :
mantissa_s[22:15] == 8'b11011011 ? 8'b00010011 :
mantissa_s[22:15] == 8'b11011100 ? 8'b00010011 :
mantissa_s[22:15] == 8'b11011101 ? 8'b00010010 :
mantissa_s[22:15] == 8'b11011110 ? 8'b00010010 :
mantissa_s[22:15] == 8'b11011111 ? 8'b00010001 :
mantissa_s[22:15] == 8'b11100000 ? 8'b00010001 :
mantissa_s[22:15] == 8'b11100001 ? 8'b00010000 :
mantissa_s[22:15] == 8'b11100010 ? 8'b00001111 :
mantissa_s[22:15] == 8'b11100011 ? 8'b00001111 :
mantissa_s[22:15] == 8'b11100100 ? 8'b00001110 :
mantissa_s[22:15] == 8'b11100101 ? 8'b00001110 :
mantissa_s[22:15] == 8'b11100110 ? 8'b00001101 :
mantissa_s[22:15] == 8'b11100111 ? 8'b00001101 :
mantissa_s[22:15] == 8'b11101000 ? 8'b00001100 :
mantissa_s[22:15] == 8'b11101001 ? 8'b00001100 :
mantissa_s[22:15] == 8'b11101010 ? 8'b00001011 :
mantissa_s[22:15] == 8'b11101011 ? 8'b00001010 :
mantissa_s[22:15] == 8'b11101100 ? 8'b00001010 :
mantissa_s[22:15] == 8'b11101101 ? 8'b00001001 :
mantissa_s[22:15] == 8'b11101110 ? 8'b00001001 :
mantissa_s[22:15] == 8'b11101111 ? 8'b00001000 :
mantissa_s[22:15] == 8'b11110000 ? 8'b00001000 :
mantissa_s[22:15] == 8'b11110001 ? 8'b00000111 :
mantissa_s[22:15] == 8'b11110010 ? 8'b00000111 :
mantissa_s[22:15] == 8'b11110011 ? 8'b00000110 :
mantissa_s[22:15] == 8'b11110100 ? 8'b00000110 :
mantissa_s[22:15] == 8'b11110101 ? 8'b00000101 :
mantissa_s[22:15] == 8'b11110110 ? 8'b00000101 :
mantissa_s[22:15] == 8'b11110111 ? 8'b00000100 :
mantissa_s[22:15] == 8'b11111000 ? 8'b00000100 :
mantissa_s[22:15] == 8'b11111001 ? 8'b00000011 :
mantissa_s[22:15] == 8'b11111010 ? 8'b00000011 :
mantissa_s[22:15] == 8'b11111011 ? 8'b00000010 :
mantissa_s[22:15] == 8'b11111100 ? 8'b00000010 :
mantissa_s[22:15] == 8'b11111101 ? 8'b00000001 :
mantissa_s[22:15] == 8'b11111110 ? 8'b00000001 : 00000000;

// Newton法を回す
// wire [63:0] x0;
assign x0 = {33'b1, upper8, lower15, 8'b0};
assign a1 = x0 << 8'd1;
assign b1 = (target * x0) >> 8'd31;

endmodule


// NOTE: stage2
module finv_stage2(
  input wire [63:0] x0,
  input wire [63:0] target,
  input wire [63:0] a1,
  input wire [63:0] b1,
  output wire [63:0] x1
);

wire [63:0] c1;
assign c1 = (b1 * x0) >> 8'd32;
assign x1 = a1 - c1;

endmodule


// NOTE: stage3
module finv_stage3(
  input wire [63:0] x1,
  input wire [63:0] target,
  output wire [63:0] a2,
  output wire [63:0] b2
);

// Newton法を回す
assign a2 = x1 << 8'd1;
assign b2 = (target * x1) >> 8'd31;

endmodule


// NOTE: stage4
module finv_stage4(
  input wire [31:0] s,
  input wire [63:0] x1,
  input wire [63:0] target,
  input wire [63:0] a2,
  input wire [63:0] b2,
  output wire [31:0] d
);

// 符号1bit、指数8bit、仮数23bitを読み出す
wire [0:0] sign_s, sign_d;
wire [7:0] exponent_s, exponent_d;
wire [22:0] mantissa_s, mantissa_d;

assign sign_s = s[31:31];
assign exponent_s = s[30:23];
assign mantissa_s = s[22:0];

wire [63:0] c2, x2;
assign c2 = (b2 * x1) >> 8'd32;
assign x2 = a2 - c2;

// 符号を決める
assign sign_d = sign_s;

// 指数を決める
assign exponent_d = 
    exponent_s == 8'd254 ? 8'd0 :
    mantissa_s == 23'd0 ? 8'd254 - exponent_s : 8'd253 - exponent_s;

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

assign mantissa_d =
    exponent_s == 8'd253 ? x2[31:9] :
    exponent_s == 8'd254 ? x2[32:10] : 
    mantissa_s == 8'd0 ? mantissa_s : x2[30:8] + {22'b0, flag};

// 出力する
wire overflow, underflow;
assign d = {sign_d, exponent_d, mantissa_d}; 
assign overflow = 1'b0;
assign underflow = 1'b0;

endmodule


// NOTE: FInv
module finv(
    input wire clk,
    input wire [31:0] s,
    output wire [31:0] d,
    output wire overflow,
    output wire underflow
);

wire [31:0] wire_s1, wire_s2, wire_s3, wire_s4;
wire [63:0] wire_target1, wire_target2, wire_target3, wire_target4;
wire [63:0] wire_a1, wire_a2, wire_a3, wire_a4;
wire [63:0] wire_b1, wire_b2, wire_b3, wire_b4;
wire [63:0] wire_c1, wire_c2, wire_c3, wire_c4;
wire [63:0] wire_x1, wire_x21, wire_x22, wire_x3, wire_x4;
reg [31:0] reg_s1, reg_s2, reg_s3, reg_s4;
reg [63:0] reg_target1, reg_target2, reg_target3, reg_target4;
reg [63:0] reg_a1, reg_a2, reg_a3, reg_a4;
reg [63:0] reg_b1, reg_b2, reg_b3, reg_b4;
reg [63:0] reg_c1, reg_c2, reg_c3, reg_c4;
reg [63:0] reg_x1, reg_x21, reg_x22, reg_x3, reg_x4;

/*
module finv_stage1(
  input wire [31:0] s,
  output wire [63:0] target,
  output reg [63:0] a1,
  output reg [63:0] b1,
  output reg [63:0] x0
);
module finv_stage2(
  input wire [63:0] x0,
  input wire [63:0] target,
  input wire [63:0] a1,
  input wire [63:0] b1,
  output reg [63:0] x1
);
module finv_stage3(
  input wire [63:0] x1,
  input wire [63:0] target,
  output reg [63:0] a2,
  output reg [63:0] b2
);
module finv_stage4(
  input wire [31:0] s,
  input wire [63:0] x1,
  input wire [63:0] target,
  input wire [63:0] a2,
  input wire [63:0] b2,
  output wire [31:0] d
);
*/

finv_stage1 u1(wire_s1,wire_target1,wire_a1,wire_b1,wire_x1);
finv_stage2 u2(wire_x21,wire_target2,wire_a2,wire_b2,wire_x22);
finv_stage3 u3(wire_x3,wire_target3,wire_a3,wire_b3);
finv_stage4 u4(wire_s4,wire_x4,wire_target4,wire_a4,wire_b4,d);

assign wire_s1 = s;
assign wire_s2 = reg_s2;
assign wire_s3 = reg_s3;
assign wire_s4 = reg_s4;
assign wire_target2 = reg_target2;
assign wire_target3 = reg_target3;
assign wire_target4 = reg_target4;
assign wire_a2 = reg_a2;
assign wire_a4 = reg_a4;
assign wire_b2 = reg_b2;
assign wire_b4 = reg_b4;
assign wire_x21 = reg_x21;
assign wire_x3 = reg_x3;
assign wire_x4 = reg_x4;

always @(posedge clk) begin
  reg_s4 <= wire_s3;
end
always @(posedge clk) begin
  reg_s3 <= wire_s2;
end
always @(posedge clk) begin
  reg_s2 <= wire_s1;
end
always @(posedge clk) begin
  reg_a2 <= wire_a1;
  reg_b2 <= wire_b1;
  reg_a4 <= wire_a3;
  reg_b4 <= wire_b3;
  reg_x21 <= wire_x1;
  reg_x3 <= wire_x22;
  reg_x4 <= wire_x22;
  reg_target2 <= wire_target1;
  reg_target3 <= wire_target1;
  reg_target4 <= wire_target1;
end

endmodule
