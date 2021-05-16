`include "32rdcla.v"
`include "24bit-barrel-shift.v"

module FP_adder(input [31:0] a, input [31:0] b, output reg [31:0] out);

	reg S1, S2, S3, SX;
	reg [7:0] E1, E2, E3, D1, D2;
	reg [23:0] M1, M2, M3, MX, MY,MY2;
	reg [24:0] MXY;
	wire [24:0] TEST;
	reg [24:0] FIN;
	wire [23:0] Mshift1,Mshift2;
	wire [24:0] MXYshift;
	integer q;
	reg cin;
	wire [6:0]dummy;
	
	rdcla r ({dummy, TEST}, , {8'b0, MX}, {8'b0, MY2}, cin);//addition 
	barrelRight br1 (M1,D1[4:0],Mshift1);//right shift
	barrelRight br2 (M2,D2[4:0],Mshift2);//right shift
	barrelLeft bl1(MXY,q[4:0],MXYshift);//left shift

	always@(*) begin
		//split the number as sign,exponent and mantissa
		// 1 sign bit
		S1 = a[31];
		S2 = b[31];
		// 8 bits for exponent
		E1 = a[30:23];
		E2 = b[30:23];
		// 23 bits mantissa + a bit for 1
		M1[23] = 1'b1;
		M2[23] = 1'b1;
		M1[22:0] = a[22:0];
		M2[22:0] = b[22:0];
		
		if(&E1 == 1 || &E2 == 1) begin //infinity case
			out = 32'b0_11111111_11111111111111111111111;
		end

		else if((|E1==0)&&(|M1[22:0]==0)) begin //first input is zero
			out={S2,E2,M2[22:0]};
		end

		else if((|E2==0)&&(|M2[22:0]==0)) begin //second input is zero
			out={S1,E1,M1[22:0]};
		end

		else begin 
			if(E1 == E2) begin //if exponents are equal
				//#1 $display("EQUAL");
				MX = M1;
				MY = M2;
				E3 = E1 + 1'b1;
			end

			else if(E1 > E2) begin //if exponents are not equal
				D2 = E1 - E2;
				if(D2>32'd24)begin
					D2=32'd24;
				end
				MX = M1;
				MY=Mshift2; //shift the matissa, difference number of times
				//MY = M2 >> D2;
				E3 = E1 + 1'b1;
				S3 = S1;
			end

			else begin
				D1 = E2 - E1;
				if(D1>32'd24)begin
					D1=32'd24;
				end
				MX = M2;
				MY=Mshift1; //shift the matissa, difference number of times
				//MY = M1 >> D1;
				E3 = E2 +1'b1;
				S3 = S2;
			end

			// Addition/Subtraction based on signs
			SX = S1 ^ S2;
			
			if(SX == 0) begin
				cin=0;
				MY2=MY;
				MXY = TEST; //adding using rdcla and assign to MXY
				S3 = S1;
			end

			else begin
				//MXY = MX - MY;
				cin=1;
				MY2=(MY^24'hffffff);//2's complement of MY 
				MXY={1'b0,TEST[23:0]};
			
				if(E1 == E2) begin //if exponents are equal
					if(M1 > M2) begin //compare mantissa
						S3 = S1;				//and assign the sign of greater number
					end
					else begin
						S3 = S2;
					end
				end
			end
		
			//Normalising the result
			q = 24;
			while (q>=0 && MXY[q] == 0) begin
				E3-=1;
				q -= 1;
			end
			
			//first 1 is found at qth index, so left shift 24-q times
			q = 24-q;
			FIN = MXYshift;
			
			if(FIN[24] == 0) begin //output is zero
				out = 32'b0;
			end
			else begin
				out = {S3, E3, FIN[23:1]};
			end
		end
	end

endmodule