`include "defines.vh"
module npc(
    input wire [1:0] NpcOperation,
    input wire [0:0] Branch,
    input wire [31:0] Offset,
    input wire[31:0] Immediate,
    input wire[31:0] Pc,
    output wire[31:0] Pc4,
    output reg[31:0] Npc
);

assign Pc4 = Pc+4;

always @(*) begin
    case({NpcOperation,Branch})
        {`NPC_JALR,1'B?}:Npc = Immediate;
        {`NPC_B,1'B0}:   Npc = Pc + Offset - 8;
        {`NPC_B,1'B1}:   Npc = Pc + 4;
        {`NPC_JAL,1'B?}: Npc = Pc + Offset - 8;
        default: Npc = Pc + 4;
    endcase
end

endmodule