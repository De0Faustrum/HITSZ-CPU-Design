`include "defines.vh"
module data_hazard_detection(
  input wire [4:0] IDReadRegister1,
  input wire [4:0] IDReadRegister2,
  input wire [1:0] IDRegisterFileReadEnable,
  input wire [31:0] IDRegisterData1,
  input wire [31:0] IDRegisterData2,
  input wire [4:0] EXWriteRegister,
  input wire [0:0] EXRegisterFileWriteEnable,
  input wire [1:0] EXRegisterFileWriteSelect,
  input wire [31:0] EXPc4,
  input wire [31:0] EXExt,
  input wire [31:0] EXAluResult,
  input wire [4:0] MEMWriteRegister,
  input wire [0:0] MEMRegisterFileWriteEnable,
  input wire [1:0] MEMRegisterFileWriteSelect,
  input wire [31:0] MEMPc4,
  input wire [31:0] MEMExt,
  input wire [31:0] MEMAluResult,
  input wire [31:0] MEMDramData,
  input wire [4:0] WBWriteRegister,
  input wire [0:0] WBRegisterFileWriteEnable,
  input wire [1:0] WBRegisterFileWriteSelect,
  input wire [31:0] WBPc4,
  input wire [31:0] WBExt,
  input wire [31:0] WBAluResult,
  input wire [31:0] WBDramData,
  output reg [31:0] NewRegisterData1, 
  output reg [31:0] NewRegisterData2, 
  output wire [0:0] DataHazard  
);


wire ReadRegisterTypeA1 = (IDReadRegister1 == EXWriteRegister) & EXRegisterFileWriteEnable &
    IDRegisterFileReadEnable[0] & (IDReadRegister1 != 5'B00000);
wire ReadRegisterTypeA2 = (IDReadRegister2 == EXWriteRegister) & EXRegisterFileWriteEnable &
    IDRegisterFileReadEnable[1] & (IDReadRegister2 != 5'B00000);
wire ReadRegisterTypeB1 = (IDReadRegister1 == MEMWriteRegister) & MEMRegisterFileWriteEnable &
    IDRegisterFileReadEnable[0] & (IDReadRegister1 != 5'B00000);
wire ReadRegisterTypeB2 = (IDReadRegister2 == MEMWriteRegister) & MEMRegisterFileWriteEnable &
    IDRegisterFileReadEnable[1] & (IDReadRegister2 != 5'B00000);
wire ReadRegisterTypeC1 = (IDReadRegister1 == WBWriteRegister) & WBRegisterFileWriteEnable &
    IDRegisterFileReadEnable[0] & (IDReadRegister1 != 5'B00000);
wire ReadRegisterTypeC2 = (IDReadRegister2 == WBWriteRegister) & WBRegisterFileWriteEnable &
    IDRegisterFileReadEnable[1] & (IDReadRegister2 != 5'B00000);
    
assign DataHazard = (ReadRegisterTypeA1 && EXRegisterFileWriteSelect == `WB_DRAM) ||
    (ReadRegisterTypeA2 && EXRegisterFileWriteSelect == `WB_DRAM);

always @(*) begin
    if(ReadRegisterTypeA1) begin
        case(EXRegisterFileWriteSelect)
            `WB_PC4: NewRegisterData1 = EXPc4;
            `WB_SEXT:NewRegisterData1 = EXExt;
            `WB_ALU: NewRegisterData1 = EXAluResult;
            default: NewRegisterData1 = EXAluResult;
        endcase
    end
    else if(ReadRegisterTypeB1) begin
        case(MEMRegisterFileWriteSelect)
            `WB_PC4: NewRegisterData1 = MEMPc4;
            `WB_SEXT:NewRegisterData1 = MEMExt;
            `WB_ALU: NewRegisterData1 = MEMAluResult;
            `WB_DRAM:NewRegisterData1 = MEMDramData;
            default: NewRegisterData1 = MEMAluResult;
        endcase
    end
    else if(ReadRegisterTypeC1) begin
        case(WBRegisterFileWriteSelect)
            `WB_PC4: NewRegisterData1 = WBPc4;   
            `WB_SEXT:NewRegisterData1 = WBExt;
            `WB_ALU: NewRegisterData1 = WBAluResult; 
            `WB_DRAM:NewRegisterData1 = WBDramData;  
            default: NewRegisterData1 = WBAluResult;  
        endcase
    end
    else NewRegisterData1 = IDRegisterData1;
end

always @(*) begin
    if(ReadRegisterTypeA2) begin
        case(EXRegisterFileWriteSelect)
            `WB_PC4: NewRegisterData2 = EXPc4;
            `WB_SEXT:NewRegisterData2 = EXExt;
            `WB_ALU: NewRegisterData2 = EXAluResult;
            default: NewRegisterData2 = EXAluResult;
        endcase
    end
    else if(ReadRegisterTypeB2) begin
        case(MEMRegisterFileWriteSelect)
            `WB_PC4: NewRegisterData2 = MEMPc4;
            `WB_SEXT:NewRegisterData2 = MEMExt;
            `WB_ALU: NewRegisterData2 = MEMAluResult;
            `WB_DRAM:NewRegisterData2 = MEMDramData;
            default: NewRegisterData2 = MEMAluResult;
        endcase
    end
    else if(ReadRegisterTypeC2) begin
        case(WBRegisterFileWriteSelect)
            `WB_PC4: NewRegisterData2 = WBPc4;    
            `WB_SEXT:NewRegisterData2 = WBExt;
            `WB_ALU: NewRegisterData2 = WBAluResult; 
            `WB_DRAM:NewRegisterData2 = WBDramData; 
            default: NewRegisterData2 = WBAluResult;  
        endcase
    end
    else NewRegisterData2 = IDRegisterData2;
end

endmodule