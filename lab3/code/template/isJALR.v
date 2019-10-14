module isJALR (
	
	input wire ISJALR,
	input wire[31:0] ALUI_OUTPUT,

	output wire[31:0] OUTPUT

	);

	reg[31:0] _OUTPUT;
	assign OUTPUT = _OUTPUT;

	always@ (ISJALR or ALUI_OUTPUT) begin
		if (ISJALR == 1) _OUTPUT = {ALUI_OUTPUT[31:1], 1'b0};
		else  _OUTPUT = ALUI_OUTPUT;
	end

endmodule
