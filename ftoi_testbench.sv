`timescale 1ns / 100ps
`default_nettype none

module ftoi_testbench();

wire [31:0] src, sink, dest;
logic [31:0] src_logic, sink_logic, dest_logic;
shortreal src_real, sink_real, dest_real;
wire signed [31:0] ans;
logic signed [31:0] ans_logic;
int signed src_int, dest_int, ans_int;
shortreal ans_real;
wire ovf, udf;
int counter;
int random;

logic sign_src_logic, sign_sink_logic;
logic [7:0] exp_src_logic, exp_sink_logic;
logic [22:0] man_src_logic, man_sink_logic;

wire ulp,guard,round,sticky,flag;
ftoi u0(src,dest);

// NOTE: wireをlogicにつないでおき、initial文の中でlogicに代入する
// assign src = {sign_src, exp_src, man_src};
wire sign_src;
wire [7:0] exp_src;
wire [22:0] man_src;

assign sign_src = sign_src_logic;
assign exp_src = exp_src_logic;
assign man_src = man_src_logic;

// assign src = src_logic;
// assign dest = dest_logic;
assign dest_int = dest;
assign ans = ans_logic;

assign src = {sign_src, exp_src, man_src};

// NOTE: 必要になった変数はここに
int i, j, k;

initial begin
    counter = 0;
end

// NOTE: テスト内容を記述する
initial begin
  for (i=1; i<255; i++) begin

      for (k=0; k<1000; k++) begin
        counter = counter + 1;
        random = $urandom() % 10;

        sign_src_logic = $urandom();
        exp_src_logic = i;
        man_src_logic = (random == 0) ? 23'd0 : $urandom();

        #1;

        src_real = $bitstoshortreal(src);

        #1;

        ans_real = sign_src ? src_real - 0.5 : src_real + 0.5; 
        ans_int = $rtoi(ans_real);
        ans_logic = ans_int;

        #1;

        // NOTE: DEBUG:のために表示する
        if (dest != ans) begin
          $display("counter = %d", counter);
          $display(" src = %b %b %b %e", src[31:31], src[30:23], src[22:0], src_real);
          $display("dest = %d %b", dest_int, dest_int);
          $display(" ans = %d %b", ans_int, ans_int);
          $display();
        end

      // end
    end
  end

end

endmodule