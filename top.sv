`timescale 1ns / 1ps



module top (input logic [1:0] sw, 
            output logic led0_r, 
            output logic led0_g,
            output logic led0_b,
            output logic led1_r,
            output logic led1_g,
            output logic led1_b);
    

    //logic [7:0] a = 8'b00000000;
    //logic [7:0] b = 8'b00000000;

    always_comb begin
        if(sw[0]) begin
            led0_b = 1;
            led0_g = 1;
            led0_r = 0;
        end else begin
            led0_b = 0;
            led0_g = 0;
            led0_r = 0;
        end

        if(sw[1]) begin
            led1_b = 0;
            led1_g = 0;
            led1_r = 1;
        end else begin
            led1_b = 0;
            led1_g = 0;
            led1_r = 0;
        end
    end

endmodule

