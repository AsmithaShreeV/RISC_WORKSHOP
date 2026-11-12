`timescale 1ns/1ps
module arbiter_tb;
    reg clk=0,reset;
    reg [3:0] req;
    wire [3:0] grant;
    integer counts[0:3];
    integer i,cycles;
    arbiter dut(.*);
    always #5 clk=~clk;
    initial begin
        reset=1; req=0;
        for(i=0;i<4;i=i+1) counts[i]=0;
        repeat(2) @(negedge clk); reset=0; req=4'b1111;
        // Keep each request asserted for a grant, then release the winner.
        for(cycles=0;cycles<40;cycles=cycles+1) begin
            @(negedge clk);
            if(grant!=0) begin
                for(i=0;i<4;i=i+1) if(grant[i]) counts[i]=counts[i]+1;
                req=req & ~grant;
            end
            if(req==0) req=4'b1111;
        end
        $display("Grant counts: %0d %0d %0d %0d",counts[0],counts[1],counts[2],counts[3]);
        if(counts[0]!=counts[1] || counts[1]!=counts[2] || counts[2]!=counts[3])
            $display("FAIRNESS CHECK FAILED");
        else $display("FAIRNESS CHECK PASSED");
        $finish;
    end
endmodule
