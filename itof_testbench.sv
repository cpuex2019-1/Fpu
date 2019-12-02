`timescale 1ns / 100ps
`default_nettype none

module itof_testbench();

wire signed [31:0] src;
wire [31:0] sink, dest;
logic signed [31:0] src_logic;
logic [31:0] sink_logic, dest_logic;
int signed src_int;
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

itof u0(src,dest);

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

assign src = src_logic;
// assign sink = sink_logic;
// assign dest = dest_logic;
assign ans = ans_logic;

// assign src = {sign_src, exp_src, man_src};
// assign sink = {sign_sink, exp_sink, man_sink};

// NOTE: 必要になった変数はここに
int signed i, j, k;

initial begin
    counter = 0;
end

// NOTE: テスト内容を記述する
initial begin
  // for (i=1; i<255; i++) begin
    // for (j=1; j<255; j++) begin

      for (k=-10000000; k<1000000; k++) begin
        counter = counter + 1;

        // sign_src_logic = $urandom();
        // sign_sink_logic = $urandom();
        // exp_src_logic = i;
        // exp_sink_logic = j;
        // man_src_logic = $urandom();
        // man_sink_logic = $urandom();
        src_logic = k;

        #1;

        src_int = src;
        sink_real = $bitstoshortreal(sink);

        #1;

        dest_real = $bitstoshortreal(dest);

        ans_real = $itor(src_int);
        ans_logic = $shortrealtobits(ans_real);

        #1;

        // NOTE: DEBUG:のために表示する
        if (dest != ans) begin
          $display("counter = %d", counter);
          $display(" src = %d %b", src, src);
          $display("dest = %e %b %b %b", dest_real, dest[31:31], dest[30:23], dest[22:0]);
          $display(" ans = %e %b %b %b", ans_real, ans[31:31], ans[30:23], ans[22:0]);
          $display();
        end

      // end
    // end
  end

end

endmodule