`include "D_Flipflop.v"
module rdcla (a, b_in, sum, cout, cin,clk);

	input [31:0] a, b_in;
	input cin,clk;
	wire [31:0] b;
	output reg [31:0] sum;
	output reg cout;
	genvar i;
    generate
    for(i=0;i<=31;i=i+1)begin
        //assign op[i]=o[i] and ~w_ov;
		assign b[i]= (!cin)*(b_in[i]) + (cin)*(!b_in[i]);
    end

    endgenerate
	wire [32:0] carry0, carry1;
	wire [32:0] carry0_1, carry1_1, carry0_2, carry1_2, carry0_4, carry1_4, carry0_8, carry1_8, carry0_16, carry1_16;
	wire [32:0] carry0_1d, carry1_1d, carry0_2d, carry1_2d, carry0_4d, carry1_4d, carry0_8d, carry1_8d, carry0_16d, carry1_16d;

	assign carry0[0] = cin;
	assign carry1[0] = cin;

	always @(*)
	begin

		sum = a^b;
		sum = sum[31:0]^carry0_16[31:0];
		cout = carry0_16[32];	

	end
	
	kpg_init init [32:1] (carry1[32:1], carry0[32:1], a[31:0], b[31:0], clk);

	assign carry1_1[0] = cin;
	assign carry0_1[0] = cin;
	assign carry1_2[1:0] = carry1_1[1:0];
	assign carry0_2[1:0] = carry0_1[1:0];
	assign carry1_4[3:0] = carry1_2[3:0];
	assign carry0_4[3:0] = carry0_2[3:0];
	assign carry1_8[7:0] = carry1_4[7:0];
	assign carry0_8[7:0] = carry0_4[7:0];
	assign carry1_16[15:0] = carry1_8[15:0];
	assign carry0_16[15:0] = carry0_8[15:0];

	kpg itr_1 [32:1] (carry1[32:1], carry0[32:1], carry1[31:0], carry0[31:0], carry1_1d[32:1], carry0_1d[32:1]);
	DFF DFF1 [32:1] (carry1_1d[32:1],clk,0,carry1_1[32:1]);
	DFF DFF2 [32:1] (carry0_1d[32:1],clk,0,carry0_1[32:1]);

	kpg itr_2 [32:2] (carry1_1[32:2], carry0_1[32:2], carry1_1[30:0], carry0_1[30:0], carry1_2d[32:2], carry0_2d[32:2]);
	DFF DFF3 [32:2] (carry1_2d[32:2],clk,1'b0,carry1_2[32:2]);
	DFF DFF4 [32:2] (carry0_2d[32:2],clk,1'b0,carry0_2[32:2]);

	kpg itr_4 [32:4] (carry1_2[32:4], carry0_2[32:4], carry1_2[28:0], carry0_2[28:0], carry1_4d[32:4], carry0_4d[32:4]);
	DFF DFF5 [32:4] (carry1_4d[32:4],clk,1'b0,carry1_4[32:4]);
	DFF DFF6 [32:4] (carry0_4d[32:4],clk,1'b0,carry0_4[32:4]);

	kpg itr_8 [32:8] (carry1_4[32:8], carry0_4[32:8], carry1_4[24:0], carry0_4[24:0], carry1_8d[32:8], carry0_8d[32:8]);
	DFF DFF7 [32:8] (carry1_8d[32:8],clk,1'b0,carry1_8[32:8]);
	DFF DFF8 [32:8] (carry0_8d[32:8],clk,1'b0,carry0_8[32:8]);

	kpg itr_16 [32:16] (carry1_8[32:16], carry0_8[32:16], carry1_8[16:0], carry0_8[16:0], carry1_16d[32:16], carry0_16d[32:16]);
	DFF DFF9 [32:16] (carry1_16d[32:16],clk,1'b0,carry1_16[32:16]);
	DFF DFF10 [32:16] (carry0_16d[32:16],clk,1'b0,carry0_16[32:16]);


endmodule

module kpg_init (
	output reg out1, out0,
	input a, b,clk
);
	always @(posedge clk)
	case ({a, b})
		2'b00: begin
			out0 = 1'b0; out1 = 1'b0;
		end
		2'b11: begin
			out0 = 1'b1; out1 = 1'b1;
		end
		default: begin 
			out0 = 1'b0; out1 = 1'b1;
		end
	endcase

endmodule

module kpg (
	input cur_bit_1, cur_bit_0, prev_bit_1, prev_bit_0,
	output reg out_bit_1, out_bit_0
);
	always @(*)
	begin
	
		if({cur_bit_1, cur_bit_0} == 2'b00)
			{out_bit_1, out_bit_0} = 2'b00;
		
		if({cur_bit_1, cur_bit_0} == 2'b11)
			{out_bit_1, out_bit_0} = 2'b11;

		if({cur_bit_1, cur_bit_0} == 2'b10)
			{out_bit_1, out_bit_0} = {prev_bit_1, prev_bit_0};

	end

endmodule

