module OUTPUT(
	
	input wire _D_MEM_WEN,
	input wire _ISBRANCH,
	input wire _BRANCH,
	input wire [31:0] _ALUIOUT,
	input wire [31:0] _RFWD,

	output wire [31:0] _OUT_RFWD

	);

	reg [31:0] reg_OUT_RFWD;
	assign _OUT_RFWD = reg_OUT_RFWD;

	always@ (*) begin
		if (_ISBRANCH == 1) reg_OUT_RFWD = 1;
		else if (_BRANCH == 1) reg_OUT_RFWD = 0;
		else if (_D_MEM_WEN == 0) reg_OUT_RFWD = _ALUIOUT;
		else reg_OUT_RFWD = _RFWD;
	end

endmodule
