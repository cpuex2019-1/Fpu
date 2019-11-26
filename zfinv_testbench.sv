`timescale 1ns / 100ps
`default_nettype none

module finv_testbench();
   wire [31:0] x1,x2,x,y;
   wire        ovf,udf,c;
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

   // DEBUG:
   logic [31:0] counter;
   wire [0:0] sign_x;
   wire [7:0] exponent_x;
   wire [22:0] mantissa_x;
   // wire [47:0] a1,b1,c1,a2,b2,c2;
   assign {sign_x, exponent_x, mantissa_x} = x2i;
   assign x = x2i;
   finv u1(x,y,ovf,udf);
   // finv u1(x,y,ovf,udf,opt1,opt2,opt3,opt4,opt5,opt6);

   initial begin
      // $dumpfile("test_fadd.vcd");
      // $dumpvars(0);

      $display("start of checking module fadd");
      $display("difference message format");
      $display("x1 = [input 1(bit)], [exponent 1(decimal)]");
      $display("x2 = [input 2(bit)], [exponent 2(decimal)]");
      $display("ref. : result(float) sign(bit),exponent(decimal),mantissa(bit) overflow(bit)");
      $display("fdiv : result(float) sign(bit),exponent(decimal),mantissa(bit) overflow(bit)");

      // counter = 0;
      // for (i=0; i<10000; i++) begin

      //    x1i = $shortrealtobits(1.0);  
      //    x2i = $urandom();

      //    // fx1 = $bitstoshortreal(x1i);
      //    fx1 = 1.0;
      //    fx2 = $bitstoshortreal(x2i);
      //    fy = fx1 / fx2;
      //    fybit = $shortrealtobits(fy);

      //    // checkovf = i < 255 && j < 255;
      //    // if ( checkovf && fybit[30:23] == 255 ) begin
      //    //    fovf = 1;
      //    // end else begin
      //    //    fovf = 0;
      //    // end
                        
      //    #1;

      //    if (y !== fybit) begin
      //       counter = counter + 1;
      //       $display("x1 = %b %b %b, %3d", x[31], x[30:23], x[22:0], x[30:23]);
      //       // DEBUG:
      //       // $display("a1 = %b %b(%d)", a1[47:24], a1[23:0], a1);
      //       // $display("b1 = %b %b(%d)", b1[47:24], b1[23:0], b1);
      //       // $display("c1 = %b %b(%d)", c1[47:24], c1[23:0], c1);
      //       // $display("a2 = %b %b(%d)", a2[47:24], a2[23:0], a2);
      //       // $display("b2 = %b %b(%d)", b2[47:24], b2[23:0], b2);
      //       // $display("c2 = %b %b(%d)", c2[47:24], c2[23:0], c2);
      //       // DEBUG:
      //       $display("%e %b %3d %b %b", fy, fybit[31], fybit[30:23], fybit[22:0], fovf);
      //       // $display("%e / %e = %e\n", fx1, fx2, fy);
      //       $display("%e %b %3d %b carry(%b) over(%b) under(%b)\n", $bitstoshortreal(y), y[31:31], y[30:23], y[22:0], c, ovf, udf);
      //       // $display("%e / %e = %e", $bitstoshortreal(1.0), $bitstoshortreal(x), $bitstoshortreal(y));
           
      //    end
      // end

      // for (i=0; i<256; i++) begin
      //    for (j=0; j<256; j++) begin
      //       for (s1=0; s1<2; s1++) begin
      //          for (s2=0; s2<2; s2++) begin
      //             for (it=0; it<10; it++) begin
      //                for (jt=0; jt<10; jt++) begin
      //                   #1;

      //                   case (it)
      //                     0 : m1 = 23'b0;
      //                     1 : m1 = {22'b0,1'b1};
      //                     2 : m1 = {21'b0,2'b10};
      //                     3 : m1 = {1'b0,3'b111,19'b0};
      //                     4 : m1 = {1'b1,22'b0};
      //                     5 : m1 = {2'b10,{21{1'b1}}};
      //                     6 : m1 = {23{1'b1}};
      //                     default : begin
      //                        if (i==256) begin
      //                           {m1,dum1} = 0;
      //                        end else begin
      //                           {m1,dum1} = $urandom();
      //                        end
      //                     end
      //                   endcase

      //                   case (jt)
      //                     0 : m2 = 23'b0;
      //                     1 : m2 = {22'b0,1'b1};
      //                     2 : m2 = {21'b0,2'b10};
      //                     3 : m2 = {1'b0,3'b111,19'b0};
      //                     4 : m2 = {1'b1,22'b0};
      //                     5 : m2 = {2'b10,{21{1'b1}}};
      //                     6 : m2 = {23{1'b1}};
      //                     default : begin
      //                        if (i==256) begin
      //                           {m2,dum2} = 0;
      //                        end else begin
      //                           {m2,dum2} = $urandom();
      //                        end
      //                     end
      //                   endcase
                        
      //                   x1i = {s1[0],i[7:0],m1};
      //                   x2i = {s2[0],j[7:0],m2};

      //                   fx1 = $bitstoshortreal(x1i);
      //                   fx2 = $bitstoshortreal(x2i);
      //                   fy = fx1 * fx2;
      //                   fybit = $shortrealtobits(fy);

		// 	checkovf = i < 255 && j < 255;
		// 	if ( checkovf && fybit[30:23] == 255 ) begin
		// 	   fovf = 1;
		// 	end else begin
		// 	   fovf = 0;
		// 	end
                        
      //                   #1;

      //                   // if (y !== fybit || ovf !== fovf) begin
      //                   if (y !== fybit) begin
      //                      $display("x1 = %b %b %b, %3d",
		// 		    x1[31], x1[30:23], x1[22:0], x1[30:23]);
      //                      $display("x2 = %b %b %b, %3d",
		// 		    x2[31], x2[30:23], x2[22:0], x2[30:23]);
      //                      // DEBUG:
      //                      // $display("ps = %b, sr = %b, sl = %b, cr = %b", ps, sr, sl, cr);
      //                      // $display("man1 = %b %b", man1[55:28], man1[27:0]);
      //                      // $display("man2 = %b %b", man2[55:28], man2[27:0]);
      //                      // $display("man3 = %b %b", man3[55:28], man3[27:0]);
      //                      // $display("%e %b,%3d,%b %b", fy,
		// 		    fybit[31], fybit[30:23], fybit[22:0], fovf);
      //                      $display("%e %b,%3d,%b %b\n", $bitstoshortreal(y),
		// 		    y[31], y[30:23], y[22:0], ovf);

      //                   end
      //                end
      //             end
      //          end
      //       end
      //    end
      //    //$finish;
      // end

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
      $display("counter: %d", counter);
      //$finish;
   end
endmodule

`default_nettype wire
