`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// Originator: S. Janamian 
// Create Date: 06/16/2024 02:28:03 PM
// Module Name: zcu102_led_top
// Target Devices: ZCU102 
// Description: Simple LED BTN control from HDL
// -----------------------------------------------------------------------------

module zcu102_top(
    input logic [7:0] btn,
    output logic [7:0] led
    );
    
    assign led = btn;
     
endmodule

