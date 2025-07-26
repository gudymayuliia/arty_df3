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
    logic clk_reset;
    logic [3:0] btn_db;

    logic pwm_r, pwm_b;
    logic [PWM_level-1:0] pwm_count; 
    logic [PWM_level-1:0] duty_r, duty_b;
    logic btn_db_prev0, btn_db_prev1, btn_db_prev2, btn_db_prev3;

    
    clk_wiz_0 clknetwork (
		// Clock out ports
		.clk_out1           (clk_60),
		.clk_out2           (clk_100),
		// Status and control signals
		.reset              (clk_reset),
		.locked             (clk_locked),
		// Clock in ports
		.clk_in1            (sys_clk_125)
	);


	button_debounce b1 (.clk(clk_100), .in(btn[0]), .out(btn_db[0]));
	button_debounce b2 (.clk(clk_100), .in(btn[1]), .out(btn_db[1]));
	button_debounce b3 (.clk(clk_100), .in(btn[2]), .out(btn_db[2]));
	button_debounce b4 (.clk(clk_100), .in(btn[3]), .out(btn_db[3]));
	
//При чому для двох варіантів (наприклад 2 кнопки керують яскравістю червоного світлодіода і 2 синього)

    always_ff @(posedge clk_100) begin
        btn_db_prev0 <= btn_db[0];
        btn_db_prev1 <= btn_db[1];
        btn_db_prev2 <= btn_db[2];
        btn_db_prev3 <= btn_db[3];
        
        if (btn_db[0] && !btn_db_prev0) begin
            if (duty_b < {PWM_level{1'b1}}) begin
                duty_b <= duty_b + 1;
            end
        end 
        if (btn_db[1] && !btn_db_prev1) begin
            if (duty_b > 1'b0) begin
                duty_b <= duty_b - 1;
            end
        end 
        if (btn_db[2] && !btn_db_prev2) begin
            if (duty_r < {PWM_level{1'b1}}) begin
                duty_r <= duty_r + 1;
            end
        end 
        if (btn_db[3] && !btn_db_prev3) begin
            if (duty_r > 1'b0) begin
                duty_r <= duty_r - 1;
            end
        end 
        
        
        
        pwm_count <= pwm_count + 1;
        pwm_b <= (pwm_count < duty_b) ? 1'b1 : 1'b0;
        pwm_r <= (pwm_count < duty_r) ? 1'b1 : 1'b0;
    end


    assign led0_b = pwm_b;
    assign led1_r = pwm_r;





    ila_0 ila_debugger (
        .clk(sys_clk_125), // input wire clk
    
    
        .probe0(clk_100), // input wire [0:0]  probe0  
        .probe1(clk_60), // input wire [0:0]  probe1 
        .probe2(btn_db), // input wire [3:0]  probe2 
        .probe3(btn) // input wire [3:0]  probe3
    );

endmodule


