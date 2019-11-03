module CONTROL (

	input wire [6:0] OPCODE,
	input wire RSTn,
	input wire CLK,

	output wire [3:0] _D_MEM_BE,
	output wire _MUX1, _MUX4, _ALU_WR, _PC_WR, _RF_WE, _PC_WRITE_COND, _IR_WR, _D_MEM_WEN, _REWR_MUX, _I_MEM_CSN, _D_MEM_CSN,  
	output wire [1:0] _MUX2, 
	output wire [10:0] _ALU_CONTROL
	);

	assign I_MEM_CSN = ~RSTn;
	assign D_MEM_CSN = ~RSTn;

	wire [3:0] CUR_STATE;
	wire [3:0] NXT_STATE;
	reg[3:0] CUR_STATE_REG;
	reg[3:0] NXT_STATE_REG;
	reg MUX1, MUX4, ALU_WR, PC_WR, RF_WE, PC_WRITE_COND, IR_WR, D_MEM_WEN, REWR_MUX, D_MEM_BE;
	reg [1:0] MUX2;
	reg [10:0] ALU_CONTROL;

	assign CUR_STATE = CUR_STATE_REG;
	assign NXT_STATE = NXT_STATE_REG;
	assign _MUX1 = MUX1;
	assign _MUX2 = MUX2;
	assign _MUX4 = MUX4;
	assign _ALU_WR = ALU_WR;
	assign _PC_WR = PC_WR;
	assign _RF_WE = RF_WE;
	assign _PC_WRITE_COND = PC_WRITE_COND;
	assign _IR_WR = IR_WR;
	assign _D_MEM_WEN = D_MEM_WEN;
	assign _REWR_MUX = REWR_MUX;
	assign _D_MEM_BE = D_MEM_BE;
	assign _ALU_CONTROL = ALU_CONTROL;

	initial begin
		CUR_STATE_REG = 1;
		NXT_STATE_REG = 1;
		MUX1 = 0;
		MUX2 = 0;
		MUX4 = 0;
		ALU_WR = 0; 
		PC_WR = 0;
		RF_WE = 0;
		PC_WRITE_COND = 0;
		IR_WR = 0;
		D_MEM_WEN = 0;
		REWR_MUX = 0;
		D_MEM_BE = 0;
		ALU_CONTROL = 0;
	end

	always@ (posedge CLK) begin
		CUR_STATE_REG = NXT_STATE;
	end

	always@ (*) begin
		case (CUR_STATE)

		4'b0001: begin //STATE 1
			MUX1 <= 0;
			MUX2 <= 0;
			ALU_WR <= 1;
			PC_WR <= 0;
			ALU_CONTROL <= {OPCODE, CUR_STATE};
			RF_WE <= 0;
			PC_WR <= 0;
			IR_WR <= 1;
			D_MEM_WEN <= 1;
			PC_WRITE_COND <= 0;

			case(OPCODE)
			7'b1101111:
				NXT_STATE_REG <= 4'b0011;
			7'b1100011:
				NXT_STATE_REG <= 4'b0100;
			default:
				NXT_STATE_REG <= 4'b0001;
			endcase
		end

		4'b0010: begin //STATE 2
			ALU_WR <= 0;
			PC_WR <= 1;
			RF_WE <= 0;
			PC_WRITE_COND <= 0;
			D_MEM_WEN <= 0;

			case(OPCODE)
			7'b0000000:
				NXT_STATE_REG <= 4'b0111;
			7'b0010011:
				NXT_STATE_REG <= 4'b0101;
			7'b0000011:
				NXT_STATE_REG <= 4'b0101;
			7'b0100011:
				NXT_STATE_REG <= 4'b0110;
			7'b1100111:
				NXT_STATE_REG <= 4'b1000;
			endcase
		end

		4'b0011: begin //STATE 3
			MUX1 <= 0;
			MUX2 <= 2'b10;
			MUX4 <= 0;
			ALU_WR <= 0;
			PC_WR <= 1;
			ALU_CONTROL <= {OPCODE, CUR_STATE};
			RF_WE <= 0;
			PC_WRITE_COND <= 0;
			IR_WR <= 0;
			D_MEM_WEN <= 1;
			NXT_STATE_REG <= 4'b1011;
		end
		
		4'b0100: begin //STATE 4
			MUX1 <= 0;
			MUX2 <= 2'b10;
			ALU_WR <= 1;
			PC_WR <= 1;
			ALU_CONTROL <= {OPCODE, CUR_STATE};
			RF_WE <= 0;
			PC_WRITE_COND <= 0;
			IR_WR <= 0;
			D_MEM_WEN <= 1;
			NXT_STATE_REG <= 4'b1001;
		end

		4'b0101: begin //STATE 5: LW EX
			MUX1 <= 1;
			MUX2 <= 2'b10;
			ALU_WR <= 1;
			PC_WR <= 0;
			ALU_CONTROL <= {OPCODE, CUR_STATE};
			RF_WE <= 0;
			PC_WRITE_COND <= 0;
			IR_WR <= 0;
			D_MEM_WEN <= 1;
			
			case (OPCODE)
			7'b0010011:
				NXT_STATE_REG <= 4'b1011;
			7'b0000011:
				NXT_STATE_REG <= 4'b1100;
			endcase
		end

		4'b0110: begin //STATE6: SW EX
			MUX1 <= 1;
			MUX2 <= 2'b10;
			ALU_WR <= 1;
			PC_WR <= 0;
			ALU_CONTROL <= {OPCODE, CUR_STATE};
			RF_WE <= 0;
			PC_WRITE_COND <= 0;
			IR_WR <= 0;
			D_MEM_WEN <= 1;
			NXT_STATE_REG <= 4'b1110;
		end

		4'b0111: begin //STATE7: R-type EX
			MUX1 <= 1;
			MUX2 <= 2'b01;
			ALU_WR <= 1;
			PC_WR <= 0;
			ALU_CONTROL <= {OPCODE, CUR_STATE};
			RF_WE <= 0;
			PC_WRITE_COND <= 0;
			IR_WR <= 0;
			D_MEM_WEN <= 1;
			NXT_STATE_REG <= 4'b1011;
		end

		4'b1000: begin //STATE8: JALR EX
			MUX1 <= 1;
			MUX2 <= 2'b10;
			MUX4 <= 0;
			ALU_WR <= 0;
			PC_WR <= 1;
			ALU_CONTROL <= {OPCODE, CUR_STATE};
			RF_WE <= 0;
			PC_WRITE_COND <= 0;
			IR_WR <= 0;
			D_MEM_WEN <= 1;
			NXT_STATE_REG <= 4'b1011;
		end

		4'b1001: begin //STATE9: BR EX
			MUX1 <= 1;
			MUX2 <= 2'b01;
			MUX4 <= 1;
			ALU_WR <= 0;
			PC_WR <= 0;
			ALU_CONTROL <= {OPCODE, CUR_STATE};
			RF_WE <= 0;
			PC_WRITE_COND <= 1;
			IR_WR <= 0;
			D_MEM_WEN <= 1;
			NXT_STATE_REG <= 4'b1010;
		end

		4'b1010: begin //STATE10: BR WB
			MUX1 <= 0;
			MUX2 <= 2'b00;
			ALU_WR <= 0;
			PC_WR <= 0;
			RF_WE <= 0;
			PC_WRITE_COND <= 0;
			IR_WR <= 0;
			D_MEM_WEN <= 1;
			NXT_STATE_REG <= 4'b0001;
		end

	
		4'b1011: begin //STATE11
			ALU_WR <= 0;
			PC_WR <= 0;
			RF_WE <= 1;
			PC_WRITE_COND <= 0;
			IR_WR <= 0;
			D_MEM_WEN <= 1;
			REWR_MUX <= 0;
			NXT_STATE_REG <= 4'b0001;
		end

	
		4'b1100: begin //STATE12 - LW MEM
			ALU_WR <= 0;
			PC_WR <= 0;
			RF_WE <= 0;
			PC_WRITE_COND <= 0;
			IR_WR <= 0;
			D_MEM_WEN <= 1;
			NXT_STATE_REG <= 4'b1101;
		end


		4'b1101: begin //STATE13: LW WB
			ALU_WR <= 0;
			PC_WR <= 0;
			RF_WE <= 1;
			PC_WRITE_COND <= 0;
			IR_WR <= 0;
			D_MEM_WEN <= 1;
			REWR_MUX <= 1;
			NXT_STATE_REG <= 4'b0001;
		end


		4'b1110: begin //STATE14: SW MEM
			ALU_WR <= 0;
			PC_WR <= 0;
			RF_WE <= 0;
			PC_WRITE_COND <= 0;
			IR_WR <= 0;
			D_MEM_WEN <= 0;
			D_MEM_BE <= 1;
			NXT_STATE_REG <= 4'b0001;
		end

	endcase
	end
endmodule


		
			

