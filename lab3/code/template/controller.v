module CONTROL (

	input wire [31:0] _Instruction, 

	output wire _ALUIMUX,
	output wire [3:0] _ALUI,
	output wire [3:0] _ALUR,
	output wire _BRANCH,
	output wire [1:0] _REMUX,
	output wire [2:0] _LFUNCT,
	output wire _ISJALR,
	output wire _ISJUMP,

	output wire _D_MEM_WEN,
	output wire [3:0] _D_MEM_BE,
	output wire _RF_WE,
	output wire	[4:0] _RF_RA1,
	output wire [4:0] _RF_RA2,
	output wire [4:0] _RF_WA1,
	output wire [31:0] _IMM, 
	output wire _HALT
	);

	reg[31:0] Instruction;

	reg ALUIMUX;
	reg [3:0] ALUI;
	reg [3:0] ALUR;
	reg BRANCH;
	reg [1:0] REMUX;
	reg [2:0] LFUNCT;
	reg ISJALR;
	reg ISJUMP;

	reg D_MEM_WEN;
	reg [3:0] D_MEM_BE;
	reg RF_WE;
	reg [4:0] RF_RA1;
	reg [4:0] RF_RA2;
	reg [4:0] RF_WA1;
	reg [31:0] IMM;
	reg HALT;

	assign _ALUIMUX = ALUIMUX;
	assign _ALUI = ALUI;
	assign _ALUR = ALUR;
	assign _BRANCH = BRANCH;
	assign _REMUX =  REMUX;
	assign _LFUNCT = LFUNCT;
	assign _D_MEM_WEN = D_MEM_WEN;
	assign _D_MEM_BE = D_MEM_BE;
	assign _RF_WE = RF_WE;
	assign _RF_RA1 = RF_RA1;
	assign _RF_RA2 = RF_RA2;
	assign _RF_WA1 = RF_WA1;
	assign _IMM = IMM;
	assign _HALT = HALT;
	assign _ISJALR = ISJALR;
	assign _ISJUMP = ISJUMP;

	initial begin
		Instruction = 0;
		ALUIMUX = 0;
		ALUI = 4'b0000;
		ALUR = 4'b0000;
		BRANCH = 0;
		REMUX = 2'b00;
		LFUNCT= 3'b000;
		ISJALR = 1'b0;
		ISJUMP = 1'b0;

		D_MEM_WEN = 1;
		D_MEM_BE = 0;
		RF_WE = 0;
		RF_RA1 = 0;
		RF_RA2 = 0;
		RF_WA1 = 0;
		IMM = 0;
		HALT = 0;
	end

	always@ (*) begin
		Instruction = _Instruction;
		//$display ("CONTROLLLLLLLLLLLLLLLLLL %0b %0h", Instruction, Instruction);
		if (Instruction == 32'h00008067) begin //HALT
			//check if RF_RD1 register value is 0x0000000c -> turn to 1
			
		end

		case (Instruction[6:0])
		
		7'b0110111: begin //LUI
		//	$display ("LUI");
			D_MEM_WEN = 1;
			BRANCH = 0;
			RF_WE = 1;
			REMUX = 2'b01;
			RF_WA1 = Instruction[11:7];
			IMM[31:12] = Instruction[31:12];
			IMM[11:0] = 12'b000000000000;
			ISJALR = 0;
			ISJUMP = 0;
		end

		7'b0010111: begin //AUIPC
		//	$display ("AUIPC");
			ALUIMUX = 0;
			ALUI = 4'b0000;
			D_MEM_WEN = 1;
			BRANCH = 0;
			RF_WE = 1;
			REMUX = 2'b01;
			RF_WA1 = Instruction[11:7];
			IMM[31:12] = Instruction[31:12];
			IMM[11:0] = 12'b000000000000;
			ISJALR = 0;
			ISJUMP = 0;
		end

		7'b1101111: begin //JAL
		//	$display("JAL");
			ALUIMUX = 0;
			ALUI = 4'b0000;
			D_MEM_WEN = 1;
			BRANCH = 0;
			RF_WE = 1;
			REMUX = 2'b00;
			RF_WA1 = Instruction[11:7];
			IMM[20] = Instruction[31];
			IMM[19:12] = Instruction[19:12];
			IMM[11] = Instruction[20];
			IMM[10:1] = Instruction[30:21];
			IMM[0] = 0;
			if (Instruction[31] == 0) IMM[31:21] = 11'b00000000000;
			else IMM[31:21] = 11'b11111111111;
			ISJALR = 0;
			ISJUMP = 1;
		end

		7'b1100111: begin //JALR
		//	$display ("JALR");
			ALUIMUX = 1;
			ALUI = 4'b0000;
			D_MEM_WEN = 1;
			BRANCH = 0;
			RF_WE = 1;
			REMUX = 2'b00;
			RF_RA1 = Instruction[19:15];
			RF_WA1 = Instruction[11:7];
			IMM[11:0] = Instruction[31:20];
			if (Instruction[31] == 0) IMM[31:12] = 20'b00000000000000000000;
			else IMM[31:12] = 20'b11111111111111111111;
			ISJALR = 1;
			ISJUMP = 1;
		end

		7'b1100011: begin //BEQ, BNE, BLT, BGE, BLTU, BGEU,
			//$display ("Bs");
			ALUIMUX = 0;
			ALUI =  4'b0000;
			D_MEM_WEN = 1;
			BRANCH = 1;
			RF_WE = 0;
			RF_RA1 = Instruction[19:15];
			RF_RA2 = Instruction[24:20];
			IMM[3:0] = Instruction[11:8];
			IMM[9:4] = Instruction[30:25];
			IMM[10] = Instruction[7];
			IMM[11] = Instruction[31];
			if (Instruction[31] == 0) IMM[31:12] = 20'b00000000000000000000;
			else IMM[31:12] = 20'b11111111111111111111;
			ISJALR = 0;
			ISJUMP = 0;
		   
			case(Instruction[14:12])
			3'b000: begin//BEQ
		//		$display ("BEQ");
				ALUR = 4'b1010;
			end
			3'b001: begin//BNE
		//		$display ("BNE");
				ALUR = 4'b1011;
			end
			3'b100: begin//BLT
		//		$display ("BLT");
				ALUR = 4'b1100;
			end
			3'b101: begin//BGE
		//		$display ("BGE");
				ALUR = 4'b1101;
			end
			3'b110: begin//BLTU
		//		$display ("BLTU");
				ALUR = 4'b1110;
			end
			3'b111: begin//BGEU
		//		$display ("BGEU");
				ALUR = 4'b1111;
			end
			endcase
		
		end


		7'b0000011: begin //LB, LH, LW, LBU, LHU
		//	$display ("LOAD");
			ALUIMUX = 1;
			ALUI = 4'b0000;
			D_MEM_WEN =  1;
			BRANCH = 0;
			RF_WE =  1;
			REMUX = 2'b10;
			LFUNCT = Instruction[14:12];
			RF_RA1 = Instruction[19:15];
			RF_WA1 = Instruction[11:7];
			IMM[11:0] = Instruction[31:20];
			if (Instruction[31] == 0) IMM[31:12] = 20'b00000000000000000000;
			else IMM[31:12] = 20'b11111111111111111111;
			ISJALR = 0;
			ISJUMP = 0;
		end

		7'b0100011: begin //SB, SJ, SW
			ALUIMUX = 1;
			ALUI = 4'b0000;
			D_MEM_WEN = 0;
			BRANCH = 0;
			RF_WE = 0;
			RF_RA1 = Instruction[19:15];
			RF_RA2 = Instruction[24:20];
			IMM[4:0] = Instruction[11:7];
			IMM[11:5] = Instruction[31:25];
			if (Instruction[31] == 0) IMM[31:12] = 20'b00000000000000000000;
			else IMM[31:12] = 20'b11111111111111111111;
			ISJALR = 0;
			ISJUMP = 0;

			case(Instruction[14:12])
			3'b000: begin//SB
		//		$display ("SB");
				D_MEM_BE = 4'b0001;
			end
			3'b001: begin//SH
		//		$display ("SH");
				D_MEM_BE = 4'b0011;
			end
			3'b010: begin//SW
		//		$display ("SW");
				D_MEM_BE = 4'b1111;
			end
			endcase
		end

		7'b0010011: begin //ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
			ALUIMUX = 1;
			D_MEM_WEN = 1;
			BRANCH = 0;
			RF_WE = 1;
			REMUX = 2'b01;
			RF_RA1 = Instruction[19:15];
			RF_WA1 = Instruction[11:7];
			IMM[11:0] = Instruction[31:20];
			if (Instruction[31] == 0) IMM[31:12] = 20'b00000000000000000000;
			else IMM[31:12] = 20'b11111111111111111111;
			ISJALR = 0;
			ISJUMP = 0;

			case(Instruction[14:12])
			3'b000: begin //ADDI
		//		$display ("ADDI");
				ALUI = 4'b0000;
			end
			3'b010: begin//SLTI
		//		$display ("SLTI");
				ALUI = 4'b0011;
			end
			3'b011: begin//SLTIU
		//		$display ("SLTIU");
				ALUI = 4'b0100;
			end
			3'b100: begin//XORI
		//		$display ("XORI");
				ALUI = 4'b0101;
			end
			3'b110: begin//ORI
		//		$display ("ORI");
				ALUI = 4'b1000;
			end
			3'b111: begin//ANDI
		//		$display ("ANDI");
				ALUI = 4'b1001;
			end
			3'b001: begin//SLLI
		//		$display ("SLLI");
				ALUI = 4'b0010;
			end
			3'b101: begin//SRLI or SRAI
				if (Instruction[31:25] == 7'b0000000) begin//SRLI
					ALUI = 4'b0110;
		//			$display ("SRLI");
				end
				else begin//SRAI
		//			$display ("SRAI");
					ALUI = 4'b0111;
				end
			end
			endcase
		end

		7'b0110011: begin //ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
			D_MEM_WEN = 1;
			BRANCH = 0;
			RF_WE = 1;
			REMUX = 2'b11;
			RF_RA1 = Instruction[19:15];
			RF_RA2 = Instruction[24:20];
			RF_WA1 = Instruction[11:7];
			ISJALR = 0;
			ISJUMP = 0;

			case(Instruction[14:12])
			3'b000: begin//ADD, SUB
		//		$display ("ADD / SUB");
				if (Instruction[31:25] == 7'b0000000) ALUR = 4'b0000; 
				else ALUR = 4'b0001;
			end
			3'b001: begin//SLL
		//		$display ("SLL");
				ALUR = 4'b0010;
			end
			3'b010: begin//SLT
		//		$display ("SLT");
				ALUR = 4'b0011;
			end	
			3'b011: begin//STLU
		//		$display ("STLU");
				ALUR = 4'b0100;
			end
			3'b100: begin//XOR
		//		$display ("XOR");
				ALUR = 4'b0101;
			end
			3'b101: begin//SRL, SRA
		//		$display ("SRL/ SRA");
				if (Instruction[31:25] == 7'b0000000) ALUR = 4'b0110; 
				else ALUR = 4'b0111;
			end
			3'b110: begin//OR
		//		$display ("OR");
				ALUR = 4'b1000;
			end
			3'b111: begin//AND
		//		$display ("AND");
				ALUR = 4'b1001;
			end
			endcase
		end

	   endcase
	end
endmodule
