module FORWARD(
    input wire [4:0] rs1ex,
    input wire [4:0] rs2ex,
    input wire [4:0] destmem,
    input wire [4:0] destwb,
    input wire regwritemem,
    input wire regwritewb,

    output wire [1:0] rs1for,
    output wire [1:0] rs2for
);
    reg [1:0] _rs1for;
    reg [1:0] _rs2for;
    assign rs1for = rs1for;
    assign rs2for = rs2for;

    always@ (*) begin
        if((rs1ex != 0) && (rs1ex==destmem) && regwritemem) begin
            _rs1for = 2'b01; // forward from mem stage
            end
        else if((rs1ex != 0) && (rs1ex==destwb) && regwritewb) begin
            _rs1for = 2'b10; // forward from wb stage
            end
        else _rs1for = 2'b00; // no forwarding

        if((rs2ex != 0) && (rs2ex==destmem) && regwritemem) begin
            _rs2for = 2'b01; // forward from mem stage
            end
        else if((rs2ex != 0) && (rs2ex==destwb) && regwritewb) begin
            _rs2for = 2'b10; // forward from wb stage
            end
        else _rs2for = 2'b00; // no forwarding
    end

endmodule
            


