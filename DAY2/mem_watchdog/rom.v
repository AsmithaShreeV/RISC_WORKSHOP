module rom #(parameter INIT_FILE="rom.hex") (
    input clk, input [3:0] addr, output reg [7:0] data_out
);
    reg [7:0] mem[0:15];
    initial $readmemh(INIT_FILE,mem);
    always @(posedge clk) data_out <= mem[addr];
endmodule
