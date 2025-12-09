module foreach_test();

	initial begin
		int prod [1:8][1:3];
			foreach(prod[k, m]) begin
				prod[k][m] = k * m;
				$display("prod[%0d][%0d] = %d", k, m, prod[k][m]);
			end
	end

endmodule
