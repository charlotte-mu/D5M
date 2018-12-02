module I2C_ctrl(
	input reset,clk2,sda,clk1,
	input [15:0]data,
	output reg [7:0]reg_address,
	output reg sda_w,ctrl_h
);

reg [2:0]fsm,fsm_next;
reg [4:0]add_con,add_con_next;
reg [7:0]address_7a,reg_address_next;
reg [1:0]mode,mode_next;
reg sda_r;

always@(negedge clk2)
begin
	sda_r <= sda;
end

always@(posedge clk2,negedge reset)
begin
	if(~reset)
	begin
		fsm <= 4'd0;
		add_con <= 4'd7;
		address_7a <= 8'hba;
		mode <= 2'd0;
		reg_address <= 8'h00;
	end
	else
	begin
		fsm <= fsm_next;
		add_con <= add_con_next;
		mode <= mode_next;
		reg_address <= reg_address_next;
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
			mode_next = mode;
			reg_address_next = reg_address;
		end
		3'd1:		//start
		begin
			sda_w = 1'b0;
			ctrl_h = 1'b1;
			fsm_next = 3'd2;
			add_con_next = add_con;
			mode_next = mode;
			reg_address_next = reg_address;
		end
		3'd2:		//8bit
		begin
			ctrl_h = 1'b0;
			if(add_con == 4'd0)
			begin
				case(mode)
					2'd0:
					begin
						fsm_next = 3'd3;
						reg_address_next = reg_address;
						mode_next = mode;
						add_con_next = 4'd7;
					end
					2'd1:
					begin
						fsm_next = 3'd2;
						reg_address_next = reg_address;
						mode_next = 2'd2;
						add_con_next = 4'd14;
					end
					2'd2:
					begin
						fsm_next = 3'd4;
						reg_address_next = reg_address + 8'd1;
						mode_next = 2'd0;
						add_con_next = 4'd7;
					end
					default:
					begin
						fsm_next = 3'd0;
						add_con_next = 4'd7;
					end
				endcase
			end
			else
			begin
				add_con_next = add_con - 4'd1;
				fsm_next = fsm;
			end
			case(mode)
				2'd0:
				begin
					sda_w = address_7a[add_con];
				end
				2'd1:
				begin
					sda_w = reg_address[add_con];
				end
				2'd2:
				begin
					sda_w = data[add_con];
				end
				default:
				begin
					sda_w = 1'b1;
				end
			endcase
		end
		3'd3:		//ack
		begin
			ctrl_h = 1'b0;
			sda_w = 1'b1;
			mode_next = 2'd1;
			if(sda_r == 1'b1)
			begin
				fsm_next = 3'd0;
			end
			else
			begin
				fsm_next = 3'd2;
			end
			add_con_next = add_con;
			reg_address_next = reg_address;
		end
		3'd4:		//stop1
		begin
			sda_w = 1'b0;
			ctrl_h = 1'b1;
			fsm_next = 3'd5;
			add_con_next = add_con;
			mode_next = mode;
			reg_address_next = reg_address;
		end
		3'd5:		//stop2
		begin
			sda_w = 1'b1;
			ctrl_h = 1'b1;
			if(reg_address != 10'd1023)
			begin
				fsm_next = 3'd1;
			end
			else
			begin
				fsm_next = 3'd6;
			end
			add_con_next = add_con;
			mode_next = mode;
			reg_address_next = reg_address;
		end
		default:
		begin
			sda_w = 1'b1;
			ctrl_h = 1'b1;
			fsm_next = fsm;
			add_con_next = add_con;
			mode_next = mode;
			reg_address_next = reg_address;
		end
	endcase
end

endmodule
