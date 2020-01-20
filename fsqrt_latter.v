module fsqrt_latter(
    input wire [31:0] s,
    input wire [63:0] x,
    output wire [31:0] d
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
wire [6:0] upper7;
wire [15:0] lower16;
wire [63:0] x0, x1, x2;
wire [63:0] a1, a2;
wire [63:0] b1, b2;
wire [63:0] c1, c2;
wire [63:0] d1, d2;
wire [63:0] e1, e2;

// FIXME: Newton法を回す x_{n+1} = 1/2 (3 x_n + a / x_n)
wire [63:0] om;
assign om = 
  exponent_s[0:0] == 1'b0 ? {31'b0, one_mantissa_s, 9'b0} : {32'b0, one_mantissa_s, 8'b0};

assign x1 = x;

assign a2 = x1 >> 8'd1; // a = x/2
assign b2 = a2 + x1; // b = 3x/2
assign c2 = (om * x1) >> 8'd31; // c = ax
assign d2 = (x1 * x1) >> 8'd31; // d = x^2/2
assign e2 = (c2 * d2) >> 8'd32; // e = ax^3/2
assign x2 = b2 - e2;   // x' = (3x-ax^3)/2

wire [63:0] y0,y1,y2;
assign y0 = (x0 * om) >> 8'd31;
assign y1 = (x1 * om) >> 8'd31;
assign y2 = (x2 * om) >> 8'd31;

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
  sign_s == 1'b0 ?
    {sign_d, exponent_d, mantissa_d}
  : {1'b0, 8'd255, 23'b1};

endmodule