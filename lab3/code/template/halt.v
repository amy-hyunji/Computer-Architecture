module HALT(

	input _CLK,
	input [31:0] _Instruction,
	input [31:0] _RF_RD1,

	output _halt

	);

	reg reg_halt;
	assign _halt = reg_halt;

	always@ (posedge _CLK) begin
		if ((_Instruction == 32'h00008067) & (_RF_RD1 == 32'h0000000c)) reg_halt = 1;
		else  reg_halt = 0;
		//$display("HALT: %0b", reg_halt);
		//$display("Instruction: %0h", _Instruction);
		//$display("RF_RD1 : %0b", _RF_RD1);
	
	end

endmodule
