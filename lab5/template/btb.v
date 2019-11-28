module BranchPrediction(
	input wire [31:0] PCOUT,
	input wire [31:0] PREV_PCOUT,
	input wire ZERO,
	input wire CLK,

	output wire [31:0] NXT_PC
		);

	reg [20:0] tagtable [511:0];
	reg [1:0] BHT [511:0];
	reg [31:0] BTB [511:0];


	reg _NXT_PC;
	assign NXT_PC = _NXT_PC;
	integer i;

	reg [20:0] _tag;
	reg [20:0] _prev_tag;
	reg [8:0] _index;
	reg [8:0] _prev_index;
	reg [31:0] _IMM;

	initial begin
		_NXT_PC = 0;
		for(i=0;i<512;i=i+1)
		begin
			tagtable[i] = 0;
			BHT[i] = 2'b10;
			BTB[i] = 0;
		end
		_tag = 0;
		_index = 0;
		_IMM = 0;
		_prev_index = 0;
		_prev_tag = 0;
	end

	// read
	always@ (PCOUT) begin
		_tag = PCOUT[31:11];
		_index = PCOUT[10:2];
		if (tagtable[_index] == _tag) begin
			//same tag
			if (BHT[_index] == 2'b10 | BHT[_index] == 2'b11) begin
				//taken
				_NXT_PC = BTB[_index];
			end
		end
		else begin
			//check if it is branch
			if (PCOUT[6:0] == 7'b1100011) begin
				//is branch
				tagtable[_index] = _tag;
				_IMM[0] = 0;
				_IMM[4:1] = PCOUT[11:8];
				_IMM[10:5] = PCOUT[30:25];
				_IMM[11] = PCOUT[7];
				_IMM[12] = PCOUT[31];
				if (_IMM[12] == 0) _IMM[31:13] = 0;
				else _IMM[31:13] = 19'b1111111111111111111;
				BTB[_index] = _IMM;
				BHT[_index] = 2'b10;
				_NXT_PC = BTB[_index];
			end
			else begin
				_NXT_PC = PCOUT + 32'b00000000000000000000000000000100;
			end
		end
	end

	//write
	always@ (posedge CLK) begin
		_prev_tag = PREV_PCOUT[31:11];
		_prev_index = PREV_PCOUT[10:2];
		if (PREV_PCOUT[6:0] == 7'b1100011 & ZERO == 1 & _prev_tag == tagtable[_prev_index]) begin
			if (BHT[_prev_index] == 2'b11) BHT[_prev_index] = 2'b11;
			else if (BHT[_prev_index] == 2'b10) BHT[_prev_index] = 2'b11;
			else if (BHT[_prev_index] == 2'b01) BHT[_prev_index] = 2'b10;
			else BHT[_prev_index] = 2'b01;
		end
		else if (PREV_PCOUT[6:0] == 7'b1100011 & ZERO == 0 & _prev_tag == tagtable[_prev_index]) begin
			if (BHT[_prev_index] == 2'b11) BHT[_prev_index] = 2'b10;
			else if (BHT[_prev_index] == 2'b10) BHT[_prev_index] = 2'b01;
			else if (BHT[_prev_index] == 2'b01) BHT[_prev_index] = 2'b00;
			else BHT[_prev_index] = 2'b00;
		end
	end

endmodule
