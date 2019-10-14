module TWOBITMUX (

	input wire SIGNAL,
	input wire [31:0] INPUT1,
	input wire [31:0] INPUT2,
	input wire [31:0] INPUT3,
	input wire [31:0] INPUT4,

	output wire [31:0] OUTPUT

	);

	// TWOBITMUX (REMUX, PC+4, rg1+IMM, memory_load, ALURoutput, RF_WD)

	reg [31:0] _OUTPUT;
	assign OUTPUT = _OUTPUT;

	always@ (*) begin
		if (SIGNAL == 2'b00) _OUTPUT = INPUT1;
		else if (SIGNAL == 2'b01) _OUTPUT = INPUT2;
		else if (SIGNAL == 2'b10) _OUTPUT = INPUT3;
		else _OUPUT = INPUT4;
	end

endmodule
