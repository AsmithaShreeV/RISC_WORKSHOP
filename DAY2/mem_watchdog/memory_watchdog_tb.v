`timescale 1ns/1ps
module memory_watchdog_tb;
    reg clk=0,we,wd_reset,kick;
    reg [3:0] addr;
    reg [7:0] data_in;
    wire [7:0] ram_out,rom_out;
    wire reset_pulse;
    ram r(clk,we,addr,data_in,ram_out);
    rom #(.INIT_FILE("rom.hex")) ro(clk,addr,rom_out);
    watchdog #(.TIMEOUT(6),.WIDTH(3),.PULSE_CYCLES(1)) w(clk,wd_reset,kick,reset_pulse);
    always #5 clk=~clk;
    initial begin
        we=0; wd_reset=1; kick=0; addr=0; data_in=0;
        @(negedge clk); wd_reset=0;
        // RAM write/read
        we=1; addr=4; data_in=8'hA6; @(negedge clk);
        we=0; @(negedge clk);
        // Allow watchdog to timeout.
        repeat(8) @(negedge clk);
        // Kick periodically to prevent another timeout.
        kick=1; @(negedge clk); kick=0;
        repeat(4) @(negedge clk);
        kick=1; @(negedge clk); kick=0;
        repeat(4) @(negedge clk);
        $finish;
    end
endmodule
