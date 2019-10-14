module TRANSLATE (
	input wire [11:0] E_ADDR,
	input wire WHICH,
	
	output wire [11:0] T_ADDR
	);

	reg [11:0] reg_T_ADDR;
	assign T_ADDR = reg_T_ADDR;

	always @ (*) begin
		// DATA
		if (WHICH) reg_T_ADDR = E_ADDR & 12'hFFF; //12'h3FFF
		else reg_T_ADDR = E_ADDR & 12'hFFF;
	end

endmodule
