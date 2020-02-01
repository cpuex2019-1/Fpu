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

// DEBUG:
wire [31:0] s, d;
wire [31:0] wire_s1, wire_s2, wire_s3, wire_s4;
wire [63:0] wire_target1, wire_target2, wire_target3, wire_target4;
wire [63:0] wire_b1, wire_b2, wire_b3, wire_b4;
wire [63:0] wire_c1, wire_c2, wire_c3, wire_c4;
wire [63:0] wire_d1, wire_d2, wire_d3, wire_d4;
wire [63:0] wire_x1, wire_x2, wire_x3, wire_x4;
reg [31:0] reg_s1, reg_s2, reg_s3, reg_s4;
reg [63:0] reg_target1, reg_target2, reg_target3, reg_target4;
reg [63:0] reg_b1, reg_b2, reg_b3, reg_b4;
reg [63:0] reg_c1, reg_c2, reg_c3, reg_c4;
reg [63:0] reg_d1, reg_d2, reg_d3, reg_d4;
reg [63:0] reg_x1, reg_x2, reg_x3, reg_x4; 
fsqrt_stage1 u1(s,wire_target1,wire_b1,wire_c1,wire_d1);
fsqrt_stage2 u2(wire_target2,wire_b2,wire_c2,wire_d2,wire_x2);
fsqrt_stage3 u3(wire_target3,wire_x3,wire_b3,wire_c3,wire_d3);
fsqrt_stage4 u4(wire_s4,wire_target4,wire_b4,wire_c4,wire_d4,d);

assign s = src;
assign wire_s1 = s;
assign wire_s2 = reg_s2;
assign wire_s3 = reg_s3;
assign wire_s4 = reg_s4;
assign wire_target2 = reg_target2;
assign wire_target3 = reg_target3;
assign wire_target4 = reg_target4;
assign wire_b2 = reg_b2;
assign wire_b4 = reg_b4;
assign wire_c2 = reg_c2;
assign wire_c4 = reg_c4;
assign wire_d2 = reg_d2;
assign wire_d4 = reg_d4;
assign wire_x3 = reg_x3;

always @(posedge clk) begin
  reg_s2 <= wire_s1;
end
always @(posedge clk) begin
  reg_s3 <= wire_s2;
end
always @(posedge clk) begin
  reg_s4 <= wire_s3;
end
always @(posedge clk) begin
  reg_target2 <= wire_target1;
  reg_target3 <= wire_target2;
  reg_target4 <= wire_target3;
  reg_b2 <= wire_b1;
  reg_c2 <= wire_c1;
  reg_d2 <= wire_d1;
  reg_x3 <= wire_x2;
  reg_b4 <= wire_b3;
  reg_c4 <= wire_c3;
  reg_d4 <= wire_d3;
end

// NOTE: wireをlogicにつないでおき、initial文の中でlogicに代入する
assign src = src_logic;
assign ans = ans_logic;

// NOTE: 必要になった変数はここに
int i, j, k;

// NOTE: テスト内容を記述する
initial begin
  clk = 0;
  for (i=0; i<100; i++) begin

    // NOTE: 入出力を決める
    src_logic = $urandom();
    src_real = $bitstoshortreal(src_logic);

      // NOTE: clock 1 
      clk = !clk; #1; clk = !clk; #1;
      // NOTE: clock 2
      clk = !clk; #1; clk = !clk; #1;
      // NOTE: clock 3
      clk = !clk; #1; clk = !clk; #1;
      // NOTE: clock 4
      clk = !clk; #1; clk = !clk; #1;

    ans_real = $sqrt(src_real);
    ans_logic = $shortrealtobits(ans_real);

    #1;

    dest_real = $bitstoshortreal(dest);

    // NOTE: DEBUG:のために表示する
    // if (ans != dest && src[31:31] == 0) begin
      $display(" src = %e %b %b %b", src_real, src[31:31], src[30:23], src[22:0]);
      $display("dest = %e %b %b %b", dest_real, dest[31:31], dest[30:23], dest[22:0]);
      $display(" ans = %e %b %b %b", ans_real, ans[31:31], ans[30:23], ans[22:0]);
      $display("x1 = %b", wire_x1);
      $display("x2 = %b", wire_x2);
      $display("x3 = %b", wire_x3);
      $display("x4 = %b", wire_x4);
      $display("target4 = %b", wire_target4);
      $display("b4 = %b", wire_b4);
      $display("c4 = %b", wire_c4);
      $display("d4 = %b", wire_d4);
      $display("x3 = %b", wire_x3);
      $display("d = %b", d);
      $display();
    // end

  end

end

endmodule