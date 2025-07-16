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

    localparam PWM_level = 16;//B

    logic clk_100;
    logic clk_60;
    logic clk_locked;
    logic [3:0] btn_db;

    logic pwm;
    logic [PWM_level-1:0] pwm_count; 
    logic [PWM_level-1:0] duty_r;
    logic btn_db_prev;

    
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
	//button_debounce b2 (.clk(clk_100), .in(btn[1]), .out(btn_db[1]));
	//button_debounce b3 (.clk(clk_100), .in(btn[2]), .out(btn_db[2]));


    always_ff @(posedge clk_100) begin
        btn_db_prev <= btn_db[0];
        if (btn_db[0] && !btn_db_prev) begin
            if (duty_r < {PWM_level{1'b1}}) begin
                duty_r <= duty_r + 1;
            end
        end
        
        pwm_count <= pwm_count + 1;
        pwm <= (pwm_count < duty_r) ? 1'b1 : 1'b0;
    end


    assign led0_b = pwm;


    ila_0 ila_debugger (
        .clk(sys_clk_125), // input wire clk
    
    
        .probe0(clk_100), // input wire [0:0]  probe0  
        .probe1(clk_60), // input wire [0:0]  probe1 
        .probe2(btn_db), // input wire [3:0]  probe2 
        .probe3(btn) // input wire [3:0]  probe3
    );

endmodule



