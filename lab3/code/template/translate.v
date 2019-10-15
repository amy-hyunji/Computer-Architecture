module TRANSLATE (
	input wire Check,
	input wire [31:0] E_ADDR,
	input wire WHICH,
	
	output wire [11:0] T_ADDR
	);

	reg [11:0] temp_E_ADDR;
	reg [11:0] reg_T_ADDR;
	assign T_ADDR = reg_T_ADDR;

	always @ (*) begin
		// DATA
		temp_E_ADDR = E_ADDR[11:0];
		//if (Check ==  1'b1) $display("temp_E_ADDR : %0b", temp_E_ADDR);
		if (WHICH) reg_T_ADDR = E_ADDR & 12'hFFF; //12'h3FFF
		else reg_T_ADDR = E_ADDR & 12'hFFF;
		//if (Check == 1'b1) $display("reg_T_ADDR : %0b", reg_T_ADDR);
	end

endmodule
