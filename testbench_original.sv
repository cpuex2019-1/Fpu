`timescale 1ns / 100ps
`default_nettype none

module finv_testbench();

wire [31:0] src, dest;
wire [63:0] tmp1, tmp2;
logic [31:0] src_logic, dest_logic;
logic [63:0] tmp1_logic, tmp2_logic;
shortreal src_real, dest_real, tmp_real;
wire [31:0] ans;
logic [31:0] ans_logic;
shortreal ans_real;
wire ovf, udf;
logic clk;

finv u0(clk,src,dest,ovf,udf);
// finv_former u1(src,tmp1_logic);
// finv_latter u2(src,tmp2,dest,ovf,udf);

// NOTE: wireをlogicにつないでおき、initial文の中でlogicに代入する
assign src = src_logic;
// assign tmp1 = tmp1_logic;
assign tmp2 = tmp2_logic;
assign ans = ans_logic;

// NOTE: 必要になった変数はここに
int i, j, k;
shortreal one_real;
logic [31:0] one_logic;

// NOTE: テスト内容を記述する
initial begin
  clk = 0;
  one_real = 1.0;
  one_logic = $shortrealtobits(one_real);
  for (i=0; i<100; i++) begin

    // NOTE: 入出力を決める
    src_logic = $urandom();
    src_real = $bitstoshortreal(src_logic);

    // NOTE: clock 1 
    clk = !clk;
    #1;

    // tmp2_logic = tmp1_logic;

    // NOTE: clock 2
    clk = !clk;
    #1;

    ans_real = one_real / src_real;
    ans_logic = $shortrealtobits(ans_real);

    #1;

    // NOTE: DEBUG:のために表示する
    $display("src = %b %b %b", src[31:31], src[30:23], src[22:0]);
    $display("dest = %b %b %b", dest[31:31], dest[30:23], dest[22:0]);
    $display("ans = %b %b %b", ans[31:31], ans[30:23], ans_logic[22:0]);

  end

end

endmodule