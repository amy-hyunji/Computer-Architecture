module LOADER (

	input wire [2:0] LFUNCT,
	input wire [31:0] _D_MEM_DOUT,

	output wire [31:0] LOADER_OUT

	);

	reg[31:0] _LOADER_OUT;
	assign LOADER_OUT = _LOADER_OUT;

	always@ (*) begin
		case (LFUNCT)
		
		3'b000: begin //LB - 8bit / [[7:0]
			_LOADER_OUT[7:0] = _D_MEM_DOUT[7:0];
			if (_D_MEM_DOUT[31] == 1'b0) _LOADER_OUT[31:8] = 24'b000000000000000000000000;
			else _LOADER_OUT[31:8] = 24'b111111111111111111111111;
		end

		3'b001: begin //LH - load 16 bit from memory and sign-extend to 32 bit 
			_LOADER_OUT[15:0] = _D_MEM_DOUT[15:0];
			if (_D_MEM_DOUT[31] == 1'b0) _LOADER_OUT[31:16] = 16'b0000000000000000;
			else _LOADER_OUT[31:16] = 16'b1111111111111111;
		end

		3'b010: begin //LW - load 32 bit from memory into rd
			_LOADER_OUT[31:0] = _D_MEM_DOUT[31:0];
		end

		3'b100: begin //LBU
			_LOADER_OUT[7:0] = {_D_MEM_DOUT[7:0], 24'b000000000000000000000000};
		end

		3'b101: begin //LHU - load 16 bit from memory and zero extend to 32 bit
			_LOADER_OUT[16:0] = {_D_MEM_DOUT[16:0], 16'b0000000000000000};
		end
	end

endmodule
