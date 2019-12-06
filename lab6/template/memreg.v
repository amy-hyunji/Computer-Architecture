module MEMREG (
    input wire D_MEM_WEN_IN,
    input wire [3:0] D_MEM_BE_IN,
    input wire D_MEM_CSN_IN,
    input wire CLK,
	 input wire ENABLE,

    output wire D_MEM_WEN_OUT,
    output wire [3:0] D_MEM_BE_OUT,
    output wire D_MEM_CSN_OUT
);

    reg _D_MEM_WEN;
    reg [3:0] _D_MEM_BE;
    reg _D_MEM_CSN;

    assign D_MEM_WEN_OUT = _D_MEM_WEN;
    assign D_MEM_BE_OUT = _D_MEM_BE;
    assign D_MEM_CSN_OUT = _D_MEM_CSN;

    initial begin
        _D_MEM_WEN = 0;
        _D_MEM_BE = 0;
        _D_MEM_CSN = 0;
    end

    always@ (posedge CLK) begin
		if (ENABLE) begin
        _D_MEM_WEN <= D_MEM_WEN_IN;
        _D_MEM_BE <= D_MEM_BE_IN;
        _D_MEM_CSN <= D_MEM_CSN_IN;
		end
    end

endmodule

