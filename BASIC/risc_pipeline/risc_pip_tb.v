module riscv_32bit_pipeline_tb;

    reg clk;
    reg reset;

    riscv_32bit_pipeline uut(
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;

        #10;
        reset = 0;

        // Run processor for 20 clock cycles
        #200;

        $display("Register values:");
        $display("x1 = %d", uut.registers[1]);
        $display("x2 = %d", uut.registers[2]);
        $display("x3 = %d", uut.registers[3]);
        $display("x4 = %d", uut.registers[4]);
        $display("x5 = %d", uut.registers[5]);

        $display("Memory[0] = %d", uut.data_memory[0]);

        $finish;
    end

    initial begin
        $monitor("Time=%0t PC=%h", $time, uut.PC);
    end

endmodule
