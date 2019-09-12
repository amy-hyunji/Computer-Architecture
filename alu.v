`timescale 1ns / 100ps

module ALU(A,B,OP,C,Cout);

	input [15:0]A;
	input [15:0]B;
	input [3:0]OP;
	output [15:0]C;
	output Cout;

	//TODO
	reg [15:0] K;
	reg [1:0] Kout;
	assign Cout = Kout;
	assign C = K;
	always @(*) begin
		Kout = 0;
		case(OP)
			4'b0000: begin
				K = A+B;
				if ((A[15]==B[15])&(A[15]!=K[15])) Kout = 1;
				end
			4'b0001: begin
				K = A-B;
				if ((B[15]==K[15])&(A[15]!=B[15])) Kout = 1;
				end
			4'b0010: K = A&B;
			4'b0011: K = A|B;
			4'b0100: K = ~(A&B);
			4'b0101: K = ~(A|B);
			4'b0110: K = A^B;
			4'b0111: K = A~^B;
			4'b1000: K = A;
			4'b1001: K = ~A;
			4'b1010: K = A >> 1;
			4'b1011: K = {A[15], A[15:1]};
			4'b1100: K = {A[0], A[15:1]};
			4'b1101: K = A << 1;
			4'b1110: K = {A[14:0], A[0]};
			default: K = {A[14:0], A[15]};
		endcase
	end
endmodule

