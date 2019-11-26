module WBREG (
    input wire RF_WE_IN,
    input wire [1:0] MREWR_MUX_IN,
    input wire NUMINSTADD_IN,
    input wire CLK,

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
        _RF_WE <= RF_WE_IN;
        _MREWR_MUX <= MREWR_MUX_IN;
        _NUMINSTADD <= NUMINSTADD_IN;
    end
endmodule


