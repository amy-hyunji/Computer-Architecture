module CONTROLREG(

		input CLK,
		input WREN,
		input [31:0] IN_VAL,

		output [31:0] OUT_VAL
 
		);

		reg _VAL;

		assign OUT_VAL = _VAL;

		initial begin
			_VAL = 0;
		end

		always@ (posedge CLK) begin
			if (WREN)
				_VAL = IN_VAL;
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
		end
endmodule
				
