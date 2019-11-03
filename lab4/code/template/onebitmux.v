module ONEBITMUX (

	input wire SIGNAL,
	input wire [31:0] INPUT1,
	input wire [31:0] INPUT2,
	input wire CHECK,

	output wire [31:0] OUTPUT

	);

	reg [31:0] _OUTPUT;
	assign OUTPUT = _OUTPUT;

	always@ (*) begin

		if (SIGNAL == 1'b0) begin
			_OUTPUT = INPUT1;
			if (CHECK==1) $display("input is : %b", INPUT1);
		end
		else begin
			_OUTPUT = INPUT2; //SIGNAL = 1
		end
	end

endmodule
