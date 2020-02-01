`timescale 1ns / 100ps
`default_nettype none

module fadd_testbench();

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

wire ulp,guard,round,sticky,flag;
wire [55:0] g_56, l_56, d_56;
wire [26:0] d_27;
wire [22:0] scale;
// fadd u0(src,sink,dest,ovf,g_56, l_56, d_27, d_56,scale,ulp,guard,round,sticky,flag);
fadd u0(src,sink,dest,ovf);

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
  for (i=1; i<255; i++) begin
    for (j=1; j<255; j++) begin

      for (k=0; k<100; k++) begin
        counter = counter + 1;
        random = $urandom % 10;

        // sign_src_logic = $urandom();
        // sign_sink_logic = $urandom();
        // exp_src_logic = i;
        // exp_sink_logic = j;
        // man_src_logic = $urandom();
        // man_sink_logic = $urandom();

        // NOTE: 入出力を決める
        // コーナーケースを検出する
        // 結果が非常に大きい/小さい時を調べる
        if (k >= 90) begin
        //   // NOTE: 演算結果が小さくなるときを調べる
          if (i == j) begin
            sign_src_logic = 1'b0;
            sign_sink_logic = 1'b1;
            exp_src_logic = i;
            exp_sink_logic = j;
            man_src_logic = $urandom();
            man_sink_logic = man_src_logic + random;
          end else if (i == j+1) begin 
            sign_src_logic = 1'b0;
            sign_sink_logic = 1'b1;
            exp_src_logic = i;
            exp_sink_logic = j;
            man_src_logic = 23'b0 + random;
            man_sink_logic = {23{1'b1}};
          // end else begin
          //   sign_src_logic = $urandom();
          //   sign_sink_logic = $urandom();
          //   exp_src_logic = i;
          //   exp_sink_logic = j;
          //   man_src_logic = $urandom();
          //   man_sink_logic = $urandom();
          end
        // end else begin
        // sign_src_logic = $urandom();
        // sign_sink_logic = $urandom();
        // exp_src_logic = i;
        // exp_sink_logic = j;
        // man_src_logic = $urandom();
        // man_sink_logic = $urandom();
        end

        #1;

        src_real = $bitstoshortreal(src);
        sink_real = $bitstoshortreal(sink);

        #1;

        ans_real = src_real + sink_real;
        ans_logic = $shortrealtobits(ans_real);

        #1;

        // NOTE: DEBUG:のために表示する
        if (dest != ans) begin
          $display("counter = %d", counter);
          // $display("ulp(%b) guard(%b) round(%b) sticky(%b) flag(%b)", ulp, guard, round, sticky, flag);
          // $display("g_56 = %b %b %b %b %b %b %b", g_56[55:48], g_56[47:40], g_56[39:32], g_56[31:24], g_56[23:16], g_56[15:8], g_56[7:0]);
          // $display("l_56 = %b %b %b %b %b %b %b", l_56[55:48], l_56[47:40], l_56[39:32], l_56[31:24], l_56[23:16], l_56[15:8], l_56[7:0]);
          // $display("d_27 = %b %b %b %b %b %b %b", d_27[26:19], d_27[18:11], d_27[10:3], {d_27[2:0], 5'd0}, 8'd0, 8'd0, 8'd0);
          // $display("d_56 = %b %b %b %b %b %b %b", d_56[55:48], d_56[47:40], d_56[39:32], d_56[31:24], d_56[23:16], d_56[15:8], d_56[7:0]);
          // $display("scale = %b", scale);
          $display(" src = %b %b %b", src[31:31], src[30:23], src[22:0]);
          $display("sink = %b %b %b", sink[31:31], sink[30:23], sink[22:0]);
          $display("dest = %b %b %b", dest[31:31], dest[30:23], dest[22:0]);
          $display(" ans = %b %b %b", ans[31:31], ans[30:23], ans[22:0]);
          $display();
        end

      end
    end
  end

end

endmodule