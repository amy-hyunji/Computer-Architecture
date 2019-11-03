module ALU (
    input wire [4:0] OP,
    input wire [31:0] A,
    input wire [31:0] B,

    output wire [31:0] Out,
	 output wire Zero
	);
    reg [31:0] Kout;
	 reg _Zero;
    assign Out = Kout;
	 assign Zero = _Zero;

    initial begin
        Kout = 0;
		  _Zero = 0;
    end

    always @ (*) begin

		case (OP)

				//add
            5'b00000: begin
					Kout = A + B;
					//$display("A: %b, B: %b, ALU OUTPUT: %b", A, B, Kout);
				end

				//sub
            5'b00001: Kout = A - B;
            
            //sll
            5'b00010: Kout = A << B[4:0];

            //slt
            5'b00011: begin
                if ($signed(A) < $signed(B)) Kout = 1;
                else Kout = 0;
            end

            //stlu
            5'b00100: begin
                if (A < B) Kout = 1;
                else Kout = 0;
            end

            //xor
            5'b00101: Kout = A^B;
            
            //srl
            5'b00110: Kout = A >> B[4:0];

            //sra
            5'b00111: Kout = A >>> B[4:0];
            
            //or
            5'b01000: Kout = A|B;

            //and
            5'b01001: Kout = A&B;
            
            //beq
            5'b01010: begin
                if (A == B) _Zero = 1;
            end

            //bne
            5'b01011: begin
                if (A != B) _Zero = 1;
            end

            //blt
            5'b01100: begin
                if ($signed(A) < $signed(B)) _Zero = 1;
            end

            //bge
            5'b01101: begin
                if ($signed(A) >= $signed(B)) _Zero = 1;
            end

            //bltu
            5'b01110: begin
               if (A < B) _Zero = 1;
            end

            //bgeu
            5'b01111: begin
					if(A >= B) _Zero = 1;
            end

				5'b10000: begin //JALR
					Kout = A+B;
					Kout = Kout & 32'hfffffffe;
				end

            default: Kout = 0;
			
			endcase
			
	end
endmodule
