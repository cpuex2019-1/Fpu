module shift_with_round(
    input wire [63:0] s,
    input wire [7:0] shift,
    output wire [63:0] d,
    output wire ulp,
    output wire guard,
    output wire round,
    output wire sticky,
    output wire flag
);

wire [63:0] t;
assign t = s >> shift;

wire [63:0] tmp;
assign ulp = |(s & (1 << shift));
assign guard = |(s & (1 << (shift - 8'd1)));
assign round = |(s & (1 << (shift - 8'd2)));
assign tmp = (1 << (shift - 8'd2)) - 64'd1;
assign sticky = |(s & tmp);

assign flag = 
    (ulp && guard && (~round) && (~sticky)) ||
    (guard && (~round) && sticky) ||
    (guard && round);

assign d = t + {63'd0, flag};

endmodule

// NOTE: FInv(latter)
module finv_latter(
    input wire [31:0] s,
    input wire [63:0] x,
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
assign exponent_d = 
    exponent_s == 8'd254 ? 8'd0 :
    mantissa_s == 23'd0 ? 8'd254 - exponent_s : 8'd253 - exponent_s;

// 仮数を決める
wire [7:0] upper8;
wire [14:0] lower15;

// Newton法を回す(targetの値を近似する)
wire [63:0] target;
wire [63:0] x1, x2;
wire [63:0] a1, a2, b1, b2, c1, c2;
wire [63:0] d1, e1, d2, e2;
assign target = {32'b0, one_mantissa_s, 8'b0};

// 初期値を決める
assign x1 = x;

// wire ulp11, guard11, round11, sticky11, flag11;
// wire ulp12, guard12, round12, sticky12, flag12;
// wire ulp21, guard21, round21, sticky21, flag21;
// wire ulp22, guard22, round22, sticky22, flag22;

// NOTE: shift_with_roundを使ったほうが誤差が出にくい

assign a2 = x1 << 8'd1;
assign b2 = (target * x1);
// shift_with_round u21(b2, 8'd31, c2, ulp21, guard21, round21, sticky21, flag21);
assign c2 = b2 >> 8'd31;
assign d2 = (c2 * x1);
// shift_with_round u22(d2, 8'd32, e2, ulp22, guard22, round22, sticky22, flag22);
assign e2 = d2 >> 8'd32;
assign x2 = a2 - e2;

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

assign d = {sign_d, exponent_d, mantissa_d}; 
assign overflow = 1'b0;
assign underflow = 1'b0;

endmodule