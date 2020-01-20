`timescale 1ns / 100ps
`default_nettype none

// for debug
module finv_original_testbench();

wire [31:0] src, sink, dest;
logic [31:0] src_logic, sink_logic, dest_logic;
shortreal src_real, sink_real, dest_real, tmp_real;
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

finv u0(clk,src,sink,ovf,udf);
finv_original u1(src,dest,ovf,udf);

// NOTE: wireをlogicにつないでおき、initial文の中でlogicに代入する
assign src_sign = src_sign_logic;
assign src_exp = src_exp_logic;
assign src_man = src_man_logic;
assign src = src_logic;
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
    for (j=0; j<10000; j++) begin

      // NOTE: 入出力を決める
      random = $urandom();
      src_sign_logic = $urandom(); 
      src_exp_logic = i;
      src_man_logic = 
        j==0 ? 23'b0 : j==1 ? {23{1'b1}} : $random();
      src_logic = {src_sign_logic, src_exp_logic, src_man_logic};
      src_real = $bitstoshortreal(src_logic);

      // NOTE: clock 1 
      clk = !clk;
      #1;

      clk = !clk;
      #1;

      // NOTE: clock 2
      clk = !clk;
      #1;

      clk = !clk;
      #1;

      ans_real = one_real / src_real;
      ans_logic = $shortrealtobits(ans_real);

      #1;

      // NOTE: DEBUG:のために表示する
      if (sink != dest) begin
        $display(" src = %b %b %b", src[31:31], src[30:23], src[22:0]);
        $display("sink = %b %b %b", sink[31:31], sink[30:23], sink[22:0]);
        $display("dest = %b %b %b", dest[31:31], dest[30:23], dest[22:0]);
        $display(" ans = %b %b %b", ans[31:31], ans[30:23], ans[22:0]);
        $display();
      end
    end
  end

end

endmodule