module MPC (
	
	input wire CLK,
	input wire RSTn,
	input wire [31:0] _PC,

	output wire [31:0] PC_OUT 
	);

	reg [31:0] reg_PC_OUT;
	assign PC_OUT = reg_PC_OUT;

	initial begin
		reg_PC_OUT = 0;
	end

	always@ (posedge CLK) begin
		if (~RSTn) reg_PC_OUT = 0;
		else reg_PC_OUT = _PC;
	end

endmodule
