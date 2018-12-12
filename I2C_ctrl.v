module I2C_ctrl(
	input reset,clk2,sda,clk1,
	input [15:0]data,
	output reg [7:0]reg_address,
	output reg sda_w,ctrl_h
);

reg [7:0]reg_address_next;
reg [2:0]fsm,fsm_next;
reg [4:0]add_con,add_con_next;
reg [7:0]address_ba;
reg [1:0]mode,mode_next;
reg sda_r,select_next;

always@(negedge clk2)
begin
	sda_r <= sda;
end

always@(posedge clk2,negedge reset)
begin
	if(~reset)
	begin
		fsm <= 4'd0;
		add_con <= 5'd7;
		address_ba <= 8'hba;
		reg_address <= 8'd0;
		mode <= 2'd0;
	end
	else
	begin
		fsm <= fsm_next;
		reg_address <= reg_address_next;
		add_con <= add_con_next;
		mode <= mode_next;
	end
end

always@(*)
begin
	case(fsm)
		3'd0:		//reset
		begin
			sda_w = 1'b1;
			ctrl_h = 1'b1;
			fsm_next = 3'd1;
			add_con_next = add_con;
			reg_address_next = reg_address;
			mode_next = mode;
		end
		3'd1:		//start
		begin
			sda_w = 1'b0;
			ctrl_h = 1'b1;
			fsm_next = 3'd2;
			add_con_next = add_con;
			reg_address_next = reg_address;
			mode_next = mode;
		end
		3'd2:		//8bit
		begin
			ctrl_h = 1'b0;
			if(add_con == 5'd0)
			begin
				add_con_next = 5'd7;
				fsm_next = 3'd3;
			end
			else
			begin
				add_con_next = add_con - 5'd1;
				fsm_next = fsm;
			end
			case(mode)
				2'd0:
				begin
					sda_w = address_ba[add_con];
				end
				2'd1:
				begin
					sda_w = reg_address[add_con];
				end
				2'd2:
				begin
					sda_w = data[add_con + 5'd8];
				end
				2'd3:
				begin
					sda_w = data[add_con];
				end
				default:
				begin
					sda_w = 1'b1;
				end
			endcase
			reg_address_next = reg_address;
			mode_next = mode;
		end
		3'd3:		//ack
		begin
			ctrl_h = 1'b0;
			sda_w = 1'b1;
			if(sda_r == 1'b1)
			begin
				fsm_next = 3'd0;
				mode_next = 2'd0;
				reg_address_next = reg_address;
			end
			else
			begin
				if(mode == 2'd3)
				begin
					fsm_next = 3'd4;
					mode_next = 2'd0;
					reg_address_next = reg_address + 8'd1;
				end
				else
				begin
					fsm_next = 3'd2;
					mode_next = mode + 2'd1;
					reg_address_next = reg_address;
				end
			end
			add_con_next = add_con;
		end
		3'd4:		//stop1
		begin
			sda_w = 1'b0;
			ctrl_h = 1'b1;
			fsm_next = 3'd5;
			add_con_next = add_con;
			reg_address_next = reg_address;
			mode_next = mode;
		end
		3'd5:		//stop2
		begin
			sda_w = 1'b1;
			ctrl_h = 1'b1;
			reg_address_next = reg_address;
			if(reg_address != 8'hff)
			begin
				fsm_next = 3'd1;
			end
			else
			begin
				fsm_next = 3'd6;
			end
			add_con_next = add_con;
			mode_next = mode;
		end
		default:
		begin
			sda_w = 1'b1;
			ctrl_h = 1'b1;
			fsm_next = fsm;
			add_con_next = add_con;
			reg_address_next = reg_address;
			mode_next = mode;
		end
	endcase
end

endmodule
