module npc(
    input wire [1:0] Operation,    
    input wire [0:0] Branch,      
    input wire [31:0] Offset,    
    input wire [31:0] NpcImmediate, 
    input wire [31:0] Pc,    
    output reg [31:0] Npc,       
    output wire [31:0] Pc4      
  
);

assign Pc4 = Pc+4;

always @(*) begin
    case(Operation)
    `NPC_PC4: Npc = Pc + 4;
    `NPC_JALR: Npc = NpcImmediate;
    `NPC_B: case(Branch) 1'B1: Npc = Pc + Offset; 1'B0: Npc = Pc+4; endcase
    `NPC_JAL: Npc = Pc + Offset;
    endcase
end

endmodule