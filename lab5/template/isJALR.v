module isJALR (
	
	input wire ISJALR,
	input wire[31:0] ALUI_OUTPUT,

	output wire[31:0] OUTPUT

	);

	reg[31:0] _OUTPUT;
	assign OUTPUT = _OUTPUT;

	always@ (*) begin
		if (ISJALR == 1) _OUTPUT = ALUI_OUTPUT & 32'hfffffffe;
		else  _OUTPUT = ALUI_OUTPUT;
	end

endmodule
