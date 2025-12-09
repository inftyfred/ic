module enum_test();

typedef enum{IDLE, TEST, START} state_t;

enum bit [2:0] {s0='b001, s1='b010, s2='b100}st;
state_t c_st, n_st=IDLE;

initial begin
	$display("################");
	$display("st=%3b, n_st=%s", st.first(), n_st.name());
	$display("st=%3b, n_st=%s", st.last(),  n_st.name());
	$display("st=%3b, n_st=%s", c_st.next(2), n_st.first());
end

endmodule
