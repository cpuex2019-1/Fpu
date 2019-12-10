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

wire src_sign;
wire [7:0] src_exp;
wire [22:0] src_man;
logic src_sign_logic;
logic [7:0] src_exp_logic;
logic [22:0] src_man_logic;

assign src_sign = src_sign_logic;
assign src_exp = src_exp_logic;
assign src_man = src_man_logic;

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

    for (i=0; i<256; i++) begin
      // for (k=0; k<1; k++) begin
        counter = counter + 1;
        random = $urandom();
        // random = $urandom() % 10;
        // src_logic = (random == 0) ? $urandom : k;

        src_sign_logic = 1'b1;
        src_exp_logic = i;
        src_man_logic = {23{1'b0}};

        src_logic = {src_sign_logic, src_exp_logic, src_man_logic};

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
  end

end

endmodule