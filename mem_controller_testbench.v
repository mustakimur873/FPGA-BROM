`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2026 03:59:01 PM
// Design Name: 
// Module Name: mem_controller_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mem_controller_tb();

    reg clk_tb;
    reg [3:0] btn_tb;
    reg [7:0] sw_tb;
    wire [7:0] led_tb;
    wire [6:0] ssd_tb;
    wire digi_sel_tb;

    mem_controller dut (
        .clk(clk_tb),
        .btn(btn_tb),
        .sw(sw_tb),
        .digi_sel(digi_sel_tb),
        .led(led_tb),
        .pmod_ssd(ssd_tb)
    );

    // 100 MHz clock: 10 ns period
    initial clk_tb = 1'b0;
    always #5 clk_tb = ~clk_tb;

    initial begin
        btn_tb = 4'b0000;
        sw_tb  = 8'h00;

        #20 btn_tb= 4'b0010; // increment
        #20 btn_tb= 4'b0010; // increment
        
        #50 btn_tb= 4'b0001; // reset
        
        
        #100 btn_tb= 4'b0100; // auto
        
        #500  btn_tb= 4'b1000; // disable auto
        
        #100 btn_tb= 4'b0100; // auto
        
        // Test switch-to-LED path
        #10 sw_tb = 8'hA5;
        #100 sw_tb = 8'hFF;
        #100 sw_tb = 8'h00;

        $finish;
    end

endmodule
