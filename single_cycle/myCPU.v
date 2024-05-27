`timescale 1ns / 1ps

`include "defines.vh"

module myCPU (
    input wire [0:0] cpu_rst,
    input wire [0:0] cpu_clk,
    
    input wire [31:0] Instruction,
    output wire [13:0] InstructionAddress, 
    
    input wire [31:0] Bus_rdata,
    output wire [31:0] Bus_addr,
    output wire [0:0] Bus_wen,
    output wire [31:0] Bus_wdata

`ifdef RUN_TRACE
    ,
    output wire [0:0] debug_wb_have_inst,
    output wire [0:0] debug_wb_ena,
    output wire [4:0] debug_wb_reg,
    output wire [31:0] debug_wb_pc,
    output wire [31:0] debug_wb_value
`endif
);

wire [31:0] Pc;
wire [31:0] Npc;
wire [31:0] Pc4;
wire [1:0] NpcOperation;
wire [0:0] RegisterFileWriteEnable;
wire [1:0] RegisterFileWriteSelect;
wire [2:0] SextOperation;
wire [0:0] AluBSelect;
wire [0:0] DramWriteEnable;
wire [3:0] AluOperation;
wire [31:0] Ext;
wire [31:0] RegisterData1;
wire [31:0] RegisterData2;
wire [31:0] WriteData;
wire [31:0] AluResult;
wire [0:0] AluStatus;
wire [31:0] DramData;

pc PC(
  .rst(cpu_rst),
  .clk(cpu_clk),
  .Din(Npc),
  .Pc(Pc)
);

npc NPC(
  .Operation(NpcOperation),
  .Branch(AluStatus),
  .Offset(Ext),
  .NpcImmediate(AluResult),
  .Pc(Pc),
  .Pc4(Pc4),
  .Npc(Npc)
);

assign InstructionAddress = Pc[15:2];

ControlUnit CU(
  .Instruction(Instruction),
  .NpcOperation(NpcOperation),
  .RegisterFileWriteEnable(RegisterFileWriteEnable),
  .rf_wsel(RegisterFileWriteSelect),
  .SextOperation(SextOperation),
  .AluBSelect(AluBSelect),
  .DramWriteEnable(DramWriteEnable),
  .AluOperation(AluOperation)
);

sext SEXT(
  .Din(Instruction),
  .SextOperation(SextOperation),
  .Ext(Ext)
);

RF U_RF(
  .clk(cpu_clk),
  .ReadRegister1(Instruction[19:15]),
  .ReadRegister2(Instruction[24:20]),
  .WriteRegister(Instruction[11:7]),
  .WriteEnable(RegisterFileWriteEnable),
  .RegisterFileWriteSelect(RegisterFileWriteSelect),
  .Pc4(Pc4), 
  .Ext(Ext), 
  .AluResult(AluResult),
  .DramData(DramData),
  .RegisterData1(RegisterData1),
  .RegisterData2(RegisterData2),
  .WriteData(WriteData)
);

alu ALU(
  .Resource1(RegisterData1),
  .Resource2(RegisterData2),
  .Immediate(Ext),
  .AluBSelect(AluBSelect),
  .AluOperation(AluOperation),
  .AluResult(AluResult),
  .AluStatus(AluStatus)
);


assign Bus_addr = AluResult;  
assign DramData = Bus_rdata;    
assign Bus_wen = DramWriteEnable; 
assign Bus_wdata = RegisterData2;   

`ifdef RUN_TRACE
    assign debug_wb_have_inst = 1;
    assign debug_wb_pc = (debug_wb_have_inst) ? Pc : 32'b0;
    assign debug_wb_ena = (debug_wb_have_inst && RegisterFileWriteEnable) ? 1'b1 : 1'b0;
    assign debug_wb_reg = (debug_wb_ena) ? Instruction[11:7] : 5'b0;
    assign debug_wb_value = (debug_wb_ena) ? WriteData : 32'b0;
`endif

endmodule
