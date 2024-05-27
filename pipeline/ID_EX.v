`include "defines.vh"
module ID_EX(
    input wire [0:0] clk,
    input wire [0:0] rst,
    input wire [0:0] ControlHazard,
    input wire [0:0] DataHazard, 
    input wire [1:0] IDNpcOperation,
    input wire [0:0] IDDramWriteEnable,
    input wire [3:0] IDAluOperation,
    input wire [0:0] IDAluBSelect,
    input wire [0:0] IDRegisterFileWriteEnable,
    input wire [1:0] IDRegisterFileWriteSelect,
    input wire [4:0] IDWriteRegister,
    input wire [31:0] IDPc4,
    input wire [31:0] IDRegisterData1,
    input wire [31:0] IDRegisterData2,
    input wire [31:0] IDExt,

    output reg [1:0] EXNpcOperation,
    output reg [0:0] EXDramWriteEnable,
    output reg [3:0] EXAluOperation,
    output reg [0:0] EXAluBSelect,
    output reg [0:0] EXRegisterFileWriteEnable,
    output reg [1:0] EXRegisterFileWriteSelect,
    output reg [4:0] EXWriteRegister,
    output reg [31:0] EXPc4,
    output reg [31:0] EXRegisterData1,
    output reg [31:0] EXRegisterData2,
    output reg [31:0] EXExt
 
);

always @(posedge clk or posedge rst) begin
    if(rst) EXNpcOperation <= 0;
    else if(ControlHazard | DataHazard) EXNpcOperation <= 0;
    else EXNpcOperation <= IDNpcOperation; 
end

always @(posedge clk or posedge rst) begin
    if(rst) EXDramWriteEnable <= 0;
    else if(ControlHazard | DataHazard) EXDramWriteEnable <= 0;
    else EXDramWriteEnable <= IDDramWriteEnable;
end

always @(posedge clk or posedge rst) begin
    if(rst) EXAluOperation <= 0;
    else if(ControlHazard | DataHazard) EXAluOperation <= 0;
    else EXAluOperation <= IDAluOperation;
end

always @(posedge clk or posedge rst) begin
    if(rst) EXAluBSelect <= 0;
    else if(ControlHazard | DataHazard) EXAluBSelect <= 0;
    else EXAluBSelect <= IDAluBSelect;
end

always @(posedge clk or posedge rst) begin
    if(rst) EXRegisterFileWriteEnable<=0;
    else if(ControlHazard | DataHazard) EXRegisterFileWriteEnable<=0;
    else EXRegisterFileWriteEnable <= IDRegisterFileWriteEnable;
end

always @(posedge clk or posedge rst) begin
    if(rst) EXRegisterFileWriteSelect<=0;
    else if(ControlHazard | DataHazard) EXRegisterFileWriteSelect<=0;
    else EXRegisterFileWriteSelect <= IDRegisterFileWriteSelect;
end

always @(posedge clk or posedge rst) begin
    if(rst) EXWriteRegister<=0;
    else if(ControlHazard | DataHazard) EXWriteRegister<=0;
    else EXWriteRegister <= IDWriteRegister;
end

always @(posedge clk or posedge rst) begin
    if(rst) EXPc4<=0;
    else if(ControlHazard | DataHazard) EXPc4<=0;
    else EXPc4 <= IDPc4;
end

always @(posedge clk or posedge rst) begin
    if(rst) EXRegisterData1<=0;
    else if(ControlHazard | DataHazard) EXRegisterData1<=0;
    else EXRegisterData1 <= IDRegisterData1;
end

always @(posedge clk or posedge rst) begin
    if(rst) EXRegisterData2<=0;
    else if(ControlHazard | DataHazard) EXRegisterData2<=0;
    else EXRegisterData2 <= IDRegisterData2;
end

always @(posedge clk or posedge rst) begin
    if(rst) EXExt<=0;
    else if(ControlHazard | DataHazard) EXExt<=0;
    else EXExt <= IDExt;
end

endmodule