`include "defines.vh"
module pc(
  input wire rst, 
  input wire clk,
  input wire[31:0] Din, 
  output reg[31:0] Pc
);

    always @(posedge clk or posedge rst) begin
        if(rst) Pc <= 1'B0;
        else Pc <= Din;
    end

endmodule