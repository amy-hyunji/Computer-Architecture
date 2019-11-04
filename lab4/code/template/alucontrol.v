module ALUCONTROL (
	
		input wire [10:0] ALU_CONTROL,
		input wire [2:0] FUNCT3,
		input wire [6:0] FUNCT7,

		output wire [3:0] CONTROLOUT
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
		
		OP = ALU_CONTROL[10:4];
		STATE = ALU_CONTROL[3:0];

		if (STATE == 4'b0001) //IF 
			_CONTROLOUT = 4'b0000;
		else if (STATE == 4'b0010) //ID
			_CONTROLOUT = 4'b0000;
		else if (STATE == 4'b0011) // STAGE3
			_CONTROLOUT = 4'b0000;
		else if (STATE == 4'b1000) // STAGE8
			_CONTROLOUT = 4'b0000;
		else if (STATE == 4'b0101 & OP == 7'b0000011) // LW EX
			_CONTROLOUT = 4'b0000;
		else if (STATE == 4'b0101 & OP == 7'b0100011) // SW EX
			_CONTROLOUT = 4'b0000;
		else if (STATE == 4'b0111 & OP == 7'b0110011) begin// R-type EX
			if (FUNCT7 == 7'b0000000) begin
				case (FUNCT3)
				3'b000: //add 
					_CONTROLOUT = 4'b0000;
				3'b001: //sll
					_CONTROLOUT = 4'b0010;
				3'b010: //slt
					_CONTROLOUT = 4'b0011;
				3'b011: //sltu
					_CONTROLOUT = 4'b0100;
				3'b100: //xor
					_CONTROLOUT = 4'b0101;
				3'b101: //srl
					_CONTROLOUT = 4'b0110;
				3'b110: //or
					_CONTROLOUT = 4'b1000;
				3'b111: //and
					_CONTROLOUT = 4'b1001;
				endcase
			end
			else begin
				case (FUNCT3)
				3'b000: //sub
					_CONTROLOUT = 4'b0001;
				3'b101: //sra
					_CONTROLOUT = 4'b0111;
				endcase
			end
		end
		else if (STATE == 4'b0101 & OP == 7'b0010011) begin // I-type EX
			case (FUNCT3)
			3'b000: begin//addi
				_CONTROLOUT = 4'b0000;
			end	
			3'b010: //slti
				_CONTROLOUT = 4'b0011;
			3'b011: //sltiu
				_CONTROLOUT = 4'b0100;
			3'b100: //xori
				_CONTROLOUT = 4'b0101;
			3'b110: //ori
				_CONTROLOUT = 4'b1000;
			3'b111: //andi
				_CONTROLOUT = 4'b1001;
			3'b001: //slli
				_CONTROLOUT = 4'b0010;
			3'b101: begin//srli, srai
				if (FUNCT7 == 7'b0000000) //srli
					_CONTROLOUT = 4'b0110;
				else if (FUNCT7 == 7'b0100000) //srai
					_CONTROLOUT = 4'b0111;
				end
			endcase
		end
		else if (STATE == 4'b1001 & OP == 7'b1100011) begin
			case (FUNCT3)
			3'b000: //beq
				_CONTROLOUT = 4'b1010;
			3'b001: //bne
				_CONTROLOUT = 4'b1011;
			3'b100: //blt
				_CONTROLOUT = 4'b1100;
			3'b101: //bge
				_CONTROLOUT = 4'b1101;
			3'b110: //bltu
				_CONTROLOUT = 4'b1110;
			3'b111: //bgeu
				_CONTROLOUT = 4'b1111;
			endcase
		end
	end
endmodule
