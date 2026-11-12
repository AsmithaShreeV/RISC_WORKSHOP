module traffic #(parameter RED_TIME=5, GREEN_TIME=5, YELLOW_TIME=2, WALK_TIME=4,
                 parameter CW=8) (
    input clk, reset, ped_request,
    output reg red, yellow, green, walk
);
    localparam RED=3'd0, GREEN=3'd1, YELLOW=3'd2, WALK=3'd3;
    reg [2:0] state, next_state;
    reg [CW-1:0] timer;
    reg ped_pending;

    always @(posedge clk) begin
        if(reset) begin state<=RED; timer<=0; ped_pending<=0; end
        else begin
            state<=next_state;
            if(ped_request && state!=WALK) ped_pending<=1;
            if(state!=next_state) timer<=0;
            else timer<=timer+1'b1;
            if(state==WALK && timer==WALK_TIME-1) ped_pending<=0;
        end
    end

    always @* begin
        next_state=state;
        red=0; yellow=0; green=0; walk=0;
        case(state)
            RED: begin red=1; if(timer>=RED_TIME-1) next_state=GREEN; end
            GREEN: begin
                green=1;
                if(timer>=GREEN_TIME-1) begin
                    if(ped_pending || ped_request) next_state=YELLOW;
                    else next_state=YELLOW;
                end
            end
            YELLOW: begin
                yellow=1;
                if(timer>=YELLOW_TIME-1) next_state=(ped_pending || ped_request)?WALK:RED;
            end
            WALK: begin walk=1; if(timer>=WALK_TIME-1) next_state=RED; end
            default: next_state=RED;
        endcase
    end
endmodule
