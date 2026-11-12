module watchdog #(parameter TIMEOUT=8, WIDTH=4, PULSE_CYCLES=1) (
    input clk, reset, kick,
    output reg reset_pulse
);
    reg [WIDTH-1:0] count;
    reg [1:0] pulse_count;
    always @(posedge clk) begin
        if(reset) begin count<=0; reset_pulse<=0; pulse_count<=0; end
        else begin
            if(kick) begin count<=0; reset_pulse<=0; pulse_count<=0; end
            else if(reset_pulse) begin
                if(pulse_count==PULSE_CYCLES-1) begin
                    reset_pulse<=0; pulse_count<=0; count<=0;
                end else pulse_count<=pulse_count+1'b1;
            end else if(count==TIMEOUT-1) begin
                reset_pulse<=1; pulse_count<=0; count<=0;
            end else count<=count+1'b1;
        end
    end
endmodule
