`timescale 100ps / 100ps 

`define OP_ADD 4'b0000
`define OP_SUB 4'b0001
`define OP_SLL 4'b0010
`define OP_SLT 4'b0011
`define OP_STLU 4'b0100
`define OP_XOR 4'b0101
`define OP_SRL 4'b0110
`define OP_SRA 4'b0111
`define OP_OR 4'b1000
`define OP_AND 4'b1001
`define OP_BEQ 4'b1010
`define OP_BNE 4'b1011
`define OP_BLT 4'b1100
`define OP_BGE 4'b1101
`define OP_BLTU 4'b1110
`define OP_BGEU 4'b1111

module ALU_TB;

reg[31:0] A;
reg [31:0] B;
wire [31:0] C;
reg [3:0] OP;

ALU UUT (
    .OP(OP),
    .A(A),
    .B(B),
    .Out(C));

initial begin
    Passed = 0;
    Failed = 0;

    AddTest;
    $finish;
end

task AddTest;
    begin
        OP = `OP_ADD;
        Test("add-1", 0,0,0);
        Test("Add-2", 1, 0, 1);
        Test("Add-3", 2, 3, 5);
        Test("Add-4", 3, 2, 5);
        Test("Add-5", 2, 3, 5);
        Test("Add-6", 3, 2, 5);
        Test("Add-7", 32'h80000000, 32'h80000000, 0);
        Test("Add-8", 32'hffffffff, 1, 0);
        Test("Add-9", 32'hffffffff, 32'hffffffff, 32'hfffffffe);
    end
endtask

task Test;
    input [16 * 8 : 0] test_name;
    input [31:0] A_;
    input [31:0] B_;
    input [31:0] C_expected;
begin
    $display("TEST %s :", test_name);
    A = A_;
    B = B_;
    #1;
    $display("C = %0b, expected_C = %0b", C, C_expected);
    if (C == C_expected) begin
        $display ("PASSED\n");
        Passed = Passed + 1;
    end
    else begin
        $display("FAILED\n");
        Failed = Failed + 1;
    end
end
endtask

endmodule
