module INSTREG(

		input CLK,
		input [31:0] INSTRUCTION,
        input IRWRITE,

		output [6:0] OPCODE,
		output [31:0] IMMEDIATE,
		output [4:0] RS1,
		output [4:0] RS2,
		output [2:0] FUNCT3,
		output [6:0] FUNCT7,
		output [4:0] RD

		);

		reg[6:0] _OPCODE;
		reg[31:0] _IMMEDIATE;
		reg[4:0] _RS1;
		reg[4:0] _RS2;
		reg[2:0] _FUNCT3;
		reg[6:0] _FUNCT7;
		reg[4:0] _RD;

		assign OPCODE = _OPCODE;
		assign IMMEDIATE = _IMMEDIATE;
		assign RS1 = _RS1;
		assign RS2 = _RS2;
		assign FUNCT3 = _FUNCT3;
		assign FUNCT7 = _FUNCT7;
		assign RD = _RD;

		initial begin
			_OPCODE = 0;
			_IMMEDIATE = 0;
			_RS1 = 0;
			_RS2 = 0;
			_FUNCT3 = 0;
			_FUNCT7 = 0;
			_RD = 0;
		end

		always@ (posedge CLK) begin
            if (IRWRITE) begin
                _RS1 <= INSTRUCTION[19:15];
                _RS2 <= INSTRUCTION[24:20];
                _RD <= INSTRUCTION[11:7];
                _FUNCT3 <= INSTRUCTION[14:12];
                _FUNCT7 <= INSTRUCTION[31:25];
                _OPCODE <= INSTRUCTION[6:0];

                case (_OPCODE)
                7'b0100011: begin//SW
                    _IMMEDIATE[4:0] = INSTRUCTION[11:7];
                    _IMMEDIATE[11:5] = INSTRUCTION[31:25];
                    if (_IMMEDIATE[11] == 0) _IMMEDIATE[31:12] = 0;
                    else _IMMEDIATE[31:12] = 1;
                end
                7'b1101111: begin //JAL
                    _IMMEDIATE[20] = INSTRUCTION[31];
                    _IMMEDIATE[19:12] = INSTRUCTION[19:12];
                    _IMMEDIATE[11] = INSTRUCTION[20];
                    _IMMEDIATE[10:1] = INSTRUCTION[30:21];
                    _IMMEDIATE[0] = 0;
                    if (_IMMEDIATE[20] == 0) _IMMEDIATE[31:21] = 0;
                    else _IMMEDIATE[31:21] = 1;
                end
                7'b0000011: begin //LW
                    _IMMEDIATE[11:0] = INSTRUCTION[31:20];
                    if (_IMMEDIATE[11] == 0) _IMMEDIATE[31:12] = 0;
                    else _IMMEDIATE[31:12] = 1;
                end
                7'b1100111: begin // JALR
                    _IMMEDIATE[11:0] = INSTRUCTION[31:20];
                    if (_IMMEDIATE[11] == 0) _IMMEDIATE[31:12] = 0;
                    else _IMMEDIATE[31:12] = 1;
                end
                7'b0010011: begin // I-type
                    _IMMEDIATE[11:0] = INSTRUCTION[31:20];
                    if (_IMMEDIATE[11] == 0) _IMMEDIATE[31:12] = 0;
                    else _IMMEDIATE[31:12] = 1;
                end
                7'b1100011: begin // BR
                    _IMMEDIATE[0] = 0;
                    _IMMEDIATE[4:1] = INSTRUCTION[11:8];
                    _IMMEDIATE[10:5] = INSTRUCTION[30:25];
                    _IMMEDIATE[11] = INSTRUCTION[7];
                    _IMMEDIATE[12] = INSTRUCTION[31];
                    if (_IMMEDIATE[12] == 0) _IMMEDIATE[31:13] = 0;
                    else _IMMEDIATE[31:13] = 1;
                end
                endcase
            end
		end
endmodule

