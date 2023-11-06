/////
///// copy from hw4
/////
module CPU
(
    clk_i, 
    rst_i,
    start_i
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;
wire [31:0] pc;
wire [31:0] instr_addr, instr;
wire [31:0] rs_data, rt_data;
wire [11:0] imm;
wire [4:0] imm2;
wire [6:0] opcode;
wire [6:0] funct7_i;
wire [4:0] rs, rt, rd;
wire [2:0] funct3_i;
wire [31 : 0] ID_EX_RSdata;
wire [31 : 0] ID_EX_RTdata;
assign opcode = instr[6:0];
wire [31:0] PC_addr;

assign rd = instr[11:7];
assign rs = instr[19:15];
assign funct3_i = instr[14:12] ;
assign rt = instr[24:20];
assign funct7_i = instr[31:25];
assign imm = instr[31:20];
//assign imm2 = instr[24:20];
//從頭到尾跑一遍 

// 由brach吐出來的決定

wire [31:0] IFID_addr_o,IFID_inst_o; //定義IFID_addr_o 等等會用來與ADD_branch做相加

/*還沒用完*/
branch_predictor Brach_Predictor(
    .clk_i (clk_i),
    .rst_i (rst_i),
    .update_i (XNor.data_o),
    .branch_i (IDEX.Branch_o),
    .predict_o (),
    .last_branch_o (),
    .bit1_o (),
    .bit2_o ()
);

MUX32_4Input MUX_PCSrc(
    .data1_i    (Add_PC.data_o),
    .data2_i    (Add_Branch_addr.data_o),
    .data3_i    ( MUX_EXPCtoPC.data_o), /*預測錯誤回傳的地址*/ /*這有很大的問題*/ 
    /*data3 有大BUG*/// 單獨沒問題 過mutex就有問題
    .select_i   (Forward_PC.forward_o),  
    .data_o     ()
);

// MUX32 MUX_PCSrc(
//     .data1_i    (Add_PC.data_o),
//     .data2_i    (Add_Branch_addr.data_o),    
//     .select_i   (Branch_And.data_o),  
//     .data_o     ()
// );
And Branch_And(
    .data1_i	(Control.Branch_o),
    .data2_i	(Brach_Predictor.predict_o), //((ID_EX_RSdata == ID_EX_RTdata)? 1'b1 : 1'b0), //1代表strong predict  0 代表 weak predict
    .data_o	    ()
);

And EX_Flush(
    .data1_i	(IDEX.Branch_o),
    .data2_i	(~XNor.data_o), //((ID_EX_RSdata == ID_EX_RTdata)? 1'b1 : 1'b0), //1代表strong predict  0 代表 weak predict
    .data_o	    ()
);
Adder Add_Branch_addr(
    .data1_i   (  ImmGen.data_o << 1), 
    .data2_i   (IFID_addr_o),
    .data_o     ()
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .PCWrite_i  (Hazard.PCWrite_o),
    .pc_i       (MUX_PCSrc.data_o),
    .pc_o       (PC_addr)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (PC_addr), 
    .instr_o    ()
);

Adder Add_PC(
    .data1_i    (PC_addr),
    .data2_i    (32'd4),
    .data_o     ()
);

Adder Add_PC2(
    .data1_i    (IDEX.PC_o),
    .data2_i    (32'd4),
    .data_o     ()
);



IFID IFID(
    .clk_i 	    (clk_i),
    .start_i 	(start_i),
    .addr_i 	(PC_addr),
    .inst_i 	(Instruction_Memory.instr_o),
    .Flush_i	(Branch_And.data_o | EX_Flush.data_o),
    .Stall_i    (Hazard.Stall_o),
    .addr_o	    (IFID_addr_o),
    .inst_o	    (IFID_inst_o)
);


Hazard Hazard(
    .IFID_RS1_i      (IFID_inst_o[19:15]),
    .IFID_RS2_i      (IFID_inst_o[24:20]),
    .IDEX_MemRead_i  (IDEX.MemRead_o),
    .IDEX_RD_i       (IDEX.RDaddr_o),
    .PCWrite_o       (),
    .Stall_o         (),
    .NoOp_o          ()
);


Registers Registers(
    .clk_i          (clk_i),
    .RS1addr_i      (IFID_inst_o[19:15]),
    .RS2addr_i      (IFID_inst_o[24:20]),
    .RDaddr_i       (MEMWB.RDaddr_o), 
    .RDdata_i       (MUX_MemtoReg.data_o),
    .RegWrite_i     (MEMWB.RegWrite_o), 
    .RS1data_o      (ID_EX_RSdata),  //用來作比較 equal branch
    .RS2data_o      (ID_EX_RTdata) 
);

Control Control(
    .Op_i       (IFID_inst_o[6:0]),
    .NoOp_i     (Hazard.NoOp_o),
	.RegWrite_o (),
	.MemtoReg_o (),
	.MemRead_o  (),
	.MemWrite_o (),
	.ALUOp_o    (),
	.ALUSrc_o   (),
    .Branch_o   ()
);

ImmGen ImmGen(
    .clk_i          (clk_i),
    .data_i         (IFID_inst_o),
    .data_o         ()
);

IDEX IDEX(
    .clk_i      (clk_i), 
    .start_i    (start_i), 
    .RegWrite_i (Control.RegWrite_o), 
    .MemtoReg_i (Control.MemtoReg_o),  
    .MemRead_i  (Control.MemRead_o), 
    .MemWrite_i (Control.MemWrite_o), 
    .ALUOp_i    (Control.ALUOp_o), 
    .ALUSrc_i   (Control.ALUSrc_o),
    .RSdata_i  (Registers.RS1data_o), 
    .RTdata_i  (Registers.RS2data_o), 
    .ImmGen_i   (ImmGen.data_o),
    //.funct_7_3_i ({IFID_inst_o[31:25],IFID_inst_o[14:12]}),
    .funct7_i (IFID_inst_o[31:25]),
    .funct3_i (IFID_inst_o[14:12]),
    .RSaddr_i  (IFID_inst_o[19:15]),
    .RTaddr_i  (IFID_inst_o[24:20]),
    .RDaddr_i   (IFID_inst_o[11:7]), 
    /*PC target i */
    .PC_target_i (Add_Branch_addr.data_o),
    .PC_i (IFID.addr_o),
    .Branch_i (Control.Branch_o),
    .Flush_i (EX_Flush.data_o), 
    /*not yet add */
    .RegWrite_o (), 
    .MemtoReg_o (),  
    .MemRead_o  (), 
    .MemWrite_o (), 
    .ALUOp_o    (), 
    .ALUSrc_o   (),
    .RSdata_o  (), 
    .RTdata_o  (), 
    .ImmGen_o   (),
    .funct7_o (),
    .funct3_o (),
    .RSaddr_o  (),
    .RTaddr_o  (),
    .RDaddr_o   (),
    .PC_o (),
    .PC_target_o (),
    .Branch_o (),
    .predict_o ()
);

MUX32_4Input MUX_ALUSrc_RS1(
    .data1_i    (IDEX.RSdata_o),
    .data2_i    (MUX_MemtoReg.data_o),
    .data3_i    (EXMEM.ALUdata_o),
    .select_i   (Forward.ForwardA_o),
    .data_o     ()
);

MUX32_4Input MUX_ALUSrc_RS2(
    .data1_i    (IDEX.RTdata_o),
    .data2_i    (MUX_MemtoReg.data_o),
    .data3_i    (EXMEM.ALUdata_o),
    .select_i   (Forward.ForwardB_o),
    .data_o     ()
);

MUX32 MUX_ALUSrc(
    .data1_i    (MUX_ALUSrc_RS2.data_o),
    .data2_i    (IDEX.ImmGen_o),
    .select_i   (IDEX.ALUSrc_o),
    .data_o     ()
);

Forward Forward(
    .ID_EX_RSaddr_i         (IDEX.RSaddr_o),
    .ID_EX_RTaddr_i         (IDEX.RTaddr_o),
    .EX_MEM_RegWrite_i   (EXMEM.RegWrite_o),
    .EX_MEM_RDaddr_i         (EXMEM.RDaddr_o),
    .MEM_WB_RegWrite_i   (MEMWB.RegWrite_o),
    .MEM_WB_RDaddr_i         (MEMWB.RDaddr_o),
    .ForwardA_o         (),
    .ForwardB_o         ()
);
Forward_PC Forward_PC(
    //這邊不是Control.Branch_o 因為如果是control 那就一定會跳 你應該要參考branch predictor
    // 也就是 AND_BRANCH 得輸出才是
    .branch_ID_i (Branch_And.data_o), 
    .branch_EX_i (IDEX.Branch_o & ~XNor.data_o),
    .forward_o ()
);



ALU_Control ALU_Control(
    .funct7_i    (IDEX.funct7_o),
    .funct3_i   (IDEX.funct3_o),
    .ALUOp_i    (IDEX.ALUOp_o),
    .ALUCtrl_o  ()
);
XNor XNor(
    .data1_i (ALU.Zero_o),
    .data2_i (Brach_Predictor.predict_o),
    .data_o ()
);

ALU ALU(
    .data1_i    (MUX_ALUSrc_RS1.data_o),
    .data2_i    (MUX_ALUSrc.data_o),
    .ALUCtrl_i  (ALU_Control.ALUCtrl_o),
    .data_o     (),
    .Zero_o     ()
);

EXMEM EXMEM (
    .clk_i      (clk_i),
    .start_i    (start_i),
    .RegWrite_i (IDEX.RegWrite_o),
    .MemtoReg_i (IDEX.MemtoReg_o),
    .MemRead_i  (IDEX.MemRead_o),
    .MemWrite_i (IDEX.MemWrite_o),
    .ALUdata_i  (ALU.data_o),
    .MemWdata_i (MUX_ALUSrc_RS2.data_o),
    .RDaddr_i (IDEX.RDaddr_o), 
    .RegWrite_o (),
    .MemtoReg_o (),
    .MemRead_o  (),
    .MemWrite_o (),
    .ALUdata_o  (),
    .MemWdata_o (),
    .RDaddr_o ()
);


Data_Memory Data_Memory(
    .clk_i      (clk_i), 
    .addr_i     (EXMEM.ALUdata_o), 
    .MemRead_i  (EXMEM.MemRead_o),
    .MemWrite_i (EXMEM.MemWrite_o),
    .data_i     (EXMEM.MemWdata_o),
    .data_o     ()
);


MEMWB MEMWB(
	.clk_i      (clk_i),
	.start_i    (start_i),
	.RegWrite_i (EXMEM.RegWrite_o),
	.MemtoReg_i (EXMEM.MemtoReg_o),
    .ALUdata_i  (EXMEM.ALUdata_o),
	.ReadData_i (Data_Memory.data_o),
	.RDaddr_i (EXMEM.RDaddr_o),
	.RegWrite_o (),
	.MemtoReg_o (),
    .ALUdata_o  (),
	.ReadData_o (),
	.RDaddr_o ()
);

MUX32 MUX_MemtoReg(
    .data1_i    (MEMWB.ALUdata_o),
    .data2_i    (MEMWB.ReadData_o),
    .select_i   (MEMWB.MemtoReg_o),
    .data_o     ()
);

MUX32 MUX_EXPCtoPC( /*這邊也有問題*/
    .data1_i    (IDEX.PC_target_o), //0是他 代表預測not taken 所以反過來 
    .data2_i    (Add_PC2.data_o), // 1是他 代表預測 taken 
    .select_i   (Brach_Predictor.predict_o), 
    .data_o     ()
);
// Control Control(
//     .Op_i       (opcode),
//     .ALUOp_o    (ALU_Control.ALUOp_i),
//     .ALUSrc_o   (MUX_ALUSrc.select_i),
//     .RegWrite_o (Registers.RegWrite_i)
// );



// Adder Add_PC(
//     .data1_in   (instr_addr),
//     .data2_in   (32'd4),
//     .data_o     (pc)
// );


// PC PC(
//     .clk_i      (clk_i),
//     .rst_i      (rst_i),
//     .start_i    (start_i),
//     .pc_i       (pc),
//     .pc_o       (instr_addr)
// );

// Instruction_Memory Instruction_Memory(
//     .addr_i     (instr_addr), 
//     .instr_o    (instr)
// );

// Registers Registers(
//     .clk_i      (clk_i),
//     .RS1addr_i   (rs),
//     .RS2addr_i   (rt),
//     .RDaddr_i    (rd), 
//     .RDdata_i   (ALU.data_o),
//     .RegWrite_i (Control.RegWrite_o), 
//     .RS1data_o   (rs_data), 
//     .RS2data_o   (rt_data) 
// );


// MUX32 MUX_ALUSrc(
//     .data1_i    (rt_data),
//     .data2_i    (Sign_Extend.data_o),
//     .select_i   (Control.ALUSrc_o),
//     .data_o     (ALU.data2_i)
// );



// Sign_Extend Sign_Extend(
//     .data_i     (imm),
//     .data_o     (MUX_ALUSrc.data2_i)
// );

  

// ALU ALU(
//     .data1_i    (rs_data),
//     .data2_i    (MUX_ALUSrc.data_o),
//     .ALUCtrl_i  (ALU_Control.ALUCtrl_o),
//     .data_o     (Registers.RDdata_i),
//     .Zero_o     (Zero_o),
//     .imm2_i     (rt)
// );



// ALU_Control ALU_Control(
//     .funct3_i    (funct3_i),
//     .funct7_i    (funct7_i),
//     .ALUOp_i    (Control.ALUOp_o),
//     .ALUCtrl_o  (ALU.ALUCtrl_i)
// );


endmodule

