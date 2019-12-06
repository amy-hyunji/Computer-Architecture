module CACHE (

	input wire CLK,

	output wire CACHE_STALL
	
	);

	reg _CACHE_STALL;
	assign CACHE_STALL = _CACHE_STALL;

	initial _CACHE_STALL <= 0;

	always@ (posedge CLK) begin
		if (_CACHE_STALL == 0) _CACHE_STALL = 1;
		else  _CACHE_STALL = 0;
	end
endmodule
