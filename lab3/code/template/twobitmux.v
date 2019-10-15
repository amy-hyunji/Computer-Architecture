module TWOBITMUX (

	input wire [1:0] SIGNAL,
	input wire [31:0] INPUT1,
	input wire [31:0] INPUT2,
	input wire [31:0] INPUT3,
	input wire [31:0] INPUT4,

	output wire [31:0] OUTPUT

	);

	// TWOBITMUX (REMUX, PC+4, rg1+IMM, memory_load, ALURoutput, RF_WD)

	reg [31:0] _OUTPUT;
	assign OUTPUT = _OUTPUT;

	initial begin
		_OUTPUT = 0;
	end

	always@ (*) begin
		if (SIGNAL == 2'b00) begin
//			$display("2'b00: %0b", INPUT1);
			_OUTPUT = INPUT1;
		end
		else if (SIGNAL == 2'b01) begin
//			$display("2'b01");
			_OUTPUT = INPUT2;
		end
		else if (SIGNAL == 2'b10) begin 
//			$display("2'b10");
			_OUTPUT = INPUT3;
		end
		else begin
//			$display("rest");
			_OUTPUT = INPUT4;
		end
	end

endmodule
