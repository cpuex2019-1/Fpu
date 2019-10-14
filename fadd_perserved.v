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
assign s_greater_than_t = ({exponent_s, mantissa_s} > {exponent_t, mantissa_t}) ? 1 : 0;
assign s_less_than_t = ({exponent_s, mantissa_s} < {exponent_t, mantissa_t}) ? 1 : 0;

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

// 後で丸めるときに使用する
wire carry, ulp, guard, round, sticky, flag;

// 符号を決める
assign sign_d = sign_g;

// 指数を決める
// FIXME: 繰り上がりの関係で変更になるはず
// assign exponent_d = exponent_g;

// 仮数を決める

// 仮数どうしのAddのために省略している1を元に戻す
// carry + 1. + mantissa
wire [24:0] one_mantissa_g, one_mantissa_l;
assign one_mantissa_g = {2'b01, mantissa_g};
assign one_mantissa_l = {2'b01, mantissa_l};

// 仮数の桁を揃えるために指数の差を計算し、その分だけone_mantissa_lを右シフトする
// 計算自体は27bit(先の25bitにulpとguard bitがつく)だが、round bitのためにそれ以下の桁も必要になる
// FIXME: 差が大きかったときに例外処理を行う(なぜ31bitも確保する???25bit程度で十分では???)
// carry + 1. + mantissa + 31bit
// 31bitの先頭がguard bit、その次がround bit、それ以降がsticky bitになる
wire [7:0] relative_scale;
wire [4:0] shift;
wire [55:0] one_mantissa_g_56bit, one_mantissa_l_56bit, one_mantissa_d_56bit;

assign relative_scale = exponent_g - exponent_l;
assign shift = (relative_scale > 8'b00011111) ? 5'b11111 : relative_scale[4:0];
assign one_mantissa_g_56bit = {one_mantissa_g, 31'b0};
assign one_mantissa_l_56bit = {one_mantissa_l, 31'b0} >> shift;

// 仮数同士でAddを行う
// 加算のときのためにcarryを設定しておく
// 減算のときのためにulp, guard bit, round bitを設定しておく
// carry + 1. + mantissa + 31bit

wire [26:0] one_mantissa_g_27bit, one_mantissa_l_27bit, one_mantissa_d_27bit;

assign one_mantissa_g_27bit = one_mantissa_g_56bit[55:29];
assign one_mantissa_l_27bit = one_mantissa_l_56bit[55:29];
assign one_mantissa_d_27bit = is_add ? one_mantissa_g_27bit + one_mantissa_l_27bit : one_mantissa_g_27bit - one_mantissa_l_27bit;

// 正規化を行う
// FIXME:
wire shift_right;
wire [4:0] shift_left;
wire [55:0] one_mantissa_d_scaled;
wire [26:0] mantissa_d_scaled;

// FIXME: 加算か減算かで場合分けする
// 加算ならばcarryを見る
// carryが出たら指数を+1して仮数を>>1する
// assign carry = one_mantissa_d_27bit[26:26];

// 減算ならば最上位から1を探す
// それまでに出た0の数だけ<<する
assign carry = one_mantissa_d_27bit[26:26];
assign shift_right = carry;
assign shift_left = 
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


// 正規化のためだけに56bitに拡張する
// 正規化後は必ず下位27bitの先頭が1になる(最下位２bitは後で丸めるときに使う)
assign one_mantissa_d_56bit =
is_add ?
{29'b0, one_mantissa_d_27bit} >> shift_right :
{29'b0, one_mantissa_d_27bit} << shift_left;

assign one_mantissa_d_scaled = one_mantissa_d_56bit[26:2];


// 丸めを行う
// FIXME: 
wire [24:0] mantissa_d_rounded; // carry + 1. + 23bit

assign ulp = one_mantissa_d_56bit[2:2];
assign guard = one_mantissa_d_56bit[1:1];
assign round = one_mantissa_d_56bit[0:0];
assign sticky = |(one_mantissa_l_56bit[28:0]);
// assign mantissa_d_rounded[24:1] = one_mantissa_d_scaled[24:1];
// assign mantissa_d_rounded[0:0] = guard & (ulp | round | sticky) ? 1 : 0;
assign flag = guard & (round | sticky);
assign mantissa_d_rounded = one_mantissa_d_scaled + {24'b0, flag};

assign exponent_d =
is_add ? 
exponent_g + {7'b0, shift_right} :
exponent_g - {3'b0, shift_left};
// assign exponent_d = exponent_g;
assign mantissa_d = mantissa_d_rounded[22:0];

// 出力する
// assign d = 32'b0;
assign d = {sign_d, exponent_d, mantissa_d};
assign overflow = (exponent_d == 8'b11111111 && exponent_s != 8'b11111111 && exponent_t != 8'b11111111) ? 1 : 0;

endmodule

