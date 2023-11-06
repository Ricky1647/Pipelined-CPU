module Control
(
    Op_i,
    NoOp_i,
	RegWrite_o,
	MemtoReg_o,
	MemRead_o,
	MemWrite_o,
	ALUOp_o,
	ALUSrc_o,
    Branch_o,
);

input NoOp_i;
input [6:0] Op_i;
output [1:0] ALUOp_o;
output RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o, ALUSrc_o, Branch_o;
reg RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o, ALUSrc_o, Branch_o;
reg [1:0] ALUOp_o;

always@(*)begin
    if (NoOp_i==1) begin
        RegWrite_o <= 1'b0;
        MemtoReg_o <= 1'b0;
        MemRead_o <= 1'b0;
        MemWrite_o <= 1'b0;
        ALUOp_o <= 2'b00;
        ALUSrc_o <= 1'b0;
        Branch_o <= 1'b0;  
    end
    else begin
        case(Op_i)
            7'b0110011:begin //R-type
                RegWrite_o <= 1'b1;
                MemtoReg_o <= 1'b0;
                MemRead_o <= 1'b0;
                MemWrite_o <= 1'b0;
                ALUOp_o <= 2'b10;
                ALUSrc_o <= 1'b0;
                Branch_o <= 1'b0;    
            end
            7'b0010011:begin //addi,srai
                RegWrite_o <= 1'b1;
                MemtoReg_o <= 1'b0;
                MemRead_o <= 1'b0;
                MemWrite_o <= 1'b0;
                ALUOp_o <= 2'b00;
                ALUSrc_o <= 1'b1;   
                Branch_o <= 1'b0;       
            end
            7'b0000011:begin //lw
                RegWrite_o <= 1'b1;
                MemtoReg_o <= 1'b1;
                MemRead_o <= 1'b1;
                MemWrite_o <= 1'b0;
                ALUOp_o <= 2'b00;
                ALUSrc_o <= 1'b1;   
                Branch_o <= 1'b0;       
            end
            7'b0100011:begin //sw
                RegWrite_o <= 1'b0;
                MemtoReg_o <= 1'b0;
                MemRead_o <= 1'b0;
                MemWrite_o <= 1'b1;
                ALUOp_o <= 2'b00;
                ALUSrc_o <= 1'b1;   
                Branch_o <= 1'b0;       
            end
            7'b1100011:begin //beq
                RegWrite_o <= 1'b0;
                MemtoReg_o <= 1'b0;
                MemRead_o <= 1'b0;
                MemWrite_o <= 1'b0;
                ALUOp_o <= 2'b01;
                ALUSrc_o <= 1'b0;  
                Branch_o <= 1'b1;        
            end
            default:begin
                RegWrite_o <= 1'b0;
                MemtoReg_o <= 1'b0;
                MemRead_o <= 1'b0;
                MemWrite_o <= 1'b0;
                ALUOp_o <= 2'b00;
                ALUSrc_o <= 1'b0;
                Branch_o <= 1'b0;  
            end
        endcase
    end
end

endmodule


    // 目的 srai 不會用到相加 但 addi 會用到相加 所以assign 00
    // 耕心 是１１
    // ALUOP
    // 00 add
    // 01 sub
    // 10 look at funct
    // 11 not used



/*
funct7       rs2 rs1 funct3 rd       opcode    function
0000000      rs2 rs1 111    rd       0110011   and
0000000      rs2 rs1 100    rd       0110011   xor
0000000      rs2 rs1 001    rd       0110011   sll
0000000      rs2 rs1 000    rd       0110011   add
0100000      rs2 rs1 000    rd       0110011   sub
0000001      rs2 rs1 000    rd       0110011   mul
    imm[11:0]    rs1 000    rd       0010011   addi
0100000 imm[4:0] rs1 101    rd       0010011   srai
    imm[11:0]    rs1 010    rd       0000011   lw
imm[11:5]    rs2 rs1 010  imm[4:0]   0100011   sw
imm[12,10:5] rs2 rs1 000  imm[4:1,11]1100011   beq


https://passlab.github.io/CSE564/notes/lecture09_RISCV_Impl_pipeline.pdf
https://github.com/Michaelvll/RISCV_CPU/tree/master/Source
https://github.com/VenciFreeman/RISC-V
*/