// module IF_ID (
//     clk_i, rst_i, flush_i, stall_i, 
//     inst_i, PC_i,
//     inst_o, PC_o
// );
// input         clk_i, rst_i, flush_i, stall_i;
// input  [31:0] inst_i, PC_i;
// output reg [31:0] inst_o, PC_o;

// // TODO 

// endmodule

/*
兩種flush
第一種預測 taken 設定 flush
另一種是預測失誤要洗掉的 flush
*/
module IFID (
    clk_i,
    start_i,
    addr_i,
    inst_i,
    Stall_i,
    Flush_i,
    Flush_EX_i, /*add*/
    addr_o,
    inst_o
);

input clk_i, start_i;
input   Stall_i, Flush_i;
input [31:0] addr_i, inst_i;
output [31:0] addr_o, inst_o;
reg [31:0] addr_o, inst_o;
/*add*/
input Flush_EX_i;

always @ ( posedge clk_i or negedge start_i) begin
  if (start_i == 0) begin
    addr_o <= 0;
    inst_o <= 0;
  end
  else if (Flush_i) begin
    addr_o <= 0;
    inst_o <= 0;
  end
  else begin
    if (Stall_i) begin //stall
        addr_o <= addr_o;
        inst_o <= inst_o;
    end
    else begin
        addr_o <= addr_i;
        inst_o <= inst_i;
    end
  end
end
endmodule


/*
Flush 發生 output清成０
lw 後面接ALU運算會發生stall
*/