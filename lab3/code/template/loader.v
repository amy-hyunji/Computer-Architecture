module LOADER (

	input wire [2:0] LFUNCT,
	input wire [31:0] _D_MEM_DOUT,

	output wire [31:0] LOADER_OUT

	);

	reg[31:0] _LOADER_OUT;
	assign LOADER_OUT = _LOADER_OUT;

	always@ (*) begin
		case (LFUNCT)
