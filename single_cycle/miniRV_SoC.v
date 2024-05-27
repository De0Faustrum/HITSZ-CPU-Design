`timescale 1ns / 1ps

`include "defines.vh"

module miniRV_SoC (
    input wire [0:0] fpga_rst,   
    input wire [0:0] fpga_clk,
    input wire [23:0] switch, 
    input wire [4:0] button,
    output wire [23:0] led,
    output wire [7:0] dig_en,
    output wire [0:0] DN_A,
    output wire [0:0] DN_B,
    output wire [0:0] DN_C,
    output wire [0:0] DN_D,
    output wire [0:0] DN_E,
    output wire [0:0] DN_F,
    output wire [0:0] DN_G,
    output wire [0:0] DN_DP


`ifdef RUN_TRACE
    ,
    output wire [0:0] debug_wb_have_inst, 
    output wire [31:0] debug_wb_pc,        
    output wire [0:0] debug_wb_ena,        
    output wire [4:0] debug_wb_reg,        
    output wire [31:0] debug_wb_value       
`endif
);

    wire [0:0] pll_lock;
    wire [0:0] pll_clk;
    wire [0:0] cpu_clk;
    `ifdef  RUN_TRACE wire [15:0] inst_addr;  
    `else   wire [13:0] inst_addr;
    `endif  wire [31:0] inst;
    wire [0:0] Bus_wen;
    wire [31:0] Bus_rdata;
    wire [31:0] Bus_addr;
    wire [31:0] Bus_wdata;
    wire [0:0] clk_BridgeToDram;
    wire [0:0] wen_BridgeToDram;
    wire [31:0] addr_BridgeToDram;
    wire [31:0] wdata_BridgeToDram;
    wire [31:0] rdata_DramToBridge;
	wire [0:0] rst_BridgeToDigit;
	wire [0:0] clk_BridgeToDigit;
	wire [0:0] wen_BridgeToDigit;
    wire [11:0] addr_BridgeToDigit;
    wire [31:0] wdata_BridgeToDigit;
	wire [0:0] rst_BridgeToLed;
	wire [0:0] clk_BridgeToLed;
	wire [0:0] wen_BridgeToLed;
    wire [11:0] addr_BridgeToLed; 
    wire [31:0] wdata_BridgeToLed;
	wire [0:0] rst_BridgeToSwith;
	wire [0:0] clk_BridgeToSwith;
    wire [11:0] addr_BridgeToSwith;
    wire [31:0] rdata_SwitchToBridge = {8'H0,switch[23:0]};
	wire [0:0] rst_BridgeToButton;
	wire [0:0] clk_BridgeToButton;
    wire [11:0] addr_BridgeToButton;
    wire [31:0] rdata_ButtonToBridge = {27'H0,button[4:0]};
    
    
    `ifdef RUN_TRACE assign cpu_clk = fpga_clk;
    `else assign cpu_clk = pll_clk & pll_lock; cpuclk Clkgen (.reset(!fpga_rst),.clk_in1(fpga_clk),.clk_out1(pll_clk),.locked(pll_lock));
    `endif
    
    myCPU Core_cpu (
        .cpu_rst(fpga_rst),
        .cpu_clk(cpu_clk),
        .inst_addr(inst_addr),
        .inst(inst),
        .Bus_addr(Bus_addr),
        .Bus_rdata(Bus_rdata),
        .Bus_wen(Bus_wen),
        .Bus_wdata(Bus_wdata)

`ifdef RUN_TRACE
        ,
        .debug_wb_have_inst (debug_wb_have_inst),
        .debug_wb_pc        (debug_wb_pc),
        .debug_wb_ena       (debug_wb_ena),
        .debug_wb_reg       (debug_wb_reg),
        .debug_wb_value     (debug_wb_value)
`endif
    );
    
    IROM Mem_IROM(.a(inst_addr), .spo(inst));
    
    Bridge Bridge(       
        .rst_from_cpu       (fpga_rst),
        .clk_from_cpu       (cpu_clk),
        .addr_from_cpu      (Bus_addr),
        .wen_from_cpu       (Bus_wen),
        .wdata_from_cpu     (Bus_wdata),
        .rdata_to_cpu       (Bus_rdata),
        .clk_to_dram        (clk_BridgeToDram),
        .addr_to_dram       (addr_BridgeToDram),
        .rdata_from_dram    (rdata_DramToBridge),
        .wen_to_dram        (wen_BridgeToDram),
        .wdata_to_dram      (wdata_BridgeToDram),
        .rst_to_dig         (rst_BridgeToDigit),
        .clk_to_dig         (clk_BridgeToDigit),
        .addr_to_dig        (addr_BridgeToDigit),
        .wen_to_dig         (wen_BridgeToDigit),
        .wdata_to_dig       (wdata_BridgeToDigit),
        .rst_to_led         (rst_BridgeToLed),
        .clk_to_led         (clk_BridgeToLed),
        .addr_to_led        (addr_BridgeToLed),
        .wen_to_led         (wen_BridgeToLed),
        .wdata_to_led       (wdata_BridgeToLed),
        .rst_to_sw          (rst_BridgeToSwith),
        .clk_to_sw          (clk_BridgeToSwith),
        .addr_to_sw         (addr_BridgeToSwith),
        .rdata_from_sw      (rdata_SwitchToBridge), 
        .rst_to_btn         (rst_BridgeToButton),
        .clk_to_btn         (clk_BridgeToButton),
        .addr_to_btn        (addr_BridgeToButton),
        .rdata_from_btn     (rdata_ButtonToBridge)
    );

    DRAM Mem_DRAM (.clk(clk_BridgeToDram),.a(addr_BridgeToDram[15:2]),.spo(rdata_DramToBridge),.we(wen_BridgeToDram),.d(wdata_BridgeToDram));
    display U_display(.clk(fpga_clk),.rst(fpga_rst),.data(wdata_BridgeToDigit),.data_en(wen_BridgeToDigit),.led_en(dig_en),.led_cx({DN_DP,DN_G,DN_F,DN_E,DN_D,DN_C,DN_B,DN_A}));
    leds U_leds(.rst(fpga_rst),.data(wdata_BridgeToLed),.data_en(wen_BridgeToLed),.led(led));
endmodule
