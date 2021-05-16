`include "wallace.v"
`include "adder_8bit.v"
module fp_multiplier(input [31:0] a,input [31:0] b,output [31:0]out);

	wire S3,overflow;
	wire [47:0] product,wallace_out;
	wire [7:0] exponent1,exponent2;
	wire [15:0] trim;
	wire [22:0] prod;
	wire [31:0] out1,out2,out3;

	//sign of output is xor output
	xor (S3,a[31],b[31]);
	//multiplying mantissa parts
	wallace w1({8'b0,1'b1,a[22:0]},{8'b0,1'b1,b[22:0]},{trim,product});
	
	assign overflow=product[47];
	assign wallace_out=product;
	
	//adding exponents(and overflow if any) and subtracting 127 from it
	adder_8bit adder1(a[30:23],b[30:23],overflow,exponent1);
	adder_8bit subtract_127(exponent1,8'b10000000,1'b1,exponent2);
	
	//selecting 23 bits based on overflow
	shifter_1bit shift [22:0] (prod[22:0],overflow, wallace_out[45:23], wallace_out[46:24]);

	assign out1={S3,exponent2,prod};
	
	check_zero check1(out2,a,b,out1); //zero multiplication case
	check_inf check2(out3,a,b,out2); //multiplication with infinity
	check_nan check3(out,a,b,out3); //zero*infinity case


endmodule

//selecting 23 bits based on overflow
module shifter_1bit(output prod,input overflow,input out1,input out2);
	
	assign prod = (!overflow & out1) | (overflow & out2);

endmodule

//multiplication by 0
module check_zero(output [31:0] out,input [31:0] a,	input [31:0] b,	input [31:0] prod);
	
	//if exponent part is all-zeroes
	wire is_zero = ((|a[30:23]) & (|b[30:23]));		// if zero => is_zero=0
	assign out = (prod & {32{is_zero}}) | (32'b0_00000000_00000000000000000000000 & {32{!is_zero}});

endmodule

//multiplication by infinity
module check_inf(output [31:0] out,input [31:0] a,	input [31:0] b,input [31:0] prod);

	//if exponent part is all-ones
	wire is_inf = ((&a[30:23]) | (&b[30:23]));		// if inf => is_inf=1
	assign out = (prod & {32{!is_inf}}) | ({a[31] ^ b[31], 31'b11111111_00000000000000000000000} & {32{is_inf}});

endmodule

//zero*infinity=NaN
module check_nan(output [31:0] out,input [31:0] a,	input [31:0] b,	input [31:0] prod);

	//exponent of a number is all-ones and other is all-zeroes
	wire is_nan = ((&a[30:23]) & !(|b[30:23])) || (!(|a[30:23]) & (&b[30:23]));		// if nan => is_nan = 1
	assign out = (prod & {32{!is_nan}}) | ({32'b0_11111111_11111111111111111111111} & {32{is_nan}});

endmodule