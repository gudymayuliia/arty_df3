module tb_top();

logic clk, porb, sync_reset;
tri1 seg_sda, seg_scl;
logic sda_in;
logic [3:0] btn;

initial begin
    porb = 0;
    sync_reset = 1;
    btn = 4'b0;
    #120ns;
    @(posedge clk);
    porb = 1;
    repeat(20) @(posedge clk);
    sync_reset = 0;

    #200ms;
    $finish();

end

initial begin
    //seg_sda = 1;
    forever begin
        repeat(9) @(negedge seg_scl);
        #10ns;
        //seg_sda = 0;
        @(negedge seg_scl)
        #10ns;
        //seg_sda = 1;
    end
end


initial begin
    clk = 0;
    forever #40ns clk = ~clk;
end


seven_segment_top top_u(
    .clk_i(clk),
    .porb_i(porb),
    .sw(sync_reset),
    .btn(btn),
    .sda(seg_sda),
    .scl(seg_scl)
);

//module seven_segment_top(
//    input  clk_i,
//    input  porb_i,//async reset sw0
//    //input  sync_reset_i,
//    input logic sw,
//    input logic [3:0] btn,
//    inout  sda,
//    output scl
//);


endmodule