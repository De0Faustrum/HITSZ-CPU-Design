`include "defines.vh"
module pc(
    input wire [0:0] rst,
    input wire [0:0] clk,
    input wire [31:0] Din,
    input wire DataHazard, 
    input wire ControlHazard,
    output reg [31:0] Pc
);

always @(posedge clk or posedge rst) begin
  if(rst) Pc <= 0;
  else if(ControlHazard) Pc<=Din;
  else if(DataHazard) Pc<=Pc;
  else Pc <= Din;
end

endmodule