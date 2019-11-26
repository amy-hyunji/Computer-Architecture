module CONTROLREG(

		input CLK,
		input WREN,
		input [31:0] IN_VAL,
        input RSTn,

		output [31:0] OUT_VAL
 
		);

		reg[31:0] _VAL;

		assign OUT_VAL = _VAL;

		initial begin
			_VAL = 0;
		end

		always@ (posedge CLK) begin
            if (~RSTn) _VAL = 0;
            else begin
                if (WREN)
                    _VAL = IN_VAL;
            end
		end
endmodule

module REG(

		input CLK,
		input [31:0] IN_VAL,

		output [31:0] OUT_VAL

		);

		reg[31:0] _VAL;

		assign OUT_VAL = _VAL;

		initial _VAL = 0;

		always@ (posedge CLK) begin
			_VAL = IN_VAL;
		end
endmodule
				
module BIT5REG(

		input CLK,
		input [4:0] IN_VAL,

		output [4:0] OUT_VAL

		);

		reg[4:0] _VAL;

		assign OUT_VAL = _VAL;

		initial _VAL = 0;

		always@ (posedge CLK) begin
			_VAL = IN_VAL;
		end
endmodule
