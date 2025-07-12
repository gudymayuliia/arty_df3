`timescale 1ns / 1ps



module top (// Clock definition
            input logic			sys_clk_125,	// input clock 125 MHz
            // Switches
            input logic [3:0]	sw,
            input logic [3:0]	btn,
            // RGB leds
            output logic		led0_r,
            output logic		led0_g,
            output logic		led0_b,
            output logic		led1_r,
            output logic		led1_g,
            output logic		led1_b,
            // 4 green leds
            output [3:0]		led);
            
    logic clk_100;
    logic clk_60;
    logic clk_locked;
    logic [3:0] btn_db;
    logic led0_r_s, led0_g_s, led0_b_s;
    
    clk_wiz_0 clknetwork (
		// Clock out ports
		.clk_out1           (clk_60),
		.clk_out2           (clk_100),
		// Status and control signals
		.reset              (btn[3]),
		.locked             (clk_locked),
		// Clock in ports
		.clk_in1            (sys_clk_125)
	);

	button_debounce b1 (.clk(clk_100), .in(btn[0]), .out(btn_db[0]));
	button_debounce b2 (.clk(clk_100), .in(btn[1]), .out(btn_db[1]));
	button_debounce b3 (.clk(clk_100), .in(btn[2]), .out(btn_db[2]));

    always_ff @(posedge clk_100) begin
        if (btn_db[0]) begin
            led0_r_s <= ~led0_r_s;
        end
        if (btn_db[1]) begin
            led0_g_s <= ~led0_g_s;
        end
        if (btn_db[2]) begin 
            led0_b_s <= ~led0_b_s;
        end
    end

    assign led0_r = led0_r_s;
    assign led0_g = led0_g_s;
    assign led0_b = led0_b_s;


    ila_0 ila_debugger (
        .clk(sys_clk_125), // input wire clk
    
    
        .probe0(clk_100), // input wire [0:0]  probe0  
        .probe1(clk_60), // input wire [0:0]  probe1 
        .probe2(btn_db), // input wire [3:0]  probe2 
        .probe3(btn) // input wire [3:0]  probe3
    );

endmodule


