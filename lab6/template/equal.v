module EQUAL(
    input wire [3:0] OP,
    input wire [31:0] A,
    input wire [31:0] B,

	 output wire Zero //output is 1 if equal
);

	 reg _ZERO;
	 assign Zero = _ZERO;

    initial begin
		  _ZERO = 0;
    end

    always @ (*) begin

		case (OP)
            
            //beq
            4'b1010: begin
                if (A == B) begin
                    _ZERO = 1;
                end
                else begin
                    _ZERO = 0;
				end
            end

            //bne
            4'b1011: begin
                if (A != B) begin
                    _ZERO = 1;
                end
                else begin
                    _ZERO = 0;
                end
            end

            //blt
            4'b1100: begin
                if ($signed(A) < $signed(B)) begin
                    _ZERO = 1;
                end
			    else begin
                    _ZERO = 0;
                end
            end

            //bge
            4'b1101: begin
                if ($signed(A) >= $signed(B)) begin
                    _ZERO = 1;
                end
			    else begin
                    _ZERO = 0;
                end
			end

            //bltu
            4'b1110: begin
                if (A < B) begin
                    _ZERO = 1;
                end
			    else begin
                    _ZERO = 0;
                end
            end

            //bgeu
            4'b1111: begin
                if(A >= B) begin
                    _ZERO = 1;
                end
                else begin
                    _ZERO = 0;
                end
            end

            default: begin 
					//$display("equal.v is wrong!");
					_ZERO = 0;
				end

			endcase
			
	end
endmodule
