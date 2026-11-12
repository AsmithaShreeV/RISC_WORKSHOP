module atm #(parameter PIN_CODE=4'b1234, INITIAL_BALANCE=1000) (
    input clk, reset, card_insert, pin_submit,
    input [3:0] pin,
    input balance_request, withdraw_request,
    input [15:0] withdraw_amount,
    input cancel,
    output reg pin_ok, locked, transaction_done, insufficient_funds,
    output reg [15:0] balance,
    output reg [2:0] state_out
);
    localparam IDLE=0, PIN_CHECK=1, MENU=2, BALANCE=3, WITHDRAW=4, LOCKED=5;
    reg [2:0] state, next_state;
    reg [1:0] attempts;

    always @(posedge clk) begin
        if(reset) begin
            state<=IDLE; attempts<=0; balance<=INITIAL_BALANCE;
            pin_ok<=0; locked<=0; transaction_done<=0; insufficient_funds<=0;
        end else begin
            state<=next_state;
            pin_ok<=0; transaction_done<=0; insufficient_funds<=0;
            if(state==PIN_CHECK && pin_submit) begin
                if(pin==PIN_CODE) begin attempts<=0; pin_ok<=1; end
                else if(attempts==2) begin attempts<=3; locked<=1; end
                else attempts<=attempts+1'b1;
            end
            if(state==WITHDRAW && withdraw_request) begin
                if(withdraw_amount<=balance) begin
                    balance<=balance-withdraw_amount;
                    transaction_done<=1;
                end else insufficient_funds<=1;
            end
            if(state==IDLE && card_insert) locked<=0;
        end
    end

    always @* begin
        next_state=state;
        case(state)
            IDLE: if(card_insert) next_state=PIN_CHECK;
            PIN_CHECK: begin
                if(cancel) next_state=IDLE;
                else if(pin_submit && pin==PIN_CODE) next_state=MENU;
                else if(pin_submit && attempts==2) next_state=LOCKED;
            end
            MENU: begin
                if(cancel) next_state=IDLE;
                else if(balance_request) next_state=BALANCE;
                else if(withdraw_request) next_state=WITHDRAW;
            end
            BALANCE: next_state=MENU;
            WITHDRAW: next_state=MENU;
            LOCKED: if(cancel) next_state=IDLE;
            default: next_state=IDLE;
        endcase
    end
    always @* state_out=state;
endmodule
