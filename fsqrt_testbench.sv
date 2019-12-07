`timescale 1ns / 100ps
`default_nettype none

module fsqrt_testbench();

wire [31:0] src, dest;
logic [31:0] src_logic, dest_logic;
shortreal src_real, dest_real, tmp_real;
wire [31:0] ans;
logic [31:0] ans_logic;
shortreal ans_real;
logic clk;

fsqrt u0(clk,src,dest);

// NOTE: wireをlogicにつないでおき、initial文の中でlogicに代入する
assign src = src_logic;
assign ans = ans_logic;

// NOTE: 必要になった変数はここに
int i, j, k;

// NOTE: テスト内容を記述する
initial begin
  clk = 0;
  for (i=0; i<1000000; i++) begin

    // NOTE: 入出力を決める
    src_logic = $urandom();
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

    ans_real = $sqrt(src_real);
    ans_logic = $shortrealtobits(ans_real);

    #1;

    dest_real = $bitstoshortreal(dest);

    // NOTE: DEBUG:のために表示する
    if (ans != dest && src[31:31] == 0) begin
      $display(" src = %e %b %b %b", src_real, src[31:31], src[30:23], src[22:0]);
      $display("dest = %e %b %b %b", dest_real, dest[31:31], dest[30:23], dest[22:0]);
      $display(" ans = %e %b %b %b", ans_real, ans[31:31], ans[30:23], ans[22:0]);
      $display();
    end

  end

end

endmodule