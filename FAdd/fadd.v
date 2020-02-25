module fadd_stage1(
  input wire [31:0] s,
  input wire [31:0] t,
  output wire [31:0] g,
  output wire [31:0] l,
  output wire [26:0] one_mantissa_d_27bit,
  output wire for_sticky
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

// sとtでどちらが絶対値が大きいか調べる
wire s_greater_than_t;
assign s_greater_than_t = ({exponent_s, mantissa_s} > {exponent_t, mantissa_t}) ? 1 : 0;
assign g = s_greater_than_t ? s : t;
assign l = s_greater_than_t ? t : s;

// 加算か減算か調べる
wire is_add;
assign is_add = (sign_s == sign_t) ? 1 : 0;

// sとtで大きいほうをgreater、小さいほうをlessとして扱う
wire [0:0] sign_g, sign_l;
wire [7:0] exponent_g, exponent_l;
wire [22:0] mantissa_g, mantissa_l;

assign sign_g = s_greater_than_t ? sign_s : sign_t;
assign sign_l = s_greater_than_t ? sign_t : sign_s;
assign exponent_g = s_greater_than_t ? exponent_s : exponent_t;
assign exponent_l = s_greater_than_t ? exponent_t : exponent_s;
assign mantissa_g = s_greater_than_t ? mantissa_s : mantissa_t;
assign mantissa_l = s_greater_than_t ? mantissa_t : mantissa_s;

// 仮数どうしのAddのために省略している1を元に戻す
wire [24:0] one_mantissa_g, one_mantissa_l;
assign one_mantissa_g = {2'b01, mantissa_g};
assign one_mantissa_l = {2'b01, mantissa_l};

// 仮数の桁を揃えるために指数の差を計算し、その分だけone_mantissa_lを右シフトする
// 計算自体は27bit(先の25bitにulpとguard bitがつく)だが、round bitのためにそれ以下の桁も必要になる
// carry + 1. + mantissa + 31bit
// 31bitの先頭がguard bit、その次がround bit、それ以降がsticky bitになる

wire [7:0] relative_scale;
wire [4:0] pre_shift;
wire [55:0] one_mantissa_g_56bit, one_mantissa_l_56bit, one_mantissa_d_56bit;
wire [26:0] one_mantissa_g_27bit, one_mantissa_l_27bit;

assign relative_scale = exponent_g - exponent_l;
assign pre_shift =  (relative_scale > 8'b00011001) ? 5'b11111 : relative_scale[4:0];

assign one_mantissa_g_56bit = {one_mantissa_g, 31'b0};
assign one_mantissa_l_56bit = {one_mantissa_l, 31'b0} >> pre_shift;

assign one_mantissa_g_27bit = one_mantissa_g_56bit[55:29];
assign one_mantissa_l_27bit = one_mantissa_l_56bit[55:29];

// 仮数同士でAddを行う
// 加算のときのためにcarryを設定しておく
// 減算のときのためにulp, guard bit, round bitを設定しておく
// carry + 1. + mantissa + 31bit

// NOTE: output
assign one_mantissa_d_27bit =
  is_add ? one_mantissa_g_27bit + one_mantissa_l_27bit : one_mantissa_g_27bit - one_mantissa_l_27bit; 
assign for_sticky = |(one_mantissa_l_56bit[28:0]);

endmodule

module fadd_stage2(
  input wire [31:0] s,
  input wire [31:0] t,
  input wire [26:0] one_mantissa_d_27bit,
  input wire for_sticky,
  output wire [22:0] one_mantissa_d_scaled,
  output wire [4:0] shift,
  output wire [4:0] shift_left,
  output wire shift_right,
  output wire [3:0] for_round
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

wire s_greater_than_t;
assign s_greater_than_t = ({exponent_s, mantissa_s} > {exponent_t, mantissa_t}) ? 1 : 0;

wire [7:0] exponent_g, exponent_l;
assign exponent_g = s_greater_than_t ? exponent_s : exponent_t;
assign exponent_l = s_greater_than_t ? exponent_t : exponent_s;

wire is_add;
assign is_add = (sign_s == sign_t) ? 1'b1 : 1'b0;

wire [7:0] relative_scale;
assign relative_scale = exponent_g - exponent_l;

// 正規化を行う

// 減算ならば最上位から1を探す
// それまでに出た0の数だけ<<する
// assign shift_right = carry;
assign shift = 
    (one_mantissa_d_27bit[25:25] == 1'b1) ? 0 :
    (one_mantissa_d_27bit[24:24] == 1'b1) ? 1 :
    (one_mantissa_d_27bit[23:23] == 1'b1) ? 2 :
    (one_mantissa_d_27bit[22:22] == 1'b1) ? 3 :
    (one_mantissa_d_27bit[21:21] == 1'b1) ? 4 :
    (one_mantissa_d_27bit[20:20] == 1'b1) ? 5 :
    (one_mantissa_d_27bit[19:19] == 1'b1) ? 6 :
    (one_mantissa_d_27bit[18:18] == 1'b1) ? 7 :
    (one_mantissa_d_27bit[17:17] == 1'b1) ? 8 :
    (one_mantissa_d_27bit[16:16] == 1'b1) ? 9 :
    (one_mantissa_d_27bit[15:15] == 1'b1) ? 10 :
    (one_mantissa_d_27bit[14:14] == 1'b1) ? 11 :
    (one_mantissa_d_27bit[13:13] == 1'b1) ? 12 :
    (one_mantissa_d_27bit[12:12] == 1'b1) ? 13 :
    (one_mantissa_d_27bit[11:11] == 1'b1) ? 14 :
    (one_mantissa_d_27bit[10:10] == 1'b1) ? 15 :
    (one_mantissa_d_27bit[9:9] == 1'b1) ? 16 :
    (one_mantissa_d_27bit[8:8] == 1'b1) ? 17 :
    (one_mantissa_d_27bit[7:7] == 1'b1) ? 18 :
    (one_mantissa_d_27bit[6:6] == 1'b1) ? 19 :
    (one_mantissa_d_27bit[5:5] == 1'b1) ? 20 :
    (one_mantissa_d_27bit[4:4] == 1'b1) ? 21 :
    (one_mantissa_d_27bit[3:3] == 1'b1) ? 22 :
    (one_mantissa_d_27bit[2:2] == 1'b1) ? 23 :
    (one_mantissa_d_27bit[1:1] == 1'b1) ? 24 :
    (one_mantissa_d_27bit[0:0] == 1'b1) ? 25 : 26;

assign shift_right = one_mantissa_d_27bit[26:26];
assign shift_left =
    shift >= exponent_g ? exponent_g - 8'd1 : shift;

// 正規化のためだけに56bitに拡張する
// 正規化後は必ず下位28bitの先頭が1になる(最下位２bitは後で丸めるときに使う
wire [55:0] d_concat_l;
wire [55:0] d_concat_l_shift;
wire [55:0] one_mantissa_d_56bit;
assign d_concat_l =
  { one_mantissa_d_27bit, 29'd0 };

assign one_mantissa_d_56bit =
  is_add ? d_concat_l >> shift_right : d_concat_l << shift_left;

// NOTE: carry=1のときには右shiftするが、その際に落ちたbitを考慮に入れる
wire ulp, guard, round, sticky, dropped;
assign dropped = one_mantissa_d_27bit[0:0];
assign ulp = one_mantissa_d_56bit[31:31];
assign guard = one_mantissa_d_56bit[30:30];
assign round = one_mantissa_d_56bit[29:29];
assign sticky = for_sticky || (shift_right && dropped);

// NOTE: output
assign one_mantissa_d_scaled = one_mantissa_d_56bit[53:31];
assign for_round = {ulp, guard, round, sticky};

endmodule


module fadd_stage3(
    input wire [31:0] s,
    input wire [31:0] t,
    input wire [22:0] one_mantissa_d_scaled,
    input wire [4:0] shift,
    input wire [4:0] shift_left,
    input wire shift_right,
    input wire [3:0] for_round,
    output wire [31:0] d
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

wire s_greater_than_t;
assign s_greater_than_t = ({exponent_s, mantissa_s} > {exponent_t, mantissa_t}) ? 1 : 0;

wire sign_g;
wire [7:0] exponent_g, exponent_l;
assign sign_g = s_greater_than_t ? sign_s : sign_t;
assign exponent_g = s_greater_than_t ? exponent_s : exponent_t;
assign exponent_l = s_greater_than_t ? exponent_t : exponent_s;

wire is_add;
assign is_add = (sign_s == sign_t) ? 1'b1 : 1'b0;

wire [7:0] relative_scale;
assign relative_scale = exponent_g - exponent_l;

// 丸めを行う
// G and (ulp or R or (sticky and is_add)) 
wire ulp, guard, round, sticky, flag;
wire [23:0] mantissa_d_rounded; // carry + 23bit
wire carry_round;

assign ulp = for_round[3:3];
assign guard = for_round[2:2];
assign round = for_round[1:1];
assign sticky = for_round[0:0];
assign flag =
    (ulp && guard && (~round) && (~sticky)) ||
    (guard && (~round) && sticky && (sign_s == sign_t)) ||
    (guard && round);
assign mantissa_d_rounded = {1'b0,one_mantissa_d_scaled} + {23'b0, flag};
assign carry_round = mantissa_d_rounded[23:23];


// NOTE: 例外処理をしていく
// IEEE 754
// exp = 0, man = 0 -> zero (probably included in denormalized)
// exp = 0, man = not 0 -> denormalized (very small)
// exp = 255, man = 0 -> inf
// exp = 255, man = not 0 -> NaN

// inf + inf = inf (as is negative case)
// inf - inf = NaN
// Nan +/- * = NaN (as is the reverse)

// 符号を決める
assign sign_d = sign_g;

// 仮数を決める
assign mantissa_d = mantissa_d_rounded[22:0];

// 指数を決める
assign exponent_d =
is_add ? 
    exponent_g + {7'b0, shift_right} + {7'b0, carry_round}
:
    exponent_g - {3'b0, shift_left} + {7'b0, carry_round};

wire s_is_nan;
assign s_is_nan =
    exponent_s == 8'd255 && mantissa_s != 8'd0;
wire t_is_nan;
assign t_is_nan =
    exponent_t == 8'd255 && mantissa_t != 8'd0;
wire s_is_inf;
assign s_is_inf =
    exponent_s == 8'd255 && mantissa_s == 8'd0;
wire t_is_inf;
assign t_is_inf =
    exponent_t == 8'd255 && mantissa_t == 8'd0;
wire d_is_inf;
assign d_is_inf =
    exponent_d == 8'd255 && shift_right == 1'b1;
wire s_is_zero;
assign s_is_zero =
    exponent_s == 8'd0 && mantissa_s == 8'd0;
wire t_is_zero;
assign t_is_zero =
    exponent_t == 8'd0 && mantissa_t == 8'd0;

wire d_is_s, d_is_t, d_is_zero;
assign d_is_s =
    t_is_zero || (s_greater_than_t && relative_scale > 8'b00011000);
assign d_is_t =
    s_is_zero || (~s_greater_than_t && relative_scale > 8'b00011000);
assign d_is_zero =
    (sign_s != sign_t) && (exponent_s == exponent_t) && (mantissa_s == mantissa_t);

// NOTE: 引き算についてはshift_leftできるかどうかで決める
// 結果が非正規化数になるときにも先頭に1がくるまでshiftする
// できなければ非正規化数として指数を0にする

wire d_is_denormalized;
assign d_is_denormalized = 
    ~is_add && (shift_left < shift);

assign d = 
    t_is_nan ? {sign_t, 8'd255, mantissa_t} :
    s_is_nan ? {sign_s, 8'd255, mantissa_s} :
    s_is_inf && t_is_inf ? (sign_s == sign_t ? {sign_s, 8'd255, 23'd0} : {1'b0, 8'd255, 1'b1, 22'd0}) :
    s_is_inf ? {sign_s, 8'd255, 23'd0} :
    t_is_inf ? {sign_t, 8'd255, 23'd0} :
    d_is_inf ? {sign_d, 8'd255, 23'b0} :
    d_is_s ? {sign_s, exponent_s, mantissa_s} :
    d_is_t ? {sign_t, exponent_t, mantissa_t} :
    d_is_zero ? {1'b0, 8'b0, 23'b0} :
    d_is_denormalized ? {sign_d, 8'd0, mantissa_d} :
    {sign_d, exponent_d, mantissa_d};

endmodule

/*
module fadd_stage1(
  input wire [31:0] s,
  input wire [31:0] t,
  output wire [26:0] one_mantissa_d_27bit,
  output wire for_sticky
);

module fadd_stage2(
  input wire [31:0] s,
  input wire [31:0] t,
  input wire [26:0] one_mantissa_d_27bit,
  input wire for_sticky,
  output wire [22:0] one_mantissa_d_scaled,
  output wire [4:0] shift,
  output wire [4:0] shift_left,
  output wire shift_right,
  output wire [3:0] for_round
);

module fadd_stage3(
    input wire [31:0] s,
    input wire [31:0] t,
    input wire [22:0] one_mantissa_d_scaled,
    input wire [4:0] shift,
    input wire [4:0] shift_left,
    input wire shift_right,
    input wire [3:0] for_round,
    output wire [31:0] d
);
*/

module fadd(
  input wire clk,
  input wire [31:0] s,
  input wire [31:0] t,
  output wire [31:0] d
);

wire [31:0] wire_g1, wire_g2, wire_g3;
reg [31:0] reg_g1, reg_g2, reg_g3;
wire [31:0] wire_l1, wire_l2, wire_l3;
reg [31:0] reg_l1, reg_l2, reg_l3;
wire [26:0] wire_one_mantissa_d_27bit1, wire_one_mantissa_d_27bit2;
reg [26:0] reg_one_mantissa_d_27bit1, reg_one_mantissa_d_27bit2;
wire wire_for_sticky1, wire_for_sticky2;
reg reg_for_sticky1, reg_for_sticky2;

wire [22:0] wire_one_mantissa_d_scaled2, wire_one_mantissa_d_scaled3;
reg [22:0] reg_one_mantissa_d_scaled2, reg_one_mantissa_d_scaled3;
wire [4:0] wire_shift2, wire_shift3;
reg [4:0] reg_shift2, reg_shift3;
wire [4:0] wire_shift_left2, wire_shift_left3;
reg [4:0] reg_shift_left2, reg_shift_left3;
wire wire_shift_right2, wire_shift_right3;
reg reg_shift_right2, reg_shift_right3;
wire [3:0] wire_for_round2, wire_for_round3;
reg [3:0] reg_for_round2, reg_for_round3;

fadd_stage1 u1(s, t, wire_g1, wire_l1, wire_one_mantissa_d_27bit1, wire_for_sticky1);
fadd_stage2 u2(wire_g2, wire_l2, wire_one_mantissa_d_27bit2, wire_for_sticky2, wire_one_mantissa_d_scaled2, wire_shift2, wire_shift_left2, wire_shift_right2, wire_for_round2);
fadd_stage3 u3(wire_g3, wire_l3, wire_one_mantissa_d_scaled3, wire_shift3, wire_shift_left3, wire_shift_right3, wire_for_round3, d);

assign wire_g2 = reg_g2;
assign wire_g3 = reg_g3;
assign wire_l2 = reg_l2;
assign wire_l3 = reg_l3;
assign wire_one_mantissa_d_27bit2 = reg_one_mantissa_d_27bit2;
assign wire_for_sticky2 = reg_for_sticky2; 
assign wire_one_mantissa_d_scaled3 = reg_one_mantissa_d_scaled3;
assign wire_shift3 = reg_shift3;
assign wire_shift_left3 = reg_shift_left3;
assign wire_shift_right3 = reg_shift_right3;
assign wire_for_round3 = reg_for_round3;

always @(posedge clk) begin
  reg_g3 <= wire_g2;
  reg_l3 <= wire_l2;
end
always @(posedge clk) begin
  reg_g2 <= wire_g1;
  reg_l2 <= wire_l1;
end
always @(posedge clk) begin
  reg_one_mantissa_d_27bit2 <= wire_one_mantissa_d_27bit1;
  reg_for_sticky2 <= wire_for_sticky1;
  reg_one_mantissa_d_scaled3 <= wire_one_mantissa_d_scaled2;
  reg_shift3 <= wire_shift2;
  reg_shift_left3 <= wire_shift_left2;
  reg_shift_right3 <= wire_shift_right2;
  reg_for_round3 <= wire_for_round2;
end

endmodule