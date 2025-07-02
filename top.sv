`timescale 1ns / 1ps



module top (input logic sys_clk_125, 
            //input logic [3:0] btn, 
            output logic led0_g, 
            output logic led1_r);


    logic [26:0] counter_a = 0;
    logic [25:0] counter_b = 0;

    logic [7:0]  a = 8'b00000000;
    logic [7:0] b = 8'b00000000;

    always_ff @(posedge sys_clk_125) begin
        if (counter_a == 125_000_000 - 1) begin
            counter_a <= 0;
            a <= a + 1;
        end else begin
            counter_a <= counter_a + 1;
        end

        if (counter_b == 62_500_000 - 1) begin
            counter_b <= 0;
            b <= b + 1;
        end else begin
            counter_b <= counter_b + 1;
        end
    end


    assign led0_g = a[0];
    assign led1_r = b[0];

endmodule

