module EXREG (
    input wire [3:0] ALUCONTROLOUT_IN,
    input wire AMUX_IN,
    input wire [1:0] BMUX_IN,
    input wire CLK,
	 input wire ENABLE,

    output wire [3:0] ALUCONTROLOUT_OUT,
    output wire AMUX_OUT,
    output wire [1:0] BMUX_OUT
);

    reg [3:0] _ALUCONTROLOUT;
    reg _AMUX;
    reg [1:0] _BMUX;

    assign ALUCONTROLOUT_OUT = _ALUCONTROLOUT;
    assign AMUX_OUT = _AMUX;
    assign BMUX_OUT = _BMUX;

    initial begin
        _ALUCONTROLOUT = 0;
        _AMUX = 0;
        _BMUX = 0;
    end

    always@ (posedge CLK) begin
		if (ENABLE) begin 
        _ALUCONTROLOUT <= ALUCONTROLOUT_IN;
        _AMUX <= AMUX_IN;
        _BMUX <= BMUX_IN;
		end
    end
endmodule
