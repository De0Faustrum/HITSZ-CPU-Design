module alu(
    input wire [31:0] Resource1,
    input wire [31:0] Resource2,
    input wire [31:0] Immediate,
    input wire [0:0] AluBSelect, 
    input wire [3:0] AluOperation,  
    output wire [31:0] AluResult,
    output wire [0:0] AluStatus
);

wire[31:0] DataA = Resource1;
wire[31:0] DataB = AluBSelect ? Immediate : Resource2;
reg [31:0] Result;

always @(*) begin
    case(AluOperation)
        `ALU_ADD: Result = DataA + DataB;
        `ALU_SUB: Result = DataA - DataB;
        `ALU_AND: Result = DataA & DataB;
        `ALU_OR : Result = DataA | DataB;
        `ALU_XOR: Result = DataA ^ DataB;
        `ALU_SLL: Result = DataA << DataB[4:0];
        `ALU_SRL: Result = DataA >> DataB[4:0];
        `ALU_SRA: Result = ($signed(DataA)) >>> DataB[4:0];
        default : Result = 0;
    endcase
end

assign AluResult = Result;

wire[31:0] Discrepancy = DataA - DataB;
reg [0:0]Status;
always @(*) begin
    if(AluOperation == `ALU_BEQ && Discrepancy == 0) Status = 1;
    else if(AluOperation == `ALU_BNE && Discrepancy != 0) Status = 1;
    else if(AluOperation == `ALU_BLT && Discrepancy[31]) Status = 1;
    else if(AluOperation == `ALU_BGE && Discrepancy[31] == 0) Status = 1;
    else Status = 0; 
end

assign AluStatus = Status;

endmodule