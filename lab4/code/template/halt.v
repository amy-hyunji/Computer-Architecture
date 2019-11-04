module HALT(

	input [31:0] CUR_INST,
	input [31:0] _RF_RD1,

	output _halt

	);

	reg reg_halt;
	assign _halt = reg_halt;

	always@ (*) begin
		if ((CUR_INST == 32'h00008067) & (_RF_RD1 == 32'h0000000c)) reg_halt = 1;
		else  reg_halt = 0;
	end

endmodule
