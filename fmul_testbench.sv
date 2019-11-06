`timescale 1ns / 100ps
`default_nettype none

module fmul_testbench();
   wire [31:0] x1,x2,y;
   wire        ovf,udf;
   logic [31:0] x1i,x2i;
   shortreal    fx1,fx2,fy;
   int          i,j,k,it,jt;
   bit [22:0]   m1,m2;
   bit [9:0]    dum1,dum2;
   logic [31:0] fybit;
   int          s1,s2;
   logic [23:0] dy;
   bit [22:0] tm;
   bit 	      fovf;
   bit 	      checkovf;

   wire [0:0] sign_x1, sign_x2;
   wire [7:0] exponent_x1, exponent_x2;
   wire [22:0] mantissa_x1, mantissa_x2;
   wire [7:0] tmp1, tmp2;   

   assign {sign_x1, exponent_x1, mantissa_x1} = x1i;
   assign {sign_x2, exponent_x2, mantissa_x2} = x2i;

   assign tmp1 = 
      exponent_x1 > 8'b11000000 ?
          exponent_x1 - 8'b01000000
      : (exponent_x1 < 8'b01000000 ?
          exponent_x1 + 8'b01000000
      : exponent_x1);
   assign tmp2 = 
      exponent_x2 > 8'b11000000 ?
          exponent_x2 - 8'b01000000
      : (exponent_x2 < 8'b01000000 ?
          exponent_x2 + 8'b01000000
      : exponent_x2);

   // assign x1 = {sign_x1, tmp1, mantissa_x1};
   // assign x2 = {sign_x2, tmp2, mantissa_x2};
   assign x1 = x1i;
   assign x2 = x2i;

   wire snan, tnan;
   wire [22:0] man_s, man_t;
   wire c, de, u, g, r, st, f;
   wire [7:0] sr, sl;
   wire [47:0] mul;
   wire [23:0] one_man;
   wire denormal;
   wire ulp,guard,round,sticky,flag;
   wire shift_left;
   wire [4:0] shift_right;
   // fmul u1(x1,x2,y,c,ovf,udf);
   fmul u1(x1,x2,y,ovf,udf,shift_left,shift_right,ulp,guard,round,sticky,flag,denormal);

   initial begin
      // $dumpfile("test_fadd.vcd");
      // $dumpvars(0);

      $display("start of checking module fadd");
      $display("difference message format");
      $display("x1 = [input 1(bit)], [exponent 1(decimal)]");
      $display("x2 = [input 2(bit)], [exponent 2(decimal)]");
      $display("ref. : result(float) sign(bit),exponent(decimal),mantissa(bit) overflow(bit)");
      $display("fadd : result(float) sign(bit),exponent(decimal),mantissa(bit) overflow(bit)");

      // for (i=0; i<10000; i++) begin

      //    x1i = $urandom();         
      //    x2i = $urandom();

      //    fx1 = $bitstoshortreal(x1i);
      //    fx2 = $bitstoshortreal(x2i);
      //    fy = fx1 * fx2;
      //    fybit = $shortrealtobits(fy);

      //    // checkovf = i < 255 && j < 255;
      //    // if ( checkovf && fybit[30:23] == 255 ) begin
      //    //    fovf = 1;
      //    // end else begin
      //    //    fovf = 0;
      //    // end
                        
      //    #1;

      //    if (y !== fybit ) begin
      //       $display("x1 = %b %b %b, %3d", x1[31], x1[30:23], x1[22:0], x1[30:23]);
      //       $display("x2 = %b %b %b, %3d", x2[31], x2[30:23], x2[22:0], x2[30:23]);
      //       $display("denormal(%b) carry(%b) sl(%d) sr(%d) ", de, c, sl, sr);
      //       $display("%b", one_man);
      //       $display("u(%b) g(%b) r(%b) s(%b) f(%b)", u,g,r,st,f);
      //       $display("%b %b %b %b %b %b", mul[47:40], mul[39:32], mul[31:24], mul[23:16], mul[15:8], mul[7:0]);
      //       $display("%e %b %3d %b", fy, fybit[31], fybit[30:23], fybit[22:0]);
      //       $display("%e %b %3d %b ovf(%b) udf(%b)\n", $bitstoshortreal(y), y[31], y[30:23], y[22:0], ovf, udf);
      //       // $display("%e * %e = %e\n", fx1, fx2, fy);
      //    end
      // end

      for (i=0; i<256; i++) begin
         for (j=0; j<256; j++) begin
            for (s1=0; s1<2; s1++) begin
               for (s2=0; s2<2; s2++) begin
                  for (it=0; it<10; it++) begin
                     for (jt=0; jt<10; jt++) begin
                        #1;

                        case (it)
                          0 : m1 = 23'b0;
                          1 : m1 = {22'b0,1'b1};
                          2 : m1 = {21'b0,2'b10};
                          3 : m1 = {1'b0,3'b111,19'b0};
                          4 : m1 = {1'b1,22'b0};
                          5 : m1 = {2'b10,{21{1'b1}}};
                          6 : m1 = {23{1'b1}};
                          default : begin
                             if (i==256) begin
                                {m1,dum1} = 0;
                             end else begin
                                {m1,dum1} = $urandom();
                             end
                          end
                        endcase

                        case (jt)
                          0 : m2 = 23'b0;
                          1 : m2 = {22'b0,1'b1};
                          2 : m2 = {21'b0,2'b10};
                          3 : m2 = {1'b0,3'b111,19'b0};
                          4 : m2 = {1'b1,22'b0};
                          5 : m2 = {2'b10,{21{1'b1}}};
                          6 : m2 = {23{1'b1}};
                          default : begin
                             if (i==256) begin
                                {m2,dum2} = 0;
                             end else begin
                                {m2,dum2} = $urandom();
                             end
                          end
                        endcase
                        
                        x1i = {s1[0],i[7:0],m1};
                        x2i = {s2[0],j[7:0],m2};

                        fx1 = $bitstoshortreal(x1i);
                        fx2 = $bitstoshortreal(x2i);
                        fy = fx1 * fx2;
                        fybit = $shortrealtobits(fy);

			checkovf = i < 255 && j < 255;
			if ( checkovf && fybit[30:23] == 255 ) begin
			   fovf = 1;
			end else begin
			   fovf = 0;
			end
                        
                        #1;

                        // if (y !== fybit || ovf !== fovf) begin
                        if (y !== fybit && (y == 32'd0 || fybit == 32'd0)) begin
                           $display("x1 = %b %b %b, %3d", x1[31], x1[30:23], x1[22:0], x1[30:23]);
                           $display("x2 = %b %b %b, %3d", x2[31], x2[30:23], x2[22:0], x2[30:23]);
                           // DEBUG:
                           $display("ulp(%b) guard(%b) round(%b) sticky(%b) flag(%b)", ulp,guard,round,sticky,flag);
                           $display("denormal(%b)", denormal);
                           // $display("ps = %b, sr = %b, sl = %b, cr = %b", ps, sr, sl, cr);
                           // $display("man1 = %b %b", man1[55:28], man1[27:0]);
                           // $display("man2 = %b %b", man2[55:28], man2[27:0]);
                           // $display("man3 = %b %b", man3[55:28], man3[27:0]);
                           $display("%e %b,%3d,%b %b", fy,
				    fybit[31], fybit[30:23], fybit[22:0], fovf);
                $display("%e %b,%3d,%b %b\n", $bitstoshortreal(y), y[31], y[30:23], y[22:0], ovf);

                        end
                     end
                  end
               end
            end
         end
         //$finish;
      end

      // for (i=0; i<255; i++) begin
      //    for (s1=0; s1<2; s1++) begin
      //       for (s2=0; s2<2; s2++) begin
      //          for (j=0;j<23;j++) begin
      //             repeat(10) begin
      //                #1;

      //                {m1,dum1} = $urandom();
      //                x1i = {s1[0],i[7:0],m1};
      //                {m2,dum2} = $urandom();
      //                for (k=0;k<j;k++) begin
      //                   tm[k] = m2[k];
      //                end
      //                for (k=j;k<23;k++) begin
      //                   tm[k] = m1[k];
      //                end
      //                x2i = {s2[0],i[7:0],tm};

      //                fx1 = $bitstoshortreal(x1i);
      //                fx2 = $bitstoshortreal(x2i);
      //                fy = fx1 + fx2;
      //                fybit = $shortrealtobits(fy);
                     
		//      checkovf = i < 255;
		//      if (checkovf && fybit[30:23] == 255) begin
		// 	fovf = 1;
		//      end else begin
		// 	fovf = 0;
		//      end

      //                #1;

      //                if (y !== fybit || ovf !== fovf) begin
      //                   $display("x1 = %b %b %b, %3d",
		// 		 x1[31], x1[30:23], x1[22:0], x1[30:23]);
      //                   $display("x2 = %b %b %b, %3d",
		// 		 x2[31], x2[30:23], x2[22:0], x2[30:23]);
      //                   $display("%e %b,%3d,%b %b", fy,
		// 		 fybit[31], fybit[30:23], fybit[22:0], fovf);
      //                   $display("%e %b,%3d,%b %b\n", $bitstoshortreal(y),
		// 		 y[31], y[30:23], y[22:0], ovf);
      //                end
      //             end
      //          end
      //       end
      //    end
      // end

      $display("end of checking module fadd");
      //$finish;
   end
endmodule

`default_nettype wire
