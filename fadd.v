module fadd(
    input wire [31:0] s,
    input wire [31:0] t,
    output wire [31:0] d,
    output wire overflow
);

// FIXME: overflowなどのcorner caseに対応する

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
wire s_greater_than_t, s_less_than_t;
s_greater_than_t = ({exponent_s, mantissa_s} > {exponent_t, mantissa_t}) ? 1 : 0
s_less_than_t = ({exponent_s, mantissa_s} < {exponent_t, mantissa_t}) ? 1 : 0

// 加算か減算か調べる
wire is_add, is_sub;
assign is_add = sign_s == sign_t ? 1 : 0;
assign is_sub = sign_s != sign_t ? 1 : 0;

// sとtで大きいほうをgreater、小さいほうをlessとして扱う
wire [0:0] sign_g, sign_l;
wire [7:0] exponent_g, exponent_l;
wire [22:0] mantissa_g, mantissa_l;

assign sign_g = s_greater_than_t ? sign_s : sign_t;
assign sign_l = s_less_than_t ? sign_s : sign_t;
assign exponent_g = s_greater_than_t ? exponent_s : exponent_t;
assign exponent_l = s_less_than_t ? exponent_s : exponent_t;
assign mantissa_g = s_greater_than_t ? mantissa_s : mantissa_t;
assign mantissa_l = s_less_than_t ? mantissa_s : mantissa_t;

// 符号を決める
assign sign_d = sign_g;

// 指数を決める
// FIXME: 繰り上がりの関係で変更になるはず
assign exponent_d = exponent_g;

// 仮数を決める

// 仮数どうしのAddのために省略している1を元に戻す(とともにcarryのための1bitを用意するので25bitになる)
wire [24:0] one_mantissa_g, one_mantissa_l;
assign one_mantissa_g = {2'b01, mantissa_g};
assign one_mantissa_l = {2'b01, mantissa_l};

// 仮数の桁を揃えるために指数の差を計算し、その分だけone_mantissa_lを右シフトする
// 計算自体は27bit(先の25bitにulpとguard bitがつく)だが、round bitのためにそれ以下の桁も必要になる
// FIXME: 差が大きかったときに例外処理を行う(なぜ31bitも確保する???25bit程度で十分では???)
wire [7:0] relative_scale;
wire [55:0] one_mantissa_g_56bit, one_mantissa_l_56bit, one_mantissa_d_56bit;

assign relative_scale = exponent_g - exponent_l;
assign one_mantissa_g_56bit = {one_mantissa_g, 31'b0};
assign one_mantissa_l_56bit = {one_mantissa_l, 31'b0} >> relative_scale;

// 仮数同士でAddを行う
// 加算のときのためにcarryを設定しておく
// 減算のときのためにulp, guard bit, round bitを設定しておく
wire carry, ulp, guard, round;
wire [26:0] one_mantissa_g_27bit, one_mantissa_l_27bit, one_mantissa_d_27bit;

assign one_mantissa_g_27bit = one_mantissa_g_56bit[55:29];
assign one_mantissa_l_27bit = one_mantissa_l_56bit[55:29];
assign one_mantissa_d_27bit = is_add ? one_mantissa_g_27bit + one_mantissa_l_27bit : one_mantissa_g_27bit - one_mantissa_l_27bit

assign carry = one_mantissa_d_27bit[26:26];
assign ulp = one_mantissa_d_27bit[1:1];
assign guard = one_mantissa_d_27bit[0:0];
assign round = |(one_mantissa_d_56bit[28:0]);

// 正規化を行う
// FIXME:
wire [31:0] order;
wire [24:0] mantissa_d_scaled;
assign order =  (one_mantissa_d_27bit[25:25] == 1) ? 0 :
                (one_mantissa_d_27bit[24:24] == 1) ? 1 :
                (one_mantissa_d_27bit[23:23] == 1) ? 2 :
                (one_mantissa_d_27bit[22:22] == 1) ? 3 :
                (one_mantissa_d_27bit[21:21] == 1) ? 4 :
                (one_mantissa_d_27bit[20:20] == 1) ? 5 :
                (one_mantissa_d_27bit[19:19] == 1) ? 6 :
                (one_mantissa_d_27bit[18:18] == 1) ? 7 :
                (one_mantissa_d_27bit[17:17] == 1) ? 8 :
                (one_mantissa_d_27bit[16:16] == 1) ? 9 :
                (one_mantissa_d_27bit[15:15] == 1) ? 10 :
                (one_mantissa_d_27bit[14:14] == 1) ? 11 :
                (one_mantissa_d_27bit[13:13] == 1) ? 12 :
                (one_mantissa_d_27bit[12:12] == 1) ? 13 :
                (one_mantissa_d_27bit[11:11] == 1) ? 14 :
                (one_mantissa_d_27bit[10:10] == 1) ? 15 :
                (one_mantissa_d_27bit[9:9] == 1) ? 16 :
                (one_mantissa_d_27bit[8:8] == 1) ? 17 :
                (one_mantissa_d_27bit[7:7] == 1) ? 18 :
                (one_mantissa_d_27bit[6:6] == 1) ? 19 :
                (one_mantissa_d_27bit[5:5] == 1) ? 20 :
                (one_mantissa_d_27bit[4:4] == 1) ? 21 :
                (one_mantissa_d_27bit[3:3] == 1) ? 22 :
                (one_mantissa_d_27bit[2:2] == 1) ? 23 :
                (one_mantissa_d_27bit[1:1] == 1) ? 24 :
                (one_mantissa_d_27bit[0:0] == 1) ? 25 : 26;

assign one_mantissa_d_56bit = one_mantissa_d_27bit << order;
assign mantissa_d_scaled = one_mantissa_d_56bit[53:29];

// 丸めを行う
// FIXME:
wire [22:0] mantissa_d_rounded;
assign mantissa_d_rounded[22:1] = mantissa_d_scaled[22:1];
assign mantissa_d_rounded[0:0] = ulp | (guard & round);

assign mantissa_d = mantissa_d_rounded;

endmodule

