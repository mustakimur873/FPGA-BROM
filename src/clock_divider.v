`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2026 09:12:35 PM
// Design Name: 
// Module Name: clock_divider
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



module clock_divider #(
    parameter integer INPUT_FREQ_HZ = 100_000_000,
    parameter integer OUTPUT_FREQ_HZ = 1 //  have Output Freq less or equal to Input Freq
    )(
    input clk_in, // 100Mhz
    output reg clk_out //1hz
    );
    localparam integer HALF_PERIOD = INPUT_FREQ_HZ / (2 * OUTPUT_FREQ_HZ);
    localparam integer COUNTER_WIDTH = (HALF_PERIOD <= 1) ? 1 : $clog2(HALF_PERIOD);

    reg [COUNTER_WIDTH-1:0] count = 0; // this works as a reset
    initial clk_out = 1'b0; // this works as a reset

    always @(posedge clk_in) begin
        if (count == HALF_PERIOD-1)begin
            count <= 0;
            clk_out <= ~clk_out;

        end else begin
            count <= count + 1'b1;
        end
    end
endmodule
