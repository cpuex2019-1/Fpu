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

itof u0(src,dest);

// NOTE: wireをlogicにつないでおき、initial文の中でlogicに代入する
assign src = src_logic;
// assign dest = dest_logic;
assign ans = ans_logic;

// NOTE: 必要になった変数はここに
int signed i, j, k;

initial begin
    counter = 0;
end

// NOTE: テスト内容を記述する
initial begin

      for (k=-100; k<100; k++) begin
        counter = counter + 1;
        random = $urandom() % 10;

        src_logic = (random == 0) ? $urandom : k;

        #1;

        src_int = src;
        sink_real = $bitstoshortreal(sink);

        #1;

        dest_real = $bitstoshortreal(dest);

        ans_real = $itor(src_int);
        ans_logic = $shortrealtobits(ans_real);

        #1;

        // NOTE: DEBUG:のために表示する
        // if (dest != ans) begin
          $display("counter = %d", counter);
          $display(" src = %d %b", src, src);
          $display("dest = %e %b %b %b", dest_real, dest[31:31], dest[30:23], dest[22:0]);
          $display(" ans = %e %b %b %b", ans_real, ans[31:31], ans[30:23], ans[22:0]);
          $display();
        // end

  end

end

endmodule