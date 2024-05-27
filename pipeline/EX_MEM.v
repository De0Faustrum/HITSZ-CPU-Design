`include "defines.vh"
module EX_MEM(
    input wire [0:0] clk,
    input wire [0:0] rst,
    input wire [0:0] EXDramWriteEnable,
    input wire [0:0] EXRegisterFileWriteEnable,
    input wire [1:0] EXRegisterFileWriteSelect,
    input wire [4:0] EXWriteRegister,
    input wire [31:0] EXPc4,
    input wire [31:0] EXAluResult,
    input wire [31:0] EXRegisterData2,
    input wire [31:0] EXExt,

    output reg MEMDramWriteEnable,
    output reg MEMRegisterFileWriteEnable,
    output reg[1:0] MEMRegisterFileWriteSelect,
    output reg[4:0] MEMWriteRegister,
    output reg[31:0] MEMPc4,
    output reg[31:0] MEMAluResult,
    output reg[31:0] MEMRegisterData2,
    output reg[31:0] MEMExt
);

always @(posedge clk or posedge rst) begin
    if(rst) MEMDramWriteEnable <= 0;
    else MEMDramWriteEnable <= EXDramWriteEnable;
end

always @(posedge clk or posedge rst) begin
    if(rst) MEMRegisterFileWriteEnable <= 0;
    else MEMRegisterFileWriteEnable <= EXRegisterFileWriteEnable;
end

always @(posedge clk or posedge rst) begin
    if(rst) MEMRegisterFileWriteSelect <= 0;
    else MEMRegisterFileWriteSelect <= EXRegisterFileWriteSelect;
end

always @(posedge clk or posedge rst) begin
    if(rst) MEMWriteRegister <= 0;
    else MEMWriteRegister <= EXWriteRegister;
end

always @(posedge clk or posedge rst) begin
    if(rst) MEMPc4 <= 0;
    else MEMPc4 <= EXPc4;
end

always @(posedge clk or posedge rst) begin
    if(rst) MEMAluResult <= 0;
    else MEMAluResult <= EXAluResult;
end

always @(posedge clk or posedge rst) begin
    if(rst) MEMRegisterData2 <= 0;
    else MEMRegisterData2 <= EXRegisterData2;
end

always @(posedge clk or posedge rst) begin
    if(rst) MEMExt <= 0;
    else MEMExt <= EXExt;
end

endmodule