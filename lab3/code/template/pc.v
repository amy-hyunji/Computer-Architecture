module PC (
	
	input wire CLK,
	input wire RSTn,
	input wire [31:0] _PC,

	output wire [31:0] I_MEM_ADDR
	);

	reg [31:0] reg_I_MEM_ADDR;
	assign I_MEM_ADDR = reg_I_MEM_ADDR;

	always@ (posedge CLK or posedge RSTn) begin
		if (RSTn) reg_I_MEM_ADDR = 32'b00000000000000000000000000000000;
		else reg_I_MEM_ADDR = _PC;
	end

endmodule
