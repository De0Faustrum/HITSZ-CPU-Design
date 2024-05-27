`timescale 1ns / 1ps

`include "defines.vh"

module myCPU (
    input  wire         cpu_rst,
    input  wire         cpu_clk,

    // Interface to IROM
    output wire [13:0]  InstructionAddress,
    input  wire [31:0]  Instruction,
    
    // Interface to Bridge
    output wire [31:0]  Bus_addr,
    input  wire [31:0]  Bus_rdata,
    output wire         Bus_wen,
    output wire [31:0]  Bus_wdata

`ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst,
    output wire [31:0]  debug_wb_pc,
    output              debug_wb_ena,
    output wire [ 4:0]  debug_wb_reg,
    output wire [31:0]  debug_wb_value
`endif
);

wire [31:0] Pc;
wire [31:0] Npc;
wire [31:0] Pc4;
wire [31:0] IDInstruction;
wire [31:0] IDPc4;
wire [1:0] NpcOperation;
wire [0:0] RegisterFileWriteEnable;
wire [1:0] RegisterFileWriteSelect;
wire [2:0] SextOperation;
wire [0:0] AluBSelect;
wire [0:0] DramWriteEnable;
wire [3:0] AluOperation;
wire [1:0] RegisterFileReadEnable;
wire [31:0] Ext;
wire [31:0] RegisterData1;
wire [31:0] RegisterData2;
wire [31:0] WriteData;
wire [1:0] EXNpcOperation;
wire [0:0] EXDramWriteEnable;
wire [3:0] EXAluOperation;
wire [0:0] EXAluBSelect;
wire [0:0] EXRegisterFileWriteEnable;
wire [1:0] EXRegisterFileWriteSelect;
wire [4:0] EXWriteRegister;
wire [31:0] EXPc4;
wire [31:0] EXRegisterData1;
wire [31:0] EXRegisterData2;
wire [31:0] EXExt;
wire [31:0] AluResult;
wire [0:0] AluStatus;
wire [0:0] MEMDramWriteEnable;
wire [0:0] MEMRegisterFileWriteEnable;
wire [1:0] MEMRegisterFileWriteSelect;
wire [4:0] MEMWriteRegister;
wire [31:0] MEMPc4;
wire [31:0] MEMAluResult;
wire [31:0] MEMRegisterData2;
wire [31:0] MEMExt;
wire [31:0] DramData;
wire [0:0] WBRegisterFileWriteEnable;
wire [1:0] WBRegisterFileWriteSelect;
wire [4:0] WBWriteRegister;
wire [31:0] WBPc4;
wire [31:0] WBAluResult;
wire [31:0] WBDramData;
wire [31:0] WBExt;
wire [31:0] NewRegisterData1;
wire [31:0] NewRegisterData2;
wire [0:0] DataHazard;
wire [0:0] ControlHazard;

pc PC(
  .rst(cpu_rst),
  .clk(cpu_clk),
  .Din(Npc),
  .DataHazard(DataHazard),
  .ControlHazard(ControlHazard),
  .Pc(Pc)
);

npc NPC(
  .NpcOperation(EXNpcOperation),
  .Branch(AluStatus),
  .Offset(EXExt),
  .Immediate(AluResult),
  .Pc(Pc),
  .Pc4(Pc4),
  .Npc(Npc)
);

//IROM part
assign InstructionAddress = Pc[15:2];

IF_ID U_IF_ID(
  .clk(cpu_clk),
  .rst(cpu_rst),
  .IFInstruction(Instruction),
  .IFPc4(Pc4),
  .DataHazard(DataHazard),
  .ControlHazard(ControlHazard),  //control_hazard has the top priority!!
  .IDInstruction(IDInstruction),
  .IDPc4(IDPc4)
);

ControlUnit CU(
  .Instruction(IDInstruction),
  .NpcOperation(NpcOperation),
  .RegisterFileWriteEnable(RegisterFileWriteEnable),
  .RegisterFileWriteSelect(RegisterFileWriteSelect),
  .SextOperation(SextOperation),
  .AluBSelect(AluBSelect),
  .DramWriteEnable(DramWriteEnable),
  .AluOperation(AluOperation),
  .RegisterFileReadEnable(RegisterFileReadEnable)
);

sext SEXT(
  .Din(IDInstruction),
  .SextOperation(SextOperation),
  .Ext(Ext)
);

RF U_RF(
  .clk(cpu_clk),
  .ReadRegister1(IDInstruction[19:15]),
  .ReadRegister2(IDInstruction[24:20]),
  .WriteRegister(WBWriteRegister),
  .WriteEnable(WBRegisterFileWriteEnable),
  //the following four datas are components of wD that is a result of the mux
  .RegisterFileWriteSelect(WBRegisterFileWriteSelect),
  .Pc4(WBPc4), //from npc
  .Ext(WBExt), //from sext
  .AluResult(WBAluResult), //from alu
  .DramData(WBDramData),  //from dram
  .RegisterData1(RegisterData1),
  .RegisterData2(RegisterData2),
  .WriteData(WriteData) //only for debug
);

ID_EX U_ID_EX(
  .clk(cpu_clk),
  .rst(cpu_rst),
  .IDNpcOperation(NpcOperation),
  .IDDramWriteEnable(DramWriteEnable),
  .IDAluOperation(AluOperation),
  .IDAluBSelect(AluBSelect),
  .IDRegisterFileWriteEnable(RegisterFileWriteEnable),
  .IDRegisterFileWriteSelect(RegisterFileWriteSelect),
  .IDWriteRegister(IDInstruction[11:7]),
  .IDPc4(IDPc4),
  .IDRegisterData1(NewRegisterData1),
  .IDRegisterData2(NewRegisterData2),
  .IDExt(Ext),
  .EXNpcOperation(EXNpcOperation),
  .EXDramWriteEnable(EXDramWriteEnable),
  .EXAluOperation(EXAluOperation),
  .EXAluBSelect(EXAluBSelect),
  .EXRegisterFileWriteEnable(EXRegisterFileWriteEnable),
  .EXRegisterFileWriteSelect(EXRegisterFileWriteSelect),
  .EXWriteRegister(EXWriteRegister),
  .EXPc4(EXPc4),
  .EXRegisterData1(EXRegisterData1),
  .EXRegisterData2(EXRegisterData2),
  .EXExt(EXExt),
  .ControlHazard(ControlHazard),
  .DataHazard(DataHazard)
);

alu ALU(
  .Resource1(EXRegisterData1),
  .Resource2(EXRegisterData2),
  .Immediate(EXExt),
  .AluBSelect(EXAluBSelect),
  .AluOperation(EXAluOperation),
  .AluResult(AluResult),
  .AluStatus(AluStatus)
);

EX_MEM U_EX_MEM(
  .clk(cpu_clk),
  .rst(cpu_rst),

  .EXDramWriteEnable(EXDramWriteEnable),
  .EXRegisterFileWriteEnable(EXRegisterFileWriteEnable),
  .EXRegisterFileWriteSelect(EXRegisterFileWriteSelect),
  .EXWriteRegister(EXWriteRegister),
  .EXPc4(EXPc4),
  .EXAluResult(AluResult),
  .EXRegisterData2(EXRegisterData2),
  .EXExt(EXExt),

  .MEMDramWriteEnable(MEMDramWriteEnable),
  .MEMRegisterFileWriteEnable(MEMRegisterFileWriteEnable),
  .MEMRegisterFileWriteSelect(MEMRegisterFileWriteSelect),
  .MEMWriteRegister(MEMWriteRegister),
  .MEMPc4(MEMPc4),
  .MEMAluResult(MEMAluResult),
  .MEMRegisterData2(MEMRegisterData2),
  .MEMExt(MEMExt)
);

//dram part 
assign Bus_addr = MEMAluResult;  //DRAM_addr will be alu_c[15:2],you can see it in the Soc part
assign DramData = Bus_rdata;    //lw read 
assign Bus_wen = MEMDramWriteEnable; //sw mem
assign Bus_wdata = MEMRegisterData2;   //sw

MEM_WB U_MEM_WB(
  .clk(cpu_clk),
  .rst(cpu_rst),
  .MEMRegisterFileWriteEnable(MEMRegisterFileWriteEnable),
  .MEMRegisterFileWriteSelect(MEMRegisterFileWriteSelect),
  .MEMWriteRegister(MEMWriteRegister),
  .MEMPc4(MEMPc4),
  .MEMAluResult(MEMAluResult),
  .MEMDramData(DramData),
  .MEMExt(MEMExt),
  .WBRegisterFileWriteEnable(WBRegisterFileWriteEnable),
  .WBRegisterFileWriteSelect(WBRegisterFileWriteSelect),
  .WBWriteRegister(WBWriteRegister),
  .WBPc4(WBPc4),
  .WBAluResult(WBAluResult),
  .WBDramData(WBDramData),
  .WBExt(WBExt)
);

data_hazard_detection U_datahazard_detection(
  .IDReadRegister1(IDInstruction[19:15]),
  .IDReadRegister2(IDInstruction[24:20]),
  .IDRegisterFileReadEnable(RegisterFileReadEnable), //read enable
  .IDRegisterData1(RegisterData1),
  .IDRegisterData2(RegisterData2),

  .EXWriteRegister(EXWriteRegister),
  .EXRegisterFileWriteEnable(EXRegisterFileWriteEnable),
  .EXRegisterFileWriteSelect(EXRegisterFileWriteSelect),
  .EXPc4(EXPc4),
  .EXExt(EXExt),
  .EXAluResult(AluResult),

  .MEMWriteRegister(MEMWriteRegister),
  .MEMRegisterFileWriteEnable(MEMRegisterFileWriteEnable),
  .MEMRegisterFileWriteSelect(MEMRegisterFileWriteSelect),
  .MEMPc4(MEMPc4),
  .MEMExt(MEMExt),
  .MEMAluResult(MEMAluResult),
  .MEMDramData(DramData),

  .WBWriteRegister(WBWriteRegister),
  .WBRegisterFileWriteEnable(WBRegisterFileWriteEnable),
  .WBRegisterFileWriteSelect(WBRegisterFileWriteSelect),
  .WBPc4(WBPc4),
  .WBExt(WBExt),
  .WBAluResult(WBAluResult),
  .WBDramData(WBDramData),

  .NewRegisterData1(NewRegisterData1),
  .NewRegisterData2(NewRegisterData2),
  .DataHazard(DataHazard)
);

control_hazard_detection U_control_hazard_detection(
  .EXNpcOperation(EXNpcOperation),
  .AluStatus(AluStatus),
  .ControlHazard(ControlHazard)
);

`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = (WBPc4 == 32'b0) ? 0 : 1; //if pc4 == 0,it must be nop
    assign debug_wb_pc        = (debug_wb_have_inst) ? (WBPc4 - 4) : 32'b0;
    assign debug_wb_ena       = (debug_wb_have_inst && WBRegisterFileWriteEnable) ? 1'b1 : 1'b0;
    assign debug_wb_reg       = (debug_wb_ena) ? WBWriteRegister : 5'b0;
    assign debug_wb_value     = (debug_wb_ena) ? WriteData : 32'b0;  //wD is only for debug
`endif

endmodule
