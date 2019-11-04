module OUTPUTPORT(

		input wire [31:0] REGWRVAL,
		input wire ZERO,
		input wire [11:0] DMEMADDR,
		input wire [6:0] OPCODE,

		output wire[31:0] OUTPUT

		);
	
		reg[31:0] _OUTPUT;
		assign OUTPUT = _OUTPUT;
		initial _OUTPUT = 0;

		always@ (*) begin
			
			case (OPCODE)
			7'b0100011: begin//SW
				_OUTPUT = DMEMADDR;
			end
			7'b1100011: begin//BR
				if (ZERO) _OUTPUT = 1;
				else _OUTPUT = 0;
			end
			default: begin 
				_OUTPUT = REGWRVAL;	
			end
			endcase

		end
endmodule
				
