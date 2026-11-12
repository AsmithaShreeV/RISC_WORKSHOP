`timescale 1ns/1ps
module traffic_tb;
    reg clk=0,reset,ped_request;
    wire red,yellow,green,walk;
    traffic #(.RED_TIME(3),.GREEN_TIME(4),.YELLOW_TIME(2),.WALK_TIME(3),.CW(4))
        dut(.*);
    always #5 clk=~clk;
    initial begin
        reset=1; ped_request=0; repeat(2) @(negedge clk); reset=0;
        repeat(5) @(negedge clk);
        ped_request=1; @(negedge clk); ped_request=0;
        repeat(20) @(negedge clk);
        // Request during walk is ignored.
        ped_request=1; repeat(2) @(negedge clk); ped_request=0;
        repeat(15) @(negedge clk);
        $finish;
    end
endmodule
