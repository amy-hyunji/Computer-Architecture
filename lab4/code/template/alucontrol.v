module ALUCONTROL (
	
		input wire [10:0] ALU_CONTROL,
		input wire [2:0] FUNCT3,
		input wire [6:0] FUNCT7,

		output wire [4:0] CONTROLOUT
		);

	reg [6:0] OP;
	reg [3:0] STATE;
	reg [4:0] _CONTROLOUT;

	assign CONTROLOUT = _CONTROLOUT;

	initial begin
		OP = 0;
		STATE = 0;
		_CONTROLOUT = 0;
	end

	always@ (*) begin
		if (STATE == 4'b0001) //IF 
			_CONTROLOUT <= 5'b00000;
		else if (STATE == 4'b0011) //JAL ID
			_CONTROLOUT <= 5'b00000;
		else if (STATE == 4'b0100) //BR ID
			_CONTROLOUT <= 5'b00000;
		else if (STATE == 4'b1000) // JALR EX
			_CONTROLOUT <= 5'b10000;
		else if (STATE == 4'b0101 & OP == 7'b0000011) // LW EX
			_CONTROLOUT <= 5'b00000;
		else if (STATE == 4'b0110 & OP == 7'b0100011) // SW EX
			_CONTROLOUT <= 5'b00000;
		else if (STATE == 4'b0111 & OP == 7'b0110011) begin// R-type EX
			if (FUNCT7 == 7'b0000000) begin
				case (FUNCT3)
				3'b000: 
					_CONTROLOUT <= 5'b00000;
				3'b001:
					_CONTROLOUT <= 5'b00010;
				3'b010:
					_CONTROLOUT <= 5'b00011;
				3'b011:
					_CONTROLOUT <= 5'b00100;
				3'b100:
					_CONTROLOUT <= 5'b00101;
				3'b101:
					_CONTROLOUT <= 5'b00110;
				3'b110:
					_CONTROLOUT <= 5'b01000;
				3'b111:
					_CONTROLOUT <= 5'b01001;
				endcase
			end
			else begin
				case (FUNCT3)
				3'b000:
					_CONTROLOUT <= 5'b00001;
				3'b101:
					_CONTROLOUT <= 5'b00111;
				endcase
			end
		end
		else if (STATE == 4'b0101 & OP == 7'b0010011) begin // I-type EX
			case (FUNCT3)
			3'b000:
				_CONTROLOUT <= 5'b00000;
			3'b010:
				_CONTROLOUT <= 5'b00011;
			3'b011:
				_CONTROLOUT <= 5'b00100;
			3'b100:
				_CONTROLOUT <= 5'b00101;
			3'b110: //ori
				_CONTROLOUT <= 5'b01000;
			3'b111: //andi
				_CONTROLOUT <= 5'b01001;
			3'b001:
				_CONTROLOUT <= 5'b00010;
			3'b101:
				if (FUNCT7 == 7'b0000000)
					_CONTROLOUT <= 5'b00110;
				else if (FUNCT7 == 7'b0100000)
					_CONTROLOUT <= 5'b00111;
			endcase
		end
		else if (STATE == 4'b1001 & OP == 7'b1100011) begin
			case (FUNCT3)
			3'b000: //beq
				_CONTROLOUT <= 5'b01010;
			3'b001: //bne
				_CONTROLOUT <= 5'b01011;
			3'b100: //blt
				_CONTROLOUT <= 5'b01100;
			3'b101: //bge
				_CONTROLOUT <= 5'b01101;
			3'b110: //bltu
				_CONTROLOUT <= 5'b01110;
			3'b111: //bgeu
				_CONTROLOUT <= 5'b01111;
			endcase
		end
	end
endmodule
