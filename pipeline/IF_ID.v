`include "defines.vh"
module IF_ID(
    input wire [0:0] clk,         
    input wire [0:0]rst,
    input wire [31:0] IFInstruction, 
    input wire [31:0] IFPc4, 
    input wire [0:0] DataHazard,   
    input wire [0:0] ControlHazard,  
    output reg[31:0] IDInstruction, 
    output reg[31:0] IDPc4 
);


always @(posedge clk or posedge rst) begin
    if(rst) IDInstruction <= 0;
    else if(ControlHazard) IDInstruction <= 0;
    else if(DataHazard) IDInstruction <= IDInstruction;
    else IDInstruction <= IFInstruction;
end

always @(posedge clk or posedge rst) begin
    if(rst) IDPc4<=0;
    else if(ControlHazard) IDPc4 <= 0;  
    else if(DataHazard) IDPc4 <= IDPc4;
    else IDPc4 <= IFPc4;
end

endmodule