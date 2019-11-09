module CONTROL (

	input wire [6:0] OPCODE,
	input wire RSTn,
	input wire CLK,

	output wire [3:0] _D_MEM_BE,
	output wire _PC_WR, _RF_WE, _PC_WRITE_COND, _IR_WR, _D_MEM_WEN, _REWR_MUX, _I_MEM_CSN, _D_MEM_CSN,  
	output wire [1:0] _MUX1, _MUX2, _MUX4, 
	output wire [10:0] _ALU_CONTROL,
   output wire [31:0] NUM_INST
	);

	wire [3:0] CUR_STATE;
	wire [3:0] NXT_STATE;
	reg[3:0] CUR_STATE_REG;
	reg[3:0] NXT_STATE_REG;
	reg[3:0] D_MEM_BE;
	reg PC_WR, RF_WE, PC_WRITE_COND, IR_WR, D_MEM_WEN, REWR_MUX;
	reg [1:0] MUX4, MUX2, MUX1;
	reg [10:0] ALU_CONTROL;
   reg [31:0] _NUMINST;

	assign CUR_STATE = CUR_STATE_REG;
	assign NXT_STATE = NXT_STATE_REG;
	assign _MUX1 = MUX1;
	assign _MUX2 = MUX2;
	assign _MUX4 = MUX4;
	assign _PC_WR = PC_WR;
	assign _RF_WE = RF_WE;
	assign _PC_WRITE_COND = PC_WRITE_COND;
	assign _IR_WR = IR_WR;
	assign _D_MEM_WEN = D_MEM_WEN;
	assign _REWR_MUX = REWR_MUX;
	assign _D_MEM_BE = D_MEM_BE;
	assign _ALU_CONTROL = ALU_CONTROL;
   assign NUM_INST = _NUMINST; 
	assign _I_MEM_CSN = ~RSTn;
	assign _D_MEM_CSN = ~RSTn;
		

	initial begin
      _NUMINST <= 0;
		CUR_STATE_REG <= 1;
		NXT_STATE_REG <= 1;
		MUX1 <= 0;
		MUX2 <= 0;
		MUX4 <= 0;
		PC_WR <= 0;
		RF_WE <= 0;
		PC_WRITE_COND <= 0;
		IR_WR <= 0;
		D_MEM_WEN <= 0;
		REWR_MUX <= 0;
		D_MEM_BE <= 0;
		ALU_CONTROL <= 0;

	end

    always@ (negedge CLK) begin
        if (RSTn & NXT_STATE_REG == 1) _NUMINST <= _NUMINST + 1;
    end

	always@ (posedge CLK) begin
		CUR_STATE_REG = NXT_STATE;
	end

	always@ (*) begin
		case (CUR_STATE)
		
		4'b0001: begin //stage1
		MUX1 <= 2'b00;
		MUX2 <= 2'b00;
		PC_WR <= 0;
		ALU_CONTROL <= {OPCODE, CUR_STATE};
		RF_WE <= 0;
		PC_WRITE_COND <= 0;
		IR_WR <= 1;
		D_MEM_WEN <= 1;
		if (RSTn) NXT_STATE_REG <= 4'b0010;
		else NXT_STATE_REG <= 4'b0001;
		end

		4'b0010: begin
		MUX1 <= 2'b00;
		MUX2 <= 2'b10;
		MUX4 <= 2'b10;
		PC_WR <= 1;
		ALU_CONTROL <= {OPCODE, CUR_STATE};
		RF_WE <= 0;
		PC_WRITE_COND <= 0;
		IR_WR <= 0;
		D_MEM_WEN <= 1;
		case (OPCODE)
		7'b1101111: //JAL
			NXT_STATE_REG <= 4'b0011;
		7'b0010011: //I_TYPE
			NXT_STATE_REG <= 4'b0101;
		7'b0110011: //R_TYPE
			NXT_STATE_REG <= 4'b0111;
		7'b1100111: //JALR
			NXT_STATE_REG <= 4'b1000;
		7'b1100011: //BR
			NXT_STATE_REG <= 4'b1001;
		7'b0000011: //LD
			NXT_STATE_REG <= 4'b0101;
		7'b0100011: //SW
			NXT_STATE_REG <= 4'b0101;
		default:
			NXT_STATE_REG <= 4'b0001;
		endcase
		end

		4'b0011: begin
		MUX1 <= 2'b00;
		MUX2 <= 2'b11;
		MUX4 <= 2'b10;
		PC_WR <= 1;
		ALU_CONTROL <= {OPCODE, CUR_STATE};
		RF_WE <= 0;
		PC_WRITE_COND <= 0;
		IR_WR <= 0;
		D_MEM_WEN <= 1;
		NXT_STATE_REG <= 4'b1011;
		end

		4'b0100: begin
		PC_WR <= 0;
		RF_WE <= 0;
		PC_WRITE_COND <= 0;
		IR_WR <= 0;
		D_MEM_WEN <= 0;
		D_MEM_BE <= 4'b1111;
		NXT_STATE_REG <= 4'b0001;
		end

		4'b0101: begin
		MUX1 <= 2'b01;
		MUX2 <= 2'b10;
		PC_WR <= 0;
		ALU_CONTROL <= {OPCODE, CUR_STATE};
		RF_WE <= 0;
		PC_WRITE_COND <= 0;
		IR_WR <= 0;
		D_MEM_WEN <= 1;
		case (OPCODE)
		7'b0100011: //SW
			NXT_STATE_REG <= 4'b0100;
		7'b0000011: begin //LD
			NXT_STATE_REG <= 4'b1100;
		end
		7'b0010011: //I_TYPE
			NXT_STATE_REG <= 4'b1011;
		endcase
		end

		4'b0110: begin
		PC_WR <= 0;
		RF_WE <= 1;
		PC_WRITE_COND <= 0;
		IR_WR <= 0;
		D_MEM_WEN <= 1;
		REWR_MUX <= 1;
		NXT_STATE_REG <= 4'b0001;
		end

		4'b0111: begin
		MUX1 <= 2'b01;
		MUX2 <= 2'b01;
		PC_WR <= 0;
		ALU_CONTROL <= {OPCODE, CUR_STATE};
		RF_WE <= 0;
		PC_WRITE_COND <= 0;
		IR_WR <= 0;
		D_MEM_WEN <= 1;
		NXT_STATE_REG <= 4'b1011;
		end

		4'b1000: begin
		MUX1 <= 2'b00;
		MUX2 <= 2'b11;
		MUX4 <= 2'b01;
		PC_WR <= 1;
		ALU_CONTROL <= {OPCODE, CUR_STATE};
		RF_WE <= 0;
		PC_WRITE_COND <= 0;
		IR_WR <= 0;
		D_MEM_WEN <= 1;
		NXT_STATE_REG <= 4'b1011;
		end

		4'b1001: begin
		MUX1 <= 2'b01;
		MUX2 <= 2'b01;
		MUX4 <= 2'b10;
		PC_WR <= 0;
		ALU_CONTROL <= {OPCODE, CUR_STATE};
		RF_WE <= 0;
		PC_WRITE_COND <= 1;
		IR_WR <= 0;
		D_MEM_WEN <= 1;
		NXT_STATE_REG <= 4'b1010;
		end

		4'b1010: begin
		MUX1 <= 2'b00;
		MUX2 <= 2'b00;
		PC_WR <= 0;
		RF_WE <= 0;
		PC_WRITE_COND <= 0;
		IR_WR <= 0;
		D_MEM_WEN <= 1;
		NXT_STATE_REG <= 4'b0001;
		end

		4'b1011: begin
		MUX1 <= 2'b10;
		MUX2 <= 2'b11;
		PC_WR <= 0;
		RF_WE <= 1;
		PC_WRITE_COND <= 0;
		IR_WR <= 0;
		ALU_CONTROL <= {OPCODE, CUR_STATE};
		D_MEM_WEN <= 1;
		REWR_MUX <= 0;
		NXT_STATE_REG <= 4'b0001;
		end

		4'b1100: begin
		PC_WR <= 0;
		RF_WE <= 0;
		PC_WRITE_COND <= 0;
		IR_WR <= 0;
		D_MEM_WEN <= 1;
		NXT_STATE_REG <= 4'b0110;
		end

		endcase
	end
endmodule


		
			

