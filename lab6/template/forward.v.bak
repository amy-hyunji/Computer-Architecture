module FORWARD(
    input wire [4:0] rs1ex,
    input wire [4:0] rs2ex,
    input wire [4:0] destmem,
    input wire [4:0] destwb,
    input wire regwritemem,
    input wire regwritewb,
    input wire users1,
    input wire users2,

    output wire [1:0] rs1for,
    output wire [1:0] rs2for
);
    reg [1:0] _rs1for;
    reg [1:0] _rs2for;
    initial begin
        _rs1for <= 2'b00;
        _rs2for <= 2'b00;
    end

    assign rs1for = _rs1for;
    assign rs2for = _rs2for;

    always@ (*) begin
        if((rs1ex != 0) && (rs1ex==destmem) && regwritemem && users1) begin
            _rs1for = 2'b01; // forward from mem stage
            end
        else if((rs1ex != 0) && (rs1ex==destwb) && regwritewb && users1) begin
            _rs1for = 2'b10; // forward from wb stage
            end
        else _rs1for = 2'b00; // no forwarding

        if((rs2ex != 0) && (rs2ex==destmem) && regwritemem && users2) begin
            _rs2for = 2'b01; // forward from mem stage
            end
        else if((rs2ex != 0) && (rs2ex==destwb) && regwritewb && users2) begin
            _rs2for = 2'b10; // forward from wb stage
            end
        else _rs2for = 2'b00; // no forwarding
    end

endmodule
            


