module TOP(
	input reset,ck,
	output scl,
	inout sda
);

wire [7:0]reg_address;
wire [15:0]data;
wire clk1,clk2;
wire scl_w,sda_w,ctrl_h;

assign sda = (sda_w)? 1'bz : 1'b0;
assign scl = (scl_w)? 1'bz : 1'b0;
assign scl_w =(ctrl_h | clk1);


divider add3(
	.ck(ck),
	.reset(reset),
	.clk1(clk1),
	.clk2(clk2)
);


I2C_ctrl add1(
	.reset(reset),
	.clk2(clk2),
	.sda(sda),
	.clk1(clk1),
	.data(data),
	.reg_address(reg_address),
	.sda_w(sda_w),
	.ctrl_h(ctrl_h)
);

D5M_rom add2(
	.address(reg_address),
	.data_out(data)
);

endmodule
