module TRANSLATE (
	input wire [31:0] E_ADDR,
	
	output wire [11:0] T_ADDR
	);

	reg [11:0] reg_T_ADDR;
	assign T_ADDR = reg_T_ADDR;

	always @ (*) begin
		reg_T_ADDR = E_ADDR & 12'hFFF;
	end

endmodule
