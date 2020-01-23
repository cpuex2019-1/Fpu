`timescale 1ns / 100ps
`default_nettype none

module finv_testbench();

wire [31:0] src, dest;
logic [31:0] src_logic, dest_logic;
shortreal src_real, dest_real, tmp_real;
wire [31:0] ans;
logic [31:0] ans_logic;
shortreal ans_real;
wire ovf, udf;
logic clk;

wire src_sign;
wire [7:0] src_exp;
wire [22:0] src_man;
logic src_sign_logic;
logic [7:0] src_exp_logic;
logic [22:0] src_man_logic;

finv u0(clk,src,dest,ovf,udf);

// NOTE: wireをlogicにつないでおき、initial文の中でlogicに代入する
assign src_sign = src_sign_logic;
assign src_exp = src_exp_logic;
assign src_man = src_man_logic;
assign src = src_logic;
// assign src = src_logic;
assign ans = ans_logic;

// NOTE: 必要になった変数はここに
int i, j, k;
shortreal one_real;
logic [31:0] one_logic;

logic [22:0] random;

// NOTE: テスト内容を記述する
initial begin
  clk = 0;
  one_real = 1.0;
  one_logic = $shortrealtobits(one_real);
  for (i=1; i<255; i++) begin
    for (j=0; j<100; j++) begin

      // NOTE: 入出力を決める
      random = $urandom();
      src_sign_logic = $urandom(); 
      src_exp_logic = i;
      src_man_logic = {10'b0, random[12:0]};
      src_logic = {src_sign_logic, src_exp_logic, src_man_logic};
      src_real = $bitstoshortreal(src_logic);

      // NOTE: clock 1 
      clk = !clk; #1; clk = !clk; #1;
      // NOTE: clock 2
      clk = !clk; #1; clk = !clk; #1;
      // // NOTE: clock 3
      clk = !clk; #1; clk = !clk; #1;
      // // NOTE: clock 4
      clk = !clk; #1; clk = !clk; #1;

      ans_real = one_real / src_real;
      ans_logic = $shortrealtobits(ans_real);

      #1;

      // NOTE: DEBUG:のために表示する
      // if (ans[31:10] != dest[31:10] && src[30:23] > 8'd0 && src[30:23] < 8'd255) begin
        $display(" src = %b %b %b", src[31:31], src[30:23], src[22:0]);
        $display("dest = %b %b %b", dest[31:31], dest[30:23], dest[22:0]);
        $display(" ans = %b %b %b", ans[31:31], ans[30:23], ans[22:0]);
        $display();
      // end
    end
  end

end

endmodule