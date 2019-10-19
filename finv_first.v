module finv(
    input wire [31:0] s,
    output wire [31:0] d,
    output wire overflow,
    output wire underflow
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
wire [47:0] oms;
wire [47:0] x0, x1, x2, x3, x4, x5, x6;
wire [47:0] a0, a1, a2, a3, a4, a5, a6;
wire [47:0] b0, b1, b2, b3, b4, b5, b6;
wire [47:0] c0, c1, c2, c3, c4, c5, c6;


// FIXME: 1.mmmの形にしてあげる
assign oms = {24'b0, one_mantissa_s};
assign x0 = oms;
// step 1
assign a1 = x0 << 1;
assign b1 = s * x0;
assign c1 = b1[47:24] * x0;
assign x1 = a1 + c1;
// step 2
assign a2 = x1 << 1;
assign b2 = s * x1;
assign c2 = b2[47:24] * x1;
assign x2 = a2 + c2;
// step 3
assign a3 = x2 << 1;
assign b3 = s * x2;
assign c3 = b3[47:24] * x2;
assign x3 = a3 + c3;
// step 4
assign a4 = x3 << 1;
assign b4 = s * x3;
assign c4 = b4[47:24] * x3;
assign x4 = a4 + c4;
// step 5
assign a5 = x4 << 1;
assign b5 = s * x4;
assign c5 = b5[47:24] * x4;
assign x5 = a5 + c5;
// step 6
assign a6 = x5 << 2;
assign b6 = s * x5;
assign c6 = b6[47:24] * x5;
assign x6 = a6 + c6;

assign mantissa_d = x6[47:24];

// 出力する
assign d = {sign_d, exponent_d, mantissa_d}; 

// // TODO:
// // 50bit / 24bit の割り算を行って商を26bit(27bit)得る
// // 除数と被除数の大小比較で商の桁数がわかる
// // あとで26bit分補正をかける

// wire [49:0] one_mantissa_s_50bit, one_mantissa_d_50bit;
// wire [49:0] sticky_50bit;
// wire carry;

// assign one_mantissa_s_50bit = {one_mantissa_s, 26'b0};

// assign one_mantissa_d_50bit = one_mantissa_s_50bit / {26'b0, one_mantissa_t};
// assign sticky_50bit = one_mantissa_s_50bit % {26'b0, one_mantissa_t};
// assign carry = mantissa_s > mantissa_t;

// assign c = carry;

// // 正規化する
// wire [22:0] mantissa_d_23bit;
// assign mantissa_d_23bit[22:1] =
//     (carry == 1) ? one_mantissa_d_50bit[26:4] : one_mantissa_d_50bit[25:3];

// // 丸める
// wire ulp, guard, round, sticky;
// assign ulp = (carry == 1) ? one_mantissa_d_50bit[4:4] : one_mantissa_d_50bit[3:3];
// assign guard = (carry == 1) ? one_mantissa_d_50bit[3:3] : one_mantissa_d_50bit[2:2];
// assign round = (carry == 1) ? one_mantissa_d_50bit[2:2] : one_mantissa_d_50bit[1:1];
// assign sticky = (carry == 1) ? |(sticky_50bit) | (one_mantissa_d_50bit[0:0]): |(sticky_50bit); 
// assign mantissa_d_23bit[0:0] = guard | (ulp & round & sticky);

// // 指数と仮数を決定する

// assign overflow = 0; // ({1'b0, exponent_t} - {1'b0, exponent_s} > 9'b010000000);
// assign underflow = 0; // ({1'b0, exponent_s} - {1'b0, exponent_t} > 9'b010000000);

// assign exponent_d =
//     overflow ?
//         8'b11111111
//     : (underflow ?
//         8'b00000000
//     : (carry==1 ?
//         exponent_s - exponent_t - 8'b10000001
//     : exponent_s - exponent_t - 8'b10000010
//     ));

// assign mantissa_d =
//     overflow ?
//         23'b0
//     : (underflow ?
//         23'b0
//     : mantissa_d_23bit[22:0]
//     );

endmodule