`timescale 1ns/10ps

module syncfifo(
	fifo_rst,
	clock,
	read_enable,
	write_enable,
	write_data,
	read_data,
	full,
	empty,
	fifo_counter //counter the number of data in fifo
);

parameter	DATA_WIDTH = 8;
parameter	ADDR_WIDTH = 9;
parameter 	FIFO_DEPTH = (1 << ADDR_WIDTH) - 1;

input							fifo_rst;
input							clock;
input							read_enable;
input							write_enable;
input		[DATA_WIDTH-1:0]	write_data;
output reg	[DATA_WIDTH-1:0]	read_data;
output reg						full;
output reg						empty;
output reg	[ADDR_WIDTH-1:0]	fifo_counter;

reg			[ADDR_WIDTH-1:0]	read_addr;
reg			[ADDR_WIDTH-1:0]	write_addr;

wire	read_allow = (read_enable && !empty);
wire	write_allow = (write_enable && !full);

dp_ram #(
	.RAM_WIDTH(DATA_WIDTH),
	.RAM_DEPTH(FIFO_DEPTH),
	.ADDR_WIDTH(ADDR_WIDTH)
) u_dp_ram_1(
	.write_clock(clock),
	.read_clock(clock),
	.dram_rst(fifo_rst),
	.write_allow(write_allow),
	.read_allow(read_allow),
	.write_addr(write_addr),
	.read_addr(read_addr),
	.write_data(write_data),
	.read_data(read_data)
);

always@(posedge clock or posedge fifo_rst)
	if(fifo_rst) begin
		empty <= 1'b1;
	end
	else begin
		empty <= (fifo_counter == 9'b0);
	end

always@(posedge clock or posedge fifo_rst) begin
	if(fifo_rst) begin
		full <= 1'b0;
	end
	else begin
		full <= (fifo_counter == FIFO_DEPTH);
	end
end

always@(posedge clock or posedge fifo_rst) begin
	if(fifo_rst) begin
		read_addr <= 'b0;
	end
	else if(read_allow) begin
		read_addr <= read_addr + 'b1;
	end
end

always@(posedge clock or posedge fifo_rst) begin
	if(fifo_rst) begin
		write_addr <= 'b0;
	end
	else if(write_allow) begin
		write_addr <= write_addr + 'b1;
	end
end

always@(posedge clock or posedge fifo_rst) begin
	if(fifo_rst) begin
		fifo_counter <= 'h0;
	end
	else if((!read_allow && write_allow) || (read_allow && !write_allow)) begin
		if(write_allow)	begin
			if(fifo_counter >= FIFO_DEPTH)	fifo_counter <= FIFO_DEPTH;
			else							fifo_counter <= fifo_counter + 'b1;
		end
		else	fifo_counter <= fifo_counter - 'b1;
	end
end

endmodule
