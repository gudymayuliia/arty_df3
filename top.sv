`timescale 1ns / 1ps



module top (output logic led_red, output logic led_green);

    // Hardcoded 8-bit signals
    logic [7:0] a = 8'b00000001;
    logic [7:0] b = 8'b00000010;

    // Connect LSBs to LEDs
    assign led0_g   = a[0];
    assign led1_r = b[0];

endmodule

