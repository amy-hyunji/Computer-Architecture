module CACHE (

	input wire CLK,
	input wire CSN,
	input wire [31:0] C_MEM_DI,
	input wire C_MEM_WEN,
	input wire C_MEM_REN, 
	input wire [11:0] C_MEM_ADDR,
	input wire [31:0] D_MEM_DI,

	output wire [31:0] C_MEM_DOUT,
	output wire CACHE_STALL,
	output wire [11:0] D_MEM_ADDR, 
	output wire [31:0] D_MEM_DOUT,
	output wire D_MEM_WEN,
	output wire [3:0] D_MEM_BE,
	output wire D_MEM_CSN
	);

	integer idx;
	reg _CACHE_STALL;
	reg [2:0] _STATE;
	reg [4:0] _CACHE_TAG [7:0];
	reg _CACHE_VALID [7:0];
	reg [127:0] _CACHE_DATA [7:0]; 
	reg [11:0] _D_MEM_ADDR;
	reg [31:0] _D_MEM_DOUT;
	reg _D_MEM_WEN;
	reg [4:0] _CUR_TAG;
	reg [2:0] _CUR_INDEX;
	reg [1:0] _CUR_BO;
	reg _READ_MISS;
	reg _WRITE_MISS;
	reg _WRITE_HIT;
	reg [31:0]_C_MEM_DOUT;

	assign CACHE_STALL = _CACHE_STALL;
	assign D_MEM_ADDR = _D_MEM_ADDR;
	assign D_MEM_CSN = CSN;
	assign D_MEM_BE = 4'b1111;
	assign C_MEM_DOUT = _C_MEM_DOUT;
	assign D_MEM_DOUT = _D_MEM_DOUT;
	assign D_MEM_WEN = _D_MEM_WEN;

	initial begin
		_CACHE_STALL <= 0;
		_STATE <= 3'b000;
		_CUR_TAG <= 0;
		_CUR_INDEX <= 0;
		_CUR_BO <= 0; 
		_READ_MISS <= 0;
		_WRITE_MISS <= 0;
		_D_MEM_ADDR <= 0;
		_C_MEM_DOUT <= 0;
		_D_MEM_DOUT <= 0;
		_D_MEM_WEN <= 1;
		_WRITE_HIT <= 0;

		for(idx=0; idx<8; idx=idx+1) begin
			_CACHE_TAG[idx] <= 0;
			_CACHE_VALID[idx] <= 0;
			_CACHE_DATA[idx] <= 0;
		end
	end

	always@ (*) begin
		if (~CSN) begin
			_CUR_TAG = C_MEM_ADDR[11:7];
			_CUR_INDEX = C_MEM_ADDR[6:4];
			_CUR_BO = C_MEM_ADDR[3:2];
		end
	end

	always@ (negedge CLK) begin
		if (~CSN) begin
			if (_STATE == 3'b000) begin
				if ((C_MEM_REN == 0)&(_CUR_TAG == _CACHE_TAG[_CUR_INDEX]) & (_CACHE_VALID[_CUR_INDEX] == 1)) begin
					//READ HIT
					case (_CUR_BO) 
					2'b00: _C_MEM_DOUT = _CACHE_DATA[_CUR_INDEX][127:96];
					2'b01: _C_MEM_DOUT = _CACHE_DATA[_CUR_INDEX][95:64];
					2'b10: _C_MEM_DOUT = _CACHE_DATA[_CUR_INDEX][63:32];
					2'b11: _C_MEM_DOUT = _CACHE_DATA[_CUR_INDEX][31:0];
					endcase
				end
				else if (C_MEM_REN == 0) begin
					//READ MISS
					_READ_MISS = 1;
					_CACHE_STALL = 1;
					_STATE = 3'b001;
					_D_MEM_ADDR = {_CUR_TAG, _CUR_INDEX, 2'b00, 2'b00};
					_CACHE_VALID[_CUR_INDEX] = 0;
				end
				else if ((C_MEM_WEN == 0)&(_CUR_TAG==_CACHE_TAG[_CUR_INDEX])&(_CACHE_VALID[_CUR_INDEX]==1)) begin
					//WRITE HIT
					_WRITE_HIT = 1;
					_D_MEM_ADDR = C_MEM_ADDR;
					_D_MEM_DOUT = C_MEM_DI;
					_D_MEM_WEN = 0;
					_CACHE_STALL = 1;
					_STATE = 3'b001;
					_CACHE_VALID[_CUR_INDEX] = 0;
					case (_CUR_BO)
					2'b00: _CACHE_DATA[_CUR_INDEX][127:96] = C_MEM_DI;
					2'b01: _CACHE_DATA[_CUR_INDEX][95:64] = C_MEM_DI;
					2'b10: _CACHE_DATA[_CUR_INDEX][63:32] = C_MEM_DI;
					2'b11: _CACHE_DATA[_CUR_INDEX][31:0] = C_MEM_DI;
					endcase
				end
				else if (C_MEM_WEN == 0) begin
					//WRITE MISS
					_WRITE_MISS = 1;
					_CACHE_STALL = 1;
					_D_MEM_WEN = 0;
					_D_MEM_ADDR = C_MEM_ADDR;
					_D_MEM_DOUT = C_MEM_DI;
					_STATE = 3'b001;
					_CACHE_VALID[_CUR_INDEX] = 0;
				end
			end
			else begin
				if (_READ_MISS == 1) begin
					case (_STATE) 
					3'b001: begin
					_CACHE_STALL = 1;
					_CACHE_DATA[_CUR_INDEX][127:96] = D_MEM_DI;
					_D_MEM_ADDR = {_CUR_TAG, _CUR_INDEX, 2'b01, 2'b00};
					_STATE = 3'b010;
					end
					3'b010: begin
					_CACHE_STALL = 1;
					_CACHE_DATA[_CUR_INDEX][95:64] = D_MEM_DI;
					_D_MEM_ADDR = {_CUR_TAG, _CUR_INDEX, 2'b10, 2'b00};
					_STATE = 3'b011;
					end
					3'b011: begin
					_CACHE_STALL = 1;
					_CACHE_DATA[_CUR_INDEX][63:32] = D_MEM_DI;
					_D_MEM_ADDR = {_CUR_TAG, _CUR_INDEX, 2'b11, 2'b00};
					_STATE = 3'b100;
					end
					3'b100: begin
					_CACHE_STALL = 0;
					_CACHE_DATA[_CUR_INDEX][31:0] = D_MEM_DI;
					_STATE = 3'b000;
					_READ_MISS = 0;
					_CACHE_TAG[_CUR_INDEX] = _CUR_TAG;
					_CACHE_VALID[_CUR_INDEX] = 1;
					case (_CUR_BO) 
					2'b00: _C_MEM_DOUT = _CACHE_DATA[_CUR_INDEX][127:96];
					2'b01: _C_MEM_DOUT = _CACHE_DATA[_CUR_INDEX][95:64];
					2'b10: _C_MEM_DOUT = _CACHE_DATA[_CUR_INDEX][63:32];
					2'b11: _C_MEM_DOUT = _CACHE_DATA[_CUR_INDEX][31:0];
					endcase
					end
					endcase
				end
				else if (_WRITE_HIT == 1) begin
					if (_STATE == 3'b001) begin
					_CACHE_STALL = 0;
					_D_MEM_WEN = 1;
					_STATE = 3'b000;
					_WRITE_HIT = 0;
					_CACHE_VALID[_CUR_INDEX] = 1;
					end
					else $display("WRITE HIT STATE SHOULD BE 3'b001 but is %b", _STATE);
				end
				else if (_WRITE_MISS == 1) begin
					case (_STATE)
					3'b001: begin
					_CACHE_STALL = 1;
					_STATE = 3'b010;
					_D_MEM_WEN = 1;
					_D_MEM_ADDR = {_CUR_TAG, _CUR_INDEX, 2'b00, 2'b00};
					end
					3'b010: begin
					_CACHE_STALL = 1;
					_STATE = 3'b011;
					_D_MEM_ADDR = {_CUR_TAG, _CUR_INDEX, 2'b01, 2'b00};
					end
					3'b011: begin
					_CACHE_STALL = 1;
					_D_MEM_ADDR = {_CUR_TAG, _CUR_INDEX, 2'b10, 2'b00};
					_STATE = 3'b100;
					end
					3'b100: begin
					_CACHE_STALL = 1;
					_D_MEM_ADDR = {_CUR_TAG, _CUR_INDEX, 2'b11, 2'b00};
					_STATE = 3'b101;
					end
					3'b101: begin
					_CACHE_STALL = 0;
					_STATE = 3'b000;
					_WRITE_MISS = 0;
					_CACHE_VALID[_CUR_INDEX] = 1;
					_CACHE_TAG[_CUR_INDEX] = _CUR_TAG;
					end
					endcase
				end
				else $display("SOMETHING WRONG IN CACHE");
			end
		end
	end

	always@ (posedge CLK) begin
		if (~CSN) begin
		if (_WRITE_MISS == 1)begin
			case (_STATE) 
			3'b010: _CACHE_DATA[_CUR_INDEX][127:96] = D_MEM_DI;
			3'b011: _CACHE_DATA[_CUR_INDEX][95:64] = D_MEM_DI;
			3'b100: _CACHE_DATA[_CUR_INDEX][63:32] = D_MEM_DI;
			3'b101: _CACHE_DATA[_CUR_INDEX][31:0] = D_MEM_DI;
			endcase
		end	
		end
	end

endmodule
