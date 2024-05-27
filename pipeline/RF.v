module RF(
    input wire [0:0] clk,          
    input wire [4:0] ReadRegister1,
    input wire [4:0] ReadRegister2,
    input wire [4:0] WriteRegister, 
    input wire [0:0] WriteEnable, 
    input wire [1:0] RegisterFileWriteSelect,
    input wire [31:0] Pc4,         
    input wire [31:0] Ext,         
    input wire [31:0] AluResult,    
    input wire [31:0] DramData,     
    output wire [31:0] RegisterData1,
    output wire [31:0] RegisterData2,
    output reg [31:0] WriteData    
);

reg [31:0] RegisterFile[31:0];

assign RegisterData1 = (ReadRegister1 == 5'B00000)? 32'H00000000 : RegisterFile[ReadRegister1];
assign RegisterData2 = (ReadRegister2 == 5'B00000)? 32'H00000000 : RegisterFile[ReadRegister2];

always @(*) begin
  case(RegisterFileWriteSelect)
    `WB_ALU : WriteData = AluResult;
    `WB_DRAM: WriteData = DramData;
    `WB_PC4 : WriteData = Pc4;
    `WB_SEXT: WriteData = Ext;
    default : WriteData = Pc4;
  endcase
end

always @(posedge clk) begin
    if(WriteEnable && (WriteRegister != 5'B00000)) RegisterFile[WriteRegister] <= WriteData;
end

endmodule