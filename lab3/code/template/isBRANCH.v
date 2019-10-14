module isBRANCH (
	
	input wire [31:0] _ALUR_OUT,
	input wire _BRANCH,

	output wire _ISBRANCH

	);

	reg REG_ISBRANCH;
	assign _ISBRANCH = REG_ISBRANCH;

	always@ (*) begin
		REG_ISBRANCH = _ALUR_OUT[0];
		REG_ISBRANCH = REG_ISBRANCH & _BRANCH;
	end

endmodule
