`timescale 1ns / 100ps
`default_nettype none

module finv_testbench();
   wire [31:0] x1,x2,y;
   wire        ovf,udf;
   logic [31:0] x1i,x2i;
   shortreal    fx1,fx2,fy;
   int          j,k,jt;
   bit [22:0]   m2;
   bit [9:0]    dum1,dum2;
   logic [31:0] fybit;
   int          s2;
   logic [23:0] dy;
   bit [22:0] tm;
   bit 	      fovf;
   bit 	      checkovf;

   // DEBUG:
   wire [63:0] x00,a1,b1,c1,x11,a2,b2,c2,x22;
   
   assign x1 = x1i;
   assign x2 = x2i;
   
   finv u1(x2,y,ovf,udf,x00,a1,b1,c1,x11,a2,b2,c2,x22);

   initial begin
      // $dumpfile("finv_testbench.vcd");
      // $dumpvars(0);

      $display("start of checking module fadd");
      $display("difference message format");
      $display("x2 = [input 2(bit)], [exponent 2(decimal)]");
      $display("ref. : result(float) sign(bit),exponent(decimal),mantissa(bit) overflow(bit)");
      $display("finv : result(float) sign(bit),exponent(decimal),mantissa(bit) overflow(bit)");

         for (j=1; j<255; j++) begin
               for (s2=0; s2<2; s2++) begin
                     for (jt=0; jt<10; jt++) begin
                        #1;

                        case (jt)
                          0 : m2 = 23'b0;
                          1 : m2 = {22'b0,1'b1};
                          2 : m2 = {21'b0,2'b10};
                          3 : m2 = {1'b0,3'b111,19'b0};
                          4 : m2 = {1'b1,22'b0};
                          5 : m2 = {2'b10,{21{1'b1}}};
                          6 : m2 = {23{1'b1}};
                          default : begin
                              {m2,dum2} = $urandom();
                           end
                        endcase
                        
                        x1i = 32'h3f800000;
                        x2i = {s2[0],j[7:0],m2};

                        fx1 = $bitstoshortreal(x1i);
                        fx2 = $bitstoshortreal(x2i);
                        fy = fx1 / fx2;
                        fybit = $shortrealtobits(fy);

			checkovf = j < 255;
			if ( checkovf && fybit[30:23] == 255 ) begin
			   fovf = 1;
			end else begin
			   fovf = 0;
			end
                        
                        #1;

                        if (y !== fybit) begin
                           $display("x2 = %b %b %b, %3d",
				    x2[31], x2[30:23], x2[22:0], x2[30:23]);
                           // DEBUG:
                           $display("%b %b %b %b %b %b %b %b", x00[63:56], x00[55:48], x00[47:40], x00[39:32], x00[31:24], x00[23:16], x00[15:8], x00[7:0]);
                           $display("%b %b %b %b %b %b %b %b", a1[63:56], a1[55:48], a1[47:40], a1[39:32], a1[31:24], a1[23:16], a1[15:8], a1[7:0]);
                           $display("%b %b %b %b %b %b %b %b", b1[63:56], b1[55:48], b1[47:40], b1[39:32], b1[31:24], b1[23:16], b1[15:8], b1[7:0]);
                           $display("%b %b %b %b %b %b %b %b", c1[63:56], c1[55:48], c1[47:40], c1[39:32], c1[31:24], c1[23:16], c1[15:8], c1[7:0]);
                           $display("%b %b %b %b %b %b %b %b", x11[63:56], x11[55:48], x11[47:40], x11[39:32], x11[31:24], x11[23:16], x11[15:8], x11[7:0]);
                           $display("%b %b %b %b %b %b %b %b", a2[63:56], a2[55:48], a2[47:40], a2[39:32], a2[31:24], a2[23:16], a2[15:8], a2[7:0]);
                           $display("%b %b %b %b %b %b %b %b", b2[63:56], b2[55:48], b2[47:40], b2[39:32], b2[31:24], b2[23:16], b2[15:8], b2[7:0]);
                           $display("%b %b %b %b %b %b %b %b", c1[63:56], c1[55:48], c1[47:40], c1[39:32], c1[31:24], c1[23:16], c1[15:8], c1[7:0]);
                           $display("%b %b %b %b %b %b %b %b", x22[63:56], x22[55:48], x22[47:40], x22[39:32], x22[31:24], x22[23:16], x22[15:8], x22[7:0]);

                           $display("%e %b,%3d,%b %b", fy,
				    fybit[31], fybit[30:23], fybit[22:0], fovf);
                           $display("%e %b,%3d,%b %b\n", $bitstoshortreal(y),
				    y[31], y[30:23], y[22:0], ovf);
                        end
                     end
                  end
               end
/*
      for (i=0; i<255; i++) begin
         for (s1=0; s1<2; s1++) begin
            for (s2=0; s2<2; s2++) begin
               for (j=0;j<23;j++) begin
                  repeat(10) begin
                     #1;

                     {m1,dum1} = $urandom();
                     x1i = {s1[0],i[7:0],m1};
                     {m2,dum2} = $urandom();
                     for (k=0;k<j;k++) begin
                        tm[k] = m2[k];
                     end
                     for (k=j;k<23;k++) begin
                        tm[k] = m1[k];
                     end
                     x2i = {s2[0],i[7:0],tm};

                     fx1 = $bitstoshortreal(x1i);
                     fx2 = $bitstoshortreal(x2i);
                     fy = fx1 / fx2;
                     fybit = $shortrealtobits(fy);
                     
		     checkovf = i < 255;
		     if (checkovf && fybit[30:23] == 255) begin
			fovf = 1;
		     end else begin
			fovf = 0;
		     end

                     #1;

                     if (y !== fybit) begin
                        $display("x1 = %b %b %b, %3d",
				 x1[31], x1[30:23], x1[22:0], x1[30:23]);
                        $display("x2 = %b %b %b, %3d",
				 x2[31], x2[30:23], x2[22:0], x2[30:23]);
                        $display("%e %b,%3d,%b %b", fy,
				 fybit[31], fybit[30:23], fybit[22:0], fovf);
                        $display("%e %b,%3d,%b %b\n", $bitstoshortreal(y),
				 y[31], y[30:23], y[22:0], ovf);
                     end
                  end
               end
            end
         end
      end*/
      $display("end of checking module finv");
      $finish;
   end
endmodule

`default_nettype wire
