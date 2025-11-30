// dp ram
module dp_ram(
	write_clock,
	read_clock,
	dram_rst,
	write_allow,
	read_allow,
	write_addr,
	read_addr,
	write_data,
	read_data
);

parameter DLY			=	1;
parameter RAM_WIDTH		=	8;
parameter RAM_DEPTH		=	16;
parameter ADDR_WIDTH	=	4;

input						write_clock;
input						read_clock;
input						write_allow;
input						read_allow;
input						dram_rst;
input	[ADDR_WIDTH-1:0]	write_addr;
input	[ADDR_WIDTH-1:0]	read_addr;
input	[RAM_WIDTH-1:0]		write_data;
output	[RAM_WIDTH-1:0]		read_data;
reg		[RAM_WIDTH-1:0]		read_data;

reg 	[RAM_WIDTH-1:0]		memory [RAM_DEPTH-1:0];

always@(posedge write_clock) begin
	 if(write_allow)
		memory[write_addr] <= write_data;//#DLY write_data;
end

always@(posedge read_clock) begin
	if(read_allow)
		read_data <= memory[read_addr];//#DLY memory[read_addr];
end

endmodule
