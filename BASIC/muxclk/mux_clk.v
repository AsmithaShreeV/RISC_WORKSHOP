module mux_2x1_clk(
    input I0, I1,
    input sel,
    input clk,
    output reg Y
);

always @(posedge clk)
begin
    if(sel == 0)
        Y <= I0;
    else
        Y <= I1;
end

endmodule