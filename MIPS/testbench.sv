// Code your testbench here
// or browse Examples

module MIPS;
  
  reg tb_clock, tb_reset;  
  
  wire [31:0] tb_PCin, tb_PCout, tb_PCout4;
  wire [31:0] tb_Instruction, tb_ExtendedInstr15_0, tb_InstructionShifted31_0, tb_BranchAdd, tb_MUXBrRes, tb_JumpAddr, tb_MuxReg, tb_ALURes;
  wire [31:0] tb_WriteData, tb_ReadData1, tb_ReadData2, tb_ReadData;
  wire [27:0] tb_InstructionShifted25_0;
  wire [4:0] tb_WriteReg;
  
  wire tb_RegDst, tb_ALUSrc, tb_MemToReg, tb_RegWrite, tb_MemRead, tb_MemWrite, tb_Branch, tb_Jump, tb_Zero, tb_AndOut;
  wire [1:0] tb_ALUOp;
  wire [3:0] tb_ALUCtrlRes;
  
  initial
    begin
      #0 tb_clock = 1'b0;
      forever #2 tb_clock = ~tb_clock;
    end
  
  initial
    begin
      #0 tb_reset = 1'b0;
      #7 tb_reset = 1'b1;
      #1 tb_reset = 1'b0;
    end
  
  PC PC_Reg(tb_PCin, tb_PCout, tb_clock, tb_reset);
  
  ADD_PC ADDPC(tb_PCout, tb_PCout4);
  
  Instruction_Memory InstrMem(tb_PCout, tb_Instruction, tb_clock, tb_reset);
  
  MUX_Instruction MUX_Instr(tb_Instruction[20:16], tb_Instruction[15:11], tb_RegDst, tb_WriteReg);
  
  Control_Unit CtrlUnit(tb_Instruction[31:26],tb_RegDst, tb_ALUSrc, tb_MemToReg, tb_RegWrite, tb_MemRead, tb_MemWrite, tb_Branch, tb_ALUOp, tb_Jump);
  
  Sign_Extend SignExtend(tb_Instruction[15:0], tb_ExtendedInstr15_0);
  
   ShiftLeft2IR ShiftLeftIR(tb_Instruction[25:0], tb_InstructionShifted25_0);
  
  ShiftLeft2Addr ShiftLeftADDR(tb_ExtendedInstr15_0, tb_InstructionShifted31_0);
  
  Registers Register(tb_Instruction[25:21], tb_Instruction[20:16], tb_WriteReg, tb_WriteData, tb_ReadData1, tb_ReadData2, tb_RegWrite, tb_clock, tb_reset); 
  
  ADD_Branch AdderBr(tb_InstructionShifted31_0, tb_PCout4, tb_BranchAdd);
  
  AND And(tb_Branch, tb_Zero, tb_AndOut);
  
  MUX_Branch Branch(tb_BranchAdd, tb_PCout4, tb_AndOut, tb_MUXBrRes);
  
  assign tb_JumpAddr = {tb_PCout4[31:28], tb_InstructionShifted25_0[27:0]};
  
  MUX_Jump Jump(tb_JumpAddr, tb_MUXBrRes, tb_Jump, tb_PCin);
  
  MUX_Registers MuxReg(tb_ReadData2, tb_ExtendedInstr15_0, tb_ALUSrc, tb_MuxReg);
  
  ALU_Control ALUCtrl(tb_ALUOp, tb_Instruction[5:0], tb_ALUCtrlRes);
  
  ALU ALUTb (tb_ReadData1, tb_MuxReg, tb_ALUCtrlRes, tb_Zero, tb_ALURes);
  
  Data_Memory DataMemory(tb_ALURes, tb_ReadData2, tb_ReadData, tb_MemWrite, tb_MemRead, tb_clock);
  
  MUX_DataMemory MuxDataMem(tb_ReadData, tb_ALURes, tb_MemToReg, tb_WriteData);
  
    initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars(0, MIPS);
    end
  
  initial
    #200 $finish;
  
endmodule