module HALT(

	input [31:0] CUR_INST,
	input [31:0] A_OUT,

	output _halt

	);

	reg reg_halt;
	assign _halt = reg_halt;
	initial reg_halt = 0;

	always@ (CUR_INST) begin
		if ((CUR_INST == 32'h00008067)) reg_halt = 1;
		else reg_halt = 0;
	end

endmodule
