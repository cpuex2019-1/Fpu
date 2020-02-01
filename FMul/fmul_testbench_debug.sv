`timescale 1ns / 100ps
`default_nettype none

module fmul_testbench_debug();

wire [31:0] src, sink, dest;
logic [31:0] src_logic, sink_logic, dest_logic;
shortreal src_real, sink_real, dest_real;
wire [31:0] ans;
logic [31:0] ans_logic;
shortreal ans_real;
wire ovf, udf;
int counter;
int random;

logic sign_src_logic, sign_sink_logic;
logic [7:0] exp_src_logic, exp_sink_logic;
logic [22:0] man_src_logic, man_sink_logic;
logic clk, overflow, underflow;

wire ulp,guard,round,sticky,flag;
fmul u0(clk,src,sink,dest,overflow,underflow);

// DEBUG:
logic [31:0] s, t, d
logic [31:0] s1_reg, t1_reg, s2_reg, t2_reg, mantissa1_reg, mantissa2_reg;
fmul_stage1 u1(s, t, mantissa1_reg);
fmul_stage2 u2(s2_reg,t2_reg,mantissa2_reg,d,_,_);
assign s = src;
assign t = sink;
always @(posedge clk) begin
  s1_reg <= s;
  t1_reg <= t;
  s2_reg <= s1_reg;
  t2_reg <= t1_reg;
  mantissa2_reg <= mantissa1_reg;
end
// DEBUG:

// NOTE: wireをlogicにつないでおき、initial文の中でlogicに代入する
// assign src = {sign_src, exp_src, man_src};
// assign sink = {sign_sink, exp_sink, man_sink};
wire sign_src, sign_sink;
wire [7:0] exp_src, exp_sink;
wire [22:0] man_src, man_sink;

assign sign_src = sign_src_logic;
assign sign_sink = sign_sink_logic;
assign exp_src = exp_src_logic;
assign exp_sink = exp_sink_logic;
assign man_src = man_src_logic;
assign man_sink = man_sink_logic;

// assign src = src_logic;
// assign sink = sink_logic;
// assign dest = dest_logic;
assign ans = ans_logic;

assign src = {sign_src, exp_src, man_src};
assign sink = {sign_sink, exp_sink, man_sink};

// NOTE: 必要になった変数はここに
int i, j, k;

initial begin
    counter = 0;
end

// NOTE: テスト内容を記述する
initial begin
  clk = 0;

  for (i=120; i<150; i++) begin
    for (j=120; j<150; j++) begin

      for (k=0; k<10; k++) begin
        counter = counter + 1;
        random = $urandom % 10;

        sign_src_logic = $urandom();
        sign_sink_logic = $urandom();
        exp_src_logic = i;
        exp_sink_logic = j;
        man_src_logic = $urandom();
        man_sink_logic = $urandom();

        // NOTE: 入出力を決める
        // コーナーケースを検出する
        // 結果が非常に大きい/小さい時を調べる
        // if (k >= 90) begin
        //   // NOTE: 演算結果が小さくなるときを調べる
        //   if (i == j) begin
        //     sign_src_logic = 1'b0;
        //     sign_sink_logic = 1'b1;
        //     exp_src_logic = i;
        //     exp_sink_logic = j;
        //     man_src_logic = $urandom();
        //     man_sink_logic = man_src_logic + random;
        //   end else if (i == j+1) begin 
        //     sign_src_logic = 1'b0;
        //     sign_sink_logic = 1'b1;
        //     exp_src_logic = i;
        //     exp_sink_logic = j;
        //     man_src_logic = 23'b0 + random;
        //     man_sink_logic = {23{1'b1}};
        //   // end else begin
          //   sign_src_logic = $urandom();
          //   sign_sink_logic = $urandom();
          //   exp_src_logic = i;
          //   exp_sink_logic = j;
          //   man_src_logic = $urandom();
          //   man_sink_logic = $urandom();
          // end
        // end else begin
        // sign_src_logic = $urandom();
        // sign_sink_logic = $urandom();
        // exp_src_logic = i;
        // exp_sink_logic = j;
        // man_src_logic = $urandom();
        // man_sink_logic = $urandom();
        // end

        #1;

        src_real = $bitstoshortreal(src);
        sink_real = $bitstoshortreal(sink);

        #1;

          // NOTE: clock 1 
        clk = !clk; #1; clk = !clk; #1;
        // NOTE: clock 2
        clk = !clk; #1; clk = !clk; #1;

        #1;

        ans_real = src_real * sink_real;
        ans_logic = $shortrealtobits(ans_real);

        #1;

        // NOTE: DEBUG:のために表示する
        // if ((dest[30:23] != 0 && ans[30:23] != 0 && dest != ans) || (dest[30:23] == 0 && ans[30:23] != 0) || (dest[30:23] != 0 && ans[30:23] == 0)) begin
          $display("counter = %d", counter);
          $display("overflow(%b) underflow(%b)", ovf, udf);
          $display(" src = %b %b %b", src[31:31], src[30:23], src[22:0]);
          $display("sink = %b %b %b", sink[31:31], sink[30:23], sink[22:0]);
          $display("dest = %b %b %b", dest[31:31], dest[30:23], dest[22:0]);
          $display(" ans = %b %b %b", ans[31:31], ans[30:23], ans[22:0]);
          $display(" s1_reg = %b", s1_reg);
          $display(" s2_reg = %b", s2_reg);
          $display(" d = %b", d);
          $display();
        // end

      end
    end
  end

end

endmodule