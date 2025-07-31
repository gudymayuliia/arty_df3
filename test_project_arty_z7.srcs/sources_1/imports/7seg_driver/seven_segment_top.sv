`timescale 1ns / 1ps

`include "driver.svh"


module seven_segment_top(
    input  clk_i,
    input  porb_i,//async reset sw0
    //input  sync_reset_i,
    input logic sw,
    input logic [3:0] btn,
    inout  sda,
    output scl
);

wire sda_in, seg_scl, sda_out_en, sda_out;


logic [7:0] digits [3:0];
logic disp_strobe;

function automatic logic [7:0] get_digit_pattern(input int number);
    case (number)
        0: return `_0;
        1: return `_1;
        2: return `_2;
        3: return `_3;
        4: return `_4;
        5: return `_5;
        6: return `_6;
        7: return `_7;
        8: return `_8;
        9: return `_9;
        default: return 8'h00;
    endcase
endfunction


//sw1 - change counter
//sw0 - reset
logic [7:0] counter_a;
logic [7:0] counter_b; 
logic [7:0] selected_counter;
logic [3:0] btn_db;
logic btn_db_prev0, btn_db_prev1, btn_db_prev2, btn_db_prev3;

button_debounce b0 (.clk(clk_i), .in(btn[0]), .out(btn_db[0]));
button_debounce b1 (.clk(clk_i), .in(btn[1]), .out(btn_db[1]));
button_debounce b2 (.clk(clk_i), .in(btn[2]), .out(btn_db[2]));
button_debounce b3 (.clk(clk_i), .in(btn[3]), .out(btn_db[3]));

//Для наступного завдання потрібно вивести лічильники (А і В) на цей індикатор 
//із можливістю переключення між значеннями А-В за допомогою перемикачів sw.
// Інкремент і декремент для кожного числа робиться окремою кнопкою btn0-3


always_ff @(posedge clk_i or negedge porb_i) begin
    if (porb_i == 0)
        selected_counter <= 0;
    else
        selected_counter <= (sw == 1'b0) ? counter_a : counter_b;
end

always_ff @(negedge porb_i, posedge clk_i) begin
    if (porb_i == 0) begin//!porb_i
        counter_a <= 8'd0;
        counter_b <= 8'd0;
    end else  begin
        btn_db_prev0 <= btn_db[0];
        btn_db_prev1 <= btn_db[1];
        btn_db_prev2 <= btn_db[2];
        btn_db_prev3 <= btn_db[3];
        
        if (btn_db[0] && !btn_db_prev0) begin 
            counter_a <= counter_a + 1;
        end
        if (btn_db[1] && !btn_db_prev1) begin 
            if(counter_a > 0) begin
                counter_a <= counter_a - 1;
            end else 
                counter_a <= 8'd0;
        end
        if (btn_db[2] && !btn_db_prev2) begin
            counter_b <= counter_b + 1;
        end
        if (btn_db[3] && !btn_db_prev3) begin 
            if(counter_b > 0) begin
                counter_b <= counter_b - 1;
            end else 
                counter_b <= 8'd0;
        end

    end
end

always_comb begin
    digits[0] = `_0;
    digits[1] = `_0;
    digits[2] = `_0;
    digits[3] = `_0;


    digits[0] = get_digit_pattern(selected_counter % 10);    
    digits[1] = get_digit_pattern((selected_counter / 10) % 10);     
    digits[2] = get_digit_pattern((selected_counter / 100) % 10);     
    digits[3] = get_digit_pattern((selected_counter / 1000) % 10);  
                                

    disp_strobe = 1'b1;
end



driver #(
    .CLK_DIV(1024)
)
driver_u
(
    .clk_i(clk_i),
    .porb_i(porb_i),
    //.sync_reset_i(sync_reset_i),
    .digits_i(digits),
    .disp_strobe_i(disp_strobe),
    .busy_o(busy),
    .sda_out(sda_out),
    .sda_in(sda_in),
    .sda_out_en(sda_out_en),
    .seg_scl_o(seg_scl)
);

assign sda_in = sda;
assign sda = (!sda_out_en || sda_out) ? 'Z : '0;

assign scl = seg_scl;// ? 'Z : '0;

ila_0 your_instance_name (
	.clk(clk_i), // input wire clk


	.probe0(counter_a), // input wire [7:0]  probe0  
	.probe1(counter_b), // input wire [7:0]  probe1 
	.probe2(btn), // input wire [3:0]  probe2 
	.probe3(sw), // input wire [0:0]  probe3 
	.probe4(porb_i), // input wire [0:0]  probe4 
	.probe5(btn_db) // input wire [3:0]  probe5
);

endmodule
