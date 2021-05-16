`include "FP_adder.v"

module FP_adder_tb;
reg [31:0]a, b;
wire [31:0]out;

FP_adder FP1 (a, b, out);

initial
begin
	// a = 32'b0_10000000_11110000000000000000000;		// 3.875
	// b = 32'b0_10000000_11000000000000000000000;		// 3.5
	a =	32'b0_10000010_00111000000000000000000;
	b = 32'b0_01111110_00100000000000000000000;

	#5 $display("S: %b", out);
end


endmodule