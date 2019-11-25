module CONTROL (
		
	input wire [6:0] OPCODE,
	input wire RSTn,
	input wire CLK,
	input wire [4:0] RD1,
	input wire [4:0] RD2,
	input wire [4:0] PREV_DEST,
	input wire PREV_REWR_MUX,

	output wire [3:0] D_MEM_BE,
	output wire RF_WE, D_MEM_WEN, D_MEM_CSN, I_MEM_CSN, REWR_MUX, AMUX, ISJALR, CONDMUX, 
	output wire [6:0] ALU_CONTROL,
	output wire [1:0] BMUX,
	output wire IR_WR, PC_WR
	);


	reg[31:0] _NUMINST;
	reg[6:0] _ALU_CONTROL;
	reg[3:0] _D_MEM_BE;
	reg[1:0] _BMUX;
	reg _RF_WE, _D_MEM_WEN, _REWR_MUX, _AMUX, _IS_JALR, _CONDMUX, _STALL; 
	
	assign ALU_CONTROL = _ALU_CONTROL;
	assign IR_WR = ~_STALL;
	assign PC_WR = ~_STALL;
	assign RF_WE = _RF_WE;
	assign D_MEM_WEN = _D_MEM_WEN;
	assign D_MEM_BE = _D_MEM_BE;
	assign REWR_MUX = _REWR_MUX;
	assign AMUX = _AMUX;
	assign BMUX = _BMUX;
	assign IS_JALR = _IS_JALR;
	assign CONDMUX = _CONDMUX;
	assign D_MEM_CSN = ~RSTn;
	assign I_MEM_CSN = ~RSTn;

	initial begin
		_NUMINST <= 0;
		_ALU_CONTROL <=0;
		_RF_WE <= 0;
		_D_MEM_WEN <=0;
		_REWR_MUX <= 0;
		_AMUX <= 0;
		_BMUX <= 0;
		_IS_JALR <= 0;
		_CONDMUX <= 0;
		_NUMINST <= 0;
	end


	//TODO FLUSH, numinst	
	//TODO mux connection
	
	/*
	always@ (posedge CLK) begin
		if(RSTn) _NUMINST <= _NUMINST +1;
	always@ (*) begin
	*/

	always@ (*) begin
		case (OPCODE) 

		//add
		7'b0110011: begin
			_ALU_CONTROL <= OPCODE;
			_RF_WE <= 1;
			_D_MEM_WEN <= 1;
			_REWR_MUX <= 0;
			_AMUX <= 1;
			_BMUX <= 2'b11;
			_IS_JALR <= 0;
			// detect load data hazard
			_STALL <= ((RD1==PREV_DEST) | (RD2==PREV_DEST)) & PREV_REWR_MUX;  
		end

		//addi
		7'b0010011: begin
		_ALU_CONTROL <= OPCODE;
		_RF_WE <= 1;
		_D_MEM_WEN <= 1;
		_REWR_MUX <= 0;
		_AMUX <= 1;
		_BMUX <= 2'b00;
		_IS_JALR <= 0;
		// detect load data hazard
		_STALL <= (RD1==PREV_DEST) & PREV_REWR_MUX;  
		end

		//SW
		7'b0100011: begin
		_ALU_CONTROL <= OPCODE;
		_RF_WE <= 0;
		_D_MEM_WEN <= 0;
		_D_MEM_BE <= 4'b1111;
		_AMUX <= 1;
		_BMUX <= 2'b00;
		_IS_JALR <= 0;
		// detect load data hazard
		_STALL <= ((RD1==PREV_DEST) | (RD2==PREV_DEST)) & PREV_REWR_MUX;  
		end

		//LW
		7'b0000011: begin
		_ALU_CONTROL <= OPCODE;
		_RF_WE <= 1;
		_D_MEM_WEN <= 1;
		_REWR_MUX <= 1;
		_AMUX <= 1;
		_BMUX <= 2'b00;
		_IS_JALR <= 0;
		// detect load data hazard
		_STALL <= (RD1==PREV_DEST) & PREV_REWR_MUX;  
		end

		//BRANCH
		7'b1100011: begin
		_ALU_CONTROL <= OPCODE;
		_RF_WE <= 0;
		_D_MEM_WEN <= 1;
		_AMUX <= 0;
		_BMUX <= 2'b00;
		_IS_JALR <= 0;
		_CONDMUX <= 0;
		// detect load data hazard
		_STALL <= ((RD1==PREV_DEST) | (RD2==PREV_DEST)) & PREV_REWR_MUX;  
		end

		//JAL
		7'b1101111: begin
		_ALU_CONTROL <= OPCODE;
		_RF_WE <= 1;
		_D_MEM_WEN <= 1;
		_REWR_MUX <= 0;
		_AMUX <= 0;
		_BMUX <= 2'b01;
		_IS_JALR <= 0;
		_CONDMUX <= 0;
		// detect load data hazard
		_STALL <= (RD1==PREV_DEST) & PREV_REWR_MUX; 
		end

		//JALR
		7'b1100111: begin
		_ALU_CONTROL <= OPCODE;
		_RF_WE <= 1;
		_D_MEM_WEN <= 1;
		_REWR_MUX <= 0;
		_AMUX <= 0;
		_BMUX <= 2'b01;
		_IS_JALR <= 1;
		_CONDMUX <= 1;
		// detect load data hazard
		_STALL <= (RD1==PREV_DEST) & PREV_REWR_MUX; 
		end
		endcase
	end
endmodule
