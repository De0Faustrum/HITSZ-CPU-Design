`include "defines.vh"
module ControlUnit #(
    localparam OP_R    = 7'b0110011,
    localparam OP_I    = 7'b0010011,
    localparam OP_LOAD = 7'b0000011,
    localparam OP_S    = 7'b0100011,
    localparam OP_B    = 7'b1100011,
    localparam OP_LUI  = 7'b0110111,
    localparam OP_JAL  = 7'b1101111,
    localparam OP_JALR = 7'b1100111
)
(
    input wire [31:0] Instruction,
    output reg [1:0] NpcOperation,
    output reg [0:0] RegisterFileWriteEnable,
    output reg [1:0] RegisterFileWriteSelect,
    output reg [2:0] SextOperation,
    output reg [0:0] AluBSelect,
    output reg [0:0] DramWriteEnable,
    output reg [3:0] AluOperation,
    output reg [1:0] RegisterFileReadEnable
);

wire[6:0] OperationCode = Instruction[6:0];
wire[2:0] Function3 = Instruction[14:12];
wire[6:0] Function7 = Instruction[31:25];

always @(*) begin
    case(OperationCode)
        OP_R:   NpcOperation = `NPC_PC4;
        OP_I:   NpcOperation = `NPC_PC4;
        OP_S:   NpcOperation = `NPC_PC4;
        OP_LOAD:NpcOperation = `NPC_PC4;
        OP_LUI: NpcOperation = `NPC_PC4;
        OP_JALR:NpcOperation = `NPC_JALR;
        OP_B:   NpcOperation = `NPC_B;
        OP_JAL: NpcOperation = `NPC_JAL;
        default:NpcOperation = `NPC_PC4;
    endcase
end

always @(*) begin
  if(OperationCode == OP_B || OperationCode == OP_S) RegisterFileWriteEnable = 0;
  else RegisterFileWriteEnable = 1;
end

always @(*) begin
    case(OperationCode)
        OP_R:   RegisterFileWriteSelect = `WB_ALU;
        OP_I:   RegisterFileWriteSelect = `WB_ALU;
        OP_LOAD:RegisterFileWriteSelect = `WB_DRAM;
        OP_JALR:RegisterFileWriteSelect = `WB_PC4;
        OP_JAL: RegisterFileWriteSelect = `WB_PC4;
        OP_LUI: RegisterFileWriteSelect = `WB_SEXT;
        default:RegisterFileWriteSelect = `WB_ALU;
    endcase
end

always @(*) begin
    case(OperationCode)
        OP_LOAD:SextOperation = `SEXT_I;
        OP_JALR:SextOperation = `SEXT_I;
        OP_LUI: SextOperation = `SEXT_U;
        OP_JAL: SextOperation = `SEXT_J;
        OP_B: SextOperation = `SEXT_B;
        OP_S: SextOperation = `SEXT_S;
        OP_R: SextOperation = `SEXT_R;
        OP_I:
            case(Function3)
                3'b001, 3'b101: SextOperation = `SEXT_MOVE; //
                default: SextOperation = `SEXT_I;
            endcase
        default: SextOperation = `SEXT_R;
  endcase
end

always @ (*) begin
    case (OperationCode)
        OP_I:   AluBSelect = 1;
        OP_S:   AluBSelect = 1;
        OP_LOAD:AluBSelect = 1;
        OP_JALR:AluBSelect = 1;
        default:AluBSelect = 0; 
    endcase
end

always @(*) begin
  if(OperationCode == OP_S) DramWriteEnable = 1;
  else DramWriteEnable = 0;
end

always @ (*) begin
    case({OperationCode,Function3})
        {OP_R,3'B000}: AluOperation = Function7[5] ? `ALU_SUB : `ALU_ADD;
        {OP_R,3'B001}: AluOperation = `ALU_SLL;
        {OP_R,3'B010}: AluOperation = `ALU_AND;
        {OP_R,3'B011}: AluOperation = `ALU_AND;
        {OP_R,3'B100}: AluOperation = `ALU_XOR;
        {OP_R,3'B101}: AluOperation = Function7[5] ? `ALU_SRA : `ALU_SRL;
        {OP_R,3'B110}: AluOperation = `ALU_OR;
        {OP_R,3'B111}: AluOperation = `ALU_AND;
        {OP_I,3'B000}: AluOperation = `ALU_ADD;
        {OP_I,3'B001}: AluOperation = `ALU_SLL;
        {OP_I,3'B010}: AluOperation = `ALU_AND;
        {OP_I,3'B011}: AluOperation = `ALU_AND;
        {OP_I,3'B100}: AluOperation = `ALU_XOR;
        {OP_I,3'B101}: AluOperation = Function7[5] ? `ALU_SRA : `ALU_SRL;
        {OP_I,3'B110}: AluOperation = `ALU_OR;
        {OP_I,3'B111}: AluOperation = `ALU_AND;
        {OP_I,3'B000}: AluOperation = `ALU_BEQ;
        {OP_I,3'B001}: AluOperation = `ALU_BNE;
        {OP_I,3'B010}: AluOperation = `ALU_BEQ;
        {OP_I,3'B011}: AluOperation = `ALU_BEQ;
        {OP_I,3'B100}: AluOperation = `ALU_BLT;
        {OP_I,3'B101}: AluOperation = `ALU_BGE;
        {OP_I,3'B110}: AluOperation = `ALU_BEQ;
        {OP_I,3'B111}: AluOperation = `ALU_BEQ;
        {OP_S,3'B???}:   AluOperation = `ALU_ADD;
        {OP_LOAD,3'B???}:AluOperation = `ALU_ADD;
        {OP_JALR,3'B???}:AluOperation = `ALU_ADD;
        default: AluOperation = `ALU_AND;
    endcase
end

always @(*) begin
    case(OperationCode)
        OP_I:   RegisterFileReadEnable = 2'B01;
        OP_LOAD:RegisterFileReadEnable = 2'B01;
        OP_JALR:RegisterFileReadEnable = 2'B01;
        OP_LUI: RegisterFileReadEnable = 2'B00;
        OP_JAL: RegisterFileReadEnable = 2'B00;
        default:RegisterFileReadEnable = 2'B11;
    endcase
end

endmodule