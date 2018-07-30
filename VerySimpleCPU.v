module  VerySimpleCPU(clk , rst , data_fromRAM , wrEn , addr_toRAM , data_toRAM);

	parameter  SIZE = 14;
	input clk , rst;
	input  wire  [31:0]  data_fromRAM;
	output  reg  wrEn;
	output  reg [SIZE -1:0]  addr_toRAM;
	output  reg  [31:0]  data_toRAM;


	reg  [3:0]  state_current , state_next;
	reg [SIZE -1:0]  pc_current , pc_next; // pc: program  counter
	reg  [31:0]  iw_current , iw_next; // iw: instruction  word
	reg  [31:0]  r1_current , r1_next;
	reg  [31:0]  r2_current , r2_next;

	always@(posedge  clk) begin

		if(rst) begin
			state_current  <= 0;
			pc_current  <= 14'b0;
			iw_current  <= 32'b0;
			r1_current  <= 32'b0;
			r2_current  <= 32'b0;
		end

		else  begin
			state_current  <= state_next;
			pc_current  <= pc_next;
			iw_current  <= iw_next;
			r1_current  <= r1_next;
			r2_current  <= r2_next;
		end
	end

	always@ (*)  begin

		state_next = state_current;
		pc_next = pc_current;
		iw_next = iw_current;
		r1_next = r1_current;
		r2_next = r2_current;
		wrEn = 0;
		addr_toRAM = 0;
		data_toRAM = 0;
		case(state_current)
			0: begin
				pc_next = 0;
				iw_next = 0;
				r1_next = 0;
				r2_next = 0;
				state_next = 1;
			end
			1: begin
				addr_toRAM = pc_current;
				state_next = 2;
			end
			2: begin
				iw_next = data_fromRAM;
				case(data_fromRAM [31:28])
					{3'b000 ,1'b0}: begin
					addr_toRAM = data_fromRAM [27:14];		//ADD
					state_next = 3;
					end
					{3'b000 ,1'b1}: begin
					addr_toRAM = data_fromRAM [27:14];		//ADDi
					state_next = 3;
					end
					{3'b001 ,1'b0}: begin
					addr_toRAM = data_fromRAM [27:14];		//NAND
					state_next = 3;
					end
					{3'b001 ,1'b1}: begin
					addr_toRAM = data_fromRAM [27:14];		//NANDÝ
					state_next = 3;
					end
					{3'b010 ,1'b0}: begin
					addr_toRAM = data_fromRAM [27:14];		//SRL
					state_next = 3;
					end
					{3'b010 ,1'b1}: begin
					addr_toRAM = data_fromRAM [27:14];		//SRLÝ
					state_next = 3;
					end
					{3'b011 ,1'b0}: begin
					addr_toRAM = data_fromRAM [27:14];		//LT
					state_next = 3;
					end
					{3'b011 ,1'b1}: begin
					addr_toRAM = data_fromRAM [27:14];		//LTÝ
					state_next = 3;
					end
					{3'b111 ,1'b0}: begin
					addr_toRAM = data_fromRAM [27:14];		//MUL
					state_next = 3;
					end
					{3'b111 ,1'b1}: begin
					addr_toRAM = data_fromRAM [27:14];		//MULi
					state_next = 3;
					end
					{3'b100 ,1'b0}: begin
					addr_toRAM = data_fromRAM [27:14];		//CP
					state_next = 3;
					end
					{3'b100 ,1'b1}: begin
					addr_toRAM = data_fromRAM [27:14];		//CPi
					state_next = 3;
					end
					{3'b101 ,1'b0}: begin
					addr_toRAM = data_fromRAM [13:0];		//CPI
					state_next = 3;
					end
					{3'b101 ,1'b1}: begin
					addr_toRAM = data_fromRAM [27:14];		//CPIi
					state_next = 3;
					end
					{3'b110 ,1'b0}: begin
					addr_toRAM = data_fromRAM [27:14];		//BZJ
					state_next = 3;
					end
					{3'b110 ,1'b1}: begin
					addr_toRAM = data_fromRAM [27:14];		//BZJi
					state_next = 3;
					end
				default: begin
					pc_next = pc_current;
					state_next = 1;
					end
				endcase
		end
		3:begin
			case(iw_current [31:28])
				{3'b101 ,1'b0}: begin	
					addr_toRAM = data_fromRAM;
					state_next = 4;
					
				end
				default: begin
					r1_next = data_fromRAM;
					addr_toRAM = iw_current [13:0];
					state_next = 4;
				end
			endcase
				

			end
		4: begin
			case(iw_current [31:28])
				{3'b000 ,1'b0}: begin									//ADD
				wrEn = 1;
				addr_toRAM = iw_current [27:14];
				data_toRAM = data_fromRAM + r1_current;
				pc_next = pc_current + 1'b1;
				state_next = 1;
				end
				{3'b000 ,1'b1}: begin									//ADDÝ
				wrEn = 1;
				addr_toRAM = iw_current [27:14];
				data_toRAM = iw_current [13:0] + r1_current;
				pc_next = pc_current + 1'b1;
				state_next = 1;
				end
				{3'b001 ,1'b0}: begin									//NAND
				wrEn = 1;
				addr_toRAM = iw_current [27:14];
				data_toRAM = ~(data_fromRAM & r1_current);
				pc_next = pc_current + 1'b1;
				state_next = 1;
				end
				{3'b001 ,1'b1}: begin									//NANDÝ       (r1_current = A)
				wrEn = 1;
				addr_toRAM = iw_current [27:14];
				data_toRAM = ~(iw_current [13:0] & r1_current);
				pc_next = pc_current + 1'b1;
				state_next = 1;
				end
				{3'b010 ,1'b0}: begin									//SRL       (data_fromRAM = B)    DIREKT B ::::: (iw_current [13:0])
				wrEn = 1;
				addr_toRAM = iw_current [27:14];
				data_toRAM = (data_fromRAM < 32) ? (r1_current >> data_fromRAM) : (r1_current << data_fromRAM-32);
				pc_next = pc_current + 1'b1;
				state_next = 1;
				end
				{3'b010 ,1'b1}: begin									//SRLÝ
				wrEn = 1;
				addr_toRAM = iw_current [27:14];
				data_toRAM = (iw_current [13:0] < 32) ? (r1_current >> iw_current [13:0]) : (r1_current << iw_current [13:0]-32);
				pc_next = pc_current + 1'b1;
				state_next = 1;
				end
				{3'b011 ,1'b0}: begin									//LT
				wrEn = 1;
				addr_toRAM = iw_current [27:14];
				data_toRAM = r1_current;
				data_toRAM = (r1_current < data_fromRAM) ? 1 : 0;
				pc_next = pc_current + 1'b1;
				state_next = 1;
				end
				{3'b011 ,1'b1}: begin									//LTÝ
				wrEn = 1;
				addr_toRAM = iw_current [27:14];
				data_toRAM = (r1_current < iw_current [13:0]) ? 1 : 0;
				pc_next = pc_current + 1'b1;
				state_next = 1;
				end
				{3'b111 ,1'b0}: begin									//MUL
				wrEn = 1;
				addr_toRAM = iw_current [27:14];
				data_toRAM = data_fromRAM * r1_current;
				pc_next = pc_current + 1'b1;
				state_next = 1;
				end
				{3'b111 ,1'b1}: begin									//MULÝ
				wrEn = 1;
				addr_toRAM = iw_current [27:14];
				data_toRAM = iw_current [13:0] * r1_current;
				pc_next = pc_current + 1'b1;
				state_next = 1;
				end
				{3'b100 ,1'b0}: begin									//CP
				wrEn = 1;
				addr_toRAM = iw_current [27:14];
				data_toRAM = data_fromRAM;
				pc_next = pc_current + 1'b1;
				state_next = 1;
				end
				{3'b100 ,1'b1}: begin									//CPi
				wrEn = 1;
				addr_toRAM = iw_current [27:14];
				data_toRAM = iw_current [13:0];
				pc_next = pc_current + 1'b1;
				state_next = 1;
				end
				{3'b101 ,1'b0}: begin									//CPI (BU DA OLDU)
				wrEn = 1;
				addr_toRAM = iw_current [27:14];
				data_toRAM = data_fromRAM;
				pc_next = pc_current + 1'b1;
				state_next = 1;
				end
				{3'b101 ,1'b1}: begin									//CPIi
				wrEn = 1;
				addr_toRAM = r1_current;
				data_toRAM = data_fromRAM;
				pc_next = pc_current + 1'b1;
				state_next = 1;
				end
				{3'b110 ,1'b0}: begin									//BZJ
				pc_next = (data_fromRAM == 0) ? r1_current : (pc_current + 1);
				state_next = 1;
				end
				{3'b110 ,1'b1}: begin									//BZJi
				pc_next = iw_current [13:0] + r1_current;
				state_next = 1;
				end
			endcase
		end
 endcase
end

endmodule
