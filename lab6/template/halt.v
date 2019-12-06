module HALT(

	input [31:0] CUR_INST,
	input [31:0] NXT_INST,

	output _halt

	);

	reg reg_halt;
	assign _halt = reg_halt;
	initial reg_halt = 0;

	always@ (NXT_INST) begin
		if ((NXT_INST == 32'h00008067) & (CUR_INST == 32'h00c00093)) reg_halt = 1;
		else reg_halt = 0;
	end

endmodule
