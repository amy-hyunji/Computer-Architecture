module controller (

	input [31:0] 
	input wire RSTn;

	output 

	);

	always@ (*) begin
		// I_MEM_CSN, I_MEM_ADDR
		// D_MEM_CSN, D_MEM_DOUT, D_MEM_ADDR, D_MEM_WEN, D_MEM_BE
		// RF_WE, RF_RA1, RF_RA2, RF_WA1, RF_WD, HALT, 

		I_MEM_CSN = ~RSTn;
		I_MEM_ADDR = 0;
		D_MEM_CSN = ~RSTn;
		D_MEM_DOUT = 0;
		D_MEM_ADDR = 0;
		D_MEM_WEN = 0;
		D_MEM_BE = 0;
		RF_WE = 0;
		RF_RA1 = 0;
		RF_RA2 = 0;
		RF_WA1 = 0;
		RF_WD = 0;
		HALT = 0;

		case (opcode)
		7'b0110111: begin //LUI
			RF_WA1 = 	

		7'b0010111: //AUIPC
		7'b1101111: //JAL
		7'b1100111: //JALR
		7'b1100011: //BEQ, BNE, BLT, BGE, BLTU, BGEU,
		7'b0000011: //LB, LH, LW, LBU, LHU
		7'b0100011: //SB, SJ, SW
		7'b0010011: //ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
		7'b0110011: //ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
