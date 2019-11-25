module ALUCONTROL (
	
		input wire [6:0] OPCODE,
		input wire [2:0] FUNCT3,
		input wire [6:0] FUNCT7,

		output wire [3:0] CONTROLOUT
		
		);

	reg [3:0] _CONTROLOUT;
	assign CONTROLOUT = _CONTROLOUT;

	initial begin
		_CONTROLOUT = 0;
	end

	always@ (OPCODE) begin

		if (OPCODE == 7'b0100011) //SW
			_CONTROLOUT = 4'b0000;
		else if(OPCODE == 7'b0000011) //LW
			_CONTROLOUT = 4'b0000;
		else if(OPCODE == 7'b1100011) begin//BR
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
		else if(OPCODE == 7'b1101111) //JAL
			_CONTROLOUT = 4'b0000;
		else if(OPCODE == 7'b1100111) //JALR
			_CONTROLOUT = 4'b0000;
		else if (OPCODE == 7'b0110011 | OPCODE == 7'b0010011) begin
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

	end
endmodule
