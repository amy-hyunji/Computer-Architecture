module ALU (
    input wire [3:0] OP,
    input wire [31:0] A,
    input wire [31:0] B,

    output wire [31:0] Out,
	 output wire Zero
);

    reg [31:0] Kout;
	 reg _ZERO;
	 assign Out = Kout;
	 assign Zero = _ZERO;

    initial begin
        Kout = 0;
		  _ZERO = 0;
    end

    always @ (*) begin

		case (OP)

				//add
            4'b0000: Kout = A + B;
            
				//sub
            4'b0001: Kout = A - B;
            
            //sll
            4'b0010: Kout = A << B[4:0];

            //slt
            4'b0011: begin
                if ($signed(A) < $signed(B)) Kout = 1;
                else Kout = 0;
            end

            //stlu
            4'b0100: begin
                if (A < B) Kout = 1;
                else Kout = 0;
            end

            //xor
            4'b0101: Kout = A^B;
            
            //srl
            4'b0110: Kout = A >> B[4:0];

            //sra
            4'b0111: Kout = A >>> B[4:0];
            
            //or
            4'b1000: Kout = A|B;

            //and
            4'b1001: Kout = A&B;
            
            //beq
            4'b1010: begin
                if (A == B) _ZERO = 1;
            end

            //bne
            4'b1011: begin
                if (A != B) _ZERO = 1;
            end

            //blt
            4'b1100: begin
                if ($signed(A) < $signed(B)) _ZERO = 1;
            end

            //bge
            4'b1101: begin
                if ($signed(A) >= $signed(B)) _ZERO = 1;
            end

            //bltu
            4'b1110: begin
                if (A < B) _ZERO = 1;
            end

            //bgeu
            4'b1111: begin
                if(A >= B) _ZERO = 1;
            end

            default: Kout = 0;
			
			endcase
			
	end
endmodule
