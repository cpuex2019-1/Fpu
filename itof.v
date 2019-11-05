module itof(
  input wire [31:0] s,
  output wire [31:0] d
)

// FIXME:

wire sign_d;
wire [7:0] exponent_d;
wire [22:0] mantissa_d;

// 絶対値をとってから指数を数える
wire [31:0] abs_s;
assign abs_s = s[31:31] ? ~s + 32'b1 : s;

assign sign_d = s[31:31];
assign exponent_d =
    abs_s[30:30] ? 30 :
    abs_s[29:29] ? 29 :
    abs_s[28:28] ? 28 :
    abs_s[27:27] ? 27 :
    abs_s[26:26] ? 26 :
    abs_s[25:25] ? 25 :
    abs_s[24:24] ? 24 :
    abs_s[23:23] ? 23 :
    abs_s[22:22] ? 22 :
    abs_s[21:21] ? 21 :
    abs_s[20:20] ? 20 :
    abs_s[19:19] ? 19 :
    abs_s[18:18] ? 18 :
    abs_s[17:17] ? 17 :
    abs_s[16:16] ? 16 :
    abs_s[15:15] ? 15 :
    abs_s[14:14] ? 14 :
    abs_s[13:13] ? 13 :
    abs_s[12:12] ? 12 :
    abs_s[11:11] ? 11 :
    abs_s[10:10] ? 10 :
    abs_s[9:9] ? 9 :
    abs_s[8:8] ? 8 :
    abs_s[7:7] ? 7 :
    abs_s[6:6] ? 6 :
    abs_s[5:5] ? 5 :
    abs_s[4:4] ? 4 :
    abs_s[3:3] ? 3 :
    abs_s[2:2] ? 2 :
    abs_s[1:1] ? 1 : 0;

wire [55:0] tmp1, tmp2;
wire [23:0] tmp3;
assign tmp1 = {s, 32'b0};
assign tmp2 = tmp1 >> exponent_s;
assign tmp3 = tmp2[31:24];

assign mantissa_d = tmp3;

assign d = {aign_d, exponent_d, mantissa_d};

endmodule