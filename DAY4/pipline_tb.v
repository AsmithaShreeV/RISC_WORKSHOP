
`timescale 1ns/1ps

module day4_tb;

    reg clk;
    reg reset;

    wire [31:0] pc;
    wire halted;

    integer i;

    day4_pipeline dut (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .halted(halted)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;

        // Initialize instruction and data memory
        for (i = 0; i < 256; i = i + 1) begin
            dut.imem[i] = 32'h00000013; // NOP
            dut.dmem[i] = 0;
        end

        // Initialize registers
        for (i = 0; i < 32; i = i + 1)
            dut.regs[i] = 0;

        // Instruction 1: ADDI x1, x0, 10
        dut.imem[0] = 32'h00A00093;

        // Instruction 2: ADDI x2, x0, 20
        dut.imem[1] = 32'h01400113;

        // Instruction 3: ADD x3, x1, x2
        dut.imem[2] = 32'h002081B3;

        // Instruction 4: SUB x4, x3, x1
        dut.imem[3] = 32'h40118233;

        // Instruction 5: SW x3, 0(x0)
        dut.imem[4] = 32'h00302023;

        // Instruction 6: LW x5, 0(x0)
        dut.imem[5] = 32'h00002283;

        // Instruction 7: ADD x6, x5, x1
        // Checks load-use hazard handling
        dut.imem[6] = 32'h00128333;

        // Instruction 8: BEQ x6, x3, +8
        // Not taken because x6 = 40 and x3 = 30
        dut.imem[7] = 32'h00330463;

        // Instruction 9: ADDI x7, x0, 99
        dut.imem[8] = 32'h06300393;

        // Instruction 10: ADDI x8, x0, 1
        dut.imem[9] = 32'h00100413;

        // Apply reset
        #20;
        reset = 0;

        // Wait for instructions to pass through pipeline
        #250;

        // Display results
        $display("--------------------------------");
        $display("     DAY 4 PIPELINE TEST        ");
        $display("--------------------------------");

        for (i = 1; i <= 8; i = i + 1)
            $display("Register x%0d = %0d", i, dut.regs[i]);

        $display("Data Memory[0] = %0d", dut.dmem[0]);

        // Verify results
        if (dut.regs[1] == 10 &&
            dut.regs[2] == 20 &&
            dut.regs[3] == 30 &&
            dut.regs[4] == 20 &&
            dut.regs[5] == 30 &&
            dut.regs[6] == 40 &&
            dut.regs[7] == 99 &&
            dut.regs[8] == 1 &&
            dut.dmem[0] == 30) begin

            $display("DAY 4 TEST PASSED");

        end
        else begin

            $display("DAY 4 TEST FAILED");

        end

        $display("--------------------------------");

        $finish;

    end

endmodule
