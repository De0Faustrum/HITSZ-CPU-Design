module sext(
    input wire[31:0] Din, 
    input wire[2:0] SextOperation,  
    output reg[31:0] Ext 
);

wire SignToExpand = Din[31];

always @(*) begin
    case(SextOperation)
        `SEXT_R: Ext = 32'H00000000;
        `SEXT_I: Ext = {{20{Din[31]}},{Din[31:20]}};
        `SEXT_S: Ext = {{20{Din[31]}},{Din[31:25]},{Din[11:7]}};
        `SEXT_U: Ext = {{Din[31:12]},{12{1'B0}}};
        `SEXT_B: Ext = {{19{Din[31]}},{Din[31]},{Din[7]},{Din[30:25]},{Din[11:8]},{1'B0}};
        `SEXT_J: Ext = {{11{Din[31]}},{Din[31]},{Din[19:12]},{Din[20]},{Din[30:21]},{1'B0}};
        `SEXT_MOVE: Ext =  {{27{1'B0}},{Din[24:20]}};
    endcase
end

endmodule