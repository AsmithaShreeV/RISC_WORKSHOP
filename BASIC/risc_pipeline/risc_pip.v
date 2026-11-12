module riscv_32bit_pipeline(
    input clk,
    input reset
);

    // Program Counter
    reg [31:0] PC;

    // Instruction Memory
    reg [31:0] instruction_memory [0:31];

    // Data Memory
    reg [31:0] data_memory [0:31];

    // Register File
    reg [31:0] registers [0:31];

    // Pipeline Registers

    // IF/ID
    reg [31:0] IF_ID_PC;
    reg [31:0] IF_ID_Instruction;

    // ID/EX
    reg [31:0] ID_EX_PC;
    reg [31:0] ID_EX_ReadData1;
    reg [31:0] ID_EX_ReadData2;
    reg [31:0] ID_EX_Immediate;
    reg [4:0] ID_EX_Rs1;
    reg [4:0] ID_EX_Rs2;
    reg [4:0] ID_EX_Rd;
    reg [3:0] ID_EX_ALUControl;
    reg [2:0] ID_EX_MemControl;
    reg ID_EX_RegWrite;

    // EX/MEM
    reg [31:0] EX_MEM_ALUResult;
    reg [31:0] EX_MEM_WriteData;
    reg [4:0] EX_MEM_Rd;
    reg [2:0] EX_MEM_MemControl;
    reg EX_MEM_RegWrite;

    // MEM/WB
    reg [31:0] MEM_WB_Data;
    reg [4:0] MEM_WB_Rd;
    reg MEM_WB_RegWrite;

    integer i;

    // Initialize processor
    initial begin
        PC = 0;

        for(i=0; i<32; i=i+1) begin
            registers[i] = 0;
            data_memory[i] = 0;
            instruction_memory[i] = 32'h00000013;
        end

        // Example instructions
        // ADDI x1, x0, 10
        instruction_memory[0] = 32'h00A00093;

        // ADDI x2, x0, 20
        instruction_memory[1] = 32'h01400113;

        // ADD x3, x1, x2
        instruction_memory[2] = 32'h002081B3;

        // SUB x4, x2, x1
        instruction_memory[3] = 32'h40110233;

        // SW x3, 0(x0)
        instruction_memory[4] = 32'h00302023;

        // LW x5, 0(x0)
        instruction_memory[5] = 32'h00002283;
    end

    // Five-stage Pipeline
    always @(posedge clk or posedge reset) begin

        if(reset) begin
            PC <= 0;

            IF_ID_PC <= 0;
            IF_ID_Instruction <= 0;

            ID_EX_PC <= 0;
            ID_EX_ReadData1 <= 0;
            ID_EX_ReadData2 <= 0;
            ID_EX_Immediate <= 0;
            ID_EX_Rs1 <= 0;
            ID_EX_Rs2 <= 0;
            ID_EX_Rd <= 0;
            ID_EX_ALUControl <= 0;
            ID_EX_MemControl <= 0;
            ID_EX_RegWrite <= 0;

            EX_MEM_ALUResult <= 0;
            EX_MEM_WriteData <= 0;
            EX_MEM_Rd <= 0;
            EX_MEM_MemControl <= 0;
            EX_MEM_RegWrite <= 0;

            MEM_WB_Data <= 0;
            MEM_WB_Rd <= 0;
            MEM_WB_RegWrite <= 0;
        end

        else begin

            // STAGE 1: INSTRUCTION FETCH
            IF_ID_PC <= PC;
            IF_ID_Instruction <= instruction_memory[PC[6:2]];
            PC <= PC + 4;

            // STAGE 2: INSTRUCTION DECODE
            ID_EX_PC <= IF_ID_PC;

            ID_EX_Rs1 <= IF_ID_Instruction[19:15];
            ID_EX_Rs2 <= IF_ID_Instruction[24:20];
            ID_EX_Rd <= IF_ID_Instruction[11:7];

            ID_EX_ReadData1 <=
                registers[IF_ID_Instruction[19:15]];

            ID_EX_ReadData2 <=
                registers[IF_ID_Instruction[24:20]];

            ID_EX_Immediate <=
                {{20{IF_ID_Instruction[31]}},
                IF_ID_Instruction[31:20]};

            ID_EX_RegWrite <= 0;
            ID_EX_MemControl <= 0;
            ID_EX_ALUControl <= 0;

            case(IF_ID_Instruction[6:0])

                7'b0110011: begin
                    ID_EX_RegWrite <= 1;

                    case(IF_ID_Instruction[14:12])
                        3'b000: begin
                            if(IF_ID_Instruction[30])
                                ID_EX_ALUControl <= 4'b0001;
                            else
                                ID_EX_ALUControl <= 4'b0000;
                        end

                        3'b111:
                            ID_EX_ALUControl <= 4'b0010;

                        3'b110:
                            ID_EX_ALUControl <= 4'b0011;
                    endcase
                end

                7'b0010011: begin
                    ID_EX_RegWrite <= 1;
                    ID_EX_ALUControl <= 4'b0000;
                end

                7'b0000011: begin
                    ID_EX_RegWrite <= 1;
                    ID_EX_MemControl <= 3'b001;
                end

                7'b0100011: begin
                    ID_EX_MemControl <= 3'b010;
                    ID_EX_Immediate <=
                        {{20{IF_ID_Instruction[31]}},
                        IF_ID_Instruction[31:25],
                        IF_ID_Instruction[11:7]};
                end

            endcase

            // STAGE 3: EXECUTE
            EX_MEM_ALUResult <= 0;

            case(ID_EX_ALUControl)

                4'b0000:
                    EX_MEM_ALUResult <=
                    (ID_EX_MemControl == 3'b000 &&
                     ID_EX_Rs2 == 0) ?
                    ID_EX_ReadData1 + ID_EX_Immediate :
                    ID_EX_ReadData1 + ID_EX_ReadData2;

                4'b0001:
                    EX_MEM_ALUResult <=
                    ID_EX_ReadData1 - ID_EX_ReadData2;

                4'b0010:
                    EX_MEM_ALUResult <=
                    ID_EX_ReadData1 & ID_EX_ReadData2;

                4'b0011:
                    EX_MEM_ALUResult <=
                    ID_EX_ReadData1 | ID_EX_ReadData2;

            endcase

            EX_MEM_WriteData <= ID_EX_ReadData2;
            EX_MEM_Rd <= ID_EX_Rd;
            EX_MEM_MemControl <= ID_EX_MemControl;
            EX_MEM_RegWrite <= ID_EX_RegWrite;

            // STAGE 4: MEMORY ACCESS
            MEM_WB_Data <= EX_MEM_ALUResult;

            if(EX_MEM_MemControl == 3'b001)
                MEM_WB_Data <=
                data_memory[EX_MEM_ALUResult[6:2]];

            if(EX_MEM_MemControl == 3'b010)
                data_memory[EX_MEM_ALUResult[6:2]]
                    <= EX_MEM_WriteData;

            MEM_WB_Rd <= EX_MEM_Rd;
            MEM_WB_RegWrite <= EX_MEM_RegWrite;

            // STAGE 5: WRITE BACK
            if(MEM_WB_RegWrite && MEM_WB_Rd != 0)
                registers[MEM_WB_Rd] <= MEM_WB_Data;

            registers[0] <= 0;

        end
    end

endmodule
