`timescale 1ns / 1ps

`include "defines.vh"

module miniRV_SoC (
    input  wire         fpga_rst, 
    input  wire         fpga_clk,

    input  wire [23:0]  switch, 
    input  wire [ 4:0]  button,
    output wire [ 7:0]  dig_en,
    output wire         DN_A,
    output wire         DN_B,
    output wire         DN_C,
    output wire         DN_D,
    output wire         DN_E,
    output wire         DN_F,
    output wire         DN_G,
    output wire         DN_DP,
    output wire [23:0]  led

`ifdef RUN_TRACE
    ,
    output wire         debug_wb_have_inst, 
    output wire [31:0]  debug_wb_pc,       
    output              debug_wb_ena,      
    output wire [ 4:0]  debug_wb_reg,     
    output wire [31:0]  debug_wb_value   
`endif
);

    wire        pll_lock;
    wire        pll_clk;
    wire        cpu_clk;

`ifdef RUN_TRACE
    wire [15:0] InstructionAddress;  
`else
    wire [13:0] InstructionAddress;
`endif
    wire [31:0] Instruction;

    wire [31:0] Bus_rdata;
    wire [31:0] Bus_addr;
    wire        Bus_wen;
    wire [31:0] Bus_wdata;
    
    wire         clk_bridge2dram;
    wire [31:0]  addr_bridge2dram;
    wire [31:0]  rdata_dram2bridge;
    wire         wen_bridge2dram;
    wire [31:0]  wdata_bridge2dram;
    
	      wire rst_bridge2dig;
	      wire clk_bridge2dig;
        wire[11:0] addr_bridge2dig;   
        wire wen_bridge2dig;          
        wire[31:0] wdata_bridge2dig;  

	      wire rst_bridge2led;
	      wire clk_bridge2led;
        wire[11:0] addr_bridge2led; 
        wire wen_bridge2led;  
        wire[31:0] wdata_bridge2led;
        
	      wire rst_bridge2sw;
	      wire clk_bridge2sw;
        wire[11:0] addr_bridge2sw;
        wire[31:0] rdata_sw2bridge = {{8{1'b0}},{switch[23:0]}};

	      wire rst_bridge2btn;
	      wire clk_bridge2btn;
        wire[11:0] addr_bridge2btn;
        wire[31:0] rdata_btn2bridge = {{27{1'b0}},{button[4:0]}};
    
    
`ifdef RUN_TRACE
    assign cpu_clk = fpga_clk;
`else
    assign cpu_clk = pll_clk & pll_lock;
    cpuclk Clkgen (
        .clk_in1    (fpga_clk),
        .clk_out1   (pll_clk),
        .locked     (pll_lock)
    );
`endif
    
    myCPU Core_cpu (
        .cpu_rst            (fpga_rst),
        .cpu_clk            (cpu_clk),

        .InstructionAddress          (InstructionAddress),
        .Instruction               (Instruction),

        .Bus_addr           (Bus_addr),
        .Bus_rdata          (Bus_rdata),
        .Bus_wen            (Bus_wen),
        .Bus_wdata          (Bus_wdata)

`ifdef RUN_TRACE
        ,
        .debug_wb_have_inst (debug_wb_have_inst),
        .debug_wb_pc        (debug_wb_pc),
        .debug_wb_ena       (debug_wb_ena),
        .debug_wb_reg       (debug_wb_reg),
        .debug_wb_value     (debug_wb_value)
`endif
    );
    
    IROM Mem_IROM (
        .a          (InstructionAddress),
        .spo        (Instruction)
    );
    
    Bridge Bridge (    
        .rst_from_cpu       (fpga_rst),
        .clk_from_cpu       (cpu_clk),
        .addr_from_cpu      (Bus_addr),
        .wen_from_cpu       (Bus_wen),
        .wdata_from_cpu     (Bus_wdata),
        .rdata_to_cpu       (Bus_rdata),
        .clk_to_dram        (clk_bridge2dram),
        .addr_to_dram       (addr_bridge2dram),
        .rdata_from_dram    (rdata_dram2bridge),
        .wen_to_dram        (wen_bridge2dram),
        .wdata_to_dram      (wdata_bridge2dram),
        .rst_to_dig         (rst_bridge2dig),
        .clk_to_dig         (clk_bridge2dig),
        .addr_to_dig        (addr_bridge2dig),
        .wen_to_dig         (wen_bridge2dig),
        .wdata_to_dig       (wdata_bridge2dig),
        .rst_to_led         (rst_bridge2led),
        .clk_to_led         (clk_bridge2led),
        .addr_to_led        (addr_bridge2led),
        .wen_to_led         (wen_bridge2led),
        .wdata_to_led       (wdata_bridge2led),
        .rst_to_sw          (rst_bridge2sw),
        .clk_to_sw          (clk_bridge2sw),
        .addr_to_sw         (addr_bridge2sw),
        .rdata_from_sw      (rdata_sw2bridge), 
        .rst_to_btn         (rst_bridge2btn),
        .clk_to_btn         (clk_bridge2btn),
        .addr_to_btn        (addr_bridge2btn),
        .rdata_from_btn     (rdata_btn2bridge)
    );
    wire [31:0] waddr_tmp = addr_bridge2dram - 32'h4000;
    DRAM Mem_DRAM (
        .clk        (clk_bridge2dram),
        .a          (waddr_tmp[15:2]),
        .spo        (rdata_dram2bridge),
        .we         (wen_bridge2dram),
        .d          (wdata_bridge2dram)
    );
    display U_display(
      .clk(fpga_clk),
      .rst(fpga_rst),
      .data(wdata_bridge2dig),
      .data_en(wen_bridge2dig),
      .led_en(dig_en),
      .led_cx({DN_DP,DN_G,DN_F,DN_E,DN_D,DN_C,DN_B,DN_A})  
    );
    leds U_leds(
      .clk(fpga_clk),
      .rst(fpga_rst),
      .data(wdata_bridge2led),
      .data_en(wen_bridge2led),
      .led(led)
    );
endmodule
