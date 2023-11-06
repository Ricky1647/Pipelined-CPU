// copy from hw4
module ALU_Control (funct7_i,funct3_i,ALUOp_i,ALUCtrl_o);
    input [1:0] ALUOp_i;
    input [6:0] funct7_i ;
    input [2:0] funct3_i;
    output[3:0] ALUCtrl_o; //助教投影片寫錯了？ 上面３應該是４
    reg[3:0] ALUCtrl_o;


    always @(*) begin
        case (ALUOp_i)
            2'b10:case (funct7_i)   //b10 for  look at function 
                7'b0000000:case (funct3_i)
                    3'b111:ALUCtrl_o = 4'b0000; //and
                    3'b100:ALUCtrl_o = 4'b0001; //xor
                    3'b001:ALUCtrl_o = 4'b0010; // sll
                    3'b000:ALUCtrl_o = 4'b0011; // add
                    default:ALUCtrl_o = 4'bxxxx;
                endcase 
                7'b0100000:ALUCtrl_o = 4'b0100; // sub
                //     3'b000:ALUCtrl_o = 4'b0110; // sub 
                //     3'b101:ALUCtrl_o = 4'b1010; // srai
                //     default: ALUCtrl_o = 4'bxxxx;
                // endcase
                7'b0000001:ALUCtrl_o = 4'b0101; // mul 自定義ＱＱ
                //default: ALUCtrl_o = 4'bxxxx;
            endcase
            2'b00:case(funct3_i)
                3'b000: ALUCtrl_o=4'b0110;//addi
                3'b101: ALUCtrl_o=4'b0111;//srai
                3'b010: ALUCtrl_o=4'b1000;//lw,sw
            endcase
            2'b01:ALUCtrl_o=4'b1001;//beq
            
            default: ALUCtrl_o = 4'bxxxx;
        endcase

    end
endmodule


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
new!!!!
    imm[11:0]    rs1 010    rd       0000011   lw
imm[11:5]    rs2 rs1 010  imm[4:0]   0100011   sw
imm[12,10:5] rs2 rs1 000  imm[4:1,11]1100011   beq


https://passlab.github.io/CSE564/notes/lecture09_RISCV_Impl_pipeline.pdf
https://github.com/Michaelvll/RISCV_CPU/tree/master/Source
https://github.com/VenciFreeman/RISC-V
*/