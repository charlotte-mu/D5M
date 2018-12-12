module divider(
	input ck,reset,
	output reg clk1,clk2
);

parameter cnt = 125;

reg [9:0]data1,data2;
reg r1,r2;

always@(posedge ck,negedge reset)
begin
	if(~reset)
	begin
		data1 <= 10'd0;
		clk1 <= 1'b0;
		//
		data2 <= 10'd0;
		clk2 <= 1'b0;
		r1 <= 1'd1;
		r2 <= 1'd0;
	end
	else
	begin
		if(data1 == cnt)
		begin
			data1 <= 10'd0;
			if(r2 < 1'd1)
				r2 <= r2 + 1'd1;
			else
			begin
				clk1 <= ~clk1;
				r2 <= 1'd0;
			end
		end
		else
		begin
			data1 <= data1 + 10'd1;
		end
		//
		if(data2 == cnt)
		begin
			data2 <= 10'd0;
			if(r1 < 1'd1)
				r1 <= r1 + 1'd1;
			else
			begin
				clk2 <= ~clk2;
				r1 <= 1'd0;
			end
		end
		else
		begin
			data2 <= data2 + 10'd1;
		end
	end
end

endmodule
