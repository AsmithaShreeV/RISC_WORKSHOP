
module atm_tb;

reg clk, rst, card, withdraw;
reg [3:0] pin;

wire cash, error;
wire [2:0] state;

atm_fsm uut (
    .clk(clk),
    .rst(rst),
    .card(card),
    .pin(pin),
    .withdraw(withdraw),
    .cash(cash),
    .error(error),
    .state(state)
);

// Clock generation
always #5 clk = ~clk;

initial
begin
    clk = 0;
    rst = 1;
    card = 0;
    pin = 0;
    withdraw = 0;

    #10 rst = 0;

    // Insert card
    #10 card = 1;
    #10 card = 0;

    // Enter correct PIN
    pin = 4'd3;

    // Wait for verification
    #30;

    // Select withdrawal
    withdraw = 1;
    #10 withdraw = 0;

    // Wait for cash dispensing
    #20;

    // Reset ATM
    rst = 1;
    #10 rst = 0;

    // Insert card again
    #10 card = 1;
    #10 card = 0;

    // Enter incorrect PIN
    pin = 4'd5;

    #40;

    $finish;
end

initial
begin
    $monitor("Time=%0t | State=%b | Card=%b | PIN=%d | Withdraw=%b | Cash=%b | Error=%b",
    $time, state, card, pin, withdraw, cash, error);
end

endmodule
