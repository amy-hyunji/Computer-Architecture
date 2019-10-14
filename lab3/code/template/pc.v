module PC (
	
	input wire CLK,
	input wire RSTn,
	input wire [31:0] _PC,

	output wire[11:0] _OUT_I_MEM_ADDR,
	output wire [31:0] PC_OUT 
	);

	reg [31:0] reg_PC_OUT;
	reg [11:0] reg_OUT_I_MEM_ADDR;
	assign PC_OUT = reg_PC_OUT;
	assign _OUT_I_MEM_ADDR = reg_OUT_I_MEM_ADDR;

	always@ (posedge CLK or posedge RSTn) begin
		if (RSTn) reg_PC_OUT = 0;
		else reg_PC_OUT = _PC;
		reg_OUT_I_MEM_ADDR = reg_PC_OUT[11:0];
	end

endmodule
