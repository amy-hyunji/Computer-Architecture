module CONTROL (
		
	input wire [6:0] OPCODE,
	input wire RSTn,
	input wire CLK,
	input wire [4:0] RD1,
	input wire [4:0] RD2,
	input wire [4:0] PREV_DEST,
	input wire [1:0] PREV_REWR_MUX,
    input wire ZERO,

	output wire [3:0] D_MEM_BE,
	output wire RF_WE, D_MEM_WEN, D_MEM_CSN, I_MEM_CSN, AMUX, ISJALR, CONDMUX, 
	output wire [6:0] ALU_CONTROL,
	output wire [1:0] BMUX, REWR_MUX,
	output wire IR_WR, PC_WR, FLUSH, NUMINSTADD, PCMUX
	);


	reg[6:0] _ALU_CONTROL;
	reg[3:0] _D_MEM_BE;
	reg[1:0] _BMUX, _REWR_MUX;
	reg _RE_WE, _D_MEM_WEN, _AMUX, _IS_JALR, _CONDMUX, _STALL, _FLUSH, _NUMINSTADD, _PCMUX; 
	
	assign ALU_CONTROL = _ALU_CONTROL;
	assign IR_WR = ~_STALL;
	assign PC_WR = ~_STALL;
	assign RF_WE = _RE_WE;
	assign D_MEM_WEN = _D_MEM_WEN;
	assign D_MEM_BE = _D_MEM_BE;
	assign REWR_MUX = _REWR_MUX;
	assign AMUX = _AMUX;
	assign BMUX = _BMUX;
	assign IS_JALR = _IS_JALR;
	assign CONDMUX = _CONDMUX;
	assign D_MEM_CSN = ~RSTn;
	assign I_MEM_CSN = ~RSTn;
    assign FLUSH = _FLUSH;
    assign NUMINSTADD = _NUMINSTADD;
    assign PCMUX = _PCMUX;

	initial begin
		_ALU_CONTROL <=0;
		_RE_WE <= 0;
		_D_MEM_WEN <=0;
		_REWR_MUX <= 0;
		_AMUX <= 0;
		_BMUX <= 0;
		_IS_JALR <= 0;
		_CONDMUX <= 0;
		_NUMINSTADD <= 0;
        _FLUSH <= 0;
        _D_MEM_BE <= 0;
        _PCMUX <= 0;
	end


	//TODO FLUSH, numinst	
	//TODO mux connection
	
	always@ (*) begin
		case (OPCODE) 

		//add
		7'b0110011: begin
			_ALU_CONTROL = OPCODE;
			_RE_WE = 1;
			_D_MEM_WEN = 1;
			_REWR_MUX = 2'b10;
			_AMUX = 1;
			_BMUX = 2'b11;
			_IS_JALR = 0;
            _NUMINSTADD = 1;
			// detect load data hazard
			_STALL = ((RD1==PREV_DEST) | (RD2==PREV_DEST)) & (PREV_REWR_MUX == 2'b01); 
            _FLUSH = ((OPCODE == 7'b1100011)&ZERO) | (OPCODE == 7'b1100111) | (OPCODE == 7'b1101111);
            if (_STALL == 1) begin
                _ALU_CONTROL = OPCODE;
                _RE_WE = 0;
                _D_MEM_WEN = 1;
                _IS_JALR = 0;
                _FLUSH = 0;
                _NUMINSTADD = 0;
            end 
		end

		//addi
		7'b0010011: begin
            _ALU_CONTROL = OPCODE;
            _RE_WE = 1;
            _D_MEM_WEN = 1;
            _REWR_MUX = 2'b10;
            _AMUX = 1;
            _BMUX = 2'b00;
            _IS_JALR = 0;
            _NUMINSTADD = 1;
            // detect load data hazard
            _STALL = (RD1==PREV_DEST) & (PREV_REWR_MUX==2'b01);  
            _FLUSH = ((OPCODE == 7'b1100011)&ZERO) | (OPCODE == 7'b1100111) | (OPCODE == 7'b1101111);
           if (_STALL == 1) begin
                _ALU_CONTROL = OPCODE;
                _RE_WE = 0;
                _D_MEM_WEN = 1;
                _IS_JALR = 0;
                _FLUSH = 0;
                _NUMINSTADD = 0;
            end 
		end

		//SW
		7'b0100011: begin
            _ALU_CONTROL = OPCODE;
            _RE_WE = 0;
            _D_MEM_WEN = 0;
            _D_MEM_BE = 4'b1111;
            _AMUX = 1;
            _BMUX = 2'b00;
            _IS_JALR = 0;
            _REWR_MUX = 2'b00;
            _NUMINSTADD = 1;
            // detect load data hazard
            _STALL = ((RD1==PREV_DEST) | (RD2==PREV_DEST)) & (PREV_REWR_MUX==2'b01);  
            _FLUSH = ((OPCODE == 7'b1100011)&ZERO) | (OPCODE == 7'b1100111) | (OPCODE == 7'b1101111);
            if (_STALL == 1) begin
                _ALU_CONTROL = OPCODE;
                _RE_WE = 0;
                _D_MEM_WEN = 1;
                _IS_JALR = 0;
                _FLUSH = 0;
                _NUMINSTADD = 0;
            end 
		end

		//LW
		7'b0000011: begin
            _ALU_CONTROL = OPCODE;
            _RE_WE = 1;
            _D_MEM_WEN = 1;
            _REWR_MUX = 2'b01;
            _AMUX = 1;
            _BMUX = 2'b00;
            _IS_JALR = 0;
            _NUMINSTADD = 1;
            // detect load data hazard
            _STALL = (RD1==PREV_DEST) & (PREV_REWR_MUX==2'b01);  
            _FLUSH = ((OPCODE == 7'b1100011)&ZERO) | (OPCODE == 7'b1100111) | (OPCODE == 7'b1101111);
            if (_STALL == 1) begin
                _ALU_CONTROL = OPCODE;
                _RE_WE = 0;
                _D_MEM_WEN = 1;
                _IS_JALR = 0;
                _FLUSH = 0;
                _NUMINSTADD = 0;
            end 
		end

		//BRANCH
		7'b1100011: begin
            _ALU_CONTROL = OPCODE;
            _RE_WE = 0;
            _REWR_MUX = 2'b11;
            _D_MEM_WEN = 1;
            _AMUX = 0;
            _BMUX = 2'b00;
            _IS_JALR = 0;
            _CONDMUX = 0;
            _NUMINSTADD = 1;
            // detect load data hazard
            _STALL = ((RD1==PREV_DEST) | (RD2==PREV_DEST)) & (PREV_REWR_MUX == 2'b01); 
            _FLUSH = ((OPCODE == 7'b1100011)&ZERO) | (OPCODE == 7'b1100111) | (OPCODE == 7'b1101111);
            if (_STALL == 1) begin
                _ALU_CONTROL = OPCODE;
                _RE_WE = 0;
                _D_MEM_WEN = 1;
                _IS_JALR = 0;
                _FLUSH = 0;
                _NUMINSTADD = 0;
            end 
		end

		//JAL
		7'b1101111: begin
            _ALU_CONTROL = OPCODE;
            _RE_WE = 1;
            _D_MEM_WEN = 1;
            _REWR_MUX = 2'b10;
            _AMUX = 0;
            _BMUX = 2'b01;
            _IS_JALR = 0;
            _CONDMUX = 0;
            _NUMINSTADD = 1;
            // detect load data hazard
            _STALL = 0;
            _FLUSH = ((OPCODE == 7'b1100011)&ZERO) | (OPCODE == 7'b1100111) | (OPCODE == 7'b1101111);
		end

		//JALR
		7'b1100111: begin
            _ALU_CONTROL = OPCODE;
            _RE_WE = 1;
            _D_MEM_WEN = 1;
            _REWR_MUX = 2'b10;
            _AMUX = 0;
            _BMUX = 2'b01;
            _IS_JALR = 1;
            _CONDMUX = 1;
            _NUMINSTADD = 1;
            // detect load data hazard
            _STALL = (RD1==PREV_DEST) & (PREV_REWR_MUX==2'b01); 
            _FLUSH = ((OPCODE == 7'b1100011)&ZERO) | (OPCODE == 7'b1100111) | (OPCODE == 7'b1101111);
            if (_STALL == 1) begin
                _ALU_CONTROL = OPCODE;
                _RE_WE = 0;
                _D_MEM_WEN = 1;
                _IS_JALR = 0;
                _FLUSH = 0;
                _NUMINSTADD = 0;
            end 
		end

        //dummy
        7'b0000000: begin
            _ALU_CONTROL = OPCODE;
            _RE_WE = 0;
            _D_MEM_WEN = 1;
            _IS_JALR = 0;
            _STALL = 0;
            _FLUSH = 0;
            _NUMINSTADD = 0;
        end
		endcase
	end
endmodule
