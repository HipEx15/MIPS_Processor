// Code your design here

// PC -> D: 10.09.2022 H: 13:18 // MODIFIED D: 16.09.2022 H: 10:57 

module PC (PCin, PCout, clock, reset);
  
  input clock, reset;
  input [31:0] PCin;
  output reg [31:0] PCout;

  always @(posedge clock)
      PCout <= PCin;
  
  always @(reset)
    if(reset == 1'b1)
      PCout <= 32'b0;
  
  //initial
    //PCout = 0;

endmodule

// ADD_PC -> D: 10.09.2022 H: 16:37 // CREATED: D: 12.09.2022 H: 16:44

module ADD_PC(PCIn, PCOut);
  
	input [31:0] PCIn;
	
	output [31:0] PCOut;
	
	assign PCOut = PCIn + 4;

endmodule

// MUX Instruction -> D: 10.09.2022 H: 14:22 // MODIFIED D: 12.09.2022 H: 16:05
 
module MUX_Instruction(Instr20_16, Instr15_11, RegDst, WriteReg);

	input [20:16] Instr20_16;
	input [15:11] Instr15_11;
	input RegDst;
	
	output [4:0] WriteReg;
	
  	assign WriteReg = RegDst ? Instr15_11 : Instr20_16;


endmodule

// SIGN EXTEND -> D: 10.09.2022 H: 14:44 //MODIFIED D: 12.09.2022 H: 15:47

module Sign_Extend(Instr15_0, Instr15_0_Extended);

	input [15:0] Instr15_0;
	output [31:0] Instr15_0_Extended;

  	assign Instr15_0_Extended = {{16{Instr15_0[15]}}, Instr15_0};
	
endmodule

// MUX Registers -> D: 10.09.2022 H: 15:19 //MODIFIED D: 12.09.2022 H: 16:10

module MUX_Registers(ReadData2, SignExtended, ALUSrc, ALURegRes);

	input [31:0] ReadData2, SignExtended;
	input ALUSrc;
	
	output [31:0] ALURegRes;
  
    assign ALURegRes = ALUSrc ? SignExtended : ReadData2 ;


endmodule

// ALU_Control -> D: 11.09.2022 H: 11:07

module ALU_Control(ALUOp, Instr5_0, ALUCtrlRes);

	input [1:0] ALUOp;
	input [5:0] Instr5_0;
	
	output reg [3:0] ALUCtrlRes;
	
  always @(ALUOp, Instr5_0)	
		begin
			casex({ALUOp, Instr5_0})
													//pt. R-TYPE
				8'b10_100000: ALUCtrlRes = 4'b0010;	//pt. ADD		=> ADD
				8'b10_100010: ALUCtrlRes = 4'b0110;	//pt. SUB		=> SUB
				8'b10_100100: ALUCtrlRes = 4'b0000;	//pt. AND		=> AND
				8'b10_100101: ALUCtrlRes = 4'b0001;	//pt. OR		=> OR
				8'b10_101010: ALUCtrlRes = 4'b0111;	//pt. SLT		=> comp <
              	8'b00_xxxxxx: ALUCtrlRes = 4'b0010;	//pt. LW si SW	=> ADD
				8'b01_xxxxxx: ALUCtrlRes = 4'b0110;	//pt. BEQ		=> SUB
				8'bxx_xxxxxx: ALUCtrlRes = 4'b1111;   // ???
		endcase
	end
	
endmodule

//ALU -> D: 11.09.2022 H: 11:51

module ALU(ReadData1, MuxRegRes, ALUCtrlRes, Zero, ALURes);

	input [31:0] ReadData1, MuxRegRes;
	input [3:0] ALUCtrlRes;
	
	output Zero;
	output reg [31:0] ALURes;
	
	assign Zero = (ALURes == 0);
	
	always@ (ALUCtrlRes, ReadData1, MuxRegRes) 
		begin
			case (ALUCtrlRes)
				4'b0000: ALURes = ReadData1 & MuxRegRes;
				4'b0001: ALURes = ReadData1 | MuxRegRes;
				4'b0010: ALURes = ReadData1 + MuxRegRes;
				4'b0110: ALURes = ReadData1 - MuxRegRes;
				4'b0111: ALURes = ReadData1 < MuxRegRes ? 1:0;
				//4'b1100: ALURes = ~(ReadData1 | MuxRegRes);
				default: ALURes <= 32'b0;
			endcase
		end

endmodule

//MUX_DataMemory -> D: 11.09.2022 H: 14:18 //MODIFIED D: 12.09.2022 H: 16:18

module MUX_DataMemory(ReadData, ALUOut, MemToReg, WriteDataReg);

	input [31:0] ReadData, ALUOut;
	input MemToReg;
	
	output [31:0] WriteDataReg;
  
  	assign WriteDataReg = MemToReg ? ReadData : ALUOut ;
		
endmodule

//AND -> D: 11.09.2022 H: 14:49 //MODIFIED D: 12.09.2022 H: 16:18

module AND(Branch, ALUZero, ANDOut);

	input Branch, ALUZero;
	output ANDOut;
  
	assign ANDOut = Branch && ALUZero;
		
	
endmodule

//ShiftLeft2IR -> D: 11.09.2022 H: 15:00 //MODIFIED D: 12.09.2022 H: 16:21

module ShiftLeft2IR(ShiftLeft2In, ShiftLeft2Out);

  	input [25:0] ShiftLeft2In;
	
  	output [27:0] ShiftLeft2Out;
	
	assign ShiftLeft2Out = ShiftLeft2In << 2;
		
endmodule

//ShiftLeft2Addr -> D: 15.09.2022 H: 09:12

module ShiftLeft2Addr(ShiftLeft2In, ShiftLeft2Out);

	input [31:0] ShiftLeft2In;
	
	output [31:0] ShiftLeft2Out;
	
	assign ShiftLeft2Out = ShiftLeft2In << 2;
		
endmodule

//ADD_Branch -> D: 11.09.2022 H: 15:08 //MODIFIED D: 12.09.2022 H: 16:25

module ADD_Branch(ShiftLeft2Out, PCOut, ADDBRes);
  
	input [31:0] ShiftLeft2Out, PCOut;
	
	output [31:0] ADDBRes;
	
	assign ADDBRes = ShiftLeft2Out + PCOut;

endmodule

// MUX_Branch -> D: 11.09.2022 H: 15:42 //MODIFIED D: 12.09.2022 H: 16:29

module MUX_Branch(ALUBrRes, PCOut, ANDOut, MUXBrRes);

	input [31:0] ALUBrRes, PCOut;
	input ANDOut;
	
	output [31:0] MUXBrRes;
  
  	assign MUXBrRes = ANDOut ? ALUBrRes : PCOut ;

endmodule

//MUX_Jump -> D: 11.09.2022 H: 15:53 //MODIFIED D: 12.09.2022 H: 16:32

module MUX_Jump(IRin, MUXBrOut, Jump, MUXJOut);

	input [31:0] IRin, MUXBrOut;
	input Jump;
	
	output [31:0] MUXJOut;
	
    assign MUXJOut = Jump ? IRin : MUXBrOut ;

endmodule

//Control_Unit -> D: 12.09.2022 H: 10:32

module Control_Unit (Instr31_26, RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp, Jump);

	input [5:0] Instr31_26;
	
	output reg RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, Jump;
	output reg [1:0] ALUOp;
	
	always@ (Instr31_26)
		begin
			casex(Instr31_26)
				6'b000000: //R-Format
					begin
						RegDst = 1'b1;
						ALUSrc = 1'b0;
						MemToReg = 1'b0;
						RegWrite = 1'b1;
						MemRead = 1'b0;
						MemWrite = 1'b0;
						Branch = 1'b0;
						ALUOp = 2'b10;
                      	Jump = 1'b0;
					end
              6'b000010: // JUMP
                begin
						RegDst = 1'bx;
						ALUSrc = 1'bx;
						MemToReg = 1'bx;
						RegWrite = 1'b0;
						MemRead = 1'bx;
						MemWrite = 1'b0;
						Branch = 1'b0;
						ALUOp = 2'bxx;
                  		Jump = 1'b1;
					end
              6'b000100: //BEQ
					begin
						RegDst = 1'bx;
						ALUSrc = 1'b0;
						MemToReg = 1'bx;
						RegWrite = 1'b0;
						MemRead = 1'b0;
						MemWrite = 1'b0;
						Branch = 1'b1;
						ALUOp = 2'b01;
                      	Jump = 1'b0;
					end
              6'b101011: //SW
					begin
						RegDst = 1'bx;
						ALUSrc = 1'b1;
						MemToReg = 1'bx;
						RegWrite = 1'b0;
						MemRead = 1'b0;
						MemWrite = 1'b1;
						Branch = 1'b0;
						ALUOp = 2'b00;
                      	Jump = 1'b0;
					end
              6'b100011: /// LW
					begin
						RegDst = 1'b0;
						ALUSrc = 1'b1;
						MemToReg = 1'b1;
						RegWrite = 1'b1;
						MemRead = 1'b1;
						MemWrite = 1'b0;
						Branch = 1'b0;
						ALUOp = 2'b00;
                      	Jump = 1'b0;
					end
              default:
                 begin
						RegDst = 1'b0;
						ALUSrc = 1'b0;
						MemToReg = 1'b0;
						RegWrite = 1'b0;
						MemRead = 1'b0;
						MemWrite = 1'b0;
						Branch = 1'b0;
						ALUOp = 2'b00;
                  		Jump = 1'b0;
					end
			endcase
		end
endmodule

//Instruction_Memory -> D: 13.09.2022 H: 12:07 //MODIFIED D: 13.09.2022 H: 16:02

module Instruction_Memory(ReadAddr, Instruction31_0, clock, reset);

  	integer i;
  
	input [31:0] ReadAddr;
	input clock, reset;
	
	output reg [31:0] Instruction31_0;

  	reg [7:0] Memory [0:1023];
  
  	initial
      begin
  		$readmemh("Memory.mem", Memory);
        for(i=0; i < 127; i=i+1)
          begin
            $display("%x \n", Memory[i]);
          end
      end
	
  always@ (negedge clock)
      begin
        Instruction31_0 = { Memory[ReadAddr+0], Memory[ReadAddr+1], Memory[ReadAddr+2], Memory[ReadAddr+3] };
      end
  
  always@ (reset)
      begin
        if(reset == 1'b1)
          Instruction31_0 = 32'b0;
      end
	
endmodule

//Registers -> D: 14.09.2022 H: 08:31

module Registers(Instr25_21, Instr20_16, WriteReg, WriteData, ReadData1, ReadData2, RegWrite, clock, reset);

  	integer i;
  
	input RegWrite, clock, reset;
	input [4:0] Instr25_21, Instr20_16, WriteReg;
	input [31:0] WriteData;
	
	output [31:0] ReadData1, ReadData2;
	
  	reg [31:0] Registers [0:31];
  
  wire [31:0] zero, at, v0, v1, a0, a1, a2, a3, t0, t1, t2, t3, t4, t5, t6, t7, s0, s1, s2, s3, s4, s5, s6, s7, t8, t9, k0, k1, gp, sp, fp, ra;
  
  assign zero = Registers[0]; // The Constant Value 0
  
  assign at = Registers[1]; // Assembler Temporary
  
  assign v0 = Registers[2]; // Values for Function Results 
  assign v1 = Registers[3];	// and Expression Evaluation
  
  assign a0 = Registers[4]; // Arguments
  assign a1 = Registers[5];
  assign a2 = Registers[6];
  assign a3 = Registers[7];
  
  assign t0 = Registers[8]; // Temporaries
  assign t1 = Registers[9];
  assign t2 = Registers[10];
  assign t3 = Registers[11];
  assign t4 = Registers[12];
  assign t5 = Registers[13];
  assign t6 = Registers[14];
  assign t7 = Registers[15];
  
  assign s0 = Registers[16]; // Saved Temporaries
  assign s1 = Registers[17];
  assign s2 = Registers[18];
  assign s3 = Registers[19];
  assign s4 = Registers[20];
  assign s5 = Registers[21];
  assign s6 = Registers[22];
  assign s7 = Registers[23];
  
  assign t8 = Registers[24]; // Temporaries
  assign t9 = Registers[25];
  
  assign k0 = Registers[26]; // Reserved for OS Kernel
  assign k1 = Registers[27];
  
  assign gp = Registers[28]; // Global Pointer
  assign sp = Registers[29]; // Stack Pointer
  assign fp = Registers[30]; // Frame Pointer
  assign ra = Registers[31]; // Return Address
	
  	//Read
  
	assign ReadData1 = Registers[Instr25_21];
	assign ReadData2 = Registers[Instr20_16];
	
  	//Write
  
	always@ (posedge clock)
		begin
			if(RegWrite == 1'b1)
              Registers[WriteReg] = WriteData;
		 end
  
    always@ (reset)
      begin
        if(reset == 1'b1)
          for(i=0; i < 32; i=i+1)
            begin
              Registers[i] = 32'b0;
            end
      end
  
  	/*initial
      for(i=0; i < 32; i=i+1)
        begin
          Registers[i] = 32'b0;
        end
  	*/
endmodule

//Data_Memory -> D: 14.09.2022 H: 09:37
	
module Data_Memory(Address, WriteData, ReadData, MemWrite, MemRead, clock); // + reset

	input clock, MemWrite, MemRead; // reset
	input [31:0] Address, WriteData;
	
	output [31:0] ReadData;
  	
  	reg [7:0] Memory [0:1023];
	
  	// Memory write is sync with the clock and the memory read is async
  
    always@ (posedge clock)
      if(MemWrite == 1'b1)
        begin
          Memory[Address] = WriteData[31:24];
          Memory[Address+1] = WriteData[23:16];
          Memory[Address+2]	= WriteData[15:8];
          Memory[Address+3]	=  WriteData[7:0];
        end

    assign ReadData = MemRead ? { Memory[Address+0], Memory[Address+1], Memory[Address+2], Memory[Address+3] } : 32'bz;

  
    /*always@ (reset)
        begin
          if(reset == 1'b1)
            ReadData = 0;
        end*/
  
	initial
      begin
        //ReadData = 0;
        $readmemh("Memory.mem", Memory,0,1023);
      end
	  
endmodule
