`include "defines.vh"
module control_hazard_detection(
    input wire [1:0] EXNpcOperation,  
    input wire [0:0] AluStatus,       
    output reg [0:0] ControlHazard  
);

always @(*) begin
    if(EXNpcOperation == `NPC_JALR || EXNpcOperation == `NPC_JAL) ControlHazard = 1'B1;
    else if(EXNpcOperation == `NPC_B && AluStatus == 1) ControlHazard = 1'B1; 
    else ControlHazard = 1'B0;
end

endmodule