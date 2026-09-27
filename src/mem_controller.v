`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2026 03:47:16 PM
// Design Name: 
// Module Name: mem_controller
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


module mem_controller(
    input clk,
    input [3:0] btn,
    input [7:0] sw,
    output [7:0] led, // switches control the LEDs
    output reg digi_sel, // last bit is digit select
    output reg [6:0] pmod_ssd // the shown value
    );

    // Switch  = to set the mem address

    /*
    *  Button Logic
    *  BTN0 = resets address
    *  BTN1 = increments address by 1
    *  BTN2 = enables auto increment
    *  BTN3 = disables it
    */


    wire [7:0] address_LED;
    wire clk_SSD; // clock for SSD 
    reg [7:0] address_SSD;
    wire [7:0] data_SSD, data_LED;
    reg auto_count_flag; // 0 dont count, 1 count up

//    reg [6:0] temp_val_l; // the first HEX value is displayed on the left
//    reg [6:0] temp_val_r;


    blk_mem_gen_0 myram_LED ( // Always enabled
    .addra(address_LED),
    //.ena(enable), // for pausing purpose
    .clka(clk),
    .douta(data_LED)
   );

    /*
    * This assignment is only for task one
    */
    assign address_LED = sw; // for task 1 and 2 this changes
    assign led = data_LED;
    // END of Task One


    blk_mem_gen_0 myram_SSD ( // Always enabled
    .addra(address_SSD),
    .clka(clk),
    .douta(data_SSD)
    );
    
     clock_divider #(
    .INPUT_FREQ_HZ(100_000_000), // turn 100Mhz to 1kHz
    .OUTPUT_FREQ_HZ(1_000) // Changed from 1_000 for SIMULATION to 10_000_000 (10MHz)
        ) clk_disp(
        .clk_in(clk),
        .clk_out(clk_SSD)
    );

    // Initialization Block
    initial begin
        digi_sel <= 1'b1; // selects left SSD first
        address_SSD = 8'h00;
        auto_count_flag = 1'b0;
    end




// Debouncer Logic
// if current button state == prev button state, its the same button

    reg [3:0] btn_meta, btn_sync, btn_prev;
    wire [3:0] btn_press;
    
    //Posedge detector
    assign btn_press = btn_sync & ~btn_prev; // if its the same BTNs returns 0000
    
    reg [26:0] two_hz_count = 27'd0;
    wire two_hz_tick;
    
    // changes for SIMULATION 27'd49_999_999 => 27'd19  
    assign two_hz_tick = (two_hz_count == 27'd49_999_999); // updates on clk
    
    always @(posedge clk) begin
        if (two_hz_tick)
            two_hz_count <= 27'd0;
        else
            two_hz_count <= two_hz_count + 27'd1;
    end
    
    always @(posedge clk) begin // when any button is pressed
        // Synchronize buttons
        btn_meta <= btn; // this is for holding the value for stability
        btn_sync <= btn_meta;
        btn_prev <= btn_sync; 
        // takes 3 clk cycles to get to update btn_prev

        
        if (btn_press[0]) // if reset btn is pressed
            address_SSD <= 8'h00;
         else if (btn_press[1]) // increment by 1
            address_SSD <= address_SSD + 8'h01;
        else if (btn_press[2]) // begin auto count
            auto_count_flag <= 1'b1;
        else if (btn_press[3]) // stop auto count
            auto_count_flag <= 1'b0;
        else if (auto_count_flag && two_hz_tick)
        // two_hz_tick has same pulse width as clk,the address doesnt update more than twice
            address_SSD <= address_SSD + 8'h01;
    end

    // Displayer
    // digi_sel  = 1  left
    // digi_sel  = 0 right
    always @(posedge clk_SSD) begin
        if (!digi_sel) begin // when right SSD
            digi_sel <= 1'b1; // set left
            pmod_ssd <= hex_in_SSD(data_SSD[7:4]);
        end else begin // when left SSD
            digi_sel <= 1'b0; // set right
            pmod_ssd <= hex_in_SSD(data_SSD[3:0]);
        end
    end

    function [6:0] hex_in_SSD; // gets data_SSD[3:0] or data_SSD[7:4] and decode the SSD value
           input [3:0] ssd_data;
           begin
               case (ssd_data)
                   4'h0: hex_in_SSD = 7'b1111110; // 0
                   4'h1: hex_in_SSD = 7'b0110000; // 1
                   4'h2: hex_in_SSD = 7'b1101101; // 2
                   4'h3: hex_in_SSD = 7'b1111001; // 3
                   4'h4: hex_in_SSD = 7'b0110011; // 4
                   4'h5: hex_in_SSD = 7'b1011011; // 5
                   4'h6: hex_in_SSD = 7'b1011111; // 6
                   4'h7: hex_in_SSD = 7'b1110000; // 7
                   4'h8: hex_in_SSD = 7'b1111111; // 8
                   4'h9: hex_in_SSD = 7'b1111011; // 9
                   4'hA: hex_in_SSD = 7'b1110111; // A
                   4'hB: hex_in_SSD = 7'b0011111; // b
                   4'hC: hex_in_SSD = 7'b1001110; // C
                   4'hD: hex_in_SSD = 7'b0111101; // d
                   4'hE: hex_in_SSD = 7'b1001111; // E
                   4'hF: hex_in_SSD = 7'b1000111; // F

                   default: hex_in_SSD = 7'b0000000; // blank
               endcase
           end
    endfunction

endmodule
