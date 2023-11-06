/*

* 要把PC+4 跟 PC+target 放進來 (add)
* 以及預測錯誤的IDEX flush 放進來 (add)
* branch_i 也要往下傳 為了能確認當前ex stage是否為branch
* predict 也要往下傳 確認是不是預測錯誤

*/ 
module IDEX 
(
    clk_i, 
    start_i,
    RegWrite_i,
    MemtoReg_i, 
    MemRead_i,
    MemWrite_i,
    ALUOp_i,
    ALUSrc_i,
    /*add */
    Branch_i,
    /*add */
    RSdata_i, 
    RTdata_i,
    ImmGen_i,
    funct7_i,
	funct3_i,
    RSaddr_i,
    RTaddr_i,
    RDaddr_i,
    /* new add */
    PC_i,
    PC_target_i,
    Flush_i,
    predict_i,
    /* new add */
    RegWrite_o,
    MemtoReg_o, 
    MemRead_o,
    MemWrite_o,
    ALUOp_o,
    ALUSrc_o,
    RSdata_o,
    RTdata_o,
    ImmGen_o,
    funct7_o,
	funct3_o,
    RSaddr_o,
    RTaddr_o,
    RDaddr_o,
    PC_o,
    PC_target_o,
    Branch_o,
    predict_o
    /* new add */

    /* new add */
);

input clk_i, start_i;
input RegWrite_i,
      MemtoReg_i, 
      MemRead_i,
      MemWrite_i, 
      ALUSrc_i;
input [1:0] ALUOp_i;
input [31:0] RSdata_i,
             RTdata_i,
             ImmGen_i;
input [6:0] funct7_i;
input [2:0] funct3_i;
input [4:0] RSaddr_i,
            RTaddr_i,
            RDaddr_i;

output RegWrite_o,
       MemtoReg_o, 
       MemRead_o,
       MemWrite_o, 
       ALUSrc_o;
output [1:0] ALUOp_o;
output [31:0] RSdata_o,
             RTdata_o,
             ImmGen_o;
output [6:0] funct7_o;
output [2:0] funct3_o;

output [4:0] RSaddr_o,
            RTaddr_o,
            RDaddr_o;

reg         RegWrite_o,
            MemtoReg_o, 
            MemRead_o,
            MemWrite_o, 
            ALUSrc_o;
reg [1:0]   ALUOp_o;
reg [31:0]  RSdata_o,
            RTdata_o,
            ImmGen_o;
reg [6:0]   funct7_o;
reg [2:0]   funct3_o;
reg [4:0]   RSaddr_o,
            RTaddr_o,
            RDaddr_o;
/*new  add*/
input Branch_i;
input Flush_i;
input predict_i;
input [31:0] PC_i , PC_target_i;
output [31:0]PC_o,PC_target_o;
reg[31:0] PC_o , PC_target_o;

output Branch_o;
reg Branch_o;
output predict_o;
reg predict_o;
/*new  add*/

always @ ( posedge clk_i or negedge start_i) begin
    if (~start_i) begin
        RegWrite_o <= 0;
        MemtoReg_o <= 0;
        MemRead_o <= 0;
        MemWrite_o <= 0;
        ALUSrc_o <= 0;
        ALUOp_o <= 0;
        RSdata_o <= 0;
        RTdata_o <= 0;
        ImmGen_o <= 0;
        funct7_o <= 0;
		funct3_o <= 0;
        RSaddr_o <= 0;
        RTaddr_o <= 0;
        RDaddr_o <= 0;
        PC_o <=0;
        PC_target_o <= 0 ;
        Branch_o <= 0;
        predict_o <= 0;
    end
    else if (Flush_i)begin
        RegWrite_o <= 0;
        MemtoReg_o <= 0;
        MemRead_o <= 0;
        MemWrite_o <= 0;
        ALUSrc_o <= 0;
        ALUOp_o <= 0;
        RSdata_o <= 0;
        RTdata_o <= 0;
        ImmGen_o <= 0;
        funct7_o <= 0;
		funct3_o <= 0;
        RSaddr_o <= 0;
        RTaddr_o <= 0;
        RDaddr_o <= 0;
        PC_o <=0;
        PC_target_o <= 0 ;
        Branch_o <= 0;
        predict_o <= 0;
    end 
    else begin
        RegWrite_o <= RegWrite_i;
        MemtoReg_o <= MemtoReg_i;
        MemRead_o <= MemRead_i;
        MemWrite_o <= MemWrite_i;
        ALUSrc_o <= ALUSrc_i;
        ALUOp_o <= ALUOp_i;
        RSdata_o <= RSdata_i;
        RTdata_o <= RTdata_i;
        ImmGen_o <= ImmGen_i;
        funct7_o <= funct7_i;
		funct3_o <= funct3_i;
        RSaddr_o <= RSaddr_i;
        RTaddr_o <= RTaddr_i;
        RDaddr_o <= RDaddr_i;
        PC_o <= PC_i;
        PC_target_o <= PC_target_i ;
        Branch_o <= Branch_i;
        predict_o <= predict_i;
    end
end

endmodule