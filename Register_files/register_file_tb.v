`include "register_file.v"

module top;

reg [4:0] addr1, addr2, write_at_addr;
wire [31:0] out1, out2;
reg [31:0]write_data;
reg write_enable,reset;
integer j;

register_file regs (out1, out2, addr1, addr2, write_at_addr, write_data, write_enable,reset);

initial begin

	//to print values of all registers
	// for(j=0; j<32; j=j+2) begin
	// 	addr1=j;
	// 	addr2=j+1;
	// 	#5 $display("addr: %d\tdata: %d\naddr: %d\tdata: %d\n", addr1, out1, addr2, out2);
	// end
	//$display("addr: %d\tdata: %d\naddr: %d\tdata: %d\n", addr1, out1, addr2, out2);
	
	reset=1;

	#2 addr1 = 5'd8;
	#2 addr2 = 5'd10;
	#2 $display("addr: %d\tdata: %d\naddr: %d\tdata: %d\n", addr1, out1, addr2, out2);
	#1 reset=0;

	write_enable = 1'b1;
	write_at_addr = 5'd10;
	write_data = 32'd10;
	#2 $display("addr: %d\tdata: %d\naddr: %d\tdata: %d\n", addr1, out1, addr2, out2);
	#3	write_enable = 1'b0;

		#5 write_enable = 1'b1;
	#5 write_at_addr = 5'd8;
	#5 write_data = 32'd8;
	#5 $display("addr: %d\tdata: %d\naddr: %d\tdata: %d\n", addr1, out1, addr2, out2);
	#7 write_enable = 1'b0;

	#10 write_enable = 1'b1;
	#10 write_at_addr = 5'd8;
	#10 write_data = 32'd256;
	#12 write_enable = 1'b0;
	#10 $display("addr: %d\tdata: %d\naddr: %d\tdata: %d\n", addr1, out1, addr2, out2);

	
end

endmodule