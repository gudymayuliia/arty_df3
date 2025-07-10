`timescale 1ns / 1ps


module button_debounce (input logic clk,  
                        input logic in,  
                        output logic out  
                        );

    logic sync_0, sync_1;
    always_ff @(posedge clk) sync_0 <= in;
    always_ff @(posedge clk) sync_1 <= sync_0;

    logic [19:0] cnt;  
    logic idle, max;
    always_comb begin
        idle = (out == sync_1);
        max  = &cnt;
    end

    always_ff @(posedge clk) begin
        if (idle) begin
            cnt <= 0;
        end else begin
            cnt <= cnt + 1;
            if (max) out <= ~out;
        end
    end
    
        
endmodule
