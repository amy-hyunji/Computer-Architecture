module CONTROLREG(

		input CLK,
		input WREN,
		input [31:0] IN_VAL,
		input IS_ALU,

		output [31:0] OUT_VAL
 
		);

		reg[31:0] _VAL;

		assign OUT_VAL = _VAL;

		initial begin
			_VAL = 0;
		end

		always@ (posedge CLK) begin
			if (WREN == 1) begin
				if (IS_ALU == 1) $display ("writing %b in ALUout", IN_VAL);
				if (IS_ALU == 0) $display ("writing %b in PC", IN_VAL);
				_VAL = IN_VAL;
			end
		end
endmodule

module REG(

		input CLK,
		input [31:0] IN_VAL,

		output [31:0] OUT_VAL

		);

		reg _VAL;

		assign OUT_VAL = _VAL;

		initial _VAL = 0;

		always@ (posedge CLK) begin
			_VAL = IN_VAL;
			$display("value in register is : %b", IN_VAL);
		end
endmodule
				
