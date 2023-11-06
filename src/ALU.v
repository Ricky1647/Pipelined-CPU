// module ALU(data1_i, data2_i, ALUCtrl_i, data_o, Zero_o);
// input signed [31:0] data1_i, data2_i;
// input  [2:0]  ALUCtrl_i;
// output [31:0] data_o;
// output        Zero_o;

// // TODO

// endmodule

// copy from lab1


module ALU (
    data1_i,
    data2_i,
    ALUCtrl_i,
    data_o,
    Zero_o,
    imm2_i
);
    input signed [31:0] data1_i, data2_i;
    //input [31:0]data1_i,data2_i;

    input [3:0]ALUCtrl_i;
    input [4:0]imm2_i;
    output signed [31:0]data_o;
    output Zero_o;
    assign Zero_o=(data1_i==data2_i)? 1:0;
    assign data_o = (ALUCtrl_i == 4'b0000)?(data1_i & data2_i):
    (ALUCtrl_i == 4'b0001)?(data1_i ^ data2_i):
    (ALUCtrl_i == 4'b0010)?(data1_i << data2_i):
    (ALUCtrl_i == 4'b0011)?(data1_i + data2_i):
    (ALUCtrl_i == 4'b0100)?(data1_i - data2_i):
    (ALUCtrl_i == 4'b0101)?(data1_i * data2_i)://(data1_i >>> imm2_i):
    (ALUCtrl_i == 4'b0110)?(data1_i + data2_i): //addi
    (ALUCtrl_i == 4'b0111)?(data1_i >>> data2_i[4:0])://srai
    (ALUCtrl_i == 4'b1000)?(data1_i + data2_i):
    (data1_i - data2_i); //beq 相減
endmodule

