// @nc app=nowcoder id=e5e86054a0ce4355b9dfc08238f25f5f topic=311 question=5000686 lang=Verilog
// 2026-08-20 00:45:12
// https://www.nowcoder.com/practice/e5e86054a0ce4355b9dfc08238f25f5f?tpId=311&tqId=5000686
// [VL68] 同步FIFO

// @nc code=start

`timescale 1ns/1ns

/**********************************RAM************************************/
module dual_port_RAM #(parameter DEPTH = 16,
					   parameter WIDTH = 8)(
	 input wclk
	,input wenc
	,input [$clog2(DEPTH)-1:0] waddr  
	,input [WIDTH-1:0] wdata      	
	,input rclk
	,input renc
	,input [$clog2(DEPTH)-1:0] raddr  
	,output reg [WIDTH-1:0] rdata 		
);

reg [WIDTH-1:0] RAM_MEM [0:DEPTH-1];

always @(posedge wclk) begin
	if(wenc)
		RAM_MEM[waddr] <= wdata;
end 

always @(posedge rclk) begin
	if(renc)
		rdata <= RAM_MEM[raddr];
end 

endmodule  

/**********************************SFIFO************************************/
module sfifo#(
	parameter	WIDTH = 8,
	parameter 	DEPTH = 16
)(
	input 					clk		, 
	input 					rst_n	,
	input 					winc	,
	input 			 		rinc	,
	input 		[WIDTH-1:0]	wdata	,

	output reg				wfull	,
	output reg				rempty	,
	output wire [WIDTH-1:0]	rdata
);

	parameter N = $clog2(DEPTH);

	reg [N:0] waddr;
	reg [N:0] raddr;

	

dual_port_RAM #(.DEPTH(DEPTH), .WIDTH(WIDTH)) u1(
	.wclk(clk),
	.wenc(winc),
	.waddr(waddr),
	.wdata(wdata),      	
	.rclk(clk),
	.renc(rinc),
	.raddr(raddr),  
	.rdata(rdata) 
);

//parameter L = (1 << N);
// always @(posedge clk or negedge rst_n) begin
// 	if(!rst_n) begin
// 		rempty <= 0;
// 		wfull <= 0;
// 	end else begin
// 		if(waddr == raddr)
// 			rempty <= 1;
// 		else if((waddr % L) == raddr) 
// 			wfull <= 1;
// 		else begin
// 			rempty <= 0;
// 			wfull <= 0;
// 		end
// 	end
// end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rempty <= 0;
		wfull <= 0;
	end else begin
		if(waddr[N-1:0] == raddr[N-1:0]) begin
			rempty <= (waddr[N] == raddr[N]);
			wfull <= !(waddr[N] == raddr[N]);
		end else begin
			rempty <= 0;
			wfull <= 0;
		end
	end
end


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		waddr <= 0;
		raddr <= 0;
	end else begin
		if(winc) begin
			waddr <= waddr + 1;
		end
		if(rinc) begin
			raddr <= raddr + 1;
		end
	end
end
    
endmodule

// @nc code=end
