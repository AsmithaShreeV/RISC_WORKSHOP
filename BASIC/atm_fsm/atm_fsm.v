
module atm_fsm (
    input clk,
    input rst,
    input card,
    input [3:0] pin,
    input withdraw,
    output reg cash,
    output reg error,
    output reg [2:0] state
);

parameter IDLE        = 3'b000;
parameter PIN_ENTRY   = 3'b001;
parameter VERIFY      = 3'b010;
parameter TRANSACTION = 3'b011;
parameter DISPENSE    = 3'b100;
parameter ERROR       = 3'b101;

reg [3:0] balance;
reg [3:0] entered_pin;

// State register
always @(posedge clk or posedge rst)
begin
    if (rst)
        state <= IDLE;
    else
    begin
        case(state)

            IDLE:
                if (card)
                    state <= PIN_ENTRY;

            PIN_ENTRY:
                state <= VERIFY;

            VERIFY:
                if (pin == 4'd3)
                    state <= TRANSACTION;
                else
                    state <= ERROR;

            TRANSACTION:
                if (withdraw)
                begin
                    if (balance >= 4'd1)
                        state <= DISPENSE;
                    else
                        state <= ERROR;
                end

            DISPENSE:
                state <= IDLE;

            ERROR:
                state <= IDLE;

            default:
                state <= IDLE;

        endcase
    end
end

// Output and balance control
always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        cash <= 0;
        error <= 0;
        balance <= 4'd5;
    end
    else
    begin
        cash <= 0;
        error <= 0;

        case(state)

            DISPENSE:
            begin
                cash <= 1;
                balance <= balance - 4'd1;
            end

            ERROR:
                error <= 1;

        endcase
    end
end

endmodule
