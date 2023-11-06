module Forward_PC
(
	branch_ID_i,
	branch_EX_i,
	forward_o,
);


input branch_EX_i,branch_ID_i;
output [1 : 0] forward_o;

reg [1 : 0] select1_reg;


assign forward_o = select1_reg;


always @(branch_EX_i or branch_ID_i)
begin
	if (branch_EX_i)
	begin
		select1_reg = 2'b10;
	end
	else if (branch_ID_i)
	begin
		select1_reg = 2'b01;
	end
	else
	begin
		select1_reg = 2'b00;
	end
end

endmodule