module WBREG (
    input wire RF_WE_IN,
    input wire [1:0] MREWR_MUX_IN,
    input wire NUMINSTADD_IN,
    input wire RD_FOR_MUX_IN,
    input wire CLK,
	 input wire ENABLE,

    output wire RF_WE_OUT,
    output wire [1:0] MREWR_MUX_OUT,
    output wire NUMINSTADD_OUT,
    output wire RD_FOR_MUX_OUT
);

    reg _RF_WE;
    reg _NUMINSTADD;
    reg [1:0] _MREWR_MUX;
    reg RD_FOR_MUX;

    assign RF_WE_OUT = _RF_WE;
    assign MREWR_MUX_OUT = _MREWR_MUX;
    assign NUMINSTADD_OUT = _NUMINSTADD;
    assign RD_FOR_MUX_OUT = RD_FOR_MUX;

    initial begin
        _RF_WE = 0;
        _NUMINSTADD = 0;
        _MREWR_MUX = 0;
		  RD_FOR_MUX = 0;
    end

    always@ (posedge CLK) begin
		if (ENABLE) begin
        _RF_WE <= RF_WE_IN;
        _MREWR_MUX <= MREWR_MUX_IN;
        _NUMINSTADD <= NUMINSTADD_IN;
		  RD_FOR_MUX <= RD_FOR_MUX_IN;
		end
    end
endmodule

module LASTWBREG (
    input wire RF_WE_IN,
    input wire [1:0] MREWR_MUX_IN,
    input wire NUMINSTADD_IN,
    input wire CLK,
	 input wire ENABLE,

    output wire RF_WE_OUT,
    output wire [1:0] MREWR_MUX_OUT,
    output wire NUMINSTADD_OUT
);

    reg _RF_WE;
    reg _NUMINSTADD;
    reg [1:0] _MREWR_MUX;

    assign RF_WE_OUT = _RF_WE;
    assign MREWR_MUX_OUT = _MREWR_MUX;
    assign NUMINSTADD_OUT = _NUMINSTADD;

    initial begin
        _RF_WE = 0;
        _NUMINSTADD = 0;
        _MREWR_MUX = 0;
    end

    always@ (posedge CLK) begin
		if (ENABLE) begin
        _RF_WE <= RF_WE_IN;
        _MREWR_MUX <= MREWR_MUX_IN;
        _NUMINSTADD <= NUMINSTADD_IN;
		end
		else begin
			_RF_WE <= 0;
			_MREWR_MUX <= 2'b10;
			_NUMINSTADD <= 0;
		end
    end
endmodule
