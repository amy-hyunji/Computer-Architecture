module TRANSLATE (
	input wire [31:0] E_ADDR,

	output wire [11:0] T_ADDR
	);

	reg[11:0] temp_T_ADDR;
	assign T_ADDR = temp_T_ADDR;
	initial temp_T_ADDR = 0;

	always @ (*) begin
		temp_T_ADDR = E_ADDR & 12'hFFF;
	end

endmodule
