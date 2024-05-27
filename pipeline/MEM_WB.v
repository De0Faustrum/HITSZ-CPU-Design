`include "defines.vh"
module MEM_WB(
    input wire [0:0] clk,
    input wire [0:0] rst,
    input wire [0:0] MEMRegisterFileWriteEnable,
    input wire [1:0] MEMRegisterFileWriteSelect,
    input wire [4:0] MEMWriteRegister,
    input wire [31:0] MEMPc4,
    input wire [31:0] MEMAluResult,
    input wire [31:0] MEMDramData,
    input wire [31:0] MEMExt,

    output reg [0:0] WBRegisterFileWriteEnable,
    output reg [1:0] WBRegisterFileWriteSelect,
    output reg [4:0] WBWriteRegister,
    output reg [31:0] WBPc4,
    output reg [31:0] WBAluResult,
    output reg [31:0] WBDramData,
    output reg [31:0] WBExt
);

always @(posedge clk or posedge rst) begin
    if(rst) WBRegisterFileWriteEnable <= 0;
    else WBRegisterFileWriteEnable <= MEMRegisterFileWriteEnable; 
end

always @(posedge clk or posedge rst) begin
    if(rst) WBRegisterFileWriteSelect <= 0;
    else WBRegisterFileWriteSelect <= MEMRegisterFileWriteSelect;
end

always @(posedge clk or posedge rst) begin
    if(rst) WBWriteRegister <= 0;
    else WBWriteRegister <= MEMWriteRegister;
end

always @(posedge clk or posedge rst) begin
    if(rst) WBPc4 <= 0;
    else WBPc4 <= MEMPc4;
end

always @(posedge clk or posedge rst) begin
    if(rst) WBAluResult <= 0;
    else WBAluResult <= MEMAluResult;
end

always @(posedge clk or posedge rst) begin
    if(rst) WBDramData <= 0;
    else WBDramData <= MEMDramData;
end

always @(posedge clk or posedge rst) begin
    if(rst) WBExt <= 0;
    else WBExt <= MEMExt;
end

endmodule