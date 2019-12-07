module MEMREG (
    input wire C_MEM_WEN_IN,
	 input wire C_MEM_REN_IN,
    input wire CLK,
	 input wire ENABLE,

    output wire C_MEM_WEN_OUT,
	 output wire C_MEM_REN_OUT,
);

    reg _C_MEM_WEN;
	 reg _C_MEM_REN;

    assign C_MEM_WEN_OUT = _C_MEM_WEN;
	 assign C_MEM_REN_OUT = _C_MEM_REN;

    initial begin
        _C_MEM_WEN = 0;
		  _C_MEM_REN = 0;
    end

    always@ (posedge CLK) begin
		if (ENABLE) begin
        _C_MEM_WEN <= C_MEM_WEN_IN;
		  _C_MEM_REN <= C_MEM_REN_IN;
		end
    end

endmodule

