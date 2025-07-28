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

typedef enum logic [1:0] {
    IDLE,
    SEND_NUMBER,
    WAIT,
    DONE
} state_t;

state_t fsm_state_ff, fsm_next;
logic [7:0] digits [3:0];
logic disp_strobe;

//sw1 - change counter
//sw0 - reset
logic [7:0] counter_a, counter_b, selected_counter;
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
    if (!porb_i)
        selected_counter <= 0;
    else
        selected_counter <= (sw == 1'b0) ? counter_a : counter_b;
end




always_ff @(negedge porb_i, posedge clk_i) begin
    if (!porb_i) begin
        counter_a <= 8'd0;
        counter_b <= 8'd0;
    end else if (clk_i) begin
        btn_db_prev0 <= btn_db[0];
        btn_db_prev1 <= btn_db[1];
        btn_db_prev2 <= btn_db[2];
        btn_db_prev3 <= btn_db[3];
        
//        if (btn_db[0] && !btn_db_prev0) counter_a <= counter_a + 1;
//        if (btn_db[1] && !btn_db_prev1) counter_a <= counter_a - 1;
//        if (btn_db[2] && !btn_db_prev2) counter_b <= counter_b + 1;
//        if (btn_db[3] && !btn_db_prev3) counter_b <= counter_b - 1;

        if (btn[0]) counter_a <= counter_a + 1;
        if (btn[1]) counter_a <= counter_a - 1;
        if (btn[2]) counter_b <= counter_b + 1;
        if (btn[3]) counter_b <= counter_b - 1;
    end
end

// FSM state FF
always_ff @(negedge porb_i, posedge clk_i ) begin : state_ff
    if(!porb_i)begin
    fsm_state_ff <= IDLE;
    end else if (clk_i) begin
        fsm_state_ff <= fsm_next;
    end 
end

// State transitioning logic
always_comb begin : next_state
    fsm_next = fsm_state_ff;
    disp_strobe = 1'b0;
    digits[0] = 8'h00;
    digits[1] = 8'h00;
    digits[2] = 8'h00;
    digits[3] = 8'h00;
    case (fsm_state_ff)
        IDLE: 
            begin
                fsm_next = SEND_NUMBER;
            end
        SEND_NUMBER:
            begin
                disp_strobe = 1'b1;
                digits[3] = `_5;

                
                if(selected_counter > 2)  digits[0] = `_2;
                if(selected_counter > 7)  digits[1] = `_7;
                if(selected_counter > 10)  digits[2] = `_8;
                if(selected_counter > 13)  digits[3] = `_9;

                                                       
//                digits[0] = `_2;
//                digits[1] = `_0;
//                digits[2] = `_2;
//                digits[3] = `_5;
                
                fsm_next = WAIT;
            end
        WAIT:
            begin
                if (!busy) begin
                    fsm_next = DONE;
                end
            end
        DONE:
            fsm_next = fsm_state_ff;
        default: fsm_next = fsm_state_ff;
    endcase
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

endmodule
