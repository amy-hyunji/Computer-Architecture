module ISJALR(

		input wire [31:0] A,
		input wire [31:0] IMM,

		output wire [31:0] JALR_OUT

		);

		reg[31:0] _JALR_OUT;
		initial _JALR_OUT = 0;
		assign JALR_OUT = _JALR_OUT;

		always@ (*) begin
			_JALR_OUT = ((A+IMM) & 32'hfffffffe);
		end

endmodule
			
