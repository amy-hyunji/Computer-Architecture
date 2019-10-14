module ONEBITMUX (

	input wire SIGNAL,
	input wire [31:0] INPUT1,
	input wire [31:0] INPUT2,

	output wire [31:0] OUTPUT

	);

	reg [31:0] _OUTPUT;
	assign OUTPUT = _OUTPUT;

	always@ (*) begin
		if (SIGNAL == 1'b0) _OUTPUT = INPUT1;
		else _OUTPUT = INPUT2; //SIGNAL = 1
	end

endmodule
