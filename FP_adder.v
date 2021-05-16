
module FP_adder(input [31:0] a,input [31:0] b,output reg [31:0] out);

	reg S1,S2,S3,SX;
	reg [7:0] E1,E2,E3,D;
	reg [23:0] M1,M2,M3,MX,MY;
	reg [24:0] MXY;

	initial
	$monitor("A: %b %b %b\nB: %b %b %b",S1,E1,M1,S2,E2,M2);
	
	always@(*) begin

		// 1 sign bit
		S1=a[31];
		S2=b[31];
		// 8 bits for exponent
		E1=a[30:23];
		E2=b[30:23];
		// 23 bits mantissa + a bit for 1
		M1[23]=1'b1;
		M2[23]=1'b1;
		M1[22:0]=a[22:0];
		M2[22:0]=b[22:0];
		
		if(E1==E2) begin
			#5 $display("EQUAL");
			MX = M1;
			MY = M2;
			E3 = E1+1'b1;
		end

		else if(E1>E2) begin
			D=E1-E2;
		 	MX=M1;
		 	MY=M2>>D;
		 	E3=E1+1'b1;
		 	S3=S1;
		end

		else begin
			D=E2-E1;
			MX=M2;
			MY=M1>>D;
			E3=E2;
			S3=S2;
		end

		// Addition/Subtraction
		SX=S1^S2;
		if(SX==0) begin
			MXY=MX+MY;
			S3=S1;
		end
		else begin
			MXY=MX-MY;
			if(E1==E2) begin
				if(M1>M2) begin
					S3=S1;
				end
				else begin
					S3=S2;
				end
			end
		end

		repeat(24)
		if(MXY[24]==0) begin
			MXY=MXY<<1;
			E3=E3-1;
		end
		out={S3,E3,MXY[23:1]};
		$monitor("S: %b %b %b", S3, E3, MXY[23:1]);
	end
	
	

	



endmodule