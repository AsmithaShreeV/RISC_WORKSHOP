`timescale 1ns/1ps
module atm_tb;
    reg clk=0,reset,card_insert,pin_submit;
    reg [3:0] pin;
    reg balance_request,withdraw_request,cancel;
    reg [15:0] withdraw_amount;
    wire pin_ok,locked,transaction_done,insufficient_funds;
    wire [15:0] balance;
    wire [2:0] state_out;
    atm #(.PIN_CODE(4'b0001), .INITIAL_BALANCE(1000)) dut(.*);
    always #5 clk=~clk;
    task tick; begin @(negedge clk); end endtask
    initial begin
        reset=1; card_insert=0; pin_submit=0; pin=0;
        balance_request=0; withdraw_request=0; withdraw_amount=0; cancel=0;
        tick(); reset=0;
        // Correct PIN, balance query and successful withdrawal.
        card_insert=1; tick(); card_insert=0;
        pin=4'b0001; pin_submit=1; tick(); pin_submit=0;
        balance_request=1; tick(); balance_request=0; tick();
        withdraw_amount=200; withdraw_request=1; tick(); withdraw_request=0; tick();
        // Insufficient funds.
        withdraw_amount=2000; withdraw_request=1; tick(); withdraw_request=0; tick();
        cancel=1; tick(); cancel=0;
        // Three wrong PIN attempts lead to lock.
        card_insert=1; tick(); card_insert=0;
        pin=4'h0; pin_submit=1; tick(); tick(); tick(); pin_submit=0;
        repeat(2) tick();
        $finish;
    end
endmodule
